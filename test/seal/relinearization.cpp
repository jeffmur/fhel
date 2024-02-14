#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */

// TODO: Handle error when context is not set
// TEST(ERROR, Relinearization) {
//   Aseal* fhe = new Aseal();

//   fhe->RelinKeyGen();
// }

TEST(BGV_BFV, RelinKeyGen) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 4096, 0, 1024, 128);

    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->RelinKeyGen();
  }
}
