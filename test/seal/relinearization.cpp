#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */

TEST(Relinearization, LogicError) {
    Aseal* fhe = new Aseal();

    string ctx = fhe->ContextGen(scheme::bfv, 1024, 0, 1024, 128);
    EXPECT_STREQ(ctx.c_str(), "success: valid");

    try {
        fhe->RelinKeyGen();
    } catch (const logic_error& e) {
        EXPECT_STREQ(e.what(), "KeyGen() must be called before RelinKeyGen()");
    }

    AsealCiphertext ct = AsealCiphertext();
    try {
        fhe->relinearize(ct);
    } catch (const logic_error& e) {
        EXPECT_STREQ(e.what(), "encrypted is not valid for encryption parameters");
    }
}
