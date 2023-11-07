/**
 * @file Alseal.cpp
 * Abstraction Layer over Microsoft SEAL
 * --------------------------------------------------------------------
 * @brief Header of Alseal, library that creates an abstraction layer over basic
 *  functionalities of Microsoft SEAL as a Homomorphic Encryption library, 
 *  such as addition, multiplication, scalar product and others.
 *
 *  This is the implementation file. Refer to the .h file for a well
 *  documented API ready to use.
 *  --------------------------------------------------------------------
 * @author Alberto Ibarrondo (ibarrond)
 * @ref https://github.com/ibarrond/Pyfhel
 *  --------------------------------------------------------------------
 */

#include "Alseal.h"

using namespace std;
using namespace seal;

#include <chrono>
#include <thread>
#include <cmath>

// =============================================================================
// ================================== Alseal ===================================
// =============================================================================

// ----------------------------- CLASS MANAGEMENT -----------------------------
Alseal::Alseal(){};

Alseal::Alseal(const Alseal &otherAlseal)
{
  this->context = make_shared<SEALContext>(otherAlseal.context->first_context_data()->parms());

  // TODO: Copy Encoder ptr

  this->keyGenObj = make_shared<KeyGenerator>(*context);
  this->secretKey = make_shared<SecretKey>(*(otherAlseal.secretKey));
  this->publicKey = make_shared<PublicKey>(*(otherAlseal.publicKey));
  this->relinKeys = make_shared<RelinKeys>(*(otherAlseal.relinKeys));
  this->rotateKeys = make_shared<GaloisKeys>(*(otherAlseal.rotateKeys));

  this->encryptor = make_shared<Encryptor>(*context, *publicKey, *secretKey);
  this->evaluator = make_shared<Evaluator>(*context);
  this->decryptor = make_shared<Decryptor>(*context, *secretKey);

  this->bfvEncoder = make_shared<BatchEncoder>(*context);
  this->ckksEncoder = make_shared<CKKSEncoder>(*context);
  this->bgvEncoder = make_shared<BatchEncoder>(*context);
};

Alseal::~Alseal(){};

// -----------------------------------------------------------------------------
// ------------------------------ CRYPTOGRAPHY ---------------------------------
// -----------------------------------------------------------------------------
// CONTEXT GENERATION
string Alseal::ContextGen(scheme_t scheme,
                          uint64_t poly_modulus_degree,
                          uint64_t plain_modulus_bit_size,
                          uint64_t plain_modulus,
                          int sec,
                          std::vector<int> qi_sizes,
                          std::vector<uint64_t> qi_values)
{
  if (scheme != scheme_t::bfv && scheme != scheme_t::bgv && scheme != scheme_t::ckks)
  {
    throw invalid_argument("<Alseal>: scheme must be bfv, bgv or ckks");
  }
  EncryptionParameters parms(scheme_map_to_seal[scheme]);
  // Setting n
  parms.set_poly_modulus_degree(poly_modulus_degree);
  // Setting q & qi.
  if (!qi_values.empty())
  {
    std::vector<Modulus> qi_mods;
    for (auto &qi_val : qi_values)
    {
      qi_mods.emplace_back(Modulus(qi_val));
    }
    parms.set_coeff_modulus(qi_mods);
  }
  else if (!qi_sizes.empty()) // Generate primes qi with given sizes
  {
    parms.set_coeff_modulus(CoeffModulus::Create(poly_modulus_degree, qi_sizes));
  }
  else if (((scheme == scheme_t::bfv) || (scheme == scheme_t::bgv)) && (sec > 0))
  {
    parms.set_coeff_modulus( // BFV/BGV: Select from seal/utils/globals.cpp
        CoeffModulus::BFVDefault(poly_modulus_degree, sec_map[sec]));
  }
  else
  {
    throw invalid_argument(
        "<Alseal>: Non-empty `qi_sizes`, `qi_values` or `sec` (BFV only) required");
  }
  this->qi.clear();                           // Remove previously stored qi
  for (auto &modulus : parms.coeff_modulus()) // Store chosen qi
  {
    this->qi.emplace_back(modulus.value());
  }
  // Setting t --> BFV and BGV only
  if ((scheme == scheme_t::bfv) || (scheme == scheme_t::bgv))
  {
    if (plain_modulus_bit_size > 0) // Auto sel.
    {
      parms.set_plain_modulus(PlainModulus::Batching(
          (size_t)poly_modulus_degree, (int)plain_modulus_bit_size));
    }
    else // Does not ensure batching!
    {
      parms.set_plain_modulus(plain_modulus);
    }
  }
  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(parms, true, sec_map[sec]);

  // If parameters are valid, build {codec, evaluator, keygen}
  if (this->context->parameters_set())
  {
    // Codec
    if (scheme == scheme_t::bfv)
    {
      this->bfvEncoder = make_shared<BatchEncoder>(*context);
    }
    else if (scheme == scheme_t::bgv)
    {
      this->bgvEncoder = make_shared<BatchEncoder>(*context);
    }
    else // ckks
    {
      this->ckksEncoder = make_shared<CKKSEncoder>(*context);
    }
    // Evaluator
    this->evaluator = make_shared<Evaluator>(*context);
    // Key generator
    this->keyGenObj = make_shared<KeyGenerator>(*context);
  }
  // Return info about parameter validity.
  //    - 'success: valid' if everything went well
  //    - Error name and message from list in seal/context/context.cpp otherwise
  return string(this->context->parameter_error_name()) + ": " +
         this->context->parameter_error_message();
}

