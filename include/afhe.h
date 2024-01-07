/**
 * @file afhe.h
 * ------------------------------------------------------------------
 * @brief Abstract Fully Homomorphic Encryption (AFHE) library.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 */

#ifndef AFHE_H
#define AFHE_H

#include <string> /* string class */
#include <map>    /* map */

// Forward Declarations
class ACipherTxt; /* Ciphertext */
class APlainTxt;  /* Plaintext */
class Afhe;       /* Abstract Class*/

using namespace std;

// ------------------ Scheme Type ------------------
/**
 * @brief Enum for the scheme type.
 * @return Integer representing the scheme type.
 */
enum class scheme_t : int
{
  // No scheme set; cannot be used for encryption
  none = 0x0,
  // Brakerski-Fan-Vercauteren (BFV) scheme
  bfv = 0x1,
  // Cheon-Kim-Kim-Song (CKKS) scheme
  ckks = 0x2,
  // Brakerski-Gentry-Vaikuntanathan (BGV) scheme
  bgv = 0x3,
};

// ------------------ Libraries ------------------
/**
 * @brief Enum for the backend library type.
 * @return Integer representing the backend library type.
 */
enum class backend_t : int
{
  // No library set; cannot be used for encryption
  none = 0x0,
  // Microsoft SEAL
  seal = 0x1,
  // OpenFHE
  openfhe = 0x2,
};
static map<backend_t, std::string> backend_t_str{
    {backend_t::none, "none"},
    {backend_t::seal, "seal"},
    {backend_t::openfhe, "openfhe"},
};
static map<std::string, backend_t> backend_t_map{
    {"none", backend_t::none},
    {"seal", backend_t::seal},
    {"openfhe", backend_t::openfhe},
};

/**
 * @brief Abstract Fully Homomorphic Encryption (AFHE) class.
 */
class Afhe
{
public:
  // FHE Backend
  backend_t backend;

  // Class Management
  virtual ~Afhe(){};

  // ------------------ Parameters ------------------
  /**
   * @brief Generates a context for the Fully Homomorphic Encryption (FHE) scheme.
   *
   * The context contains all the public parameters needed for the encryption and decryption processes.
   *
   * @param scheme The encryption scheme to be used.
   * @param poly_modulus_degree The degree of the polynomial modulus, which determines the size and performance of the FHE operations.
   * @param plain_modulus_bit_size The bit size of the plaintext modulus.
   * @param plain_modulus The plaintext modulus, which affects the precision of the computations.
   * @param sec_level The security level, which affects the hardness of the cryptographic problem underlying the FHE scheme.
   * @param qi_sizes (optional) A vector of sizes for each modulus in the modulus chain.
   * @param qi_mods (optional) A vector of specific moduli for the modulus chain.
   *
   * @return A string representing the generated context.
   */
  virtual string ContextGen(
      scheme_t scheme, uint64_t poly_modulus_degree,
      uint64_t plain_modulus_bit_size, uint64_t plain_modulus,
      int sec_level, vector<int> qi_sizes = {}, vector<uint64_t> qi_mods = {}) = 0;

  virtual vector<uint64_t> get_qi() = 0;
  virtual uint64_t get_plain_modulus() = 0;
  virtual size_t get_poly_modulus_degree() = 0;
  virtual scheme_t get_scheme() = 0;

  // ------------------ Sizes ------------------
  virtual size_t sizeof_context(std::string &compr_mode) = 0;
  virtual size_t sizeof_plaintext(std::string &compr_mode, APlainTxt &pt) = 0;
  virtual size_t sizeof_ciphertext(std::string &compr_mode, ACipherTxt &ct) = 0;

  // ------------------ Cryptography ------------------

  /**
   * @brief Encrypts a plaintext message into a ciphertext.
   *
   * @param ptxt The plaintext message to be encrypted.
   * @param ctxt The ciphertext where the encrypted message will be stored.
   */
  virtual void encrypt(APlainTxt &ptxt, ACipherTxt &ctxt) = 0;

  /**
   * @brief Encrypts a vector of plaintext messages into a vector of ciphertexts.
   *
   * @param ptxts The vector of plaintext messages to be encrypted.
   * @param ctxts The vector of ciphertexts where the encrypted messages will be stored.
   */
  virtual void encrypt_v(vector<shared_ptr<APlainTxt>> &ptxts, vector<shared_ptr<ACipherTxt>> &ctxts) = 0;

  /**
   * @brief Decrypts a ciphertext into a plaintext message.
   *
   * @param ctxt The ciphertext to be decrypted.
   * @param ptxt The plaintext message where the decrypted message will be stored.
   */
  virtual void decrypt(ACipherTxt &ctxt, APlainTxt &ptxt) = 0;

  /**
   * @brief Decrypts a vector of ciphertexts into a vector of plaintext messages.
   *
   * @param ctxts The vector of ciphertexts to be decrypted.
   * @param ptxts The vector of plaintext messages where the decrypted messages will be stored.
   */
  virtual void decrypt_v(vector<shared_ptr<ACipherTxt>> &ctxts, vector<shared_ptr<APlainTxt>> &ptxts) = 0;

  // ------------------ Codec ------------------
  
  /**
   * @brief Encodes a vector of integers into a plaintext message.
   *        Used by BGV and BFV schemes.
   *
   * @param data The vector of integers to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_int(vector<int64_t> &data, APlainTxt &ptxt) = 0;

  /**
   * @brief Encodes a vector of floats into a plaintext message.
   *        Used by CKKS scheme.
   *
   * @param data The vector of floats to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_float(vector<double> &data, APlainTxt &ptxt) = 0;

  /**
   * @brief Encodes a vector of complex numbers into a plaintext message.
   *        Used by CKKS scheme.
   *
   * @param data The vector of complex numbers to be encoded.
   * @param ptxt The plaintext message where the encoded message will be stored.
   */
  virtual void encode_complex(vector<complex<double>> &data, APlainTxt &ptxt) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of integers.
   *        Used by BGV and BFV schemes.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of integers where the decoded message will be stored.
   */
  virtual void decode_int(APlainTxt &ptxt, vector<int64_t> &data) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of floats.
   *        Used by CKKS scheme.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of floats where the decoded message will be stored.
   */
  virtual void decode_float(APlainTxt &ptxt, vector<double> &data) = 0;

  /**
   * @brief Decodes a plaintext message into a vector of complex numbers.
   *        Used by CKKS scheme.
   *
   * @param ptxt The plaintext message to be decoded.
   * @param data The vector of complex numbers where the decoded message will be stored.
   */
  virtual void decode_complex(APlainTxt &ptxt, vector<complex<double>> &data) = 0;

  // ------------------ Arithmetic ------------------
  // Add, Subtract, Multiply, Divide
};

/**
 * @brief Abstraction for Plaintexts.
 */
class APlainTxt{
public:
  virtual ~APlainTxt(){};
};

/**
 * @brief Abstraction for Ciphertexts.
 */
class ACipherTxt{
public:
  virtual ~ACipherTxt(){};
};

// Include Backend Libraries
#include "aseal.h"

#endif /* AFHE_H */
