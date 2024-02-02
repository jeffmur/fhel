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

TEST(BFV_Encrypt, ConvertToHexadecimal) {

  Aseal* fhe = new Aseal();

  std::map<int, int> plaintextToModulus = {
    // Raising the modulus increases the noise level
    {100, 1024},
    {500, 1024},
    {1000, 2048},
    {2000, 2048}
  };

  for (const auto& pair : plaintextToModulus) {
    int plaintext = pair.first;
    int modulus = pair.second;

    string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, modulus, 128);
  
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->KeyGen();
    AsealPlaintext pt_x = AsealPlaintext(uint64_to_hex(plaintext));
    AsealCiphertext ct_x = AsealCiphertext();
    AsealPlaintext pt_x_dec = AsealPlaintext();

    fhe->encrypt(pt_x, ct_x);

    // 54 or 55 bits of noise budget are accumulated.
    EXPECT_LE(fhe->invariant_noise_budget(ct_x), 55);

    fhe->decrypt(ct_x, pt_x_dec);

    // Expect decryption to be equal to plaintext.
    int res_int = hex_to_uint64(pt_x_dec.to_string());
    EXPECT_EQ(res_int, plaintext);
  }
}

TEST(BFV_Encrypt, NoPlaintextConversion) {

  Aseal* fhe = new Aseal();

  std::map<int, int> plaintextToModulus = {
    {100, 1024},
    {500, 2048},
    {900, 4096},
    {1000, 8192},
    {2000, 16384}
  };

  for (const auto& pair : plaintextToModulus) {
    int plaintext = pair.first;
    int modulus = pair.second;

    string ctx = fhe->ContextGen(scheme::bfv, 4096, 0, modulus, 128);
  
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->KeyGen();
    AsealPlaintext pt_x = AsealPlaintext(to_string(plaintext));
    AsealCiphertext ct_x = AsealCiphertext();
    AsealPlaintext pt_x_dec = AsealPlaintext();

    fhe->encrypt(pt_x, ct_x);

    // 54 or 55 bits of noise budget are accumulated.
    EXPECT_LE(fhe->invariant_noise_budget(ct_x), 55);

    fhe->decrypt(ct_x, pt_x_dec);

    // Without hexademical "compression", must increase modulus.
    EXPECT_STREQ(pt_x_dec.to_string().c_str(), to_string(plaintext).c_str());
  }
}