// KEY GENERATION
void Alseal::KeyGen()
{
  auto &context = *(this->get_context());
  // Key generator
  this->keyGenObj = make_shared<KeyGenerator>(context); // Refresh KeyGen obj
  this->publicKey = make_shared<PublicKey>();
  keyGenObj->create_public_key(*publicKey); // Extract keys
  this->secretKey = make_shared<SecretKey>(keyGenObj->secret_key());
  this->encryptor = make_shared<Encryptor>(context, *publicKey);
  this->decryptor = make_shared<Decryptor>(context, *secretKey);
}

void Alseal::relinKeyGen()
{
  if (keyGenObj == NULL)
  {
    throw std::logic_error("<Alseal>: Context not initialized");
  }
  this->relinKeys = std::make_shared<RelinKeys>();
  keyGenObj->create_relin_keys(*relinKeys);
}

void Alseal::rotateKeyGen(vector<int> rot_steps)
{
  if (keyGenObj == NULL)
  {
    throw std::logic_error("<Alseal>: Context not initialized");
  }
  rotateKeys = make_shared<GaloisKeys>();
  if (!rot_steps.empty())
  {
    keyGenObj->create_galois_keys(rot_steps, *rotateKeys);
  }
  else
  {
    keyGenObj->create_galois_keys(*rotateKeys);
  }
}

// ENCRYPTION
void Alseal::encrypt(AfPtxt &plain1, AfCtxt &ctxt)
{
  this->get_encryptor()->encrypt(_dyn_p(plain1), _dyn_c(ctxt));
}
void Alseal::encrypt_v(vector<std::shared_ptr<AfPtxt>> &plainV, std::vector<std::shared_ptr<AfCtxt>> &ctxtVOut)
{
  auto encryptor = this->get_encryptor();
  vectorize(
      ctxtVOut, plainV,
      [encryptor](AfCtxt c, AfPtxt p)
      { encryptor->encrypt(_dyn_p(p), _dyn_c(c)); });
}

// DECRYPTION
void Alseal::decrypt(AfCtxt &ctxt, AfPtxt &ptxtOut)
{
  this->get_decryptor()->decrypt(_dyn_c(ctxt), _dyn_p(ptxtOut));
}
void Alseal::decrypt_v(std::vector<std::shared_ptr<AfCtxt>> &ctxtV, vector<std::shared_ptr<AfPtxt>> &plainVOut)
{
  auto decryptor = this->get_decryptor();
  vectorize(
      ctxtV, plainVOut,
      [decryptor](AfCtxt c, AfPtxt p)
      { decryptor->decrypt(_dyn_c(c), _dyn_p(p)); });
}

// NOISE MEASUREMENT
int Alseal::noise_level(AfCtxt &ctxt)
{
  return this->get_decryptor()->invariant_noise_budget(_dyn_c(ctxt));
}

// -----------------------------------------------------------------------------
// ---------------------------------- CODEC -----------------------------------
// -----------------------------------------------------------------------------
// ENCODE
// bfv
void Alseal::encode_i(vector<int64_t> &values, AfPtxt &ptxtOut)
{
  auto bfv_encoder = this->get_bfv_encoder();
  if (values.size() > bfv_encoder->slot_count())
  {
    throw range_error("<Alseal>: Data vector size is bigger than bfv nSlots");
  }
  bfvEncoder->encode(values, _dyn_p(ptxtOut));
}
// ckks
void Alseal::encode_f(vector<double> &values, double scale, AfPtxt &ptxtOut)
{
  auto ckks_encoder = this->get_ckks_encoder();
  if (values.size() > ckks_encoder->slot_count())
  {
    throw range_error("<Alseal>: Data vector size is bigger than ckks nSlots");
  }
  ckks_encoder->encode(values, scale, _dyn_p(ptxtOut));
}
void Alseal::encode_c(std::vector<complex<double>> &values, double scale, AfPtxt &ptxtOut)
{
  auto ckks_encoder = this->get_ckks_encoder();
  if (values.size() > ckks_encoder->slot_count())
  {
    throw range_error("<Alseal>: Data vector size is bigger than ckks nSlots");
  }
  ckks_encoder->encode(values, scale, _dyn_p(ptxtOut));
}
// bgv
void Alseal::encode_g(vector<int64_t> &values, AfPtxt &ptxtOut)
{
  auto bgv_encoder = this->get_bgv_encoder();
  if (values.size() > bgv_encoder->slot_count())
  {
    throw range_error("<Alseal>: Data vector size is bigger than bgv nSlots");
  }
  bgvEncoder->encode(values, _dyn_p(ptxtOut));
}

// DECODE
// bfv
void Alseal::decode_i(AfPtxt &plain1, std::vector<int64_t> &valueVOut)
{
  this->get_bfv_encoder()->decode(_dyn_p(plain1), valueVOut);
}
// ckks
void Alseal::decode_f(AfPtxt &plain1, vector<double> &valueVOut)
{
  this->get_ckks_encoder()->decode(_dyn_p(plain1), valueVOut);
}
void Alseal::decode_c(AfPtxt &plain1, vector<std::complex<double>> &valueVOut)
{
  this->get_ckks_encoder()->decode(_dyn_p(plain1), valueVOut);
}
// bgv
void Alseal::decode_g(AfPtxt &plain1, std::vector<int64_t> &valueVOut)
{
  this->get_bgv_encoder()->decode(_dyn_p(plain1), valueVOut);
}

