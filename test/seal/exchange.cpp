#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */

TEST(Exchange, Parameters) 
{
    // BFV / BGV with batching enabled
    for (auto scheme : {scheme::bfv, scheme::bgv}) {
        Aseal* host = new Aseal();
        string h_ctx = host->ContextGen(scheme, 1024, 0, 1024);
        EXPECT_STREQ(h_ctx.c_str(), "success: valid");

        string h_params = host->save_parameters();

        Aseal* guest = new Aseal();
        string g_ctxt = guest->ContextGen(h_params);
        EXPECT_STREQ(g_ctxt.c_str(), "success: valid");
    }
    // Disable Batching (bit_size = -1)
    for (auto scheme : {scheme::bfv, scheme::bgv}) {
        Aseal* host = new Aseal();
        string h_ctx = host->ContextGen(scheme, 8192, 20, -1);
        EXPECT_STREQ(h_ctx.c_str(), "success: valid");

        string h_params = host->save_parameters();

        Aseal* guest = new Aseal();
        string g_ctxt = guest->ContextGen(h_params);
        EXPECT_STREQ(g_ctxt.c_str(), "success: valid");
    }
    // CKKS
    Aseal* host = new Aseal();
    string h_ctx = host->ContextGen(scheme::ckks, 8192, pow(2.0, 40), -1, -1, {60, 40, 40, 60});
    EXPECT_STREQ(h_ctx.c_str(), "success: valid");

    string h_params = host->save_parameters();

    Aseal* guest = new Aseal();
    string g_ctxt = guest->ContextGen(h_params);
    EXPECT_STREQ(g_ctxt.c_str(), "success: valid");
}

TEST(Exchange, Ciphertext) 
{
    Aseal* host = new Aseal();
    string h_ctx = host->ContextGen(scheme::bfv, 1024, 0, 1024);
    EXPECT_STREQ(h_ctx.c_str(), "success: valid");

    // Save the secret key
    host->KeyGen();
    string h_sec_key = host->get_secret_key().save();
    AsealPlaintext four("4");
    AsealCiphertext ctxt_four;
    host->encrypt(four, ctxt_four);

    // Save the ciphertext
    string cipher_out = ctxt_four.save("none");

    // Initialize the guest
    // Note: the parameters are not passed to the guest
    // But guest parameters should match the host
    Aseal* guest = new Aseal();
    string g_ctxt = guest->ContextGen(scheme::bfv, 1024, 0, 1024);
    EXPECT_STREQ(g_ctxt.c_str(), "success: valid");

    // Load the secret key from the host
    // You wouldn't do this in practice, but for testing purposes
    guest->KeyGen(h_sec_key);

    AsealCiphertext ctxt_four_guest;
    ctxt_four_guest.load(guest, cipher_out);

    AsealPlaintext four_guest;
    guest->decrypt(ctxt_four_guest, four_guest);
    EXPECT_EQ(four_guest.to_string(), "4");
}
