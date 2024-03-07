/**
 * @file aseal.cpp
 * ------------------------------------------------------------------
 * @brief Implementation of Aseal, library that creates an abstraction over
 *        basic functionalities of Microsoft SEAL.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 * @cite Ibarrondo, Alberto, and Alexander Viand. “Pyfhel: Python for Homomorphic Encryption Libraries.”
 *       In Proceedings of the 9th on Workshop on Encrypted Computing & Applied Homomorphic Cryptography, 11–16, 2021.
*/

#include "aseal.h"
#include "afhe.h"
#include <bitset>

using namespace std;
using namespace seal;

Aseal::~Aseal(){};

string Aseal::ContextGen(scheme scheme,
                         uint64_t poly_modulus_degree,
                         uint64_t plain_modulus_bit_size,
                         uint64_t plain_modulus,
                         int sec_level,
                         vector<int> bit_sizes)
{ try {
  // Initialize parameters with scheme
  this->params = make_shared<EncryptionParameters>(scheme_map_to_seal.at(scheme));

  /*
   * BGV encodes plaintext with “least significant bits”
   * BFV uses the “most significant bits”
  */
  if (scheme == scheme::bfv || scheme == scheme::bgv)
  {
    // Set polynomial modulus degree
    this->params->set_poly_modulus_degree(poly_modulus_degree);

    // Set coefficient modulus
    this->params->set_coeff_modulus(CoeffModulus::BFVDefault(poly_modulus_degree));

    /**
     * When plain_modulus_bit_size is set, batching is enabled, plain_modulus is not used
     * Otherwise, plain_modulus is used and batching is disabled
    */
    if (plain_modulus_bit_size > 0)
    {
      this->params->set_plain_modulus(PlainModulus::Batching(poly_modulus_degree, plain_modulus_bit_size));
    }
    else
    {
      this->params->set_plain_modulus(plain_modulus);
    }
  }
  else if (scheme == scheme::ckks)
  {
    // Set polynomial modulus degree
    this->params->set_poly_modulus_degree(poly_modulus_degree);

    if (bit_sizes.size() == 0)
    {
      throw invalid_argument("CKKS requires at least one entry in bit_sizes");
    }

    if (plain_modulus_bit_size < 1)
    {
      throw invalid_argument("CKKS requires a positive value for plain_modulus_bit_size");
    }

    // Set coefficient modulus
    this->params->set_coeff_modulus(CoeffModulus::Create(poly_modulus_degree, bit_sizes));

    // Set CKKS Encoder scale
    this->cEncoderScale = plain_modulus_bit_size; //pow(2.0, plain_modulus_bit_size);
  }

  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(*this->params, true, sec_map[sec_level]);

  // Initialize Encoder object
  if(this->context->parameters_set() && plain_modulus_bit_size > 0)
  {
    set_encoders();
  }

  // Return info about parameter validity.
  //    - 'success: valid' if everything went well
  //    - Error name and message from list in seal/context/context.cpp otherwise
  return string(this->context->parameter_error_name())  + ": " +
                this->context->parameter_error_message();
  }
  catch (invalid_argument &e) {
    return string("invalid_argument: ") + e.what();
  }
}

string Aseal::ContextGen(string parms)
{
  // Initialize parameters with scheme
  this->params = make_shared<EncryptionParameters>();

  // Load parameters from string
  istringstream ss(parms);

  this->params->load(ss);

  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(*this->params, true);

  // Initialize Encoder object
  if(this->context->parameters_set())
  {
    set_encoders(true);
  }

  // Return info about parameter validity.
  //    - 'success: valid' if everything went well
  //    - Error name and message from list in seal/context/context.cpp otherwise
  return string(this->context->parameter_error_name())  + ": " +
                this->context->parameter_error_message();
}

void Aseal::set_encoders(bool ignore_exception)
{
  // Gather current context and scheme.
  auto &seal_context = *(this->context);
  const auto &context_data = context->key_context_data();
  const auto &scheme = context_data->parms().scheme();

  if (scheme == scheme_type::bfv || scheme == scheme_type::bgv)
  {
    try {
      // Initialize BatchEncoder object
      this->bEncoder = make_shared<BatchEncoder>(seal_context);
    }
    // Skip assignment, as parameters are not setup for batching
    catch (invalid_argument &e) {
      if (!ignore_exception) {
        throw e;
      }
    }
  }
  else if (scheme == scheme_type::ckks)
  {
    // Initialize CKKSEncoder object
    this->cEncoder = make_shared<CKKSEncoder>(seal_context);
  }
  else {
    if (!ignore_exception) {
        throw logic_error("Scheme is not set");;
      }
  }
}

