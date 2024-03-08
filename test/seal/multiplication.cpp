#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

// Encrypt a plaintext.
AsealCiphertext encrypt(Aseal* fhe, AsealPlaintext pt) {
  AsealCiphertext ct = AsealCiphertext();
  fhe->encrypt(pt, ct);
  return ct;
}

// Decrypt a ciphertext.
AsealPlaintext decrypt(Aseal* fhe, AsealCiphertext ct) {
  AsealPlaintext pt = AsealPlaintext();
  fhe->decrypt(ct, pt);
  return pt;
}

// Multiply two ciphertexts.
AsealCiphertext multiply(Aseal* fhe, AsealCiphertext ct_x, AsealCiphertext ct_y) {
  AsealCiphertext ct_res = AsealCiphertext();
  fhe->multiply(ct_x, ct_y, ct_res);
  // Decryption can be incorrect when noise budget is zero.
  EXPECT_GT(fhe->invariant_noise_budget(ct_res), 0);
  // When multiplying two ciphertexts, the size grows to 3.
  EXPECT_EQ(ct_res.size(), 3);
  return ct_res;
}

// Multiply a ciphertext by a plaintext.
AsealCiphertext multiply(Aseal* fhe, AsealCiphertext ct_x, AsealPlaintext pt_y) {
  AsealCiphertext ct_res = AsealCiphertext();
  fhe->multiply(ct_x, pt_y, ct_res);
  // Decryption can be incorrect when noise budget is zero.
  EXPECT_GT(fhe->invariant_noise_budget(ct_res), 0);
  // When multiplying cipher x plain, the size should not grow.
  EXPECT_EQ(ct_res.size(), 2);
  return ct_res;
}

TEST(Multiply, IntegersToHexadecimal) {
  std::map<int, int> plaintextToModulus = {
    {10, 1024},
    {50, 4196}, // 2048 - invariant_noise_budget is zero
    {100, 16784},
  };

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {

    for (const auto& pair : plaintextToModulus) {
      int plaintext = pair.first;
      int modulus = pair.second;

      Aseal* fhe = new Aseal();

      // poly_mod_degree = 4096, => max coeff_modulus bit-length = 109
      string ctx = fhe->ContextGen(scheme, 4096, 0, modulus, 128);
      EXPECT_STREQ(ctx.c_str(), "success: valid");
      fhe->KeyGen();

      /**
       * @brief Without relinearization, limited to multiply Ciphertext by Plaintext
      */
      AsealPlaintext pt_x = AsealPlaintext(uint64_to_hex(plaintext));
      AsealCiphertext ct_x = encrypt(fhe, pt_x);
      AsealPlaintext pt_y = AsealPlaintext(uint64_to_hex(plaintext));

      // Ciphertext x Plaintext
      AsealCiphertext ct_x_pt_y = multiply(fhe, ct_x, pt_y);
      AsealPlaintext pt_no_relin = decrypt(fhe, ct_x_pt_y);

      int expect = plaintext * plaintext;
      EXPECT_EQ(hex_to_uint64(pt_no_relin.to_string()), expect);

      /**
       * @brief Using relinearization to reduce ciphertext size from 3 -> 2.
       * This occurs when multiplying Ciphertext x Ciphertext
      */
      fhe->RelinKeyGen();

      // Ciphertext x Ciphertext
      AsealCiphertext ct_y = encrypt(fhe, pt_y);
      AsealCiphertext ct_x_ct_y = multiply(fhe, ct_x, ct_y);
      // When multiplying two ciphertexts, the size grows to 3.
      fhe->relinearize(ct_x_ct_y);
      AsealPlaintext pt_relin = decrypt(fhe, ct_x_ct_y);

      int before_mod_switch = fhe->invariant_noise_budget(ct_x_ct_y);
      fhe->mod_switch_to_next(ct_x_ct_y);
      int after_mod_switch = fhe->invariant_noise_budget(ct_x_ct_y);
      EXPECT_LT(after_mod_switch, before_mod_switch);

      EXPECT_EQ(hex_to_uint64(pt_relin.to_string()), expect);
    }
  }
}

