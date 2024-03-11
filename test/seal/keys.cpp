#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>
#include <cstdint>

TEST(Keys, Data)
{
    Aseal* fhe = new Aseal();
    EXPECT_EQ(fhe->ContextGen(scheme::ckks, 8192, pow(2.0, 40), -1, -1, {60, 40, 40, 60}), "success: valid");
    fhe->KeyGen();
    fhe->RelinKeyGen();

    AsealPublicKey pk = _to_public_key(fhe->get_public_key());
    vector<uint64_t> pk_data = pk.data();
    EXPECT_EQ(pk_data.size(), 2);

    for (int i = 0; i < pk_data.size(); i++)
    {
        cout << dec << "pk_data[" << i << "] = " << hex << pk_data[i] << endl;
    }

    AsealSecretKey sk = _to_secret_key(fhe->get_secret_key());
    vector<uint64_t> sk_data = sk.data();
    EXPECT_EQ(sk_data.size(), 1);

    EXPECT_NE(sk_data[0], pk_data[0]);
    EXPECT_NE(sk_data[0], pk_data[1]);

    for (int i = 0; i < sk_data.size(); i++)
    {
        cout << dec << "sk_data[" << i << "] = " << hex << sk_data[i] << endl;
    }

    AsealRelinKey relin_key = _to_relin_keys(fhe->get_relin_keys());
    vector<uint64_t> relin_key_data = relin_key.data();
    EXPECT_EQ(relin_key_data.size(), 3);

    EXPECT_NE(relin_key_data[0], pk_data[0]);
    EXPECT_NE(relin_key_data[0], pk_data[1]);
    EXPECT_NE(relin_key_data[0], sk_data[0]);

    for (int i = 0; i < relin_key_data.size(); i++)
    {
        cout << dec << "relin_key_data[" << i << "] = " << hex << relin_key_data[i] << endl;
    }

}
