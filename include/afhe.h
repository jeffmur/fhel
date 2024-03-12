/**
 * @file afhe.h
 * ------------------------------------------------------------------
 * @brief Abstract Fully Homomorphic Encryption (AFHE) library.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 */

#ifndef AFHE_H
#define AFHE_H

#include <string>  /* string class */
#include <cstdint> /* uint64_t */
#include <vector>  /* vector */
// Forward Declarations
class ACiphertext; /* Ciphertext */
class APlaintext;  /* Plaintext */
class Afhe;        /* Abstract Class */

using namespace std;

// ------------------ Backend Type ------------------
/**
 * @brief Enum for the supported backend libraries.
 * @return Integer representing the backend library type.
 */
enum backend : int
{
  no_backend = 0,   /* No Backend Set */
  seal_backend = 1, /* Microsoft SEAL */
};

// ------------------ Scheme Type ------------------
/**
 * @brief Enum for the scheme type.
 * @return Integer representing the scheme type.
 */
enum scheme : int
{
  no_scheme = 0, /* No Scheme Set */
  bfv = 1,       /* Brakerski-Fan-Vercauteren */
  ckks = 2,      /* Cheon-Kim-Kim-Song */
  bgv = 3,       /* Brakerski-Gentry-Vaikuntanathan */
};

// ------------------ Key Type ------------------
/**
 * @brief Enum for the key type.
 * @return Integer representing the key type.
 */
enum key : int
{
  no_key = 0,      /* No Key Set */
  public_key = 1,  /* Public Key */
  secret_key = 2,  /* Secret Key */
  relin_keys = 3,  /* Relinearization Keys */
  galois_keys = 4, /* Galois Keys */
};

// ------------------ Abstractions ------------------
/**
 * @brief Abstraction for FHE Context
*/
class AContext {
public:
  virtual ~AContext() = default;
  // virtual TODO param_id() = 0;
};

/**
 * @brief Abstraction for Plaintexts.
 */
class APlaintext {
public:
  virtual ~APlaintext() = default;

  /**
   * @brief Returns a string representation of the plaintext.
  */
  virtual string to_string() = 0;
};

/**
 * @brief Abstraction for Ciphertexts.
 */
class ACiphertext{
public:
  virtual ~ACiphertext() = default;

  /**
   * @brief Returns the size of the ciphertext.
  */
  virtual size_t size() = 0;

  /**
   * @brief Returns the scale of the ciphertext.
  */
  virtual double scale() = 0;

  /**
   * @brief Sets the scale of the ciphertext.
  */
  virtual void set_scale(double scale) = 0;

  /**
   * @brief Saves the ciphertext.
  */
  virtual string save(string compression_mode="none") = 0;

  /**
   * @brief Calucate the save size of the ciphertext.
  */
  virtual int save_size(string compression_mode="none") = 0;

  /**
   * @brief Loads the ciphertext.
   * @param fhe The backend library to be used to validate the ciphertext.
   * @param ctxt The ciphertext to be loaded.
  */
  virtual void load(Afhe* fhe, string ctxt) = 0;
};

/**
 * @brief Abstraction for keys.
*/
class AKey {
public:
  virtual ~AKey() = default;

  /**
   * @brief Saves the key.
   * @return A string representation of the key.
  */
  virtual string save() = 0;

  /**
   * @brief Calucate the save size of the key.
   * @return The size of the key in bytes.
  */
  virtual int save_size() = 0;

  /**
   * @brief Loads string representation of the key into the key.
   * @param fhe The backend library to validate the key.
   * @param key The key to be loaded.
  */
  virtual void load(Afhe* fhe, string key) = 0;

  /**
   * @brief Returns the data of the key.
   * @return A vector of integers representing a unique key.
   * @note The key data is unique to the backend library, and
   *       cannot not be used to recreate the key.
  */
  virtual vector<uint64_t> data() = 0;
};

/**
 * @class Afhe
 * @brief The Afhe class represents a Fully Homomorphic Encryption (FHE) scheme.
 *
 * This class provides methods for generating a context, managing keys, performing encryption and decryption operations,
 * encoding and decoding data, and performing arithmetic operations on ciphertexts.
 */
class Afhe
{
public:
  // Class Management
  Afhe(){};
  // Destructor
  virtual ~Afhe(){};

  backend backend_lib; /* The backend library to be used. */

  // ------------------ Parameters ------------------
  /**
   * @brief Generates a context for the Fully Homomorphic Encryption (FHE) scheme.
   *
   * The context contains all the public parameters needed for the encryption and decryption processes.
   *
   * @param scheme The encryption scheme to be used.
   * @param poly_modulus_degree The degree of the polynomial modulus, which determines the size and performance of the FHE operations.
   * @param plain_modulus_bit_size The bit size of the plaintext modulus / CKKS encoder scale.
   * @param plain_modulus The plaintext modulus, which affects the precision of the computations.
   * @param sec_level The security level, which affects the hardness of the cryptographic problem underlying the FHE scheme.
   * @param qi_sizes (optional) A vector of prime bit sizes for each modulus in the modulus chain.
   *
   * @return A string representing the status of generated context.
   */
  virtual string ContextGen(
    scheme scheme, uint64_t poly_modulus_degree,
    uint64_t plain_modulus_bit_size, uint64_t plain_modulus,
    int sec_level, vector<int> qi_sizes = {}) = 0;

