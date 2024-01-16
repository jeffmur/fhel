/**
 * @file aseal.h
 * ------------------------------------------------------------------
 * @brief Header of Aseal, library that creates an abstraction over
 *        basic functionalities of Microsoft SEAL.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 * @cite Ibarrondo, Alberto, and Alexander Viand. “Pyfhel: Python for Homomorphic Encryption Libraries.”
 *       In Proceedings of the 9th on Workshop on Encrypted Computing & Applied Homomorphic Cryptography, 11–16, 2021.
 */

#ifndef ASEAL_H
#define ASEAL_H

#include <iostream> /* Print in cout */
#include <string>   /* string class */
#include <vector>   /* Vectorizing all operations */
#include <thread>   /* memory pools, multithread*/
#include <memory>   /* Smart Pointers*/
#include <complex>  /* Complex Numbers */
#include <math.h>   /* pow */
#include <fstream>  /* file management */
#include <assert.h> /* assert */
#include <map>      /* map */

#include "seal/seal.h" /* Microsoft SEAL */
#include "afhe.h"      /* Abstraction */

using namespace std;
using namespace seal;

// Forward Declaration
class AsealCiphertext;
class AsealPlaintext;
class Aseal;
class AsealPoly;

/**
 * @brief Compression Modes used when compiling SEAL.
 */
static map<string, seal::compr_mode_type> compr_mode_map {
    {"none", compr_mode_type::none},
#ifdef SEAL_USE_ZLIB
    // Use ZLIB compression
    {"zlib", compr_mode_type::zlib},
#endif
#ifdef SEAL_USE_ZSTD
    // Use Zstandard compression
    {"zstd", compr_mode_type::zstd},
#endif
};

// ------------------ Parameters ------------------

/**
 * @brief Scheme types
 */
static map<scheme_t, seal::scheme_type> scheme_map_to_seal {
    {scheme_t::none, seal::scheme_type::none},
    {scheme_t::bfv, seal::scheme_type::bfv},
    {scheme_t::ckks, seal::scheme_type::ckks},
    {scheme_t::bgv, seal::scheme_type::bgv},
};

/**
 * @brief Security Levels
 */
static map<int, sec_level_type> sec_map {
    {0, seal::sec_level_type::none},
    {128, seal::sec_level_type::tc128},
    {192, seal::sec_level_type::tc192},
    {256, seal::sec_level_type::tc256},
};

/**
 * @brief Abstraction for Plaintext
 */
class AsealPlaintext : public APlaintext, public seal::Plaintext {
public:
  using seal::Plaintext::Plaintext;
  virtual ~AsealPlaintext() = default;
};

/**
 * @brief Abstraction for Ciphertext
 */
class AsealCiphertext : public ACiphertext, public seal::Ciphertext {
public:
  using seal::Ciphertext::Ciphertext;
  virtual ~AsealCiphertext() = default;
};

// DYNAMIC CASTING
inline AsealCiphertext& _to_ciphertext(ACiphertext& c){
  return dynamic_cast<AsealCiphertext&>(c);
};

inline AsealPlaintext& _to_plaintext(APlaintext& p){
  return dynamic_cast<AsealPlaintext&>(p);
};

/**
 * @brief Aseal class represents a concrete implementation of the Afhe class using the Microsoft SEAL library.
 */
class Aseal : public Afhe {
private:
  shared_ptr<seal::SEALContext> context;     /**< Pointer to the SEAL context object. */
  shared_ptr<seal::BatchEncoder> bfvEncoder; /**< Pointer to the BatchEncoder object. */

  shared_ptr<seal::KeyGenerator> keyGenObj;  /** Key generator.*/
  shared_ptr<seal::SecretKey> secretKey;     /** Secret key.*/
  shared_ptr<seal::PublicKey> publicKey;     /** Public key.*/

  shared_ptr<seal::Encryptor> encryptor;     /** Requires a Public Key.*/
  shared_ptr<seal::Evaluator> evaluator;     /** Requires a context.*/
  shared_ptr<seal::Decryptor> decryptor;     /** Requires a Secret Key.*/

  shared_ptr<seal::Ciphertext> ciphertext;   /** Ciphertext.*/

public:
  vector<uint64_t> qi; /**< Vector of uint64_t values. */

  /**
   * @brief Default constructor for the Aseal class.
   */
  Aseal(){};

  /**
   * @brief Copy constructor for the Aseal class.
   * @param other The Aseal object to be copied.
   */
  Aseal(const Aseal &other);

  /**
   * @brief Move constructor for the Aseal class.
   * @param other The Aseal object to be moved.
   */
  Aseal(Aseal &&other) = default;

  /**
   * @brief Copy assignment operator for the Aseal class.
   * @param other The Aseal object to be assigned.
   * @return A reference to the assigned Aseal object.
   */
  Aseal &operator=(const Aseal &other);

  /**
   * @brief Destructor for the Aseal class.
   */
  virtual ~Aseal();

  // ------------------ Context ------------------
  string ContextGen(
    scheme_t scheme, uint64_t poly_modulus_degree = 1024,
    uint64_t plain_modulus_bit_size = 0, uint64_t plain_modulus = 0,
    int sec_level = 128, vector<int> qi_sizes = {}, vector<uint64_t> qi_values = {}) override;

  /**
   * @return A pointer to the SEAL context object.
   * @throws std::logic_error if the context is not initialized.
  */
  inline shared_ptr<SEALContext> get_context();

  // ------------------ Keys ------------------

  void KeyGen() override;

  void setPublicKey(seal::PublicKey &pubKey) { this->publicKey = make_shared<seal::PublicKey>(pubKey); }
  void setSecretKey(seal::SecretKey &secKey) { this->secretKey = make_shared<seal::SecretKey>(secKey); }

  // ------------------ Cryptography ------------------

  void encrypt(APlaintext &ptxt, ACiphertext &ctxt) override;
  void encrypt_v(vector<shared_ptr<APlaintext>> &ptxts, vector<shared_ptr<ACiphertext>> &ctxts);

  void decrypt(ACiphertext &ctxt, APlaintext &ptxt) override;
  void decrypt_v(vector<shared_ptr<ACiphertext>> &ctxts, vector<shared_ptr<APlaintext>> &ptxts);

  // ------------------ Arithmetic ------------------

  void add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
};

#endif /* ASEAL_H */
