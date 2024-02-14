#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */

TEST(Error, RelinKeyGen) {
  Aseal* fhe = new Aseal();

  try {
    fhe->RelinKeyGen();
  } catch (const std::exception& e) {
    EXPECT_STREQ(e.what(), "<Aseal>: Context not initialized");
  }

  string ctx = fhe->ContextGen(scheme::bfv, 2048, 18, -1, 128);

  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "success: valid");

  fhe->KeyGen();

  try {
    fhe->RelinKeyGen();
  } catch (const std::exception& e) {
    EXPECT_STREQ(e.what(), "keyswitching is not supported by the context");
  }
}

TEST(BGV_BFV, RelinKeyGen) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 4096, 0, 1024, 128);

    // Expect two strings not to be equal.
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->RelinKeyGen();
  }
}

TEST(BGV_BFV, Relinearize) {
  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    string ctx = fhe->ContextGen(scheme, 8192, 20, -1, 128);

    fhe->KeyGen();
    fhe->RelinKeyGen();

    AsealPlaintext pt_x = AsealPlaintext();

    /*
      Here we create the following arrays:
          x = [ 1,  2,  3,  4,  0,  0,  0,  0 ]
        add = [ 2,  4,  6,  8,  0,  0,  0,  0 ]
    */
    vector<uint64_t> x(8, 0ULL);
    x[0] = 1ULL;
    x[1] = 2ULL;
    x[2] = 3ULL;
    x[3] = 4ULL;

    fhe->encode_int(x, pt_x);

    AsealCiphertext ct_x = AsealCiphertext();
    fhe->encrypt(pt_x, ct_x);

    AsealPlaintext pt_add = AsealPlaintext();
    vector<uint64_t> add(8, 0ULL);
    add[0] = 2ULL;
    add[1] = 4ULL;
    add[2] = 6ULL;
    add[3] = 8ULL;

    fhe->encode_int(add, pt_add);
    AsealCiphertext ct_add = AsealCiphertext();
    fhe->encrypt(pt_add, ct_add);

    AsealPlaintext pt_res = AsealPlaintext();
    AsealCiphertext ct_res = AsealCiphertext();
    fhe->add(ct_x, ct_add, ct_res);

    int before_relin = fhe->invariant_noise_budget(ct_res);
    EXPECT_GT(before_relin, 0);

    // Relinearize to reduce noise.
    fhe->relinearize(ct_res);

    int after_relin = fhe->invariant_noise_budget(ct_res);

    // Noise budget should be reduced after relinearization.
    // For addition, it may not change. TODO: x^2
    EXPECT_GE(before_relin, after_relin);

    // Decryption can be incorrect when noise budget is zero.
    EXPECT_GT(after_relin, 0);

    AsealPlaintext decrypt_res = AsealPlaintext();
    fhe->decrypt(ct_res, decrypt_res);

    vector<uint64_t> decode_res;
    fhe->decode_int(decrypt_res, decode_res);

    // Plaintext x and decoded_x must be equal.
    vector<uint16_t> expect = {3, 6, 9, 12, 0, 0, 0, 0};
    for (int i = 0; i < x.size(); i++) {
      EXPECT_EQ(expect[i], decode_res[i]);
    }
  }
}
