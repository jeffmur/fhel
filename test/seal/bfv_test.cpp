#include <gtest/gtest.h> // NOLINT
#include "aseal.h"       /* Microsoft SEAL */

TEST(BFV, ValidParameters) {
  Aseal* fhe = new Aseal();

  string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 1024, 128);
  
  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "success: valid");
}

TEST(BFV, InvalidPlaintextModulus) {
  Aseal* fhe = new Aseal();

  string ctx = fhe->ContextGen(scheme::bfv, 0, 0, 1024, 128);
  
  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "invalid_argument: non-standard poly_modulus_degree");
}

TEST(BFV, InvalidPolyModulusDegree) {
  Aseal* fhe = new Aseal();

  string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 0, 128);
  
  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "invalid_plain_modulus_bit_count: plain_modulus's bit count is not bounded by SEAL_PLAIN_MOD_BIT_COUNT_MIN(MAX)");
}

// TEST(BFV, InvalidSecurityLevel) {
//   Aseal* fhe = new Aseal();

//   string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 1024, 0);
  
//   // Expect two strings not to be equal.
//   EXPECT_STREQ(ctx.c_str(), "invalid_argument: invalid security level");
// }