// AUXILIARY
void Alseal::data(AfPtxt &ptxt, uint64_t *dest)
{
  dest = _dyn_p(ptxt).data();
}

// void Alseal::allocate_zero_poly(uint64_t n, uint64_t coeff_mod_count, uint64_t *dest) {
//   dest = &util::allocate_zero_poly(n, coeff_mod_count, pool)[0]; --> pool?
// }

// ------------------------------ RELINEARIZATION -----------------------------
void Alseal::relinearize(AfCtxt &ctxt)
{
  this->get_evaluator()->relinearize_inplace(_dyn_c(ctxt), *(this->get_relinKeys()));
}
void Alseal::relinearize_v(vector<std::shared_ptr<AfCtxt>> ctxtV)
{
  auto ev = this->get_evaluator();
  seal::RelinKeys &rlk = *(this->get_relinKeys());
  vectorize(ctxtV,
            [ev, rlk](AfCtxt c)
            { ev->relinearize_inplace(_dyn_c(c), rlk); });
}

// -----------------------------------------------------------------------------
// --------------------------------- OPERATIONS --------------------------------
// -----------------------------------------------------------------------------
// NEGATE
void Alseal::negate(AfCtxt &ctxt)
{
  this->get_evaluator()->negate_inplace(_dyn_c(ctxt));
}
void Alseal::negate_v(vector<std::shared_ptr<AfCtxt>> &ctxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtV,
            [ev](AfCtxt c)
            { ev->negate_inplace(_dyn_c(c)); });
}

// SQUARE
void Alseal::square(AfCtxt &ctxt)
{
  this->get_evaluator()->square_inplace(_dyn_c(ctxt));
}
void Alseal::square_v(vector<std::shared_ptr<AfCtxt>> &ctxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtV,
            [ev](AfCtxt c)
            { ev->square_inplace(_dyn_c(c)); });
}

// ADDITION
void Alseal::add(AfCtxt &cipherInOut, AfCtxt &cipher2)
{
  this->get_evaluator()->add_inplace(_dyn_c(cipherInOut), _dyn_c(cipher2));
}
void Alseal::add_plain(AfCtxt &cipherInOut, AfPtxt &plain2)
{
  this->get_evaluator()->add_plain_inplace(_dyn_c(cipherInOut), _dyn_p(plain2));
}
void Alseal::add_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfCtxt>> &ctxtV2)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ctxtV2,
            [ev](AfCtxt c, AfCtxt c2)
            { ev->add_inplace(_dyn_c(c), _dyn_c(c2)); });
}
void Alseal::add_plain_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfPtxt>> &ptxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ptxtV,
            [ev](AfCtxt c, AfPtxt p2)
            { ev->add_plain_inplace(_dyn_c(c), _dyn_p(p2)); });
}

// SUBTRACTION
void Alseal::sub(AfCtxt &cipherInOut, AfCtxt &cipher2)
{
  this->get_evaluator()->sub_inplace(_dyn_c(cipherInOut), _dyn_c(cipher2));
}
void Alseal::sub_plain(AfCtxt &cipherInOut, AfPtxt &plain2)
{
  this->get_evaluator()->sub_plain_inplace(_dyn_c(cipherInOut), _dyn_p(plain2));
}
void Alseal::sub_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfCtxt>> &ctxtV2)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ctxtV2,
            [ev](AfCtxt c, AfCtxt c2)
            { ev->sub_inplace(_dyn_c(c), _dyn_c(c2)); });
}
void Alseal::sub_plain_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfPtxt>> &ptxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ptxtV,
            [ev](AfCtxt c, AfPtxt p2)
            { ev->sub_plain_inplace(_dyn_c(c), _dyn_p(p2)); });
}

// MULTIPLICATION
void Alseal::multiply(AfCtxt &cipherInOut, AfCtxt &cipher2)
{
  this->get_evaluator()->multiply_inplace(_dyn_c(cipherInOut), _dyn_c(cipher2));
}
void Alseal::multiply_plain(AfCtxt &cipherInOut, AfPtxt &plain1)
{
  this->get_evaluator()->multiply_plain_inplace(_dyn_c(cipherInOut), _dyn_p(plain1));
}
void Alseal::multiply_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfCtxt>> &ctxtV2)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ctxtV2,
            [ev](AfCtxt c, AfCtxt c2)
            { ev->multiply_inplace(_dyn_c(c), _dyn_c(c2)); });
}
void Alseal::multiply_plain_v(vector<std::shared_ptr<AfCtxt>> &ctxtVInOut, vector<std::shared_ptr<AfPtxt>> &ptxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtVInOut, ptxtV,
            [ev](AfCtxt c, AfPtxt p2)
            { ev->multiply_plain_inplace(_dyn_c(c), _dyn_p(p2)); });
}

