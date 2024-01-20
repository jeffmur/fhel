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

  cout << backend_t_to_string(backend_t::seal_t) << ":" << backend_t_from_string("seal") << endl;

  Afhe* he = init_backend(backend_t::seal_t);

  /* Parameters */
  long poly_mod_degree = 4096;
  long pt_mod_bit = 20;
  long pt_mod = 1024;
  long sec_level = 128;

  string ctx = he->ContextGen(scheme_t::bfv, poly_mod_degree, pt_mod_bit, pt_mod, sec_level);
  cout << "Context generated with status " << ctx << endl;

  he->KeyGen();
  cout << "Keys generated" << endl;

  /* FHE Addition Demo */
  APlaintext* pt_x = init_plaintext_value(backend_t::seal_t, "100");
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
  he->encrypt(*pt_x, *ct_x);
  cout << "Size of freshly encrypted ct_x: " << ct_x->size() << endl;

  he->encrypt(*pt_add, *ct_add);
  cout << "Size of freshly encrypted ct_add: " << ct_add->size() << endl;

  /* Addition */
  he->add(*ct_x, *ct_add, *ct_res);
  cout << "Size of encrypted summation: " << ct_res->size() << endl;

  // /* Decryption */
  he->decrypt(*ct_res, *pt_res);
  cout << "Decrypted result: " << pt_res->to_string() << endl;

};
