#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>
#include <cstdint>

TEST(Keys, ParameterIds)
{
    Aseal* fhe = new Aseal();
    EXPECT_EQ(fhe->ContextGen(scheme::ckks, 8192, pow(2.0, 40), -1, -1, {60, 40, 40, 60}), "success: valid");
    fhe->KeyGen();
    fhe->RelinKeyGen();

    AsealPublicKey pk = _to_public_key(fhe->get_public_key());
    vector<uint64_t> pk_parms_id = pk.param_ids();
    EXPECT_EQ(pk_parms_id.size(), 4);

    AsealSecretKey sk = _to_secret_key(fhe->get_secret_key());
    vector<uint64_t> sk_parms_id = sk.param_ids();
    EXPECT_EQ(sk_parms_id.size(), 4);

    AsealRelinKey rk = _to_relin_keys(fhe->get_relin_keys());
    vector<uint64_t> rk_parms_id = rk.param_ids();
    EXPECT_EQ(rk_parms_id.size(), 4);

    for (int i = 0; i < 4; i++) {
        EXPECT_EQ(pk_parms_id[i], sk_parms_id[i]);
        EXPECT_EQ(pk_parms_id[i], rk_parms_id[i]);
    }
}
