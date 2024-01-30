#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

TEST(BFV_Encrypt, InvalidPlainModulus) {
  Aseal* fhe = new Aseal();

  string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 1024, 128);
  EXPECT_STREQ(ctx.c_str(), "success: valid");

  fhe->KeyGen();
  AsealPlaintext pt_x = AsealPlaintext("500");
  AsealCiphertext ct_x = AsealCiphertext();

  // Plaintext Modulus is 1024, so 500 is too large.
  ASSERT_THROW(fhe->encrypt(pt_x, ct_x), invalid_argument);
}

TEST(BFV_Encrypt, ValidPlainModulus) {

  Aseal* fhe = new Aseal();

  std::map<int, int> modulusToPlaintext = {
    {1024, 100},
    {2048, 500},
    {4096, 900},
    {8192, 1000},
    {16384, 2000}
  };

  for (const auto& pair : modulusToPlaintext) {
    int modulus = pair.first;
    int plaintext = pair.second;

    string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, pair.first, 128);
  
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->KeyGen();
    AsealPlaintext pt_x = AsealPlaintext(to_string(pair.second));
    AsealCiphertext ct_x = AsealCiphertext();

    fhe->encrypt(pt_x, ct_x);

    AsealPlaintext pt_x_dec = AsealPlaintext();
    fhe->decrypt(ct_x, pt_x_dec);

    // Expect decryption to be equal to plaintext.
    EXPECT_STREQ(pt_x_dec.to_string().c_str(), pt_x.to_string().c_str());
  }
}

// TEST(BFV, InvalidSecurityLevel) {
//   Aseal* fhe = new Aseal();

//   string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, 1024, 0);
  
//   // Expect two strings not to be equal.
//   EXPECT_STREQ(ctx.c_str(), "invalid_argument: invalid security level");
// }