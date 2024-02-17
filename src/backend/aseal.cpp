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

using namespace std;
using namespace seal;

Aseal::~Aseal(){};

string Aseal::ContextGen(scheme scheme,
                         uint64_t poly_modulus_degree,
                         uint64_t plain_modulus_bit_size,
                         uint64_t plain_modulus,
                         int sec_level,
                         vector<int> qi_sizes,
                         vector<uint64_t> qi_values)
{ try {
  // Initialize parameters
  EncryptionParameters param(scheme_map_to_seal[scheme]);

  /*
   * BGV encodes plaintext with “least significant bits”
   * BFV uses the “most significant bits”
  */
  if (scheme == scheme::bfv || scheme == scheme::bgv)
  {
    // Set polynomial modulus degree
    param.set_poly_modulus_degree(poly_modulus_degree);

    // Set coefficient modulus
    param.set_coeff_modulus(CoeffModulus::BFVDefault(poly_modulus_degree));

    /**
     * When plain_modulus_bit_size is set, batching is enabled, plain_modulus is not used
     * Otherwise, plain_modulus is used and batching is disabled
    */
    if (plain_modulus_bit_size > 0)
    {
      param.set_plain_modulus(PlainModulus::Batching(poly_modulus_degree, plain_modulus_bit_size));
    }
    else
    {
      param.set_plain_modulus(plain_modulus);
    }
  }
  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(param, true, sec_map[sec_level]);

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

shared_ptr<SEALContext> inline Aseal::get_context()
{
  if (this->context == nullptr)
  {
    throw logic_error("<Aseal>: Context not initialized");
  }
  return (this->context);
}

void Aseal::KeyGen()
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

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

void Aseal::RelinKeyGen()
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize KeyGen object
  if (this->keyGenObj == nullptr)
  {
    throw logic_error("<Aseal>: KeyGen() must be called before RelinKeyGen()");
  }

  // Generate Relin Key
  this->relinKeys = make_shared<RelinKeys>();
  keyGenObj->create_relin_keys(*relinKeys);
}

void Aseal::relinearize(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Relinearize using casted types
  this->evaluator->relinearize_inplace(_to_ciphertext(ctxt), *this->relinKeys);
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
  auto &seal_context = *(this->get_context());

  // Initialize Encryptor object
  this->encryptor = make_shared<Encryptor>(seal_context, *this->publicKey);

  // Encrypt using casted types
  this->encryptor->encrypt(_to_plaintext(ptxt), _to_ciphertext(ctxt));
}

void Aseal::decrypt(ACiphertext &ctxt, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Decryptor object
  this->decryptor = make_shared<Decryptor>(seal_context, *this->secretKey);

  // Decrypt using casted types
  this->decryptor->decrypt(_to_ciphertext(ctxt), _to_plaintext(ptxt));
}

int Aseal::invariant_noise_budget(ACiphertext &ctxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Decryptor object
  this->decryptor = make_shared<Decryptor>(seal_context, *this->secretKey);

  return this->decryptor->invariant_noise_budget(_to_ciphertext(ctxt));
}

void Aseal::encode_int(vector<uint64_t> &data, APlaintext &ptxt)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Encoder object
  this->encoder = make_shared<BatchEncoder>(seal_context);

  // Encode using casted types
  this->encoder->encode(data, _to_plaintext(ptxt));
}

void Aseal::decode_int(APlaintext &ptxt, vector<uint64_t> &data)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Encoder object
  this->encoder = make_shared<BatchEncoder>(seal_context);

  // Decode using casted types
  this->encoder->decode(_to_plaintext(ptxt), data);
}

void Aseal::add(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Add using casted types
  this->evaluator->add_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}

void Aseal::add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Add using casted types
  this->evaluator->add(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::subtract(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Subtract using casted types
  this->evaluator->sub_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}

void Aseal::subtract(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Subtract using casted types
  this->evaluator->sub(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::multiply(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Multiply using casted types
  this->evaluator->multiply(_to_ciphertext(ctxt1), _to_ciphertext(ctxt2), _to_ciphertext(ctxt_res));
}

void Aseal::multiply(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res)
{
  // Gather current context, resolves object
  auto &seal_context = *(this->get_context());

  // Initialize Evaluator object
  this->evaluator = make_shared<Evaluator>(seal_context);

  // Multiply using casted types
  this->evaluator->multiply_plain(_to_ciphertext(ctxt), _to_plaintext(ptxt), _to_ciphertext(ctxt_res));
}
