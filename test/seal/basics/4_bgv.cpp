#include "basics.h"

TEST(BGV, Basics)
{
     /*
     As an example, we evaluate the degree 8 polynomial

          x^8

     over an encrypted x over integers 1, 2, 3, 4. The coefficients of the
     polynomial can be considered as plaintext inputs, as we will see below. The
     computation is done modulo the plain_modulus 1032193.

     Computing over encrypted data in the BGV scheme is similar to that in BFV.
     The purpose of this example is mainly to explain the differences between BFV
     and BGV in terms of ciphertext coefficient modulus selection and noise control.

     Most of the following code are repeated from "BFV basics" and "encoders" examples.
     */
     Aseal* fhe = new Aseal();

     /*
     Note that scheme_type is now "bgv".
     */
     size_t poly_modulus_degree = 8192;
     uint64_t plain_modulus_bit_size = 20; // Enables batching
     int security_level = 128;
     string ctx = fhe->ContextGen(scheme::bgv, poly_modulus_degree, plain_modulus_bit_size, 0, security_level);
     EXPECT_STREQ(ctx.c_str(), "success: valid");

     /*
     Print the parameters that we have chosen.
     */
     print_line(__LINE__);
     cout << "Set encryption parameters and print" << endl;
     // print_parameters(fhe->get_context());

     fhe->KeyGen();
     fhe->RelinKeyGen();

     /*
     Batching and slot operations are the same in BFV and BGV.
     */
     size_t slot_count = fhe->slot_count();
     size_t row_size = slot_count / 2;
     cout << "Plaintext matrix row size: " << row_size << endl;

     /*
     Here we create the following matrix:
          [ 1,  2,  3,  4,  0,  0, ...,  0 ]
          [ 0,  0,  0,  0,  0,  0, ...,  0 ]
     */
     vector<uint64_t> pod_matrix(slot_count, 0ULL);
     pod_matrix[0] = 1ULL;
     pod_matrix[1] = 2ULL;
     pod_matrix[2] = 3ULL;
     pod_matrix[3] = 4ULL;

     cout << "Input plaintext matrix:" << endl;
     print_matrix(pod_matrix, row_size);
     AsealPlaintext x_plain;
     cout << "Encode plaintext matrix to x_plain:" << endl;
     fhe->encode_int(pod_matrix, x_plain);

     /*
     Next we encrypt the encoded plaintext.
     */
     AsealCiphertext x_encrypted;
     print_line(__LINE__);
     cout << "Encrypt x_plain to x_encrypted." << endl;
     fhe->encrypt(x_plain, x_encrypted);
     cout << "    + noise budget in freshly encrypted x: " << fhe->invariant_noise_budget(x_encrypted) << " bits"
          << endl;
     cout << endl;

     /*
     Then we compute x^2.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_squared (x^2)," << endl;
     AsealCiphertext x_squared;
     fhe->multiply(x_encrypted, x_encrypted, x_squared); // TODO: pow()
     cout << "    + size of x_squared: " << x_squared.size() << endl;
     fhe->relinearize(x_squared);
     cout << "    + size of x_squared (after relinearization): " << x_squared.size() << endl;
     cout << "    + noise budget in x_squared: " << fhe->invariant_noise_budget(x_squared) << " bits" << endl;

     AsealPlaintext decrypted_result;
     fhe->decrypt(x_squared, decrypted_result);
     vector<uint64_t> pod_result;
     fhe->decode_int(decrypted_result, pod_result);

     vector<uint64_t> expected(slot_count, 0ULL);
     expected[0] = 1ULL;
     expected[1] = 4ULL;
     expected[2] = 9ULL;
     expected[3] = 16ULL;
     print_matrix(pod_result, row_size);
     expect_equal_vector(pod_result, expected);
     cout << "    + result plaintext matrix ...... Correct." << endl;

     /*
     Next we compute x^4.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_4th (x^4)," << endl;
     AsealCiphertext x_4th;
     fhe->multiply(x_squared, x_squared, x_4th);
     cout << "    + size of x_4th: " << x_4th.size() << endl;
     fhe->relinearize(x_4th);
     cout << "    + size of x_4th (after relinearization): " << x_4th.size() << endl;
     cout << "    + noise budget in x_4th: " << fhe->invariant_noise_budget(x_4th) << " bits" << endl;
     fhe->decrypt(x_4th, decrypted_result);
     fhe->decode_int(decrypted_result, pod_result);
     print_matrix(pod_result, row_size);
     expected[0] = 1ULL;
     expected[1] = 16ULL;
     expected[2] = 81ULL;
     expected[3] = 256ULL;
     expect_equal_vector(pod_result, expected);
     cout << "    + result plaintext matrix ...... Correct." << endl;

     /*
     Last we compute x^8. We run out of noise budget.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_8th (x^8)," << endl;
     AsealCiphertext x_8th;
     fhe->multiply(x_4th, x_4th, x_8th);
     cout << "    + size of x_8th: " << x_8th.size() << endl;
     fhe->relinearize(x_8th);
     cout << "    + size of x_8th (after relinearization): " << x_8th.size() << endl;
     cout << "    + noise budget in x_8th: " << fhe->invariant_noise_budget(x_8th) << " bits" << endl;
     cout << "NOTE: Decryption can be incorrect if noise budget is zero." << endl;

     cout << endl;
     cout << "~~~~~~ Use modulus switching to calculate x^8 ~~~~~~" << endl;

     /*
     Noise budget has reached 0, which means that decryption cannot be expected
     to give the correct result. BGV requires modulus switching to reduce noise
     growth. In the following demonstration, we will insert a modulus switching
     after each relinearization.
     */
     print_line(__LINE__);
     cout << "Encrypt x_plain to x_encrypted." << endl;
     fhe->encrypt(x_plain, x_encrypted);
     cout << "    + noise budget in freshly encrypted x: " << fhe->invariant_noise_budget(x_encrypted) << " bits"
          << endl;
     cout << endl;

     /*
     Then we compute x^2.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_squared (x^2)," << endl;
     cout << "    + noise budget in x_squared (previously): " << fhe->invariant_noise_budget(x_squared) << " bits"
          << endl;
     fhe->multiply(x_encrypted, x_encrypted, x_squared);
     fhe->relinearize(x_squared);
     fhe->mod_switch_to_next(x_squared);
     cout << "    + noise budget in x_squared (with modulus switching): " << fhe->invariant_noise_budget(x_squared)
          << " bits" << endl;
     fhe->decrypt(x_squared, decrypted_result);
     fhe->decode_int(decrypted_result, pod_result);
     print_matrix(pod_result, row_size);
     expected[0] = 1ULL;
     expected[1] = 4ULL;
     expected[2] = 9ULL;
     expected[3] = 16ULL;
     expect_equal_vector(pod_result, expected);
     cout << "    + result plaintext matrix ...... Correct." << endl;

     /*
     Next we compute x^4.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_4th (x^4)," << endl;
     cout << "    + noise budget in x_4th (previously): " << fhe->invariant_noise_budget(x_4th) << " bits" << endl;
     fhe->multiply(x_squared, x_squared, x_4th);
     fhe->relinearize(x_4th);
     fhe->mod_switch_to_next(x_4th);
     cout << "    + noise budget in x_4th (with modulus switching): " << fhe->invariant_noise_budget(x_4th)
          << " bits" << endl;
     fhe->decrypt(x_4th, decrypted_result);
     fhe->decode_int(decrypted_result, pod_result);
     print_matrix(pod_result, row_size);
     expected[0] = 1ULL;
     expected[1] = 16ULL;
     expected[2] = 81ULL;
     expected[3] = 256ULL;
     expect_equal_vector(pod_result, expected);
     cout << "    + result plaintext matrix ...... Correct." << endl;

     /*
     Last we compute x^8. We still have budget left.
     */
     print_line(__LINE__);
     cout << "Compute and relinearize x_8th (x^8)," << endl;
     cout << "    + noise budget in x_8th (previously): " << fhe->invariant_noise_budget(x_8th) << " bits" << endl;
     fhe->multiply(x_4th, x_4th, x_8th);
     fhe->relinearize(x_8th);
     fhe->mod_switch_to_next(x_8th);
     cout << "    + noise budget in x_8th (with modulus switching): " << fhe->invariant_noise_budget(x_8th)
          << " bits" << endl;
     fhe->decrypt(x_8th, decrypted_result);
     fhe->decode_int(decrypted_result, pod_result);
     print_matrix(pod_result, row_size);
     expected[0] = 1ULL;
     expected[1] = 256ULL;
     expected[2] = 6561ULL;
     expected[3] = 65536ULL;
     expect_equal_vector(pod_result, expected);
     cout << "    + result plaintext matrix ...... Correct." << endl;

     /*
     Although with modulus switching x_squared has less noise budget than before,
     noise budget is consumed at a slower rate. To achieve the optimal consumption
     rate of noise budget in an application, one needs to carefully choose the
     location to insert modulus switching and manually choose coeff_modulus.
     */
}
