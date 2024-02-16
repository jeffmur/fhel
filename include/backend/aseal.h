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
static map<scheme, seal::scheme_type> scheme_map_to_seal {
    {scheme::none, seal::scheme_type::none},
    {scheme::bfv, seal::scheme_type::bfv},
    {scheme::ckks, seal::scheme_type::ckks},
    {scheme::bgv, seal::scheme_type::bgv},
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
 * @brief Convert uint_64 to hexademical string.
*/
inline string uint64_to_hex(uint64_t value) {
  return seal::util::uint_to_hex_string(&value, size_t(1));
}

/**
 * @brief Convert hexademical string to uint_64.
*/
inline uint64_t hex_to_uint64(string value) {
  return stoi(value, 0, 16);
}

/**
 * @brief Abstraction for Plaintext
 */
class AsealPlaintext : public APlaintext, public seal::Plaintext {
public:
  // Inherit constructors
  using seal::Plaintext::Plaintext;
  string to_string() override {
    return seal::Plaintext::to_string();
  }
  ~AsealPlaintext(){};
};

inline AsealPlaintext& _to_plaintext(APlaintext& p){
  return dynamic_cast<AsealPlaintext&>(p);
};

/**
 * @brief Abstraction for Ciphertext
 */
class AsealCiphertext : public ACiphertext, public seal::Ciphertext {
public:
  using seal::Ciphertext::Ciphertext;
  ~AsealCiphertext(){};
  size_t size() override {
    return seal::Ciphertext::size();
  }
};

// DYNAMIC CASTING
inline AsealCiphertext& _to_ciphertext(ACiphertext& c){
  return dynamic_cast<AsealCiphertext&>(c);
};

/**
 * @brief Aseal class represents a concrete implementation of the Afhe class using the Microsoft SEAL library.
 */
class Aseal : public Afhe {
private:
  shared_ptr<seal::SEALContext> context;     /**< Pointer to the SEAL context object. */
  shared_ptr<seal::BatchEncoder> encoder;    /**< Pointer to the BatchEncoder object. */

  shared_ptr<seal::KeyGenerator> keyGenObj;  /** Key generator.*/
  shared_ptr<seal::SecretKey> secretKey;     /** Secret key.*/
  shared_ptr<seal::PublicKey> publicKey;     /** Public key.*/
  shared_ptr<seal::RelinKeys> relinKeys;     /** Relin keys.*/

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
    scheme scheme, uint64_t poly_modulus_degree = 1024,
    uint64_t plain_modulus_bit_size = 0, uint64_t plain_modulus = 0,
    int sec_level = 128, vector<int> qi_sizes = {}, vector<uint64_t> qi_values = {}) override;

  /**
   * @return A pointer to the SEAL context object.
   * @throws std::logic_error if the context is not initialized.
  */
  inline shared_ptr<SEALContext> get_context();

  // ------------------ Keys ------------------

  void KeyGen() override;
  void RelinKeyGen() override;
  void relinearize(ACiphertext &ctxt) override;
  // string get_secret_key() override;
  // string get_public_key() override;

  void setPublicKey(seal::PublicKey &pubKey) { this->publicKey = make_shared<seal::PublicKey>(pubKey); }
  void setSecretKey(seal::SecretKey &secKey) { this->secretKey = make_shared<seal::SecretKey>(secKey); }

  // ------------------ Cryptography ------------------

  void encrypt(APlaintext &ptxt, ACiphertext &ctxt) override;
  void decrypt(ACiphertext &ctxt, APlaintext &ptxt) override;
  int invariant_noise_budget(ACiphertext &ctxt) override;

  // -------------------- Codec --------------------

  void encode_int(vector<uint64_t> &data, APlaintext &ptxt) override;
  void decode_int(APlaintext &ptxt, vector<uint64_t> &data) override;

  // ------------------ Arithmetic ------------------

  void add(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) override;
  void add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
  void subtract(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) override;
  void subtract(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
};

#endif /* ASEAL_H */
