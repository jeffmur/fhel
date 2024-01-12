/**
 * @file addition.cpp
 * ------------------------------------------------------------------
 * @brief Demonstrate the addition functionality of the library. To 
 *        successfully add two ciphertexts, they must be derived 
 *        from the same encryption keys.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr
*/
#include <afhe.h>

#include <cassert>
#include <cstdio>
#define VECTOR_SIZE 5

using namespace std;

int main(int argc, char **argv)
{
  Afhe* he = new Aseal();

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
  AsealPlaintext pt_x("2");
  AsealPlaintext pt_add("4");
  AsealPlaintext pt_res;

  AsealCiphertext ct_x;
  AsealCiphertext ct_add;
  AsealCiphertext ct_res;

  cout << "FHE Addition " << pt_x.to_string() << " + " << pt_add.to_string() << endl;

  /**
   * Encryption
   * Note: The same keys must be used for both plaintexts
   *       Otherwise, the addition will fail
  */
  he->encrypt(pt_x, ct_x);
  cout << "Size of freshly encrypted ct_x: " << ct_x.size() << endl;

  he->encrypt(pt_add, ct_add);
  cout << "Size of freshly encrypted ct_add: " << ct_add.size() << endl;

  /* Addition */
  he->add(ct_x, ct_add, ct_res);
  cout << "Size of encrypted summation: " << ct_res.size() << endl;

  /* Decryption */
  he->decrypt(ct_res, pt_res);
  cout << "Decrypted result: " << pt_res.to_string() << endl;

};