// ROTATION
void Alseal::rotate(AfCtxt &ctxt, int k)
{
  if (this->get_scheme() == scheme_t::bfv || this->get_scheme() == scheme_t::bgv)
  {
    this->get_evaluator()->rotate_rows_inplace(_dyn_c(ctxt), k, *(this->get_rotateKeys()));
  }
  else if (this->get_scheme() == scheme_t::ckks)
  {
    this->get_evaluator()->rotate_vector_inplace(_dyn_c(ctxt), k, *(this->get_rotateKeys()));
  }
  else
  {
    throw std::logic_error("<Alseal>: Scheme not supported for rotation");
  }
}
void Alseal::rotate_v(vector<std::shared_ptr<AfCtxt>> &ctxtV, int k)
{
  auto ev = this->get_evaluator();
  auto &rtk = *(this->get_rotateKeys());
  if (this->get_scheme() == scheme_t::bfv || this->get_scheme() == scheme_t::bgv)
  {
    vectorize(ctxtV,
              [ev, k, rtk](AfCtxt c)
              { ev->rotate_rows_inplace(_dyn_c(c), k, rtk); });
  }
  else if (this->get_scheme() == scheme_t::ckks)
  {
    vectorize(ctxtV,
              [ev, k, rtk](AfCtxt c)
              { ev->rotate_vector_inplace(_dyn_c(c), k, rtk); });
  }
  else
  {
    throw std::logic_error("<Alseal>: Scheme not supported for rotation");
  }
}
void Alseal::flip(AfCtxt &ctxt)
{
  if (this->get_scheme() == scheme_t::bfv)
  {
    this->get_evaluator()->rotate_columns_inplace(_dyn_c(ctxt), *(this->get_rotateKeys()));
  }
  else
  {
    throw std::logic_error("<Alseal>: Only bfv scheme supports column rotation");
  }
}
void Alseal::flip_v(vector<std::shared_ptr<AfCtxt>> &ctxtV)
{
  auto ev = this->get_evaluator();
  auto &rtk = *(this->get_rotateKeys());
  if (this->get_scheme() == scheme_t::bfv)
  {
    vectorize(ctxtV,
              [ev, rtk](AfCtxt c)
              { ev->rotate_columns_inplace(_dyn_c(c), rtk); });
  }
  else
  {
    throw std::logic_error("<Alseal>: Only bfv scheme supports column rotation");
  }
}

// POLYNOMIALS
void Alseal::exponentiate(AfCtxt &ctxt, uint64_t &expon)
{
  this->get_evaluator()->exponentiate_inplace(_dyn_c(ctxt), expon, *relinKeys);
}
void Alseal::exponentiate_v(vector<std::shared_ptr<AfCtxt>> &ctxtV, uint64_t &expon)
{
  auto ev = this->get_evaluator();
  auto &rlk = *(this->get_relinKeys());
  vectorize(ctxtV,
            [ev, expon, rlk](AfCtxt c)
            { ev->exponentiate_inplace(_dyn_c(c), expon, rlk); });
}

// CKKS -> Rescaling and mod switching
void Alseal::rescale_to_next(AfCtxt &ctxt)
{
  if (this->get_scheme() == scheme_t::ckks)
  {
    this->get_evaluator()->rescale_to_next_inplace(_dyn_c(ctxt));
  }
  else
  {
    throw std::logic_error("<Alseal>: Scheme must be ckks");
  }
}
void Alseal::rescale_to_next_v(vector<std::shared_ptr<AfCtxt>> &ctxtV)
{
  auto ev = this->get_evaluator();
  if (this->get_scheme() == scheme_t::ckks)
  {
    vectorize(ctxtV,
              [ev](AfCtxt c)
              { ev->rescale_to_next_inplace(_dyn_c(c)); });
  }
  else
  {
    throw std::logic_error("<Alseal>: Scheme must be ckks");
  }
}

void Alseal::mod_switch_to_next(AfCtxt &ctxt)
{
  this->get_evaluator()->mod_switch_to_next_inplace(_dyn_c(ctxt));
}
void Alseal::mod_switch_to_next_v(vector<std::shared_ptr<AfCtxt>> &ctxtV)
{
  auto ev = this->get_evaluator();
  vectorize(ctxtV,
            [ev](AfCtxt c)
            { ev->mod_switch_to_next_inplace(_dyn_c(c)); });
}

void Alseal::mod_switch_to_next_plain(AfPtxt &ptxt)
{
  this->get_evaluator()->mod_switch_to_next_inplace(_dyn_p(ptxt));
}
void Alseal::mod_switch_to_next_plain_v(vector<std::shared_ptr<AfPtxt>> &plainV)
{
  auto ev = this->get_evaluator();
  vectorize(plainV,
            [ev](AfPtxt p)
            { ev->mod_switch_to_next_inplace(_dyn_p(p)); });
}

