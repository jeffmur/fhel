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
 * @brief Serialization Compression Modes
*/
static map<string,seal::compr_mode_type> compression_mode_map {
    {"none", seal::compr_mode_type::none},
#ifdef SEAL_USE_ZLIB
    {"zlib", seal::compr_mode_type::zlib},
#endif
#ifdef SEAL_USE_ZSTD
    {"zstd", seal::compr_mode_type::zstd},
#endif
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
 * @brief Abstraction for Context
*/
class AsealContext : public AContext, public seal::SEALContext {
public:
  using seal::SEALContext::SEALContext;
  AsealContext(const seal::SEALContext &context) : seal::SEALContext(context) {};
  ~AsealContext(){};
};

inline AsealContext& _to_context(AContext& c){
  return static_cast<AsealContext&>(c);
};
inline AContext& _from_context(AsealContext& c){
  return static_cast<AContext&>(c);
};

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
  string save(string compression_mode="none") override {
    ostringstream stream;
    seal::Ciphertext::save(stream, compression_mode_map.at(compression_mode));
    return stream.str();
  }
  int save_size(string compression_mode="none") override {
    return seal::Ciphertext::save_size(compression_mode_map.at(compression_mode));
  }
  void load(Afhe* fhe, string data) override {
    istringstream stream(data);
    seal::Ciphertext::load(_to_context(fhe->get_context()), stream);
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
class AsealPublicKey : public AKey, public seal::PublicKey {
public:
  using seal::PublicKey::PublicKey;
  AsealPublicKey(const seal::PublicKey &pk) : seal::PublicKey(pk) {};
  ~AsealPublicKey(){};
  string save() override {
    ostringstream stream;
    seal::PublicKey::save(stream);
    return stream.str();
  }
  int save_size() override {
    return seal::PublicKey::save_size();
  }
  void load(Afhe* fhe, string data) override {
    istringstream stream(data);
    seal::PublicKey::load(_to_context(fhe->get_context()), stream);
  }
  vector<uint64_t> param_ids() override {
    // Typically returns a 4-element array
    array<uint64_t, 4> params = seal::PublicKey::parms_id();
    vector<std::uint64_t> vec(params.begin(), params.end());
    return vec;
  }
};

// DYNAMIC CASTING
inline AsealPublicKey& _to_public_key(AKey& k){
  return static_cast<AsealPublicKey&>(k);
};
inline AKey& _from_public_key(AsealPublicKey& k){
  return static_cast<AKey&>(k);
};

/**
 * @brief Abstraction for SecretKey
*/
class AsealSecretKey : public AKey, public seal::SecretKey {
public:
  using seal::SecretKey::SecretKey;
  AsealSecretKey(const seal::SecretKey &sk) : seal::SecretKey(sk) {};
  ~AsealSecretKey(){};
  string save() override {
    ostringstream stream;
    seal::SecretKey::save(stream);
    return stream.str();
  }
  int save_size() override {
    return seal::SecretKey::save_size();
  }
  void load(Afhe* fhe, string data) override {
    istringstream stream(data);
    seal::SecretKey::load(_to_context(fhe->get_context()), stream);
  }
  vector<uint64_t> param_ids() override {
    // Typically returns a 4-element array
    array<uint64_t, 4> params = seal::SecretKey::parms_id();
    vector<std::uint64_t> vec(params.begin(), params.end());
    return vec;
  }
};

// DYNAMIC CASTING
inline AsealSecretKey& _to_secret_key(AKey& k){
  return static_cast<AsealSecretKey&>(k);
};
inline AKey& _from_secret_key(AsealSecretKey& k){
  return static_cast<AKey&>(k);
};

/**
 * @brief Abstraction for RelinKey
*/
class AsealRelinKey : public AKey, public seal::RelinKeys {
public:
  using seal::RelinKeys::RelinKeys;
  AsealRelinKey(const seal::RelinKeys &rk) : seal::RelinKeys(rk) {};
  ~AsealRelinKey(){};
  string save() override {
    ostringstream stream;
    seal::RelinKeys::save(stream);
    return stream.str();
  }
  int save_size() override {
    return seal::RelinKeys::save_size();
  }
  void load(Afhe* fhe, string data) override {
    istringstream stream(data);
    seal::RelinKeys::load(_to_context(fhe->get_context()), stream);
  }
  vector<uint64_t> param_ids() override {
    // Typically returns a 4-element array
    array<uint64_t, 4> params = seal::RelinKeys::parms_id();
    vector<std::uint64_t> vec(params.begin(), params.end());
    return vec;
  }
};

// DYNAMIC CASTING
inline AsealRelinKey& _to_relin_keys(AKey& k){
  return dynamic_cast<AsealRelinKey&>(k);
};
inline AKey& _from_relin_keys(AsealRelinKey& k){
  return dynamic_cast<AKey&>(k);
};


/**
 * @brief Aseal class represents a concrete implementation of the Afhe class using the Microsoft SEAL library.
 */
class Aseal : public Afhe {
private:
  shared_ptr<seal::EncryptionParameters> params; /** Pointer to the SEAL parameters object. */
  shared_ptr<seal::SEALContext> context;     /** Pointer to the SEAL context object. */
  shared_ptr<seal::BatchEncoder> bEncoder;   /** Pointer to the BatchEncoder object. */
  shared_ptr<seal::CKKSEncoder> cEncoder;    /** Pointer to the CKKSEncoder object. */
  double cEncoderScale;                      /** Scale for CKKSEncoder. */
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

  string ContextGen(string params) override;

  inline shared_ptr<seal::SEALContext> _this_context() {
    if (this->context == nullptr)
    {
      throw logic_error("Context is not initialized");
    }
    return this->context;
  }

  AContext& get_context() {
    return _from_context(static_cast<AsealContext&>(*_this_context()));
  }

  /**
   * @brief Assign Encoders used for encoding and decoding.
   * @param ignore_exception If true, ignore exceptions.
   * 
   * We may want to ignore exceptions if we are setting the encoders without
   * access to the original parameters.
  */
  void set_encoders(bool ignore_exception=false);

  /**
   * @brief Represent SEALContext parameters as a serialized string.
   * @param compression_mode The compression mode to use.
   * Note: String may contain null-terminating characters.
  */
  string save_parameters(string compression_mode="none") override;

  /**
   * @brief Calculate the size of the serialized SEALContext parameters.
   * @param compression_mode The compression mode to use.
  */
  int save_parameters_size(string compression_mode="none") override;

  /**
   * @brief Load SEALContext parameters from a serialized byte array.
   * @param buffer The byte array containing the serialized parameters.
   * @param size The size of the byte array.
   * @param compression_mode The compression mode used.
  */
  void save_parameters_inplace(byte* buffer, int size, string compression_mode="none") override;

  /**
   * @brief Load SEALContext parameters from a serialized byte array.
   * @param buffer The byte array containing the serialized parameters.
   * @param size The size of the byte array.
  */
  void load_parameters_inplace(const byte* buffer, int size) override;

  /**
   * @brief Replaces the existing SEALContext with a new one,
   * with the same parameters, however disables mod switching.
  */
  void disable_mod_switch() override;

  /**
   * @brief Replaces the existing cEncoderScale, used for CKKSEncoder.
   * Only affects subsequent encoding operations.
   * @param scale The new scale.
  */
  void set_encoder_scale(double scale) override;

  // ------------------ Keys ------------------
  void KeyGen() override;
  void KeyGen(string sk);
  void RelinKeyGen() override;
  AKey& get_public_key() override;
  AKey& get_secret_key() override;
  AKey& get_relin_keys() override;

  // ------------------ Cryptography ------------------

  void encrypt(APlaintext &ptxt, ACiphertext &ctxt) override;
  void decrypt(ACiphertext &ctxt, APlaintext &ptxt) override;
  int invariant_noise_budget(ACiphertext &ctxt) override;
  void relinearize(ACiphertext &ctxt) override;
  void mod_switch_to(APlaintext &ptxt, ACiphertext &ctxt) override;
  void mod_switch_to(ACiphertext &to, ACiphertext &from) override;
  void mod_switch_to_next(APlaintext &ptxt) override;
  void mod_switch_to_next(ACiphertext &ctxt) override;
  void rescale_to_next(ACiphertext &ctxt) override;

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
  void square(ACiphertext &ctxt, ACiphertext &ctxt_res) override;
  void power(ACiphertext &ctxt, int power, ACiphertext &ctxt_res) override;
};

#endif /* ASEAL_H */
