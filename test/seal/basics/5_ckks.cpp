#include "basics.h"

TEST(CKKS, Basics)
{
    /*
    In this example we demonstrate evaluating a polynomial function

        PI*x^3 + 0.4*x + 1

    on encrypted floating-point input data x for a set of 4096 equidistant points
    in the interval [0, 1]. This example demonstrates many of the main features
    of the CKKS scheme, but also the challenges in using it.
    */
    Aseal* fhe = new Aseal();

    /*
    We saw in `2_encoders.cpp' that multiplication in CKKS causes scales
    in ciphertexts to grow. The scale of any ciphertext must not get too close
    to the total size of coeff_modulus, or else the ciphertext simply runs out of
    room to store the scaled-up plaintext. The CKKS scheme provides a `rescale'
    functionality that can reduce the scale, and stabilize the scale expansion.

    Rescaling is a kind of modulus switch operation (recall `3_levels.cpp').
    As modulus switching, it removes the last of the primes from coeff_modulus,
    but as a side-effect it scales down the ciphertext by the removed prime.
    Usually we want to have perfect control over how the scales are changed,
    which is why for the CKKS scheme it is more common to use carefully selected
    primes for the coeff_modulus.

    More precisely, suppose that the scale in a CKKS ciphertext is S, and the
    last prime in the current coeff_modulus (for the ciphertext) is P. Rescaling
    to the next level changes the scale to S/P, and removes the prime P from the
    coeff_modulus, as usual in modulus switching. The number of primes limits
    how many rescalings can be done, and thus limits the multiplicative depth of
    the computation.

    It is possible to choose the initial scale freely. One good strategy can be
    to is to set the initial scale S and primes P_i in the coeff_modulus to be
    very close to each other. If ciphertexts have scale S before multiplication,
    they have scale S^2 after multiplication, and S^2/P_i after rescaling. If all
    P_i are close to S, then S^2/P_i is close to S again. This way we stabilize the
    scales to be close to S throughout the computation. Generally, for a circuit
    of depth D, we need to rescale D times, i.e., we need to be able to remove D
    primes from the coefficient modulus. Once we have only one prime left in the
    coeff_modulus, the remaining prime must be larger than S by a few bits to
    preserve the pre-decimal-point value of the plaintext.

    Therefore, a generally good strategy is to choose parameters for the CKKS
    scheme as follows:

        (1) Choose a 60-bit prime as the first prime in coeff_modulus. This will
            give the highest precision when decrypting;
        (2) Choose another 60-bit prime as the last element of coeff_modulus, as
            this will be used as the special prime and should be as large as the
            largest of the other primes;
        (3) Choose the intermediate primes to be close to each other.

    We use CoeffModulus::Create to generate primes of the appropriate size. Note
    that our coeff_modulus is 200 bits total, which is below the bound for our
    poly_modulus_degree: CoeffModulus::MaxBitCount(8192) returns 218.

    We choose the initial scale to be 2^40. At the last level, this leaves us
    60-40=20 bits of precision before the decimal point, and enough (roughly
    10-20 bits) of precision after the decimal point. Since our intermediate
    primes are 40 bits (in fact, they are very close to 2^40), we can achieve
    scale stabilization as described above.
    */
    vector<int> primes = { 60, 40, 40, 60 };
    double scale = pow(2.0, 40); // 2^40
    size_t poly_modulus_degree = 8192;
    string ctx = fhe->ContextGen(scheme::ckks, poly_modulus_degree, scale, -1, -1, primes);
    EXPECT_STREQ(ctx.c_str(), "success: valid");
    print_parameters(fhe->get_context());

    fhe->KeyGen();
    fhe->RelinKeyGen();

    size_t slot_count = fhe->slot_count();
    cout << "Number of slots: " << slot_count << endl;

    vector<double> input;
    input.reserve(slot_count);
    double curr_point = 0;
    double step_size = 1.0 / (static_cast<double>(slot_count) - 1);
    for (size_t i = 0; i < slot_count; i++)
    {
        input.push_back(curr_point);
        curr_point += step_size;
    }
    print_vector(input, 5, 7);
    print_line(__LINE__);
    cout << "Evaluating polynomial PI*x^3 + 0.4x + 1 ..." << endl;

    /*
    We create plaintexts for PI, 0.4, and 1 using an overload of CKKSEncoder::encode
    that encodes the given floating-point value to every slot in the vector.
    */
    AsealPlaintext plain_coeff3, plain_coeff1, plain_coeff0;
    fhe->encode_double(3.14159265, plain_coeff3);
    fhe->encode_double(0.4, plain_coeff1);
    fhe->encode_double(1.0, plain_coeff0);

    AsealPlaintext x_plain;
    fhe->encode_double(input, x_plain);
    AsealCiphertext x1_encrypted;
    fhe->encrypt(x_plain, x1_encrypted);

    /*
    To compute x^3 we first compute x^2 and relinearize. However, the scale has
    now grown to 2^80.
    */
    print_line(__LINE__);
    AsealCiphertext x2_encrypted;
    cout << "Compute x^2 and relinearize:" << endl;
    fhe->multiply(x1_encrypted, x1_encrypted, x2_encrypted);
    fhe->relinearize(x2_encrypted);
    cout << "    + Scale of x^2 before rescale: " << log2(x2_encrypted.scale()) << " bits" << endl;

    /*
    Now rescale; in addition to a modulus switch, the scale is reduced down by
    a factor equal to the prime that was switched away (40-bit prime). Hence, the
    new scale should be close to 2^40. Note, however, that the scale is not equal
    to 2^40: this is because the 40-bit prime is only close to 2^40.
    */
    print_line(__LINE__);
    cout << "Rescale x^2." << endl;
    fhe->rescale_to_next(x2_encrypted);
    cout << "    + Scale of x^2 after rescale: " << log2(x2_encrypted.scale()) << " bits" << endl;

    /*
    Now x2_encrypted is at a different level than x1_encrypted, which prevents us
    from multiplying them to compute x^3. We could simply switch x1_encrypted to
    the next parameters in the modulus switching chain. However, since we still
    need to multiply the x^3 term with PI (plain_coeff3), we instead compute PI*x
    first and multiply that with x^2 to obtain PI*x^3. To this end, we compute
    PI*x and rescale it back from scale 2^80 to something close to 2^40.
    */
    print_line(__LINE__);
    cout << "Compute and rescale PI*x." << endl;
    AsealCiphertext x1_encrypted_coeff3;
    fhe->multiply(x1_encrypted, plain_coeff3, x1_encrypted_coeff3);
    cout << "    + Scale of PI*x before rescale: " << log2(x1_encrypted_coeff3.scale()) << " bits" << endl;
    fhe->rescale_to_next(x1_encrypted_coeff3);
    cout << "    + Scale of PI*x after rescale: " << log2(x1_encrypted_coeff3.scale()) << " bits" << endl;

    /*
    Since x2_encrypted and x1_encrypted_coeff3 have the same exact scale and use
    the same encryption parameters, we can multiply them together. We write the
    result to pi_x3_encrypted, relinearize, and rescale. Note that again the scale
    is something close to 2^40, but not exactly 2^40 due to yet another scaling
    by a prime. We are down to the last level in the modulus switching chain.
    */
    print_line(__LINE__);
    cout << "Compute, relinearize, and rescale (PI*x)*x^2." << endl;
    AsealCiphertext x3_encrypted_coeff3;
    fhe->multiply(x2_encrypted, x1_encrypted_coeff3, x3_encrypted_coeff3);
    fhe->relinearize(x3_encrypted_coeff3);
    cout << "    + Scale of PI*x^3 before rescale: " << log2(x3_encrypted_coeff3.scale()) << " bits" << endl;
    fhe->rescale_to_next(x3_encrypted_coeff3);
    cout << "    + Scale of PI*x^3 after rescale: " << log2(x3_encrypted_coeff3.scale()) << " bits" << endl;

    /*
    Next we compute the degree one term. All this requires is one multiply_plain
    with plain_coeff1. We overwrite x1_encrypted with the result.
    */
    print_line(__LINE__);
    cout << "Compute and rescale 0.4*x." << endl;
    AsealCiphertext x1_encrypted_coeff1;
    fhe->multiply(x1_encrypted, plain_coeff1, x1_encrypted_coeff1);
    cout << "    + Scale of 0.4*x before rescale: " << log2(x1_encrypted_coeff1.scale()) << " bits" << endl;
    fhe->rescale_to_next(x1_encrypted_coeff1);
    cout << "    + Scale of 0.4*x after rescale: " << log2(x1_encrypted_coeff1.scale()) << " bits" << endl
         << endl;

    /*
    Now we would hope to compute the sum of all three terms. However, there is
    a serious problem: the encryption parameters used by all three terms are
    different due to modulus switching from rescaling.

    Encrypted addition and subtraction require that the scales of the inputs are
    the same, and also that the encryption parameters (parms_id) match. If there
    is a mismatch, Evaluator will throw an exception.
    */
    print_line(__LINE__);
    cout << "Parameters used by all three terms are different." << endl;
    cout << "    + Modulus chain index for x3_encrypted_coeff3: "
         << fhe->get_context()->get_context_data(x3_encrypted_coeff3.parms_id())->chain_index() << endl;
    cout << "    + Modulus chain index for x1_encrypted_coeff1: "
         << fhe->get_context()->get_context_data(x1_encrypted_coeff1.parms_id())->chain_index() << endl;
    cout << "    + Modulus chain index for plain_coeff0: "
         << fhe->get_context()->get_context_data(plain_coeff0.parms_id())->chain_index() << endl;
    cout << endl;

    /*
    Let us carefully consider what the scales are at this point. We denote the
    primes in coeff_modulus as P_0, P_1, P_2, P_3, in this order. P_3 is used as
    the special modulus and is not involved in rescalings. After the computations
    above the scales in ciphertexts are:

        - Product x^2 has scale 2^80 and is at level 2;
        - Product PI*x has scale 2^80 and is at level 2;
        - We rescaled both down to scale 2^80/P_2 and level 1;
        - Product PI*x^3 has scale (2^80/P_2)^2;
        - We rescaled it down to scale (2^80/P_2)^2/P_1 and level 0;
        - Product 0.4*x has scale 2^80;
        - We rescaled it down to scale 2^80/P_2 and level 1;
        - The contant term 1 has scale 2^40 and is at level 2.

    Although the scales of all three terms are approximately 2^40, their exact
    values are different, hence they cannot be added together.
    */
    print_line(__LINE__);
    cout << "The exact scales of all three terms are different:" << endl;
    ios old_fmt(nullptr);
    old_fmt.copyfmt(cout);
    cout << fixed << setprecision(10);
    cout << "    + Exact scale in PI*x^3: " << x3_encrypted_coeff3.scale() << endl;
    cout << "    + Exact scale in  0.4*x: " << x1_encrypted_coeff1.scale() << endl;
    cout << "    + Exact scale in      1: " << plain_coeff0.scale() << endl;
    cout << endl;
    cout.copyfmt(old_fmt);

    /*
    There are many ways to fix this problem. Since P_2 and P_1 are really close
    to 2^40, we can simply "lie" to Microsoft SEAL and set the scales to be the
    same. For example, changing the scale of PI*x^3 to 2^40 simply means that we
    scale the value of PI*x^3 by 2^120/(P_2^2*P_1), which is very close to 1.
    This should not result in any noticeable error.

    Another option would be to encode 1 with scale 2^80/P_2, do a multiply_plain
    with 0.4*x, and finally rescale. In this case we would need to additionally
    make sure to encode 1 with appropriate encryption parameters (parms_id).

    In this example we will use the first (simplest) approach and simply change
    the scale of PI*x^3 and 0.4*x to 2^40.
    */
    cout << "Normalize scales to 2^40." << endl;
    x3_encrypted_coeff3.set_scale(pow(2.0, 40));
    x1_encrypted_coeff1.set_scale(pow(2.0, 40));

    /*
    We still have a problem with mismatching encryption parameters. This is easy
    to fix by using traditional modulus switching (no rescaling). CKKS supports
    modulus switching just like the BFV scheme, allowing us to switch away parts
    of the coefficient modulus when it is simply not needed.
    */
    cout << "Normalize encryption parameters to the lowest level." << endl;
    fhe->mod_switch_to(x1_encrypted_coeff1, x3_encrypted_coeff3);
    fhe->mod_switch_to(plain_coeff0, x3_encrypted_coeff3);

    /*
    All three ciphertexts are now compatible and can be added.
    */
    AsealCiphertext add_ct;
    AsealCiphertext add_one;
    fhe->add(x3_encrypted_coeff3, x1_encrypted_coeff1, add_ct);
    fhe->add(add_ct, plain_coeff0, add_one);

    /*
    First print the true result.
    */
    AsealPlaintext plain_result;
    cout << "Decrypt and decode PI*x^3 + 0.4x + 1." << endl;
    vector<double> true_result;
    for (size_t i = 0; i < input.size(); i++)
    {
        double x = input[i];
        true_result.push_back((3.14159265 * x * x + 0.4) * x + 1);
    }

    /*
    Decrypt, decode, and print the result.
    */
    fhe->decrypt(add_one, plain_result);
    vector<double> result;
    fhe->decode_double(plain_result, result);
    print_vector(result, 5, 7);
    expect_equal_vector(result, true_result, 0.00001);
    cout << "    + Result of PI*x^3 + 0.4x + 1 ...... Correct." << endl;
    /*
    While we did not show any computations on complex numbers in these examples,
    the CKKSEncoder would allow us to have done that just as easily. Additions
    and multiplications of complex numbers behave just as one would expect.
    */
}
