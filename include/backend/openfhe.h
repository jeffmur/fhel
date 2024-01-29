#include "afhe.h"

/**
 * @brief Abstraction for Plaintext
 */
class AopenfhePlaintext : public APlaintext {
public:
    AopenfhePlaintext(){};
    AopenfhePlaintext(const char* value){};
    string to_string() override {
        return "Not Implemented";
    }
    ~AopenfhePlaintext(){};
};

/**
 * @brief Abstraction for Ciphertext
 */
class AopenfheCiphertext : public ACiphertext {
public:
    AopenfheCiphertext(){};
    size_t size() override {
        return 0;
    }
    ~AopenfheCiphertext(){};
};

class Aopenfhe : public Afhe {
public:
    Aopenfhe(){};
    ~Aopenfhe(){};
    string ContextGen(scheme scheme, uint64_t poly_modulus_degree,
                      uint64_t plain_modulus_bit_size, uint64_t plain_modulus,
                      int sec_level, vector<int> qi_sizes = {}, vector<uint64_t> qi_mods = {}) override {
        return "Not Implemented";
    }
    void KeyGen() override {
        return;
    }
    // string get_secret_key() override {
    //     return "Not Implemented";
    // }
    // string get_public_key() override {
    //     return "Not Implemented";
    // }
    void encrypt(APlaintext &ptxt, ACiphertext &ctxt) override {
        return;
    }
    void decrypt(ACiphertext &ctxt, APlaintext &ptxt) override {
        return;
    }
    void add(ACiphertext &ctxt1, ACiphertext &ctxt2, ACiphertext &ctxt_out) override {
        return;
    }
};