TEST(Multiply, VectorInteger) {

  Aseal* fhe = new Aseal();

  for (const auto& scheme : {scheme::bgv, scheme::bfv}) {
    string ctx = fhe->ContextGen(scheme, 8192, 20, -1, 128);
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    fhe->KeyGen();
    AsealPlaintext pt_x = AsealPlaintext();
    AsealPlaintext pt_m = AsealPlaintext();
    /*
      Here we create the following arrays:
          x = [ 1,  2,  3,  4,  0,  0,  0,  0 ]
          m = [ 2,  4,  6,  8,  0,  0,  0,  0 ]
    */
    vector<uint64_t> x(8, 0ULL);
    x[0] = 1ULL;
    x[1] = 2ULL;
    x[2] = 3ULL;
    x[3] = 4ULL;

    fhe->encode_int(x, pt_x);
    AsealCiphertext ct_x = encrypt(fhe, pt_x);

    vector<uint64_t> m(8, 0ULL);
    m[0] = 2ULL;
    m[1] = 4ULL;
    m[2] = 6ULL;
    m[3] = 8ULL;

    fhe->encode_int(m, pt_m);
    AsealCiphertext ct_m = encrypt(fhe, pt_m);

    /**
     * @brief Without relinearization, limited to multiply Ciphertext by Plaintext
    */
    AsealCiphertext ct_x_pt_m = multiply(fhe, ct_x, pt_m);
    AsealPlaintext pt_x_pt_m = decrypt(fhe, ct_x_pt_m);

    vector<uint64_t> vec_ct_x_pt_m;
    fhe->decode_int(pt_x_pt_m, vec_ct_x_pt_m);

    vector<uint16_t> expect = {2, 8, 18, 32, 0, 0, 0, 0};
    for (int i = 0; i < x.size(); i++) {
      EXPECT_EQ(expect[i], vec_ct_x_pt_m[i]);
    }

    /**
     * @brief Using relinearization to reduce ciphertext size from 3 -> 2.
    */
    fhe->RelinKeyGen();
    AsealCiphertext ct_x_ct_m = multiply(fhe, ct_x, ct_m);
    fhe->relinearize(ct_x_ct_m);

    int before_mod_switch = fhe->invariant_noise_budget(ct_x_ct_m);
    fhe->mod_switch_to_next(ct_x_ct_m);
    int after_mod_switch = fhe->invariant_noise_budget(ct_x_ct_m);
    EXPECT_LT(after_mod_switch, before_mod_switch);

    AsealPlaintext pt_x_ct_m = decrypt(fhe, ct_x_ct_m);

    vector<uint64_t> vec_ct_x_ct_m;
    fhe->decode_int(pt_x_ct_m, vec_ct_x_ct_m);

    for (int i = 0; i < x.size(); i++) {
      EXPECT_EQ(expect[i], vec_ct_x_ct_m[i]);
    }
  }
}

