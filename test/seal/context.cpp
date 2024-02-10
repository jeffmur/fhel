#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */

TEST(BGV_BFV, ValidParameters) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 4096, 0, 1024, 128);
    
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");
  }
}

TEST(BGV_BFV, InvalidPlaintextModulus) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 0, 0, 1024, 128);
    
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "invalid_argument: non-standard poly_modulus_degree");
  }
}

TEST(BGV_BFV, InvalidPolyModulusDegree) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 4096, 0, 0, 128);
    
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "invalid_plain_modulus_bit_count: plain_modulus's bit count is not bounded by SEAL_PLAIN_MOD_BIT_COUNT_MIN(MAX)");
  }
}

// TEST(BFV, InvalidSecurityLevel) {
//   Aseal* fhe = new Aseal();

//   string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 1024, 0);
  
//   // Expect two strings not to be equal.
//   EXPECT_STREQ(ctx.c_str(), "invalid_argument: invalid security level");
// }
