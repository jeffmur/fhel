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
#include "error_handling.h" /* Error Handling */

// Include Backend Libraries
#include <aseal.h>   /* Microsoft SEAL */

extern "C" {
    /**
     * @brief Enum for the supported backend libraries.
     * @return Integer representing the backend library type.
     */
    enum backend_t : int32_t
    {
        no_b = backend::_none,   /* No Backend Set */
        seal_b = backend::_seal, /* Microsoft SEAL */
    };

    /**
     * @brief Enum for the supported schemes.
     * @return Integer representing the scheme type.
    */
    enum scheme_t : int32_t
    {
        no_s = scheme::none,   /* No Scheme Set */
        bfv_s = scheme::bfv,   /* Brakerski-Fan-Vercauteren */
        ckks_s = scheme::ckks, /* Cheon-Kim-Kim-Song */
        bgv_s = scheme::bgv,   /* Brakerski-Gentry-Vaikuntanathan */
    };

}

/**
 * @brief Map (abstract) backend type to backend_t
*/
static map<backend, backend_t> backend_map_backend_t{
  {backend::_none, backend_t::no_b},
  {backend::_seal, backend_t::seal_b},
};

/**
 * @brief Map scheme_t to (abstract) scheme type
*/
static map<scheme_t, scheme> scheme_t_map_scheme{
  {scheme_t::no_s, scheme::none},
  {scheme_t::bfv_s, scheme::bfv},
  {scheme_t::ckks_s, scheme::ckks},
  {scheme_t::bgv_s, scheme::bgv},
};

struct cmp_str
{
   bool operator()(const char* a, const char* b) const
   {
      return std::strcmp(a, b) < 0;
   }
};

/**
 * @brief Map string to type for the supported schemes.
*/
static map<const char*, scheme_t, cmp_str> scheme_t_map{
  {"bfv", scheme_t::bfv_s},
  {"ckks", scheme_t::ckks_s},
  {"bgv", scheme_t::bgv_s},
};

/**
 * @brief Map string to type for the supported backend libraries.
*/
static map<const char*, backend_t, cmp_str> backend_t_map{
  {"seal", backend_t::seal_b},
};