void Aseal::save_parameters_inplace(byte *out, int size, string compr_mode)
{
  // Initialize params
  this->params = make_shared<EncryptionParameters>();

  // Write to memory
  this->params->save(out, size, compression_mode_map.at(compr_mode));

  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(*this->params, true);
}

void Aseal::load_parameters_inplace(const byte *in, int size)
{
  // Initialize params
  this->params = make_shared<EncryptionParameters>();

  // Load from memory
  this->params->load(in, size);

  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(*this->params, true);
}

string Aseal::save_parameters(string compr_mode)
{
  // Share as a binary string
  ostringstream ss;

  if (this->params == nullptr)
  {
    throw logic_error("Parameters are not set, cannot save them.");
  }

  // Save parameters to stringstream
  int size = save_parameters_size(compr_mode);
  this->params->save(ss, compression_mode_map.at(compr_mode));

  // cout << endl << "save_parameters: " << ss.str() << endl;
  // cout << "save_parameters_size: " << size << " vs str length: " << ss.str().length() << endl;
  // cout << "compression_mode: " << compr_mode << endl;

  return ss.str();
}

int Aseal::save_parameters_size(string compr_mode)
{
  if (this->params == nullptr)
  {
    throw logic_error("Parameters are not set, cannot save them.");
  }

  // Save parameters to stringstream
  return this->params->save_size(compression_mode_map.at(compr_mode));
}

void Aseal::disable_mod_switch()
{
  // Update existing context with same parameters
  this->context = make_shared<SEALContext>(*this->params, false);
}

void Aseal::KeyGen()
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize KeyGen object
  this->keyGenObj = make_shared<KeyGenerator>(seal_context);

  // Initialize empty PublicKey object
  this->publicKey = make_shared<PublicKey>();

  // Derive Key Pair
  keyGenObj->create_public_key(*this->publicKey);

  // Assign Secret Key
  this->secretKey = make_shared<SecretKey>(keyGenObj->secret_key());

  // Refresh Encryptor, Evaluator, and Decryptor objects
  this->encryptor = make_shared<Encryptor>(seal_context, *this->publicKey);
}

void Aseal::KeyGen(ASecretKey &sec)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Copy Secret Key
  this->secretKey = make_shared<SecretKey>(_to_secret_key(sec));

  // Initialize KeyGen object
  this->keyGenObj = make_shared<KeyGenerator>(seal_context, *this->secretKey);

  // Initialize empty PublicKey object
  this->publicKey = make_shared<PublicKey>();

  // Derive Key Pair
  keyGenObj->create_public_key(*this->publicKey);

  // Refresh Encryptor, Evaluator, and Decryptor objects
  this->encryptor = make_shared<Encryptor>(seal_context, *this->publicKey);
}

APublicKey& Aseal::get_public_key()
{
  AsealPublicKey* publicKey = new AsealPublicKey(*this->publicKey);
  return _from_public_key(*publicKey);
}

ASecretKey& Aseal::get_secret_key()
{
  AsealSecretKey* secretKey = new AsealSecretKey(*this->secretKey);
  return _from_secret_key(*secretKey);
}

string Aseal::save_secret_key()
{
  // Share as a binary string
  ostringstream ss;

  if (this->secretKey == nullptr)
  {
    throw logic_error("Secret Key is not set, cannot save it.");
  }

  // Save secret key to stringstream
  this->secretKey->save(ss, seal::compr_mode_type::none);

  return ss.str();
}

ASecretKey& Aseal::load_secret_key(string sec_key)
{
  // Initialize a SecretKey object
  SecretKey *sealKey = new SecretKey();

  if (this->context == nullptr)
  {
    throw logic_error("Context is not set, cannot load secret key.");
  }

  // Load secret key from string
  istringstream ss(sec_key);
  sealKey->load(*this->context, ss);

  AsealSecretKey* secretKey = new AsealSecretKey(*sealKey);

  return _from_secret_key(*secretKey);
}

ARelinKey& Aseal::get_relin_keys(){
  AsealRelinKey* relinKeys = new AsealRelinKey(*this->relinKeys);
  return _from_relin_keys(*relinKeys);
}

