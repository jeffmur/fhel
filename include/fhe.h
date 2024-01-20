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
#include <afhe.h> /* Abstraction Layer */

// Include Backend Libraries
#include <aseal.h> /* Microsoft SEAL */

// ------------------ Libraries ------------------
/**
 * @brief Enum for the supported backend libraries.
 * @return Integer representing the backend library type.
 */
enum class backend_t : int32_t
{
  none = 0,    /* No Library Set */
  seal = 1,    /* Microsoft SEAL */
  openfhe = 2, /* OpenFHE */
};

/**
 * @brief Map type to string for the supported backend libraries.
*/
static map<backend_t, string> backend_t_str{
  {backend_t::none, "none"},
  {backend_t::seal, "seal"},
  {backend_t::openfhe, "openfhe"},
};

/**
 * @brief Map string to type for the supported backend libraries.
*/
static map<string, backend_t> backend_t_map{
  {"none", backend_t::none},
  {"seal", backend_t::seal},
  {"openfhe", backend_t::openfhe},
};

extern "C" int32_t add(int32_t a, int32_t b) {
  return a + b;
}

/**
 * @brief Get the backend object
*/
extern "C" Afhe* init_backend(int32_t backend) {
    switch (backend)
    {
    case 1:
        cout << "Using Microsoft SEAL" << endl;
        return new Aseal();
    case 2:
        // cout << "Using OpenFHE" << endl;
        runtime_error("Not Implemented");
    default:
        throw runtime_error("No backend set");
    }
}

// extern "C" APlaintext* init_plaintext(backend_t backend) {
//     switch (backend)
//     {
//     case backend_t::seal:
//         return new AsealPlaintext();
//     case backend_t::openfhe:
//         runtime_error("Not Implemented");
//     default:
//         throw runtime_error("No backend set");
//     }
// }

extern "C" APlaintext* init_plaintext(backend_t backend, string value) {
    switch (backend)
    {
    case backend_t::seal:
        return new AsealPlaintext(value);
    case backend_t::openfhe:
        runtime_error("Not Implemented");
    default:
        throw runtime_error("No backend set");
    }
}

extern "C" ACiphertext* init_ciphertext(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal:
        return new AsealCiphertext();
    case backend_t::openfhe:
        runtime_error("Not Implemented");
    default:
        throw runtime_error("No backend set");
    }
}

#endif /* FHE_H */