TEST(Multiply, VectorDouble) {

  Aseal* fhe = new Aseal();

  string ctx = fhe->ContextGen(scheme::ckks, 8192, pow(2.0, 40), -1, -1, {60, 40, 40, 60});

  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "success: valid");

  fhe->KeyGen();
  fhe->RelinKeyGen();

  size_t slot_count = fhe->slot_count();

  /**
   * Create an input vector with floating point values 0 ... 1.
  */
  vector<double> x;
  x.reserve(slot_count);
  double curr_point = 0;
  double step_size = 1.0 / (static_cast<double>(slot_count) - 1);
  for (size_t i = 0; i < slot_count; i++)
  {
      x.push_back(curr_point);
      curr_point += step_size;
  }
  // cout << "X vector: " << endl;
  // for (size_t i = 0; i < slot_count; i++)
  // {
  //     cout << x[i] << " ";
  // }

  AsealPlaintext pt_x = AsealPlaintext();

  fhe->encode_double(x, pt_x);

  AsealCiphertext ct_x = AsealCiphertext();

  fhe->encrypt(pt_x, ct_x);

  /**
   * Create an addend vector with floating point values 0 ... 1.
  */
  vector<double> m;
  m.reserve(slot_count);
  curr_point = 0;
  step_size = 1.0 / (static_cast<double>(slot_count) - 1);
  for (size_t i = 0; i < slot_count; i++)
  {
      m.push_back(curr_point);
      curr_point += step_size;
  }
  // cout << "Add vector: " << endl;
  // for (size_t i = 0; i < slot_count; i++)
  // {
  //     cout << add[i] << " ";
  // }
  AsealPlaintext pt_m = AsealPlaintext();
  fhe->encode_double(m, pt_m);
  AsealCiphertext ct_m = AsealCiphertext();
  fhe->encrypt(pt_m, ct_m);

  AsealCiphertext ct_res = AsealCiphertext();

  fhe->multiply(ct_x, ct_m, ct_res);
  fhe->relinearize(ct_res);

  AsealPlaintext decrypt_res = AsealPlaintext();
  fhe->decrypt(ct_res, decrypt_res);

  vector<double> decode_res;
  fhe->decode_double(decrypt_res, decode_res);

  for (int i = 0; i < x.size(); i++) {
    double expect = x[i] * m[i];
    // Compare up to 7 decimal places.
    EXPECT_NEAR(expect, decode_res[i], 0.0000001);
  }

  // Without relinearization
  AsealCiphertext ct_res_no_relin = AsealCiphertext();
  fhe->multiply(ct_x, pt_m, ct_res_no_relin);

  AsealPlaintext decrypt_res_no_relin = AsealPlaintext();
  fhe->decrypt(ct_res_no_relin, decrypt_res_no_relin);
  vector<double> decode_res_no_relin;
  fhe->decode_double(decrypt_res_no_relin, decode_res_no_relin);

  for (int i = 0; i < x.size(); i++) {
    double expect = x[i] * m[i];
    // Compare up to 7 decimal places.
    EXPECT_NEAR(expect, decode_res_no_relin[i], 0.0000001);
  }
}

TEST(Multiply, PiXSquared) {
  // π * x^2
  Aseal* fhe = new Aseal();
  string ctx = fhe->ContextGen(scheme::ckks, 8192, pow(2.0, 40), -1, -1, {60, 40, 40, 60});
  // Expect two strings not to be equal.
  EXPECT_STREQ(ctx.c_str(), "success: valid");

  fhe->KeyGen();
  fhe->RelinKeyGen();

  AsealPlaintext pi_coeff;
  double pi = 3.14159265;
  fhe->encode_double(pi, pi_coeff);

  size_t slot_count = fhe->slot_count();

  /**
   * Create an input vector (x) with floating point values 0 ... 1.
  */
  vector<double> x;
  x.reserve(slot_count);
  double curr_point = 0;
  double step_size = 1.0 / (static_cast<double>(slot_count) - 1);
  for (size_t i = 0; i < slot_count; i++)
  {
      x.push_back(curr_point);
      curr_point += step_size;
  }
  AsealPlaintext pt_x = AsealPlaintext();
  fhe->encode_double(x, pt_x);

  AsealCiphertext ct_x = AsealCiphertext();
  AsealCiphertext ct_squared = AsealCiphertext();
  AsealCiphertext ct_pi_squared = AsealCiphertext();

  // x^2
  fhe->encrypt(pt_x, ct_x);
  fhe->square(ct_x, ct_squared);
  fhe->relinearize(ct_squared);

  // π * x^2
  fhe->multiply(ct_squared, pi_coeff, ct_pi_squared);

  // AsealPlaintext decrypt_res = AsealPlaintext();
  AsealPlaintext decrypt_res = decrypt(fhe, ct_pi_squared);
  fhe->decrypt(ct_pi_squared, decrypt_res);

  vector<double> decode_res;
  fhe->decode_double(decrypt_res, decode_res);

  for (int i = 0; i < x.size(); i++) {
    double expect = pi * x[i] * x[i];
    // Compare up to 7 decimal places.
    EXPECT_NEAR(expect, decode_res[i], 0.0000001);
  }
}
