#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

TEST(BFV_Add, Integers) {
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

  for (const auto& pair : plaintextToModulus) {
    int plaintext = pair.first;
    int modulus = pair.second;

    Aseal* fhe = new Aseal();

    string ctx = fhe->ContextGen(scheme::bfv, 1024, 0, modulus, 128);
  
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

    fhe->add(ct_x, ct_y, ct_res);

    fhe->decrypt(ct_res, pt_res);

    int expect = plaintext + plaintext;

    // Convert hexademical string to uint_64.
    string res_hex = pt_res.to_string();
    int res_int = hex_to_uint64(res_hex);
    EXPECT_EQ(res_int, expect);
  }
}
