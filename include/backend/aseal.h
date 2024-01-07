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
class AsealCtxt;
class AsealPtxt;
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
class AsealPtxt : public APlainTxt, public seal::Plaintext {
public:
  using seal::Plaintext::Plaintext;
  virtual ~AsealPtxt() = default;
};

/**
 * @brief Abstraction for Ciphertext
 */
class AsealCtxt : public ACipherTxt, public seal::Ciphertext {
public:
  using seal::Ciphertext::Ciphertext;
  virtual ~AsealCtxt() = default;
};

/**
 * @brief Aseal class represents a concrete implementation of the Afhe class using the Microsoft SEAL library.
 */
class Aseal : public Afhe {
private:
  shared_ptr<seal::SEALContext> context; /**< Pointer to the SEAL context object. */
  shared_ptr<seal::BatchEncoder> bfvEncoder; /**< Pointer to the BatchEncoder object. */

public:
  vector<uint64_t> qi; /**< Vector of uint64_t values. */

  /**
   * @brief Default constructor for the Aseal class.
   */
  Aseal();

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

  /**
   * @brief Generates a context for the Fully Homomorphic Encryption (FHE) scheme.
   *
   * The context contains all the public parameters needed for the encryption and decryption processes.
   *
   * @param scheme The encryption scheme to be used.
   * @param poly_modulus_degree (optional) The degree of the polynomial modulus, which determines the size and performance of the FHE operations.
   * @param plain_modulus_bit_size (optional) The bit size of the plaintext modulus.
   * @param plain_modulus (optional) The plaintext modulus, which affects the precision of the computations.
   * @param sec (optional) The security level, which affects the hardness of the cryptographic problem underlying the FHE scheme.
   * @param qi_sizes (optional) A vector of sizes for each modulus in the modulus chain.
   * @param qi_values (optional) A vector of specific moduli for the modulus chain.
  */
  string ContextGen(
    scheme_t scheme, uint64_t poly_modulus_degree = 1024,
    uint64_t plain_modulus_bit_size = 0, uint64_t plain_modulus = 0,
    int sec = 128, vector<int> qi_sizes = {}, vector<uint64_t> qi_values = {});

  // ------------------ Cryptography ------------------
  void encrypt(APlainTxt &ptxt, ACipherTxt &ctxt);
  void encrypt_v(vector<shared_ptr<APlainTxt>> &ptxts, vector<shared_ptr<ACipherTxt>> &ctxts);

  void decrypt(ACipherTxt &ctxt, APlainTxt &ptxt);
  void decrypt_v(vector<shared_ptr<ACipherTxt>> &ctxts, vector<shared_ptr<APlainTxt>> &ptxts);
};

#endif /* ASEAL_H */