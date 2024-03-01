#include "basics.h"

TEST(Basics, Levels)
{
    /*
    In this examples we describe the concept of `levels' in BFV and CKKS and the
    related objects that represent them in Microsoft SEAL.

    In Microsoft SEAL a set of encryption parameters (excluding the random number
    generator) is identified uniquely by a 256-bit hash of the parameters. This
    hash is called the `parms_id' and can be easily accessed and printed at any
    time. The hash will change as soon as any of the parameters is changed.

    When a SEALContext is created from a given EncryptionParameters instance,
    Microsoft SEAL automatically creates a so-called `modulus switching chain',
    which is a chain of other encryption parameters derived from the original set.
    The parameters in the modulus switching chain are the same as the original
    parameters with the exception that size of the coefficient modulus is
    decreasing going down the chain. More precisely, each parameter set in the
    chain attempts to remove the last coefficient modulus prime from the
    previous set; this continues until the parameter set is no longer valid
    (e.g., plain_modulus is larger than the remaining coeff_modulus). It is easy
    to walk through the chain and access all the parameter sets. Additionally,
    each parameter set in the chain has a `chain index' that indicates its
    position in the chain so that the last set has index 0. We say that a set
    of encryption parameters, or an object carrying those encryption parameters,
    is at a higher level in the chain than another set of parameters if its the
    chain index is bigger, i.e., it is earlier in the chain.

    Each set of parameters in the chain involves unique pre-computations performed
    when the SEALContext is created, and stored in a SEALContext::ContextData
    object. The chain is basically a linked list of SEALContext::ContextData
    objects, and can easily be accessed through the SEALContext at any time. Each
    node can be identified by the parms_id of its specific encryption parameters
    (poly_modulus_degree remains the same but coeff_modulus varies).

    In this example we use a custom coeff_modulus, consisting of 5 primes of
    sizes 50, 30, 30, 50, and 50 bits. Note that this is still OK according to
    the explanation in `1_bfv_basics.cpp'. Indeed,

        CoeffModulus::MaxBitCount(poly_modulus_degree)

    returns 218 (greater than 50+30+30+50+50=210).

    Due to the modulus switching chain, the order of the 5 primes is significant.
    The last prime has a special meaning and we call it the `special prime'. Thus,
    the first parameter set in the modulus switching chain is the only one that
    involves the special prime. All key objects, such as SecretKey, are created
    at this highest level. All data objects, such as Ciphertext, can be only at
    lower levels. The special prime should be as large as the largest of the
    other primes in the coeff_modulus, although this is not a strict requirement.

              special prime +---------+
                                      |
                                      v
    coeff_modulus: { 50, 30, 30, 50, 50 }  +---+  Level 4 (all keys; `key level')
                                               |
                                               |
        coeff_modulus: { 50, 30, 30, 50 }  +---+  Level 3 (highest `data level')
                                               |
                                               |
            coeff_modulus: { 50, 30, 30 }  +---+  Level 2
                                               |
                                               |
                coeff_modulus: { 50, 30 }  +---+  Level 1
                                               |
                                               |
                    coeff_modulus: { 50 }  +---+  Level 0 (lowest level)
    */
    vector<uint64_t> coeff_modulus = { 50, 30, 30, 50, 50 };
    size_t poly_modulus_degree = 8192;
    size_t poly_modulus_bit_size = 20; // Enable Batching
    int security_level = 128;
    /*
    In this example the plain_modulus does not play much of a role; we choose
    some reasonable value.
    */
    Aseal* fhe = new Aseal();
    string ctx = fhe->ContextGen(scheme::bfv, poly_modulus_degree, poly_modulus_bit_size, 0, security_level);
    EXPECT_STREQ(ctx.c_str(), "success: valid");
    auto context = fhe->get_context();
    print_parameters(context);

    /*
    There are convenience method for accessing the SEALContext::ContextData for
    some of the most important levels:

        SEALContext::key_context_data(): access to key level ContextData
        SEALContext::first_context_data(): access to highest data level ContextData
        SEALContext::last_context_data(): access to lowest level ContextData

    We iterate over the chain and print the parms_id for each set of parameters.
    */
    print_line(__LINE__);
    cout << "Print the modulus switching chain." << endl;

    /*
    First print the key level parameter information.
    */
    auto context_data = context->key_context_data();

    cout << "----> Level (chain index): " << context_data->chain_index();
    cout << " ...... key_context_data()" << endl;
    cout << "      parms_id: " << hex;
    for (const auto &param : context_data->parms_id())
    {
        cout << param << " ";
    }
    cout << endl;
    cout << "      coeff_modulus primes: ";
    cout << hex;
    for (const auto &prime : context_data->parms().coeff_modulus())
    {
        cout << prime.value() << " ";
    }
    cout << dec << endl;
    cout << "\\" << endl;
    cout << " \\-->";

    /*
    Next iterate over the remaining (data) levels.
    */
    context_data = context->first_context_data();
    while (context_data)
    {
        cout << " Level (chain index): " << context_data->chain_index();
        if (context_data->parms_id() == context->first_parms_id())
        {
            cout << " ...... first_context_data()" << endl;
        }
        else if (context_data->parms_id() == context->last_parms_id())
        {
            cout << " ...... last_context_data()" << endl;
        }
        else
        {
            cout << endl;
        }
        cout << "      parms_id: " << hex;
        for (const auto &param : context_data->parms_id())
        {
            cout << param << " ";
        }
        cout << endl;
        cout << "      coeff_modulus primes: ";
        cout << hex;
        for (const auto &prime : context_data->parms().coeff_modulus())
        {
            cout << prime.value() << " ";
        }
        cout << dec << endl;
        cout << "\\" << endl;
        cout << " \\-->";

        /*
        Step forward in the chain.
        */
        context_data = context_data->next_context_data();
    }
    cout << " End of chain reached" << endl << endl;

    /*
    We create some keys and check that indeed they appear at the highest level.
    */
    fhe->KeyGen();
    AsealPublicKey& public_key = _to_public_key(fhe->get_public_key());
    AsealSecretKey& secret_key = _to_secret_key(fhe->get_secret_key());
    fhe->RelinKeyGen();
    AsealRelinKey& relin_keys = _to_relin_keys(fhe->get_relin_keys());

    print_line(__LINE__);
    cout << "Print the parameter IDs of generated elements." << endl;
    cout << "    + public_key:  " << hex;
    for (const auto &param : public_key.parms_id())
    {
        cout << param << " ";
    }
    cout << endl;
    cout << "    + secret_key:  " << hex;
    for (const auto &param : secret_key.parms_id())
    {
        cout << param << " ";
    }
    cout << endl;
    cout << "    + relin_keys:  ";
    for (const auto &param : relin_keys.parms_id())
    {
        cout << param << " ";
    }
    cout << dec << endl << endl;

    /*
    In the BFV scheme plaintexts do not carry a parms_id, but ciphertexts do. Note
    how the freshly encrypted ciphertext is at the highest data level.
    */
    AsealPlaintext plain("1x^3 + 2x^2 + 3x^1 + 4");
    AsealCiphertext encrypted;
    fhe->encrypt(plain, encrypted);
    cout << "    + plain:       " << hex;
    for (const auto &param : plain.parms_id())
    {
        cout << param << " ";
    }
    cout << " (not set in BFV)" << endl;
    cout << "    + encrypted:   " << hex;
    for (const auto &param : encrypted.parms_id())
    {
        cout << param << " ";
    }
    cout << dec << endl << endl;

    /*
    `Modulus switching' is a technique of changing the ciphertext parameters down
    in the chain. The function Evaluator::mod_switch_to_next always switches to
    the next level down the chain, whereas Evaluator::mod_switch_to switches to
    a parameter set down the chain corresponding to a given parms_id. However, it
    is impossible to switch up in the chain.
    */
    print_line(__LINE__);
    cout << "Perform modulus switching on encrypted and print." << endl;
    context_data = context->first_context_data();
    cout << "---->";
    while (context_data->next_context_data())
    {
        cout << " Level (chain index): " << context_data->chain_index() << endl;
        cout << "      parms_id of encrypted: " << hex;
        for (const auto &param : encrypted.parms_id())
        {
            cout << param << " ";
        }
        cout << endl << dec;
        cout << "      Noise budget at this level: " << fhe->invariant_noise_budget(encrypted) << " bits" << endl;
        cout << "\\" << endl;
        cout << " \\-->";
        fhe->mod_switch_to_next(encrypted);
        context_data = context_data->next_context_data();
    }
    cout << " Level (chain index): " << context_data->chain_index() << endl;
    cout << "      parms_id of encrypted: " << hex;
    for (const auto &param : encrypted.parms_id())
    {
        cout << param << " ";
    }
    cout << endl << dec;
    cout << "      Noise budget at this level: " << fhe->invariant_noise_budget(encrypted) << " bits" << endl;
    cout << "\\" << endl;
    cout << " \\-->";
    cout << " End of chain reached" << endl << endl;

    /*
    At this point it is hard to see any benefit in doing this: we lost a huge
    amount of noise budget (i.e., computational power) at each switch and seemed
    to get nothing in return. Decryption still works.
    */
    print_line(__LINE__);
    cout << "Decrypt still works after modulus switching." << endl;
    fhe->decrypt(encrypted, plain);
    cout << "    + Decryption of encrypted: " << plain.to_string();
    EXPECT_STREQ(plain.to_string().c_str(), "1x^3 + 2x^2 + 3x^1 + 4");
    cout << " ...... Correct." << endl << endl;

    /*
    However, there is a hidden benefit: the size of the ciphertext depends
    linearly on the number of primes in the coefficient modulus. Thus, if there
    is no need or intention to perform any further computations on a given
    ciphertext, we might as well switch it down to the smallest (last) set of
    parameters in the chain before sending it back to the secret key holder for
    decryption.

    Also the lost noise budget is actually not an issue at all, if we do things
    right, as we will see below.

    First we recreate the original ciphertext and perform some computations.
    */
    cout << "Computation is more efficient with modulus switching." << endl;
    print_line(__LINE__);
    cout << "Compute the 8th power." << endl;
    fhe->encrypt(plain, encrypted);
    cout << "    + Noise budget fresh:                    " << fhe->invariant_noise_budget(encrypted) << " bits"
         << endl;
    AsealCiphertext squared;
    fhe->multiply(encrypted, encrypted, squared);
    fhe->relinearize(squared);
    cout << "    + Noise budget of the 2nd power:         " << fhe->invariant_noise_budget(squared) << " bits"
         << endl;
    AsealCiphertext fourth_power;
    fhe->multiply(squared, squared, fourth_power);
    fhe->relinearize(fourth_power);
    cout << "    + Noise budget of the 4th power:         " << fhe->invariant_noise_budget(fourth_power) << " bits"
         << endl;

    /*
    Surprisingly, in this case modulus switching has no effect at all on the
    noise budget.
    */
    fhe->mod_switch_to_next(fourth_power);
    cout << "    + Noise budget after modulus switching:  " << fhe->invariant_noise_budget(fourth_power) << " bits"
         << endl;
    /*
    This means that there is no harm at all in dropping some of the coefficient
    modulus after doing enough computations. In some cases one might want to
    switch to a lower level slightly earlier, actually sacrificing some of the
    noise budget in the process, to gain computational performance from having
    smaller parameters. We see from the print-out that the next modulus switch
    should be done ideally when the noise budget is down to around 25 bits.
    */
    AsealCiphertext eighth_power;
    fhe->multiply(fourth_power, fourth_power, eighth_power);
    fhe->relinearize(encrypted);
    cout << "    + Noise budget of the 8th power:         " << fhe->invariant_noise_budget(eighth_power) << " bits"
         << endl;
    fhe->mod_switch_to_next(eighth_power);
    cout << "    + Noise budget after modulus switching:  " << fhe->invariant_noise_budget(eighth_power) << " bits"
         << endl;

    /*
    At this point the ciphertext still decrypts correctly, has very small size,
    and the computation was as efficient as possible. Note that the decryptor
    can be used to decrypt a ciphertext at any level in the modulus switching
    chain.
    */
    fhe->decrypt(eighth_power, plain);
    cout << "    + Decryption of the 8th power (hexadecimal)" << endl;
    cout << "    " << plain.to_string();
    EXPECT_STREQ(plain.to_string().c_str(), "1x^24 + 10x^23 + 88x^22 + 330x^21 + EFCx^20 + 3A30x^19 + C0B8x^18 + 22BB0x^17 + 58666x^16 + C88D0x^15 + 9C377x^14 + F4C0Ex^13 + E8B38x^12 + 5EE89x^11 + F8BFFx^10 + 30304x^9 + 5B9D4x^8 + 12653x^7 + 4DFB5x^6 + 879F8x^5 + 825FBx^4 + F1FFEx^3 + 3FFFFx^2 + 60000x^1 + 10000");
    cout << " ...... Correct." << endl << endl;
    /*
    In BFV modulus switching is not necessary and in some cases the user might
    not want to create the modulus switching chain, except for the highest two
    levels. This can be done by passing a bool `false' to SEALContext constructor.
    */
    print_line(__LINE__);
    cout << "Disable modulus switching chain." << endl;
    fhe->disable_mod_switch();
    context = fhe->get_context();

    /*
    We can check that indeed the modulus switching chain has been created only
    for the highest two levels (key level and highest data level). The following
    loop should execute only once.
    */
    cout << "Optionally disable modulus switching chain expansion." << endl;
    cout << "---->";
    for (context_data = context->key_context_data(); context_data; context_data = context_data->next_context_data())
    {
        cout << " Level (chain index): " << context_data->chain_index() << endl;
        cout << "      parms_id: " << hex;
        for (const auto &param : context_data->parms_id())
        {
            cout << param << " ";
        }
        cout << endl;
        cout << "      coeff_modulus primes: ";
        for (const auto &prime : context_data->parms().coeff_modulus())
        {
            cout << prime.value() << " ";
        }
        cout << dec << endl;
        cout << "\\" << endl;
        cout << " \\-->";
    }
    cout << " End of chain reached" << endl << endl;

    /*
    It is very important to understand how this example works since in the BGV
    scheme modulus switching has a much more fundamental purpose and the next
    examples will be difficult to understand unless these basic properties are
    totally clear.
    */
}