  /**
   * @brief Generates a context for the Fully Homomorphic Encryption (FHE) scheme from a set of parameters.
   *
   * The context contains all the public parameters needed for the encryption and decryption processes.
   *
   * @param params A string representing the parameters used to generate the context.
   *
   * @return A string representing the status of generated context.
  */
  virtual string ContextGen(string params) = 0;

  /**
   * @brief Returns the context.
   */
  virtual AContext& get_context() = 0;

  /**
   * @brief Returns the parameters, used for re-generating the context.
  */
  virtual string save_parameters(string compression_mode="none") = 0;

  /**
   * @brief Returns the size of the parameters, used for re-generating the context.
  */
  virtual int save_parameters_size(string compression_mode="none") = 0;

  /**
   * @brief Saves the parameters, used for re-generating the context.
   * Exposes lower level interface for saving parameters.
  */
  virtual void save_parameters_inplace(byte* out, int size, string compression_mode="none") = 0;

  /**
   * @brief Loads the parameters, used for re-generating the context.
   * Exposure lower level interface for loading parameters.
  */
  virtual void load_parameters_inplace(const byte* in, int size) = 0;

  /**
   * @brief Disables the modulus switching chain
  */
  virtual void disable_mod_switch() = 0;

  /**
   * @brief Set the encoder scale for CKKS scheme.
  */
  virtual void set_encoder_scale(double scale) = 0;

  // ------------------ Cryptography ------------------

  /**
   * @brief Generates a public and private key pair.
  */
  virtual void KeyGen() = 0;

  /**
   * @brief Returns the public key.
  */
  virtual AKey& get_public_key() = 0;

  /**
   * @brief Returns the secret key.
  */
  virtual AKey& get_secret_key() = 0;

  /**
   * @brief Generates a public and private key pair; derived from the private key.
   */
  virtual void RelinKeyGen() = 0;

  /**
   * @brief Returns the relinearization keys.
  */
  virtual AKey& get_relin_keys() = 0;

  /**
   * @brief Reduces the size of a ciphertext.
   *
   * This is a technique to reduce the size of the ciphertext typically
   * called when ciphertext.size() > 2. Results in a ciphertext.size() == 2.
   *
   * @param ctxt The ciphertext to be relinearized, inplace.
   */
  virtual void relinearize(ACiphertext &ctxt) = 0;

  /**
   * @brief Modulus switches a plaintext using a given parameter id.
  */
  virtual void mod_switch_to(APlaintext &ptxt, ACiphertext &ctxt) = 0;

  /**
   * @brief Modulus switches a ciphertext using a given parameter id.
  */
  virtual void mod_switch_to(ACiphertext &to, ACiphertext &from) = 0;

  /**
   * @brief Reduces the noise in a plaintext.
   *
   * Modulus switches an NTT transformed plaintext to the next modulus in the modulus chain.
   *
   * @param ptxt The plaintext to be mod switched, inplace.
   */
  virtual void mod_switch_to_next(APlaintext &ptxt) = 0;

  /**
   * @brief Reduces the noise in a ciphertext.
   *
   * `Modulus switching' is a technique of changing the ciphertext parameters down
   *  in the chain. This is done to reduce the noise in the ciphertext.
   *
   * @param ctxt The ciphertext to be mod switched, inplace.
   */
  virtual void mod_switch_to_next(ACiphertext &ctxt) = 0;

  /**
   * @brief Adjusts the scale of an encoded ciphertext in the CKKS scheme.
   *
   * `Rescaling' is a technique specific to the CKKS scheme that adjusts the scale of a ciphertext to enable
   * proper decryption and homomorphic operations at a new scale. It effectively divides the ciphertext by the last modulus
   * in the modulus chain and removes that modulus, thus reducing the scale and the modulus chain length.
   *
   * @param ctxt The ciphertext to be rescaled, inplace.
  */
  virtual void rescale_to_next(ACiphertext &ctxt) = 0;

  /**
   * @brief Encrypts a plaintext message into a ciphertext.
   *
   * @param ptxt The plaintext message to be encrypted.
   * @param ctxt The ciphertext where the encrypted message will be stored.
   */
  virtual void encrypt(APlaintext &ptxt, ACiphertext &ctxt) = 0;

  /**
   * @brief Decrypts a ciphertext into a plaintext message.
   *
   * @param ctxt The ciphertext to be decrypted.
   * @param ptxt The plaintext message where the decrypted message will be stored.
   */
  virtual void decrypt(ACiphertext &ctxt, APlaintext &ptxt) = 0;

  /**
   * @brief Returns the invariant noise budget of a ciphertext.
   *
   * @param ctxt The ciphertext to be analyzed.
   * @return The invariant noise budget (in bits) of the ciphertext.
  */
  virtual int invariant_noise_budget(ACiphertext &ctxt) = 0;

