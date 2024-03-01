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

// Forward Declaration
class Aseal;
class AsealPoly;

/**
 * @brief Compression Modes used when compiling SEAL.
 */
static map<string, seal::compr_mode_type> compr_mode_map {
    {"none", seal::compr_mode_type::none},
#ifdef SEAL_USE_ZLIB
    // Use ZLIB compression
    {"zlib", seal::compr_mode_type::zlib},
#endif
#ifdef SEAL_USE_ZSTD
    // Use Zstandard compression
    {"zstd", seal::compr_mode_type::zstd},
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
static map<int, seal::sec_level_type> sec_map {
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
  AsealPlaintext(const seal::Plaintext &ptxt) : seal::Plaintext(ptxt) {};
  string to_string() override {
    return seal::Plaintext::to_string();
  }
  ~AsealPlaintext(){};
};

inline AsealPlaintext& _to_plaintext(APlaintext& p){
  return dynamic_cast<AsealPlaintext&>(p);
};
inline APlaintext& _from_plaintext(AsealPlaintext& p){
  return dynamic_cast<APlaintext&>(p);
};

/**
 * @brief Abstraction for Ciphertext
 */
class AsealCiphertext : public ACiphertext, public seal::Ciphertext {
public:
  using seal::Ciphertext::Ciphertext;
  AsealCiphertext(const seal::Ciphertext &ctxt) : seal::Ciphertext(ctxt) {};
  ~AsealCiphertext(){};
  size_t size() override {
    return seal::Ciphertext::size();
  }
  double scale() override {
    return seal::Ciphertext::scale();
  }
  void set_scale(double scale) override {
    seal::Ciphertext::scale() = scale;
  }
};

// DYNAMIC CASTING
inline AsealCiphertext& _to_ciphertext(ACiphertext& c){
  return dynamic_cast<AsealCiphertext&>(c);
};
inline ACiphertext& _from_ciphertext(AsealCiphertext& c){
  return dynamic_cast<ACiphertext&>(c);
};

/**
 * @brief Abstraction for PublicKey
*/
class AsealPublicKey : public APublicKey, public seal::PublicKey {
public:
  using seal::PublicKey::PublicKey;
  AsealPublicKey(const seal::PublicKey &pk) : seal::PublicKey(pk) {};
  ~AsealPublicKey(){};
  ACiphertext& data() override {
    AsealCiphertext* ctxt = new AsealCiphertext(seal::PublicKey::data());
    return _from_ciphertext(*ctxt);
  }
};

// DYNAMIC CASTING
inline AsealPublicKey& _to_public_key(APublicKey& k){
  return dynamic_cast<AsealPublicKey&>(k);
};
inline APublicKey& _from_public_key(AsealPublicKey& k){
  return dynamic_cast<APublicKey&>(k);
};

/**
 * @brief Abstraction for SecretKey
*/
class AsealSecretKey : public ASecretKey, public seal::SecretKey {
public:
  using seal::SecretKey::SecretKey;
  AsealSecretKey(const seal::SecretKey &sk) : seal::SecretKey(sk) {};
  ~AsealSecretKey(){};
  APlaintext& data() override {
    AsealPlaintext* ctxt = new AsealPlaintext(seal::SecretKey::data());
    return _from_plaintext(*ctxt);
  }
};

// DYNAMIC CASTING
inline AsealSecretKey& _to_secret_key(ASecretKey& k){
  return dynamic_cast<AsealSecretKey&>(k);
};
inline ASecretKey& _from_secret_key(AsealSecretKey& k){
  return dynamic_cast<ASecretKey&>(k);
};

/**
 * @brief Aseal class represents a concrete implementation of the Afhe class using the Microsoft SEAL library.
 */
class Aseal : public Afhe {
private:
  shared_ptr<seal::SEALContext> context;     /**< Pointer to the SEAL context object. */
  shared_ptr<seal::BatchEncoder> bEncoder;   /**< Pointer to the BatchEncoder object. */
  shared_ptr<seal::CKKSEncoder> cEncoder;    /**< Pointer to the CKKSEncoder object. */
  double cEncoderScale;                      /**< Scale for CKKSEncoder. */
  shared_ptr<seal::KeyGenerator> keyGenObj;  /** Key generator.*/
  shared_ptr<seal::SecretKey> secretKey;     /** Secret key.*/
  shared_ptr<seal::PublicKey> publicKey;     /** Public key.*/
  shared_ptr<seal::RelinKeys> relinKeys;     /** Relin keys.*/

  shared_ptr<seal::Encryptor> encryptor;     /** Requires a Public Key.*/
  shared_ptr<seal::Evaluator> evaluator;     /** Requires a context.*/
  shared_ptr<seal::Decryptor> decryptor;     /** Requires a Secret Key.*/

  shared_ptr<seal::Ciphertext> ciphertext;   /** Ciphertext.*/

public:
  /**
   * @brief Default constructor for the Aseal class.
   */
  Aseal(){ this->backend_lib = backend::_seal; };

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
    int sec_level = 128, vector<int> qi_sizes = {}) override;

  /**
   * @return A pointer to the SEAL context object.
   * @throws std::logic_error if the context is not initialized.
  */
  inline shared_ptr<seal::SEALContext> get_context() {
    if (this->context == nullptr)
    {
      throw logic_error("Context is not initialized");
    }
    return this->context;
  }

  // ------------------ Keys ------------------

  void KeyGen() override;
  void RelinKeyGen() override;
  void relinearize(ACiphertext &ctxt) override;
  void mod_switch_to(APlaintext &ptxt, ACiphertext &ctxt) override;
  void mod_switch_to(ACiphertext &to, ACiphertext &from) override;
  void mod_switch_to_next(APlaintext &ptxt) override;
  void mod_switch_to_next(ACiphertext &ctxt) override;
  void rescale_to_next(ACiphertext &ctxt) override;
  APublicKey& get_public_key() override;
  ASecretKey& get_secret_key() override;

  // ------------------ Cryptography ------------------

  void encrypt(APlaintext &ptxt, ACiphertext &ctxt) override;
  void decrypt(ACiphertext &ctxt, APlaintext &ptxt) override;
  int invariant_noise_budget(ACiphertext &ctxt) override;

  // -------------------- Codec --------------------

  int slot_count() override;

  void encode_int(vector<uint64_t> &data, APlaintext &ptxt) override;
  void decode_int(APlaintext &ptxt, vector<uint64_t> &data) override;

  void encode_double(double data, APlaintext &ptxt) override;
  void encode_double(vector<double> &data, APlaintext &ptxt) override;
  void decode_double(APlaintext &ptxt, vector<double> &data) override;

  // ------------------ Arithmetic ------------------

  void add(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) override;
  void add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
  void subtract(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) override;
  void subtract(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
  void multiply(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) override;
  void multiply(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) override;
};

#endif /* ASEAL_H */
