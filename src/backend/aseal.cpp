/**
 * @file aseal.cpp
 * ------------------------------------------------------------------
 * @brief Implementation of Aseal, library that creates an abstraction over
 *        basic functionalities of Microsoft SEAL.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 * @cite Ibarrondo, Alberto, and Alexander Viand. “Pyfhel: Python for Homomorphic Encryption Libraries.”
 *       In Proceedings of the 9th on Workshop on Encrypted Computing & Applied Homomorphic Cryptography, 11–16, 2021.
*/

#include "aseal.h"

using namespace std;
using namespace seal;

// https://github.com/ibarrond/Pyfhel/blob/master/Pyfhel/Afhel/Afseal.cpp

/**
 * @brief Default Constructor
*/
Aseal::Aseal(){};

Aseal::Aseal(const Aseal &other){
  this->context = make_shared<KeyGenerator>(*context);
  // TODO: Copy other parameters
};

/**
 * @brief Deconstructor
*/
Aseal::~Aseal(){};

string Aseal::ContextGen(scheme_t scheme,
                         uint64_t poly_modulus_degree,
                         uint64_t plain_modulus_bit_size,
                         uint64_t plain_modulus,
                         int sec_level,
                         vector<int> qi_sizes,
                         vector<uint64_t> qi_values)
{

}