void Aseal::RelinKeyGen()
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize KeyGen object
  if (this->keyGenObj == nullptr)
  {
    throw logic_error("KeyGen() must be called before RelinKeyGen()");
  }

  // Generate Relin Key
  this->relinKeys = make_shared<RelinKeys>();
  keyGenObj->create_relin_keys(*relinKeys);
}

void Aseal::relinearize(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Relinearize using casted types
  this->evaluator->relinearize_inplace(_to_ciphertext(ctxt), *this->relinKeys);
}

void Aseal::mod_switch_to(APlaintext &ptxt, ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Mod Switch using from Ciphertext parms_id
  this->evaluator->mod_switch_to_inplace(_to_plaintext(ptxt), _to_ciphertext(ctxt).parms_id());
}

void Aseal::mod_switch_to(ACiphertext &to, ACiphertext &from)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Mod Switch using from Ciphertext parms_id
  this->evaluator->mod_switch_to_inplace(_to_ciphertext(to),  _to_ciphertext(from).parms_id());
}

void Aseal::mod_switch_to_next(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Mod Switch using casted types
  this->evaluator->mod_switch_to_next_inplace(_to_ciphertext(ctxt));
}

void Aseal::mod_switch_to_next(APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Mod Switch using casted types
  this->evaluator->mod_switch_to_next_inplace(_to_plaintext(ptxt));
}

void Aseal::rescale_to_next(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Rescale using casted types
  this->evaluator->rescale_to_next_inplace(_to_ciphertext(ctxt));
}

// string Aseal::get_secret_key()
// {
//     return this->secretKey.get()->data();
// }

// string Aseal::get_public_key()
// {
//     return this->publicKey.get()->data().size();
// }

void Aseal::encrypt(APlaintext &ptxt, ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Encryptor object
  this->encryptor = make_shared<Encryptor>(seal_context, *this->publicKey);

  // Encrypt using casted types
  this->encryptor->encrypt(_to_plaintext(ptxt), _to_ciphertext(ctxt));
}

void Aseal::decrypt(ACiphertext &ctxt, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Decryptor object
  this->decryptor = make_shared<Decryptor>(seal_context, *this->secretKey);

  // Decrypt using casted types
  this->decryptor->decrypt(_to_ciphertext(ctxt), _to_plaintext(ptxt));
}

int Aseal::invariant_noise_budget(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Decryptor object
  this->decryptor = make_shared<Decryptor>(seal_context, *this->secretKey);

  return this->decryptor->invariant_noise_budget(_to_ciphertext(ctxt));
}

int Aseal::slot_count()
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  if (this->bEncoder != nullptr) {
    return this->bEncoder->slot_count();
  }
  else if (this->cEncoder != nullptr) {
    return this->cEncoder->slot_count();
  }
  throw logic_error("Encoder is not initialized");
}

void Aseal::encode_int(vector<uint64_t> &data, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Encoder object
  // this->bEncoder = make_shared<BatchEncoder>(seal_context);

  // Encode using casted types
  this->bEncoder->encode(data, _to_plaintext(ptxt));
}

void Aseal::decode_int(APlaintext &ptxt, vector<uint64_t> &data)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Encoder object
  // this->bEncoder = make_shared<BatchEncoder>(seal_context);

  // Decode using casted types
  this->bEncoder->decode(_to_plaintext(ptxt), data);
}

void Aseal::encode_double(vector<double> &data, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Encode using casted types
  this->cEncoder->encode(data, this->cEncoderScale, _to_plaintext(ptxt));
}

void Aseal::encode_double(double data, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Encode using casted types
  this->cEncoder->encode(data, this->cEncoderScale, _to_plaintext(ptxt));
}

void Aseal::decode_double(APlaintext &ptxt, vector<double> &data)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Encoder object
  // this->cEncoder = make_shared<CKKSEncoder>(seal_context);

  // Decode using casted types
  this->cEncoder->decode(_to_plaintext(ptxt), data);
}

void Aseal::add(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Add using casted types
  this->evaluator->add_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}

void Aseal::add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Add using casted types
  this->evaluator->add(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::subtract(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Subtract using casted types
  this->evaluator->sub_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}

void Aseal::subtract(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Subtract using casted types
  this->evaluator->sub(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::multiply(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Multiply using casted types
  this->evaluator->multiply(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::multiply(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->context);

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Multiply using casted types
  this->evaluator->multiply_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}
