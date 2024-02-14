#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

TEST(Subtract, IntegersToHexadecimal) {
  std::map<int, int> plaintextToModulus = {
    {100, 1024},
    {200, 1024},
    {300, 1024},
    {400, 1024},
    {500, 1024},
    {1000, 2048},
    {2000, 4196},
    {4000, 8392},
    {5000, 16784}
  };

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    for (const auto& pair : plaintextToModulus) {
      int plaintext = pair.first;
      int modulus = pair.second;

      Aseal* fhe = new Aseal();

      string ctx = fhe->ContextGen(scheme, 1024, 0, modulus, 128);

      // Expect two strings not to be equal.
      EXPECT_STREQ(ctx.c_str(), "success: valid");

      fhe->KeyGen();
      AsealPlaintext pt_x = AsealPlaintext(uint64_to_hex(plaintext));
      AsealCiphertext ct_x = AsealCiphertext();
      fhe->encrypt(pt_x, ct_x);

      AsealPlaintext pt_y = AsealPlaintext(uint64_to_hex(plaintext));
      AsealCiphertext ct_y = AsealCiphertext();
      fhe->encrypt(pt_y, ct_y);

      AsealPlaintext pt_res = AsealPlaintext();
      AsealCiphertext ct_res = AsealCiphertext();

      fhe->subtract(ct_x, ct_y, ct_res);

      fhe->decrypt(ct_res, pt_res);

      int expect = plaintext - plaintext;

      // Convert hexademical string to uint_64.
      string res_hex = pt_res.to_string();
      int res_int = hex_to_uint64(res_hex);
      EXPECT_EQ(res_int, expect);
    }
  }
}

TEST(Subtract, VectorInteger) {

  Aseal* fhe = new Aseal();

  std::map<int, int> modulusToBitSize = {
    // {1024, 17}, /* modulus too small */
    {2048, 18},
    {4096, 19},
    {8192, 20},
    {16384, 21}
  };

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    for (const auto& pair : modulusToBitSize) {
      int modulus = pair.first;
      int bitSize = pair.second;

      string ctx = fhe->ContextGen(scheme, modulus, bitSize, -1, 128);

      // Expect two strings not to be equal.
      EXPECT_STREQ(ctx.c_str(), "success: valid");

      fhe->KeyGen();

      AsealPlaintext pt_x = AsealPlaintext();

      /*
        Here we create the following arrays:
            x = [ 1,  2,  3,  4,  0,  0,  0,  0 ]
          add = [ 2,  4,  6,  8,  0,  0,  0,  0 ]
      */
      vector<uint64_t> x(8, 0ULL);
      x[0] = 2ULL;
      x[1] = 4ULL;
      x[2] = 6ULL;
      x[3] = 8ULL;

      fhe->encode_int(x, pt_x);

      AsealCiphertext ct_x = AsealCiphertext();
      fhe->encrypt(pt_x, ct_x);

      // Decryption can be incorrect when noise budget is zero.
      EXPECT_GT(fhe->invariant_noise_budget(ct_x), 0);

      AsealPlaintext pt_sub = AsealPlaintext();
      vector<uint64_t> sub(8, 0ULL);
      sub[0] = 1ULL;
      sub[1] = 2ULL;
      sub[2] = 3ULL;
      sub[3] = 4ULL;

      fhe->encode_int(sub, pt_sub);
      AsealCiphertext ct_sub = AsealCiphertext();
      fhe->encrypt(pt_sub, ct_sub);

      // Decryption can be incorrect when noise budget is zero.
      EXPECT_GT(fhe->invariant_noise_budget(ct_sub), 0);

      AsealPlaintext pt_res = AsealPlaintext();
      AsealCiphertext ct_res = AsealCiphertext();
      fhe->subtract(ct_x, ct_sub, ct_res);

      AsealPlaintext decrypt_res = AsealPlaintext();
      fhe->decrypt(ct_res, decrypt_res);

      vector<uint64_t> decode_res;
      fhe->decode_int(decrypt_res, decode_res);

      // Plaintext x and decoded_x must be equal.
      vector<uint16_t> expect = {1, 2, 3, 4, 0, 0, 0, 0};
      for (int i = 0; i < x.size(); i++) {
        EXPECT_EQ(expect[i], decode_res[i]);
      }
    }
  }
}