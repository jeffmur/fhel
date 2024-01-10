#include <afhe.h>

#include <cassert>
#include <cstdio>
#define VECTOR_SIZE 5

using namespace std;

int main(int argc, char **argv)
{
  string fileName = "DemoBFV";
  Afhe* he = new Aseal();

  // Set parameters
  long poly_mod_degree = 4096;
  long pt_mod_bit = 20;
  long pt_mod = 1024;
  long sec_level = 128;

  string ctx = he->ContextGen(scheme_t::bfv, poly_mod_degree, pt_mod_bit, pt_mod, sec_level);
  cout << "Context generated with status " << ctx << endl;

  he->KeyGen();
  cout << "Keys generated" << endl;


  vector<long> v1;
  vector<long> v2;
  for(int i=0; i < VECTOR_SIZE; i++){ v1.push_back(i); };
  for(int i=0; i < VECTOR_SIZE; i++){ v2.push_back(2); };

  // Sum
  // string k1 = he->encrypt(v1);
  // string k2 = he->encrypt(v2);
  // he.add(k1, k2);
  // vector<long> vRes = he.decrypt(k1);

  // // Multiplication
  // k1 = he.encrypt(v1);
  // k2 = he.encrypt(v2);
  // he.mult(k1, k2);
  // vector<long> vRes2 = he.decrypt(k1);

  // // Scalar product
  // k1 = he.encrypt(v1);
  // k2 = he.encrypt(v2);
  // he.scalarProd(k1, k2);
  // vector<long> vRes3 = he.decrypt(k1);

  // // Square
  // k1 = he.encrypt(v1);
  // he.square(k1);
  // vector<long> vRes4 = he.decrypt(k1);

  // std::cout << "Saved env with values: m=" << he.getM() <<
  //     ", p=" << he.getP() << ", r=" << he.getR() << endl;
  // std::cout << "END OF DEMO" << endl;
};
