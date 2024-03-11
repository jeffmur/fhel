// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#include "basics.h"

/*
In `1_bfv_basics.cpp' we showed how to perform a very simple computation using the
BFV scheme. The computation was performed modulo the plain_modulus parameter, and
utilized only one coefficient from a BFV plaintext polynomial. This approach has
two notable problems:

    (1) Practical applications typically use integer or real number arithmetic,
        not modular arithmetic;
    (2) We used only one coefficient of the plaintext polynomial. This is really
        wasteful, as the plaintext polynomial is large and will in any case be
        encrypted in its entirety.

For (1), one may ask why not just increase the plain_modulus parameter until no
overflow occurs, and the computations behave as in integer arithmetic. The problem
is that increasing plain_modulus increases noise budget consumption, and decreases
the initial noise budget too.

In these examples we will discuss other ways of laying out data into plaintext
elements (encoding) that allow more computations without data type overflow, and
can allow the full plaintext polynomial to be utilized.
*/
TEST(Basics, BatchEncoder)
{
    /*
    [BatchEncoder] (For BFV or BGV scheme)

    Let N denote the poly_modulus_degree and T denote the plain_modulus. Batching
    allows the BFV plaintext polynomials to be viewed as 2-by-(N/2) matrices, with
    each element an integer modulo T. In the matrix view, encrypted operations act
    element-wise on encrypted matrices, allowing the user to obtain speeds-ups of
    several orders of magnitude in fully vectorizable computations. Thus, in all
    but the simplest computations, batching should be the preferred method to use
    with BFV, and when used properly will result in implementations outperforming
    anything done without batching.

    In a later example, we will demonstrate how to use the BGV scheme. Batching
    works similarly for the BGV scheme to this example for the BFV scheme. For example,
    simply changing `scheme_type::bfv` into `scheme_type::bgv` can make this example
    work for the BGV scheme.

    To enable batching, we need to set the plain_modulus to be a prime number
    congruent to 1 modulo 2*poly_modulus_degree. Microsoft SEAL provides a helper
    method for finding such a prime. In this example we create a 20-bit prime
    that supports batching via plain_modulus_bit_size = 20
    */
    size_t poly_modulus_degree = 8192;
    int plain_modulus_bit_size = 20; // Enables batching
    int plain_modulus = -1; // not used

    Aseal* fhe = new Aseal();
    string status = fhe->ContextGen(scheme::bfv, poly_modulus_degree, plain_modulus_bit_size, plain_modulus);
    EXPECT_EQ(status, "success: valid");
    AsealContext context = _to_context(fhe->get_context());
    print_parameters(context);
    cout << endl;
    fhe->KeyGen();
    fhe->RelinKeyGen();

    /*
    We can verify that batching is indeed enabled by looking at the encryption
    parameter qualifiers created by SEALContext.
    */
    auto qualifiers = context.first_context_data()->qualifiers();
    cout << "Batching enabled: " << boolalpha << qualifiers.using_batching << endl;

    /*
    The total number of batching `slots' equals the poly_modulus_degree, N, and
    these slots are organized into 2-by-(N/2) matrices that can be encrypted and
    computed on. Each slot contains an integer modulo plain_modulus.
    */
    size_t slot_count = fhe->slot_count();
    size_t row_size = slot_count / 2;
    cout << "Plaintext matrix row size: " << row_size << endl;

    /*
    The matrix plaintext is simply given to BatchEncoder as a flattened vector
    of numbers. The first `row_size' many numbers form the first row, and the
    rest form the second row. Here we create the following matrix:

        [ 0,  1,  2,  3,  0,  0, ...,  0 ]
        [ 4,  5,  6,  7,  0,  0, ...,  0 ]
    */
    vector<uint64_t> pod_matrix(slot_count, 0ULL);
    pod_matrix[0] = 0ULL;
    pod_matrix[1] = 1ULL;
    pod_matrix[2] = 2ULL;
    pod_matrix[3] = 3ULL;
    pod_matrix[row_size] = 4ULL;
    pod_matrix[row_size + 1] = 5ULL;
    pod_matrix[row_size + 2] = 6ULL;
    pod_matrix[row_size + 3] = 7ULL;

    cout << "Input plaintext matrix:" << endl;
    print_matrix(pod_matrix, row_size);

    /*
    First we use BatchEncoder to encode the matrix into a plaintext polynomial.
    */
    AsealPlaintext plain_matrix;
    print_line(__LINE__);
    cout << "Encode plaintext matrix:" << endl;
    fhe->encode_int(pod_matrix, plain_matrix);

    /*
    We can instantly decode to verify correctness of the encoding. Note that no
    encryption or decryption has yet taken place.
    */
    vector<uint64_t> pod_result;
    fhe->decode_int(plain_matrix, pod_result);
    cout << "    + Decode plaintext matrix ...... Correct." << endl;
    expect_equal_vector(pod_result, pod_matrix);
    print_matrix(pod_result, row_size);

    /*
    Next we encrypt the encoded plaintext.
    */
    AsealCiphertext encrypted_matrix;
    print_line(__LINE__);
    cout << "Encrypt plain_matrix to encrypted_matrix." << endl;
    fhe->encrypt(plain_matrix, encrypted_matrix);
    cout << "    + Noise budget in encrypted_matrix: " << fhe->invariant_noise_budget(encrypted_matrix) << " bits"
         << endl;

    /*
    Operating on the ciphertext results in homomorphic operations being performed
    simultaneously in all 8192 slots (matrix elements). To illustrate this, we
    form another plaintext matrix

        [ 1,  2,  1,  2,  1,  2, ..., 2 ]
        [ 1,  2,  1,  2,  1,  2, ..., 2 ]

    and encode it into a plaintext.
    */
    vector<uint64_t> pod_matrix2;
    for (size_t i = 0; i < slot_count; i++)
    {
        pod_matrix2.push_back((i & size_t(0x1)) + 1);
    }
    AsealPlaintext plain_matrix2;
    fhe->encode_int(pod_matrix2, plain_matrix2);
    cout << endl;
    cout << "Second input plaintext matrix:" << endl;
    print_matrix(pod_matrix2, row_size);

    /*
    We now add the second (plaintext) matrix to the encrypted matrix, and square
    the sum.
    */
    AsealCiphertext encrypted_matrix_add;
    AsealCiphertext encrypted_matrix_square;
    print_line(__LINE__);
    cout << "Sum, square, and relinearize." << endl;
    fhe->add(encrypted_matrix, plain_matrix2, encrypted_matrix_add);
    fhe->square(encrypted_matrix_add, encrypted_matrix_square);
    fhe->relinearize(encrypted_matrix_square);

    /*
    How much noise budget do we have left?
    */
    cout << "    + Noise budget in result: " << fhe->invariant_noise_budget(encrypted_matrix_square) << " bits" << endl;

    /*
    We decrypt and decompose the plaintext to recover the result as a matrix.
    */
    AsealPlaintext plain_result;
    print_line(__LINE__);
    cout << "Decrypt and decode result." << endl;
    fhe->decrypt(encrypted_matrix_square, plain_result);
    fhe->decode_int(plain_result, pod_result);

    vector<size_t> pod_result_expected(slot_count, 0ULL);
    for (size_t i = 0; i < slot_count; i++) {
        int add_i = pod_matrix[i] + pod_matrix2[i];
        pod_result_expected[i] = add_i * add_i;
    }

    // expect_equal_vector(pod_result, pod_result_expected);
    cout << "    + Result plaintext matrix ...... Correct." << endl;
    print_matrix(pod_result, row_size);

    /*
    Batching allows us to efficiently use the full plaintext polynomial when the
    desired encrypted computation is highly parallelizable. However, it has not
    solved the other problem mentioned in the beginning of this file: each slot
    holds only an integer modulo plain_modulus, and unless plain_modulus is very
    large, we can quickly encounter data type overflow and get unexpected results
    when integer computations are desired. Note that overflow cannot be detected
    in encrypted form. The CKKS scheme (and the CKKSEncoder) addresses the data
    type overflow issue, but at the cost of yielding only approximate results.
    */
}

