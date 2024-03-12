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
    enum fhe_backend_t : int32_t
    {
        no_b = backend::no_backend,     /* No Backend Set */
        seal_b = backend::seal_backend, /* Microsoft SEAL */
    };

    /**
     * @brief Enum for the supported schemes.
     * @return Integer representing the scheme type.
    */
    enum fhe_scheme_t : int32_t
    {
        no_s = scheme::no_scheme, /* No Scheme Set */
        bfv_s = scheme::bfv,      /* Brakerski-Fan-Vercauteren */
        ckks_s = scheme::ckks,    /* Cheon-Kim-Kim-Song */
        bgv_s = scheme::bgv,      /* Brakerski-Gentry-Vaikuntanathan */
    };

    /**
     * @brief Enum for the supported keys.
     * @return Integer representing the key type.
    */
    enum fhe_key_t : int32_t
    {
        no_k = key::no_key,            /* No Key Set */
        public_k = key::public_key,    /* Public Key */
        secret_k = key::secret_key,    /* Secret Key */
        relin_k = key::relin_keys,     /* Relinearization Keys */
        galois_k = key::galois_keys,   /* Galois Keys */
    };

}

/**
 * @brief Map (abstract) backend type to fhe_backend_t
*/
static map<backend, fhe_backend_t> backend_map_backend_t{
  {backend::no_backend, fhe_backend_t::no_b},
  {backend::seal_backend, fhe_backend_t::seal_b},
};

/**
 * @brief Map scheme_t to (abstract) scheme type
*/
static map<fhe_scheme_t, scheme> scheme_t_map_scheme{
  {fhe_scheme_t::no_s, scheme::no_scheme},
  {fhe_scheme_t::bfv_s, scheme::bfv},
  {fhe_scheme_t::ckks_s, scheme::ckks},
  {fhe_scheme_t::bgv_s, scheme::bgv},
};

/**
 * @brief Map key_t to (abstract) key type
*/
static map<key_t, key> key_t_map_key {
  {fhe_key_t::no_k, key::no_key},
  {fhe_key_t::public_k, key::public_key},
  {fhe_key_t::secret_k, key::secret_key},
  {fhe_key_t::relin_k, key::relin_keys},
  {fhe_key_t::galois_k, key::galois_keys},
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
static map<const char*, fhe_scheme_t, cmp_str> scheme_t_map{
  {"bfv", fhe_scheme_t::bfv_s},
  {"ckks", fhe_scheme_t::ckks_s},
  {"bgv", fhe_scheme_t::bgv_s},
};

/**
 * @brief Map string to type for the supported backend libraries.
*/
static map<const char*, fhe_backend_t, cmp_str> backend_t_map{
  {"seal", fhe_backend_t::seal_b},
};

/**
 * @brief Map string to type for the supported key types.
*/
static map<const char*, fhe_key_t, cmp_str> key_t_map{
  {"public", fhe_key_t::public_k},
  {"secret", fhe_key_t::secret_k},
  {"relin", fhe_key_t::relin_k},
  {"galois", fhe_key_t::galois_k},
};

extern "C" {
    /**
     * @brief Convert backend type to string.
     * @param backend Backend library to convert.
     * @return String representing the backend library.
     */
    // const char* fhe_backend_t_to_string(fhe_backend_t backend);

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
    fhe_backend_t backend_t_from_string(const char* backend);

    /**
     * @brief Convert scheme type to string.
     * @param scheme Scheme to convert.
     * @return String representing the scheme.
     */
    fhe_scheme_t scheme_t_from_string(const char* scheme);

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
    const char* generate_context(Afhe* afhe, fhe_scheme_t scheme, uint64_t poly_mod_degree, uint64_t pt_mod_bit, uint64_t pt_mod, uint64_t sec_level, const uint64_t* qi_sizes, uint64_t qi_sizes_length);

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
     * @brief Number of slots available based on parameters.
     * @param afhe Pointer to the backend library.
    */
    int get_slot_count(Afhe* afhe);

    /**
     * @brief Convert string to key type.
     * @param key name to convert.
     * @return Key type.
     */
    fhe_key_t key_t_from_string(const char* key);

    /**
     * @brief Initialize a key for the backend library.
     * @param afhe Pointer to the backend library.
     * @param key_type Type of key to initialize.
    */
    AKey* init_key(Afhe* afhe, fhe_key_t key_type);

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
     * @brief Save key to a serialized format.
     * @param key Pointer to the key.
     * @return String representing the key.
    */
    const char* save_key(AKey* key);

    /**
     * @brief Save the size of the key.
     * @param key Pointer to the key.
     * @return Size of the serialized key payload.
    */
    int save_key_size(AKey* key);

    /**
     * @brief Load a key from a serialized format.
     * @param afhe Pointer to the backend library.
     * @param data String representing the key.
     * @param size Size of the key.
     * @return Pointer to the loaded key.
    */
    AKey* load_key(fhe_key_t key_type, Afhe* afhe, const char* data, int size);

    /**
     * @brief Retrieve the key data.
     * @param key Pointer to the key.
     * @return Vector of integers representing the key.
     * @note Returned data cannot be used to reconstruct the key.
    */
    uint64_t* get_key_data(AKey* key);

    /**
     * @brief Retrieve the key data size.
     * @param key Pointer to the key.
     * @return Size of the key data.
    */
    int get_key_data_size(AKey* key);

    /**
     * @brief Retrieve the public key.
     * @param afhe Pointer to the backend library.
    */
    AKey* get_public_key(Afhe* afhe);

    /**
     * @brief Retrieve the secret key.
     * @param afhe Pointer to the backend library.
    */
    AKey* get_secret_key(Afhe* afhe);

    /**
     * @brief Retrieve the relinearization keys.
     * @param afhe Pointer to the backend library.
    */
    AKey* get_relin_keys(Afhe* afhe);

    /**
     * @brief Initialize the backend library.
     * @param backend Backend library to use.
     * @return Pointer to the backend library.
     */
    Afhe* init_backend(fhe_backend_t backend);

    /**
     * @brief Initialize a plaintext.
     * @param backend Backend library to use.
     * @return Pointer to the plaintext.
     */
    APlaintext* init_plaintext(fhe_backend_t backend);

    /**
     * @brief Initialize a plaintext with a value.
     * @param backend Backend library to use.
     * @param value Value to initialize the plaintext with.
     * @return Pointer to the plaintext.
     */
    APlaintext* init_plaintext_value(fhe_backend_t backend, const char* value);

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
    ACiphertext* init_ciphertext(fhe_backend_t backend);

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
     * @brief Raise ciphertext to a power.
     * @param afhe Pointer to the backend library.
     * @param ciphertext Pointer to the ciphertext.
     * @param power Power to raise the ciphertext to.
     * @return Pointer to the resulting ciphertext.
    */
    ACiphertext* power(Afhe* afhe, ACiphertext* ciphertext, int power);

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
