#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

TEST(BFV_Add, Integers) {
  std::map<int, int> plaintextToModulus = {
    {100, 1024},
    {200, 2048},
    {300, 4096},
    {400, 8192},
    // {500, 16384}, returns 0?
    {1000, 32768},
  };

  for (const auto& pair : plaintextToModulus) {
    int plaintext = pair.first;
    int modulus = pair.second;

    Aseal* fhe = new Aseal();

    string ctx = fhe->ContextGen(scheme::bfv, 1024, 0, modulus, 128);
  
    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->KeyGen();
    AsealPlaintext* pt_x = new AsealPlaintext(to_string(plaintext));
    AsealCiphertext* ct_x = new AsealCiphertext();
    fhe->encrypt(*pt_x, *ct_x);
    delete pt_x;

    AsealPlaintext* pt_y = new AsealPlaintext(to_string(plaintext));
    AsealCiphertext* ct_y = new AsealCiphertext();
    fhe->encrypt(*pt_y, *ct_y);
    delete pt_y;

    AsealPlaintext* pt_res = new AsealPlaintext();
    AsealCiphertext* ct_res = new AsealCiphertext();

    fhe->add(*ct_x, *ct_y, *ct_res);
    delete ct_x;
    delete ct_y;

    fhe->decrypt(*ct_res, *pt_res);
    delete ct_res;

    int expect = plaintext + plaintext;
    // cout << "pt_res: " << pt_res->to_string() << endl;
    int actual = atoi(pt_res->to_string().c_str());
    EXPECT_EQ(actual, expect);
    delete pt_res;
    delete fhe;
  }
}