// -----------------------------------------------------------------------------
// ------------------------------------- I/O -----------------------------------
// -----------------------------------------------------------------------------
// SAVE/LOAD CONTEXT
size_t Alseal::save_context(ostream &out_stream, string &compr_mode)
{
  return (size_t)this->get_context()->key_context_data()->parms().save(
      out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_context(istream &in_stream, int sec)
{
  EncryptionParameters parms;
  size_t loaded_bytes = (size_t)parms.load(in_stream);
  this->context = make_shared<SEALContext>(parms, true, sec_map[sec]);
  if (parms.scheme() == scheme_type::bfv)
  {
    this->bfvEncoder = make_shared<BatchEncoder>(*context);
  }
  else if (parms.scheme() == scheme_type::bgv)
  {
    this->bgvEncoder = make_shared<BatchEncoder>(*context);
  }
  else if (parms.scheme() == scheme_type::ckks)
  {
    this->ckksEncoder = make_shared<CKKSEncoder>(*context);
  }
  else
  {
    throw std::logic_error("<Alseal>: Loaded context has invalid scheme");
  }
  this->evaluator = make_shared<Evaluator>(*context);
  this->keyGenObj = make_shared<KeyGenerator>(*context);
  return loaded_bytes;
}

// SAVE/LOAD PUBLICKEY
size_t Alseal::save_public_key(ostream &out_stream, string &compr_mode)
{
  return (size_t)this->get_publicKey()->save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_public_key(istream &in_stream)
{
  seal::SEALContext &context = *(this->get_context());
  this->publicKey = make_shared<PublicKey>();
  size_t loaded_bytes = (size_t)publicKey->load(context, in_stream);
  this->encryptor = make_shared<Encryptor>(context, *publicKey);
  return loaded_bytes;
}

// SAVE/LOAD SECRETKEY
size_t Alseal::save_secret_key(ostream &out_stream, string &compr_mode)
{
  return (size_t)this->get_secretKey()->save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_secret_key(istream &in_stream)
{
  seal::SEALContext &context = *(this->get_context());
  this->secretKey = make_shared<SecretKey>();
  size_t loaded_bytes = (size_t)secretKey->load(context, in_stream);
  this->decryptor = make_shared<Decryptor>(context, *secretKey);
  return loaded_bytes;
}

// SAVE/LOAD RELINKEY
size_t Alseal::save_relin_keys(ostream &out_stream, string &compr_mode)
{
  return (size_t)this->get_relinKeys()->save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_relin_keys(istream &in_stream)
{
  this->relinKeys = make_shared<RelinKeys>();
  return (size_t)relinKeys->load(*(this->get_context()), in_stream);
}

// SAVE/LOAD ROTKEYS
size_t Alseal::save_rotate_keys(ostream &out_stream, string &compr_mode)
{
  return (size_t)this->get_rotateKeys()->save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_rotate_keys(istream &in_stream)
{
  this->rotateKeys = make_shared<GaloisKeys>();
  return (size_t)rotateKeys->load(*(this->get_context()), in_stream);
}

// SAVE/LOAD PLAINTEXT --> Could be achieved outside of Alseal
size_t Alseal::save_plaintext(ostream &out_stream, string &compr_mode, AfPtxt &pt)
{
  return (size_t)_dyn_p(pt).save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_plaintext(istream &in_stream, AfPtxt &pt)
{
  return (size_t)_dyn_p(pt).load(*context, in_stream);
}

// SAVE/LOAD CIPHERTEXT --> Could be achieved outside of Alseal
size_t Alseal::save_ciphertext(ostream &out_stream, string &compr_mode, AfCtxt &ct)
{
  return (size_t)_dyn_c(ct).save(out_stream, compr_mode_map[compr_mode]);
}
size_t Alseal::load_ciphertext(istream &in_stream, AfCtxt &ct)
{
  return (size_t)_dyn_c(ct).load(*context, in_stream);
}

// SIZES
size_t Alseal::sizeof_context(string &compr_mode)
{
  return (size_t)this->get_context()->key_context_data()->parms().save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_public_key(string &compr_mode)
{
  return (size_t)this->get_publicKey()->save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_secret_key(string &compr_mode)
{
  return (size_t)this->get_secretKey()->save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_relin_keys(string &compr_mode)
{
  return (size_t)this->get_relinKeys()->save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_rotate_keys(string &compr_mode)
{
  return (size_t)this->get_rotateKeys()->save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_plaintext(string &compr_mode, AfPtxt &pt)
{
  return (size_t)_dyn_p(pt).save_size(compr_mode_map[compr_mode]);
}
size_t Alseal::sizeof_ciphertext(string &compr_mode, AfCtxt &ct)
{
  return (size_t)_dyn_c(ct).save_size(compr_mode_map[compr_mode]);
}

// -----------------------------------------------------------------------------
// -------------------------------- AUXILIARY ----------------------------------
// -----------------------------------------------------------------------------
bool Alseal::batchEnabled()
{
  return this->get_context()->first_context_data()->qualifiers().using_batching;
}
long Alseal::maxBitCount(long poly_modulus_degree, int sec_level)
{
  return CoeffModulus::MaxBitCount(poly_modulus_degree, sec_map[sec_level]);
}
double Alseal::scale(AfCtxt &ctxt)
{
  return _dyn_c(ctxt).scale();
}
void Alseal::override_scale(AfCtxt &ctxt, double scale)
{
  _dyn_c(ctxt).scale() = scale;
}
int Alseal::get_sec()
{
  return static_cast<std::underlying_type<sec_level_type>::type>(
      this->get_context()->first_context_data()->qualifiers().sec_level);
}
std::vector<uint64_t> Alseal::get_qi()
{
  return this->qi;
}
// GETTERS
shared_ptr<SEALContext> inline Alseal::get_context()
{
  if (this->context == NULL)
  {
    throw std::logic_error("<Alseal>: Context not initialized");
  }
  return (this->context);
}
shared_ptr<Evaluator> inline Alseal::get_evaluator()
{
  if (this->evaluator == NULL)
  {
    throw std::logic_error("<Alseal>: Context not initialized");
  }
  return (this->evaluator);
}
shared_ptr<Encryptor> inline Alseal::get_encryptor()
{
  if (this->encryptor == NULL)
  {
    throw std::logic_error("<Alseal>: Missing Public key");
  }
  return (this->encryptor);
}
shared_ptr<Decryptor> inline Alseal::get_decryptor()
{
  if (this->encryptor == NULL)
  {
    throw std::logic_error("<Alseal>: Missing Public key");
  }
  return (this->decryptor);
}
shared_ptr<BatchEncoder> inline Alseal::get_bfv_encoder()
{
  if (this->bfvEncoder == NULL)
  {
    throw std::logic_error("<Alseal>: BFV context not initialized");
  }
  return (this->bfvEncoder);
}
shared_ptr<CKKSEncoder> inline Alseal::get_ckks_encoder()
{
  if (this->ckksEncoder == NULL)
  {
    throw std::logic_error("<Alseal>: CKKS context not initialized");
  }
  return (this->ckksEncoder);
}
shared_ptr<BatchEncoder> inline Alseal::get_bgv_encoder()
{
  if (this->bgvEncoder == NULL)
  {
    throw std::logic_error("<Alseal>: BGV context not initialized");
  }
  return (this->bgvEncoder);
}
shared_ptr<SecretKey> inline Alseal::get_secretKey()
{
  if (this->secretKey == NULL)
  {
    throw std::logic_error("<Alseal>: Secret Key not initialized");
  }
  return (this->secretKey);
}
shared_ptr<PublicKey> inline Alseal::get_publicKey()
{
  if (this->publicKey == NULL)
  {
    throw std::logic_error("<Alseal>: Public Key not initialized");
  }
  return (this->publicKey);
}
shared_ptr<RelinKeys> inline Alseal::get_relinKeys()
{
  if (this->relinKeys == NULL)
  {
    throw std::logic_error("<Alseal>: Relinearization Keys not initialized");
  }
  return (this->relinKeys);
}
shared_ptr<GaloisKeys> inline Alseal::get_rotateKeys()
{
  if (this->rotateKeys == NULL)
  {
    throw std::logic_error("<Alseal>: Rotation Keys not initialized");
  }
  return (this->rotateKeys);
}
size_t Alseal::get_nSlots()
{
  scheme_t scheme = this->get_scheme();
  if (scheme == scheme_t::bfv)
  {
    return this->get_bfv_encoder()->slot_count();
  }
  else if (scheme == scheme_t::ckks)
  {
    return this->get_ckks_encoder()->slot_count();
  }
  else if (scheme == scheme_t::bgv)
  {
    return this->get_bgv_encoder()->slot_count();
  }
  return -1;
}
uint64_t Alseal::get_plain_modulus()
{
  return this->get_context()->first_context_data()->parms().plain_modulus().value();
}
size_t Alseal::get_poly_modulus_degree()
{
  return this->get_context()->first_context_data()->parms().poly_modulus_degree();
}

scheme_t Alseal::get_scheme()
{
  return scheme_map_to_afhel[this->get_context()->first_context_data()->parms().scheme()];
}

int Alseal::total_coeff_modulus_bit_count()
{
  return this->get_context()->first_context_data()->total_coeff_modulus_bit_count();
}
// TODO: coeff_modulus?

// -----------------------------------------------------------------------------
// ----------------------------- VECTORIZATION ---------------------------------
// -----------------------------------------------------------------------------
void Alseal::vectorize(
    vector<std::shared_ptr<AfCtxt>> &ctxtVInOut,
    vector<std::shared_ptr<AfCtxt>> &ctxtV2,
    function<void(AfCtxt, AfCtxt)> f)
{
  if (ctxtVInOut.size() != ctxtV2.size())
  {
    throw runtime_error("Vectors must be of same size to vectorize");
  }
#pragma omp parallel for
  for (int i = 0; i < (int)ctxtVInOut.size(); i++)
  {
    f(_dyn_c(*ctxtVInOut[i]), _dyn_c(*ctxtV2[i]));
  }
}
void Alseal::vectorize(
    vector<std::shared_ptr<AfCtxt>> &ctxtVInOut,
    vector<std::shared_ptr<AfPtxt>> &ptxtV,
    function<void(AfCtxt, AfPtxt)> f)
{
  if (ctxtVInOut.size() != ptxtV.size())
  {
    throw runtime_error("Vectors must be of same size to vectorize");
  }
#pragma omp parallel for
  for (int i = 0; i < (int)ctxtVInOut.size(); i++)
  {
    f(_dyn_c(*ctxtVInOut[i]), _dyn_p(*ptxtV[i]));
  }
}

void Alseal::vectorize(
    vector<std::shared_ptr<AfCtxt>> &ctxtVInOut,
    function<void(AfCtxt)> f)
{
#pragma omp parallel for
  for (int i = 0; i < (int)ctxtVInOut.size(); i++)
  {
    f(_dyn_c(*ctxtVInOut[i]));
  }
}

void Alseal::vectorize(
    vector<std::shared_ptr<AfPtxt>> &plainVInOut,
    function<void(AfPtxt)> f)
{
#pragma omp parallel for
  for (int i = 0; i < (int)plainVInOut.size(); i++)
  {
    f(_dyn_p(*plainVInOut[i]));
  }
}

// -----------------------------------------------------------------------------
// ------------------------------ POLYNOMIALS ----------------------------------
// -----------------------------------------------------------------------------
void Alseal::add_inplace(AfPoly &p1, AfPoly &p2)
{
  dynamic_cast<AlsealPoly &>(p1).add_inplace(dynamic_cast<AlsealPoly &>(p2));
}

void Alseal::subtract_inplace(AfPoly &p1, AfPoly &p2)
{
  dynamic_cast<AlsealPoly &>(p1).subtract_inplace(dynamic_cast<AlsealPoly &>(p2));
}

void Alseal::multiply_inplace(AfPoly &p1, AfPoly &p2)
{
  dynamic_cast<AlsealPoly &>(p1).multiply_inplace(dynamic_cast<AlsealPoly &>(p2));
}

void Alseal::invert_inplace(AfPoly &poly)
{
  if (!dynamic_cast<AlsealPoly &>(poly).invert_inplace())
  {
    // TODO: How to communicate this information without throwing an exception?
    throw runtime_error("<Alseal>: Inverse does not exist.");
  }
}

void Alseal::poly_to_ciphertext(AfPoly &p, AfCtxt &ctxt, size_t i)
{
  // TODO: This shouldn't be too hard, just copy into position,
  //  but we need to ensure the sizes match,
  //  allocate a zero poly if the index doesn't exist, etc
  throw runtime_error("<Alseal>: Not yet implemented.");
}

void Alseal::poly_to_plaintext(AfPoly &p, AfPtxt &ptxt)
{
  // TODO: This shouldn't be too hard, just copy into position,
  //  but we need to ensure the sizes match,
  //  allocate a zero poly if the poly doesn't yet exist, etc
  throw runtime_error("<Alseal>: Not yet implemented.");
}

std::complex<double> Alseal::get_coeff(AfPoly &poly, size_t i)
{
  return poly.get_coeff(*this, i);
}

void Alseal::set_coeff(AfPoly &poly, complex<double> &val, size_t i)
{
  dynamic_cast<AlsealPoly &>(poly).set_coeff(*this, val, i);
}

std::vector<std::complex<double>> Alseal::to_coeff_list(AfPoly &poly)
{
  return dynamic_cast<AlsealPoly &>(poly).to_coeff_list(*this);
}

AlsealPoly Alseal::get_publicKey_poly(size_t index)
{
  if (this->publicKey == NULL)
  {
    throw std::logic_error("<Alseal>: Public Key not initialized");
  }
  return AlsealPoly(*this, static_cast<AlsealCtxt &>(this->publicKey->data()), index);
}

AlsealPoly Alseal::get_secretKey_poly()
{
  if (this->secretKey == NULL)
  {
    throw std::logic_error("<Alseal>: Secret Key not initialized");
  }
  return AlsealPoly(*this, static_cast<AlsealPtxt &>(this->secretKey->data()));
}

// =============================================================================
// ================================ AlsealPOLY =================================
// =============================================================================

/// Internally, seal stores the polynomials of a ctxt as DynArray<uint64_t>,
/// i.e., linear arrays of size ctxt.size * ctxt.poly_modulus_degree * ctxt.coeff_modulus_size

// ----------------------------- CLASS MANAGEMENT -----------------------------

AlsealPoly::AlsealPoly(Alseal &Alseal) : parms_id(Alseal.context->first_parms_id()),
                                         mempool(seal::MemoryManager::GetPool()),
                                         coeff_count(Alseal.context->first_context_data()->parms().poly_modulus_degree()),
                                         coeff_modulus(Alseal.context->first_context_data()->parms().coeff_modulus()),
                                         coeff_modulus_count(Alseal.context->first_context_data()->parms().coeff_modulus().size())
{
  eval_repr.resize(coeff_count * coeff_modulus_count, true);
}

AlsealPoly::AlsealPoly(Alseal &Alseal, const AlsealCtxt &ref)
    : parms_id(ref.parms_id()), mempool(seal::MemoryManager::GetPool()),
      coeff_count(ref.poly_modulus_degree()),
      coeff_modulus(Alseal.context->get_context_data(parms_id)->parms().coeff_modulus()),
      coeff_modulus_count(Alseal.context->get_context_data(parms_id)->parms().coeff_modulus().size())
{

  eval_repr.resize(coeff_count * coeff_modulus_count, true);
}

AlsealPoly::AlsealPoly(Alseal &Alseal, AlsealCtxt &ctxt, size_t index)
    : parms_id(ctxt.parms_id()), mempool(seal::MemoryManager::GetPool()),
      coeff_count(ctxt.poly_modulus_degree()),
      coeff_modulus(Alseal.context->get_context_data(parms_id)->parms().coeff_modulus()),
      coeff_modulus_count(Alseal.context->get_context_data(parms_id)->parms().coeff_modulus().size())
{

  // Copy coefficients from ctxt
  if (ctxt.is_ntt_form())
  {
    eval_repr.resize(coeff_count * coeff_modulus_count);
    for (size_t i = 0; i < coeff_count * coeff_modulus_count; ++i)
    {
      eval_repr[i] = *(ctxt.data(index) + i);
    }
  }
  else
  {
    // TODO: Think about supporting this?
    throw runtime_error("<Alseal>: Not yet implemented.");
  }
}

AlsealPoly::AlsealPoly(Alseal &Alseal, AlsealPtxt &ptxt) : parms_id(ptxt.parms_id()),
                                                           mempool(seal::MemoryManager::GetPool()),
                                                           coeff_count(ptxt.coeff_count()),
                                                           coeff_modulus(Alseal.context->get_context_data(parms_id)
                                                                             ->parms()
                                                                             .coeff_modulus()),
                                                           coeff_modulus_count(Alseal.context
                                                                                   ->get_context_data(parms_id)
                                                                                   ->parms()
                                                                                   .coeff_modulus()
                                                                                   .size())
{

  if (ptxt.is_ntt_form())
  {
    eval_repr.resize(coeff_count * coeff_modulus_count);
    for (size_t i = 0; i < coeff_count * coeff_modulus_count; ++i)
    {
      eval_repr[i] = *(ptxt.data() + i);
    }
  }
  else
  {
    // TODO: Think about supporting this?
    throw runtime_error("<Alseal>: Not yet implemented.");
  }
}

AlsealPoly::~AlsealPoly(){};

// -------------------------------- COEFFICIENTS -------------------------------
void AlsealPoly::generate_coeff_repr(Alseal &Alseal)
{
  if (!coeff_repr_valid)
  {

    // Resize the coeff_repr

    // Copy the coefficients over
    coeff_repr = eval_repr;

    // Now do the actual conversion
    auto small_ntt_tables = Alseal.context->get_context_data(parms_id)->small_ntt_tables();
#pragma omp parallel for
    for (int j = 0; j < coeff_modulus_count; j++)
    {
      util::inverse_ntt_negacyclic_harvey(coeff_repr.begin() + (j * coeff_count), small_ntt_tables[j]); // non-ntt form
    }

    // set valid flag
    coeff_repr_valid = true;
  }
}

std::vector<std::complex<double>> AlsealPoly::to_coeff_list(Afhel &afhel)
{
  generate_coeff_repr(dynamic_cast<Alseal &>(afhel));
  // TODO: Need to also decompose the CRT representation
  //  and then do some more magic!
  throw runtime_error("<Alseal>: Not yet implemented.");
}

std::complex<double> AlsealPoly::get_coeff(Afhel &afhel, size_t i)
{
  return to_coeff_list(afhel)[i];
}

void AlsealPoly::set_coeff(Afhel &afhel, std::complex<double> &val, size_t i)
{
  auto v = to_coeff_list(afhel);
  v[i] = val;
  // TODO: Convert vector back into CRT, then apply NTT
  //  don't forget to also write the coeff_repr and set the valid bit,
  //  since we already have the data around!
  throw runtime_error("<Alseal>: Not yet implemented.");
}

// -------------------------------- OPERATIONS ---------------------------------
void AlsealPoly::add_inplace(const AfPoly &other)
{
#pragma omp parallel for
  for (int j = 0; j < (int)coeff_modulus.size(); j++)
  {
    util::add_poly_coeffmod(&eval_repr[j * coeff_count],
                            &dynamic_cast<const AlsealPoly &>(other).eval_repr[j * coeff_count],
                            coeff_count,
                            coeff_modulus[j],
                            &eval_repr[j * coeff_count]); // TODO: Check if this is safe (used to be result + ..)
  }
  // invalidate the coeff_repr
  coeff_repr_valid = false;
}

void AlsealPoly::subtract_inplace(const AfPoly &other)
{
#pragma omp parallel for
  for (int j = 0; j < (int)coeff_modulus.size(); j++)
  {
    util::sub_poly_coeffmod(&eval_repr[j * coeff_count],
                            &dynamic_cast<const AlsealPoly &>(other).eval_repr[j * coeff_count],
                            coeff_count,
                            coeff_modulus[j],
                            &eval_repr[j * coeff_count]); // TODO: Check if this is safe (used to be result + ..)
  }
  // invalidate the coeff_repr
  coeff_repr_valid = false;
}

void AlsealPoly::multiply_inplace(const AfPoly &other)
{
  const AlsealPoly *o_p = dynamic_cast<const AlsealPoly *>(&other);
#pragma omp parallel for
  for (int j = 0; j < (int)coeff_modulus.size(); j++)
  {
    util::dyadic_product_coeffmod(&eval_repr[j * coeff_count],
                                  &(*o_p).eval_repr[j * coeff_count],
                                  coeff_count,
                                  coeff_modulus[j],
                                  &eval_repr[j * coeff_count]); // TODO: Check if this is safe (used to be result + ..)
  }
  // invalidate the coeff_repr
  coeff_repr_valid = false;
}

bool AlsealPoly::invert_inplace()
{
  // compute a^{-1}, where a is a double-CRT polynomial whose evaluation representation
  // is in a. The double-CRT representation in SEAL is stored as a flat array of
  // length coeff_count * modulus_count:
  //    [ 0 .. coeff_count-1 , coeff_count .. 2*coeff_count-1, ... ]
  //      ^--- a (mod p0)    , ^--- a (mod p1),              ,  ...
  // return if the inverse exists, and result is also in evaluation representation

  bool *has_inv = new bool[coeff_modulus_count];
  fill_n(has_inv, coeff_modulus_count, true);
#pragma omp parallel for
  for (int j = 0; j < coeff_modulus_count; j++)
  {
    for (size_t i = 0; i < coeff_count && has_inv[j]; i++)
    {
      uint64_t inv = 0;
      if (util::try_invert_uint_mod(eval_repr[i + (j * coeff_count)], coeff_modulus[j], inv))
      {
        eval_repr[i + (j * coeff_count)] = inv; // TODO: Check if this is safe (used to be result[...])
      }
      else
      {
        has_inv[j] = false;
      }
    }
  }
  for (int j = 0; j < (int)coeff_modulus.size(); j++)
  {
    // invalidate the coeff_repr
    coeff_repr_valid = false;
    if (!has_inv[j])
      return false;
  }
  delete[] has_inv;

  // invalidate the coeff_repr
  coeff_repr_valid = false;

  return true;
}
