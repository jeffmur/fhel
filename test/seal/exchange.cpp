#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>
#include <cstdint>

TEST(Exchange, Ciphertext) 
{
    Aseal* host = new Aseal();
    string h_ctx = host->ContextGen(scheme::bfv, 1024, 0, 1024);
    EXPECT_STREQ(h_ctx.c_str(), "success: valid");
    host->KeyGen();

    string params = host->save_parameters();

    AsealPlaintext four("4");

    AsealCiphertext ctxt_four;
    host->encrypt(four, ctxt_four);

    // AsealPlaintext four_test;
    // host->decrypt(ctxt_four, four_test);
    // EXPECT_EQ(four_test.to_string(), "4");

    stringstream cipher_out;
    ctxt_four.save(cipher_out, seal::compr_mode_type::none);

    Aseal* guest = new Aseal();
    string g_ctxt = guest->ContextGen(params);
    EXPECT_STREQ(g_ctxt.c_str(), "success: valid");
    guest->KeyGen(host->get_secret_key());

    AsealCiphertext ctxt_four_guest;
    ctxt_four_guest.load(*guest->get_context(), cipher_out);

    AsealPlaintext four_guest;
    guest->decrypt(ctxt_four_guest, four_guest);
    EXPECT_EQ(four_guest.to_string(), "4");
}