  // ------------------ Codec ------------------

  /**
   * @brief Returns the number of plaintext slots in an encoded ciphertext.
  */
  virtual int slot_count() = 0;

  /**
   * @brief Encodes a vector of integers into a plaintext message.
   *        Used by BGV and BFV schemes.
   *
   * @param data The vector of integers to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_int(vector<uint64_t> &data, APlaintext &ptxt) = 0;

  /**
   * @brief Encodes a vector of floats into a plaintext message.
   *        Used by CKKS scheme.
   *
   * @param data The vector of floats to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_double(vector<double> &data, APlaintext &ptxt) = 0;

  /**
   * @brief Encodes a single double into a plaintext message.
   *        Used by CKKS scheme.
   *
   * @param data The double to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_double(double data, APlaintext &ptxt) = 0;

  /**
   * @brief Encodes a vector of complex numbers into a plaintext message.
   *        Used by CKKS scheme.
   *
   * @param data The vector of complex numbers to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  // virtual void encode_complex(vector<complex<double>> &data, APlainTxt &ptxt) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of integers.
   *        Used by BGV and BFV schemes.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of integers where the decoded message will be stored.
   */
  virtual void decode_int(APlaintext &ptxt, vector<uint64_t> &data) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of floats.
   *        Used by CKKS scheme.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of floats where the decoded message will be stored.
   */
  virtual void decode_double(APlaintext &ptxt, vector<double> &data) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of complex numbers.
   *        Used by CKKS scheme.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of complex numbers where the decoded message will be stored.
   */
  // virtual void decode_complex(APlainTxt &ptxt, vector<complex<double>> &data) = 0;

  // ------------------ Arithmetic ------------------

  /**
   * @brief Adds plaintext to ciphertexts and stores the result in another ciphertext.
   *
   * This function performs the addition operation on plaintext and ciphertext and stores the result in a ciphertext.
   * Can be used as an alternative to relinearization.
   *
   * @param ptx The plaintext to be added.
   * @param ctxt The ciphertext to be added.
   * @param ctxt_res The ciphertext where the result will be stored.
   */
  virtual void add(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Adds two ciphertexts and stores the result in another ciphertext.
   *
   * This function performs the addition operation on two ciphertexts and stores the result in a third ciphertext.
   *
   * @param ctxt1 The first ciphertext to be added.
   * @param ctxt2 The second ciphertext to be added.
   * @param ctxt_res The ciphertext where the result will be stored.
   */
  virtual void add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Subtracts a plaintext from a ciphertext and stores the result in another ciphertext.
   *
   * This function performs the subtraction operation on a ciphertext and a plaintext and stores the result in a ciphertext.
   * Can be used as an alternative to relinearization.
   *
   * @param ctxt The ciphertext to be subtracted from.
   * @param ptxt The plaintext to be subtracted.
   * @param ctxt_res The ciphertext where the result will be stored.
   */
  virtual void subtract(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Subtracts two ciphertexts and stores the result in another ciphertext.
   *
   * This function performs the subtraction operation on two ciphertexts and stores the result in a third ciphertext.
   *
   * @param ctxt1 The ciphertext to be subtracted from.
   * @param ctxt2 The ciphertext to be subtracted.
   * @param ctxt_res The ciphertext where the result will be stored.
   */
  virtual void subtract(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Multiplies two ciphertexts and stores the result in another ciphertext.
   * @param ctxt1 The first ciphertext to be multiplied.
   * @param ctxt2 The second ciphertext to multiply by.
   * @param ctxt_res The ciphertext where the result will be stored.
   *
   * This function performs the multiplication operation on two ciphertexts and stores the result in a third ciphertext.
  */
  virtual void multiply(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Multiplies a ciphertext by a plaintext and stores the result in another ciphertext.
   * @param ctxt The ciphertext to be multiplied.
   * @param ptxt The plaintext to multiply by.
   * @param ctxt_res The ciphertext where the result will be stored.
   *
   * This function performs the multiplication operation on a ciphertext and a plaintext and stores the result in a ciphertext.
  */
  virtual void multiply(ACiphertext &ctxt, APlaintext &ptxt, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Squares a ciphertext and stores the result in another ciphertext.
   * @param ctxt The ciphertext to be squared.
   * @param ctxt_res The ciphertext where the result will be stored.
   *
   * This function performs the squaring operation on a ciphertext and stores the result in another ciphertext.
  */
  virtual void square(ACiphertext &ctxt, ACiphertext &ctxt_res) = 0;

  /**
   * @brief Raises a ciphertext to a power and stores the result in another ciphertext.
   *
   * Applies relinearization after each multiplication step.
   * @param ctxt The ciphertext to be raised to a power.
   * @param power The power to raise the ciphertext to.
   * @param ctxt_res The ciphertext where the result will be stored.
  */
  virtual void power(ACiphertext &ctxt, int power, ACiphertext &ctxt_res) = 0;
};

#endif /* AFHE_H */
