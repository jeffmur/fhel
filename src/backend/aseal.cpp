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

// https://github.com/ibarrond/Pyfhel/blob/master/Pyfhel/Afhel/Afseal.cpp

// Aseal::Aseal(const Aseal &other){
//   this->context = make_shared<SEALContext>(other.context->first_context_data()->param());

//   // TODO: Verify behavior of other.publicKey
//   this->encryptor = make_shared<Encryptor>(*context, **other.publicKey);

//   this->bfvEncoder = make_shared<BatchEncoder>(*context);
// };

Aseal::~Aseal(){};

string Aseal::ContextGen(scheme_t scheme,
                         uint64_t poly_modulus_degree,
                         uint64_t plain_modulus_bit_size,
                         uint64_t plain_modulus,
                         int sec_level,
                         vector<int> qi_sizes,
                         vector<uint64_t> qi_values)
{
  // Initialize parameters
  EncryptionParameters param(scheme_map_to_seal[scheme]);

  // BFV
  if (scheme == scheme_t::bfv)
  {
    // Set polynomial modulus degree
    param.set_poly_modulus_degree(poly_modulus_degree);

    // Set coefficient modulus
    param.set_coeff_modulus(CoeffModulus::BFVDefault(poly_modulus_degree));

    // Set plaintext modulus
    param.set_plain_modulus(plain_modulus);

  }

  // Validate parameters by putting them inside a SEALContext
  this->context = make_shared<SEALContext>(param, true, sec_map[sec_level]);

  // Return info about parameter validity.
  //    - 'success: valid' if everything went well
  //    - Error name and message from list in seal/context/context.cpp otherwise
  return string(this->context->parameter_error_name())  + ": " +
                this->context->parameter_error_message();
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
