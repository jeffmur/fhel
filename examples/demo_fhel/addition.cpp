/**
 * @file addition.cpp
 * ------------------------------------------------------------------
 * @brief Demonstrate the addition functionality of the library. To
 *        successfully add two ciphertexts, they must be derived
 *        from the same encryption keys.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr
*/
#include "fhe.h"

using namespace std;

int main(int argc, char **argv)
{
  Afhe* fhe = init_backend(backend_t::seal_t);

  /* Parameters */
  long poly_mod_degree = 4096;
  long pt_mod_bit = 20;
  long pt_mod = 1024;
  long sec_level = 128;

  const char* ctx1 = generate_context(backend_t::seal_t, fhe, scheme_t::bfv_s, poly_mod_degree, pt_mod_bit, 4096, sec_level);
  cout << "Context char* generated with status " << ctx1 << endl;
  string ctx = fhe->ContextGen(scheme::bfv, poly_mod_degree, pt_mod_bit, pt_mod, sec_level);
  cout << "Context generated with status " << ctx << endl;

  fhe->KeyGen();
  cout << "Keys generated" << endl;

  /* FHE Addition Demo */
  APlaintext* pt_x = init_plaintext_value(backend_t::seal_t, "399");
  APlaintext* pt_add = init_plaintext_value(backend_t::seal_t, "17");
  APlaintext* pt_res = init_plaintext(backend_t::seal_t);

  ACiphertext* ct_x = init_ciphertext(backend_t::seal_t);
  ACiphertext* ct_add = init_ciphertext(backend_t::seal_t);
  ACiphertext* ct_res = init_ciphertext(backend_t::seal_t);

  cout << "FHE Addition " << pt_x->to_string() << " + " << pt_add->to_string() << endl;

  /**
   * Encryption
   * Note: The same keys must be used for both plaintexts
   *       Otherwise, the addition will fail
  */
  ct_x = encrypt(backend_t::seal_t, fhe, pt_x);
  cout << "Size of freshly encrypted ct_x: " << ct_x->size() << endl;

  ct_add = encrypt(backend_t::seal_t, fhe, pt_add);
  cout << "Size of freshly encrypted ct_add: " << ct_add->size() << endl;

  /* Addition */
  ct_res = add(backend_t::seal_t, fhe, ct_x, ct_add);
  cout << "Size of encrypted summation: " << ct_res->size() << endl;

  /* Decryption */
  pt_res = decrypt(backend_t::seal_t, fhe, ct_res);
  cout << "Decrypted result: " << pt_res->to_string() << endl;

};