extern "C" {
    /**
     * @brief Convert backend type to string.
     * @param backend Backend library to convert.
     * @return String representing the backend library.
     */
    // const char* backend_t_to_string(backend_t backend);

    /**
     * @brief Check for an error.
     * @return Reference to the error translator.
    */
    const char* check_for_error();

    /**
     * @brief Clear the error.
    */
    void clear_error();

    /**
     * @brief Convert string to backend type.
     * @param backend String to convert.
     * @return Backend library type.
     */
    backend_t backend_t_from_string(const char* backend);

    /**
     * @brief Convert scheme type to string.
     * @param scheme Scheme to convert.
     * @return String representing the scheme.
     */
    scheme_t scheme_t_from_string(const char* scheme);

    /**
     * @brief Generate a context for the backend library.
     * @param afhe Pointer to the backend library.
     * @param scheme Scheme to use.
     * @param poly_mod_degree Polynomial modulus degree.
     * @param pt_mod_bit Plaintext modulus bit size.
     * @param pt_mod Plaintext modulus.
     * @param sec_level Security level.
     * @param qi_sizes Array of primes for the coefficient modulus.
     * @param qi_sizes_length Length of the array of primes.
     * @return String representing the context.
    */
    const char* generate_context(Afhe* afhe, scheme_t scheme, uint64_t poly_mod_degree, uint64_t pt_mod_bit, uint64_t pt_mod, uint64_t sec_level, const uint64_t* qi_sizes, uint64_t qi_sizes_length);

    /**
     * @brief Generate a context for the backend library from parameters.
     * @param afhe Pointer to the backend library.
     * @param params String representing the parameters.
     * @return String representing the context.
    */
    const char* generate_context_from_str(Afhe* afhe, const char* params, int size);

    /**
     * @brief Save the parameters for the backend library.
     * @param afhe Pointer to the backend library.
     * @return String representing the parameters.
    */
    const char* save_parameters(Afhe* afhe);

    /**
     * @brief Save the size of the parameters for the backend library.
    */
    int save_parameters_size(Afhe* afhe);

    /**
     * @brief Generate keys for the backend library.
     * @param afhe Pointer to the backend library.
    */
    void generate_keys(Afhe* afhe);

    /**
     * @brief Generate relinearization keys for the backend library.
     * @param afhe Pointer to the backend library.
    */
    void generate_relin_keys(Afhe* afhe);

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
     * @brief Get the value of a plaintext.
     * @param plaintext Pointer to the plaintext.
     * @return Value of the plaintext.
     */
    const char* get_plaintext_value(APlaintext* plaintext);

    /**
     * @brief Initialize a ciphertext.
     * @param backend Backend library to use.
     * @return Pointer to the ciphertext.
     */
    ACiphertext* init_ciphertext(backend_t backend);

    /**
     * @brief Get the size of a ciphertext.
     * @param ciphertext Pointer to the ciphertext.
     * @return Size of the ciphertext.
     */
    int get_ciphertext_size(ACiphertext* ciphertext);

    /**
     * @brief Convert the ciphertext to a string.
     * @param ciphertext Pointer to the ciphertext.
     * @return String representing the ciphertext.
    */
    const char* save_ciphertext(ACiphertext* ciphertext);

    /**
     * @brief Save the size of the ciphertext.
     * @param ciphertext Pointer to the ciphertext.
     * @return Size of the serialized ciphertext payload.
    */
    int save_ciphertext_size(ACiphertext* ciphertext);

    /**
     * @brief Load a ciphertext from a string.
     * @param afhe Pointer to the backend library.
     * @param data String representing the ciphertext.
     * @param size Size of the ciphertext.
     * @return Pointer to the loaded ciphertext.
    */
    ACiphertext* load_ciphertext(Afhe* afhe, const char* data, int size);

    /**
     * @brief Encrypt a plaintext.
     * @param afhe Pointer to the backend library.
     * @param plaintext Pointer to the plaintext.
     * @return Pointer to the ciphertext.
    */
    ACiphertext* encrypt(Afhe* afhe, APlaintext* plaintext);

    /**
     * @brief Decrypt a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @return Pointer to the plaintext.
    */
    APlaintext* decrypt(Afhe* afhe, ACiphertext* ciphertext);

    /**
     * @brief Calculate the added noise to the ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @return Noise added to the ciphertext.
    */
    int invariant_noise_budget(Afhe* afhe, ACiphertext* ciphertext);

    /**
     * @brief Relinearize a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @return Pointer to the relinearized ciphertext.
    */
    ACiphertext* relinearize(Afhe* afhe, ACiphertext* ciphertext);

    /**
     * @brief Mod switch to the next level for a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
    */
    void mod_switch_to_next(Afhe* afhe, ACiphertext* ciphertext);

    /**
     * @brief Add two ciphertexts.
     * @param afhe Pointer to the backend library.
     * @param ciphertext1 Pointer to the first ciphertext.
     * @param ciphertext2 Pointer to the second ciphertext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* add(Afhe* afhe, ACiphertext* ciphertext1, ACiphertext* ciphertext2);

    /**
     * @brief Add a plaintext to a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @param plaintext Pointer to the plaintext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* add_plain(Afhe* afhe, ACiphertext* ciphertext, APlaintext* plaintext);

    /**
     * @brief Subtract two ciphertexts.
     * @param afhe Pointer to the backend library.
     * @param ciphertext1 Pointer to the first ciphertext.
     * @param ciphertext2 Pointer to the second ciphertext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* subtract(Afhe* afhe, ACiphertext* ciphertext1, ACiphertext* ciphertext2);

    /**
     * @brief Subtract a plaintext from a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @param plaintext Pointer to the plaintext.
    */
    ACiphertext* subtract_plain(Afhe* afhe, ACiphertext* ciphertext, APlaintext* plaintext);

    /**
     * @brief Multiply two ciphertexts.
     * @param afhe Pointer to the backend library.
     * @param ciphertext1 Pointer to the first ciphertext.
     * @param ciphertext2 Pointer to the second ciphertext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* multiply(Afhe* afhe, ACiphertext* ciphertext1, ACiphertext* ciphertext2);

    /**
     * @brief Multiply a ciphertext by a plaintext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @param plaintext Pointer to the plaintext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* multiply_plain(Afhe* afhe, ACiphertext* ciphertext, APlaintext* plaintext);

    /**
     * @brief Square a ciphertext.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* square(Afhe* afhe, ACiphertext* ciphertext);

    /**
     * @brief Encode a vector of integers into a plaintext.
     * @param afhe Pointer to the backend library.
     * @param data Vector of integers to encode.
     * @return Pointer to the plaintext.
    */
    APlaintext* encode_int(Afhe* afhe, uint64_t* data, int len);

    /**
     * @brief Decode a plaintext into a vector of integers.
     * @param afhe Pointer to the backend library.
     * @param plaintext Pointer to the plaintext.
     * @return Vector of integers.
    */
    uint64_t* decode_int(Afhe* afhe, APlaintext* plaintext);

    /**
     * @brief Encode a vector of doubles into a plaintext.
     * @param afhe Pointer to the backend library.
     * @param data Vector of doubles to encode.
     * @return Pointer to the plaintext.
    */
    APlaintext* encode_double(Afhe* afhe, double* data, int len);

    /**
     * @brief Encode a double into a plaintext.
     * @param afhe Pointer to the backend library.
     * @param data Double to encode.
     * @return Pointer to the plaintext.
    */
    APlaintext* encode_double_value(Afhe* afhe, double data);

    /**
     * @brief Decode a plaintext into a vector of doubles.
     * @param afhe Pointer to the backend library.
     * @param plaintext Pointer to the plaintext.
     * @return Vector of doubles.
    */
    double* decode_double(Afhe* afhe, APlaintext* plaintext);
}

#endif /* FHE_H */