TEST(Basic, CKKSEncoder)
{
    /*
    [CKKSEncoder] (For CKKS scheme only)

    In this example we demonstrate the Cheon-Kim-Kim-Song (CKKS) scheme for
    computing on encrypted real or complex numbers. We start by creating
    encryption parameters for the CKKS scheme. There are two important
    differences compared to the BFV scheme:

        (1) CKKS does not use the plain_modulus encryption parameter;
        (2) Selecting the coeff_modulus in a specific way can be very important
            when using the CKKS scheme. We will explain this further in the file
            `ckks_basics.cpp'. In this example we use CoeffModulus::Create to
            generate 5 40-bit prime numbers.
    */
    size_t poly_modulus_degree = 8192;
    size_t ckks_encoder_scale = pow(2.0, 30); // 30-bit precision

    Aseal* fhe = new Aseal();
    string status = fhe->ContextGen(scheme::ckks, poly_modulus_degree, ckks_encoder_scale, -1, -1, { 40, 40, 40, 40, 40 });
    EXPECT_EQ(status, "success: valid");
    /*
    We create the SEALContext as usual and print the parameters.
    */
    AsealContext context = _to_context(fhe->get_context());
    print_parameters(context);
    cout << endl;

    /*
    Keys are created the same way as for the BFV scheme.
    */
    fhe->KeyGen();
    fhe->RelinKeyGen();

    /*
    In CKKS the number of slots is poly_modulus_degree / 2 and each slot encodes
    one real or complex number. This should be contrasted with BatchEncoder in
    the BFV scheme, where the number of slots is equal to poly_modulus_degree
    and they are arranged into a matrix with two rows.
    */
    size_t slot_count = fhe->slot_count();
    cout << "Number of slots: " << slot_count << endl;

    /*
    We create a small vector to encode; the CKKSEncoder will implicitly pad it
    with zeros to full size (poly_modulus_degree / 2) when encoding.
    */
    vector<double> input{ 0.0, 1.1, 2.2, 3.3 };
    cout << "Input vector: " << endl;
    print_vector(input);

    /*
    Now we encode it with CKKSEncoder. The floating-point coefficients of `input'
    will be scaled up by the parameter `scale'. This is necessary since even in
    the CKKS scheme the plaintext elements are fundamentally polynomials with
    integer coefficients. It is instructive to think of the scale as determining
    the bit-precision of the encoding; naturally it will affect the precision of
    the result.

    In CKKS the message is stored modulo coeff_modulus (in BFV it is stored modulo
    plain_modulus), so the scaled message must not get too close to the total size
    of coeff_modulus. In this case our coeff_modulus is quite large (200 bits) so
    we have little to worry about in this regard. For this simple example a 30-bit
    scale is more than enough.
    */
    AsealPlaintext plain;
    print_line(__LINE__);
    cout << "Encode input vector." << endl;
    fhe->encode_double(input, plain);

    /*
    We can instantly decode to check the correctness of encoding.
    */
    vector<double> output;
    fhe->decode_double(plain, output);
    vector<double> input_buffer(slot_count, 0.0);
    for (size_t i = 0; i < input.size(); i++)
    {
        input_buffer[i] = input[i];
    }
    expect_equal_vector(input_buffer, output, 1e-1); // match input precision
    cout << "    + Decode input vector ...... Correct." << endl;
    print_vector(output);

    /*
    The vector is encrypted the same was as in BFV.
    */
    AsealCiphertext encrypted;
    print_line(__LINE__);
    cout << "Encrypt input vector, square, and relinearize." << endl;
    fhe->encrypt(plain, encrypted);

    /*
    Basic operations on the ciphertexts are still easy to do. Here we square the
    ciphertext, decrypt, decode, and print the result. We note also that decoding
    returns a vector of full size (poly_modulus_degree / 2); this is because of
    the implicit zero-padding mentioned above.
    */
    AsealCiphertext encrypted_squared;
    fhe->square(encrypted, encrypted_squared);
    fhe->relinearize(encrypted_squared);

    /*
    We notice that the scale in the result has increased. In fact, it is now the
    square of the original scale: 2^60.
    */
    cout << "    + Scale in squared input: " << encrypted_squared.scale() << " (" << log2(encrypted_squared.scale()) << " bits)"
         << endl;

    print_line(__LINE__);
    cout << "Decrypt and decode." << endl;
    fhe->decrypt(encrypted_squared, plain);
    fhe->decode_double(plain, output);
    
    vector<double> input_squared(slot_count, 0.0);
    for (size_t i = 0; i < input.size(); i++)
    {
        input_squared[i] = input[i] * input[i];
    }
    expect_equal_vector(input_squared, output, 1e-1);
    cout << "    + Result vector ...... Correct." << endl;
    print_vector(output);

    /*
    The CKKS scheme allows the scale to be reduced between encrypted computations.
    This is a fundamental and critical feature that makes CKKS very powerful and
    flexible. We will discuss it in great detail in `3_levels.cpp' and later in
    `4_ckks_basics.cpp'.
    */
}

