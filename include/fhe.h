/**
 * @file fhe.h
 * ------------------------------------------------------------------
 * @brief Interface with Fully Homomorphic Encryption (AFHE) library.
 *
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 */

#ifndef FHE_H
#define FHE_H

#include <vector> /* Vectorizing all operations */
#include <string> /* string class */
#include <map>    /* map */
#include "afhe.h" /* Abstraction Layer */

// Include Backend Libraries
#include <aseal.h>   /* Microsoft SEAL */
#include <openfhe.h> /* OpenFHE */

extern "C" {
    /**
     * @brief Enum for the supported backend libraries.
     * @return Integer representing the backend library type.
     */
    enum backend_t : int32_t
    {
        no_t = 0,    /* No Library Set */
        seal_t = 1,    /* Microsoft SEAL */
        openfhe_t = 2, /* OpenFHE */
    };

}

/**
 * @brief Map type to string for the supported backend libraries.
*/
static map<backend_t, const char*> backend_t_str{
  {backend_t::no_t, "none"},
  {backend_t::seal_t, "seal"},
  {backend_t::openfhe_t, "openfhe"},
};

struct cmp_str
{
   bool operator()(const char* a, const char* b) const
   {
      return std::strcmp(a, b) < 0;
   }
};

/**
 * @brief Map string to type for the supported backend libraries.
*/
static map<const char*, backend_t, cmp_str> backend_t_map{
  {"none", backend_t::no_t},
  {"seal", backend_t::seal_t},
  {"openfhe", backend_t::openfhe_t},
};

extern "C" {
    /**
     * @brief Convert backend type to string.
     * @param backend Backend library to convert.
     * @return String representing the backend library.
     */
    const char* backend_t_to_string(backend_t backend);

    /**
     * @brief Convert string to backend type.
     * @param backend String to convert.
     * @return Backend library type.
     */
    backend_t backend_t_from_string(const char* backend);

    /**
     * @brief Initialize the backend library.
     * @param backend Backend library to use.
     * @return Pointer to the backend library.
     */
    Afhe* init_backend(backend_t backend);

    /**
     * @brief Initialize a plaintext.
     * @param backend Backend library to use.
     * @return Pointer to the plaintext.
     */
    APlaintext* init_plaintext(backend_t backend);

    /**
     * @brief Initialize a plaintext with a value.
     * @param backend Backend library to use.
     * @param value Value to initialize the plaintext with.
     * @return Pointer to the plaintext.
     */
    APlaintext* init_plaintext_value(backend_t backend, const char* value);

    /**
     * @brief Initialize a ciphertext.
     * @param backend Backend library to use.
     * @return Pointer to the ciphertext.
     */
    ACiphertext* init_ciphertext(backend_t backend);

    /**
     * @brief Encrypt a plaintext.
     * @param backend Backend library to use.
     * @param afhe Pointer to the backend library.
     * @param plaintext Pointer to the plaintext.
     * @return Pointer to the ciphertext.
    */
    ACiphertext* encrypt(backend_t backend, Afhe* afhe, APlaintext* plaintext);

    const char* generate_context(backend_t backend, Afhe* afhe, scheme_t scheme, long poly_mod_degree, long pt_mod_bit, long pt_mod, long sec_level);

    void generate_keys(backend_t backend, Afhe* afhe);

    // const char* get_secret_key(Afhe* afhe);

    // const char* get_public_key(Afhe* afhe);
}

#endif /* FHE_H */