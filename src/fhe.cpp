#include "fhe.h"

backend_t backend_t_from_string(const char* backend)
{
    return backend_t_map[backend];
}

scheme_t scheme_t_from_string(const char* scheme)
{
    return scheme_t_map[scheme];
}

const char* generate_context(backend_t backend, Afhe* afhe, scheme_t scheme_type, long poly_mod_degree, long pt_mod_bit, long pt_mod, long sec_level)
{
    switch (backend)
    {
    case backend_t::seal_t:
    {
        scheme a_scheme = scheme_t_map_scheme[scheme_type];
        string ctx = afhe->ContextGen(a_scheme, poly_mod_degree, pt_mod_bit, pt_mod, sec_level);
        // !Important: Must copy string to char* to avoid memory leak
        char *cpy = new char[ctx.size()+1] ;
        strcpy(cpy, ctx.c_str());
        return cpy;
    }
    default:
        return "error: [generate_context] No backend set";
    }
}

void generate_keys(backend_t backend, Afhe* afhe)
{
    switch (backend)
    {
    case backend_t::seal_t:
        afhe->KeyGen();
    default:
        break;
    }
}

Afhe* init_backend(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new Aseal();
    default:
        throw runtime_error("No backend set");
    }
}

APlaintext* init_plaintext(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new AsealPlaintext();
    default:
        throw runtime_error("No backend set");
    }
}

APlaintext* init_plaintext_value(backend_t backend, const char* value) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new AsealPlaintext(value);
    default:
        throw runtime_error("No backend set");
    }
}

const char* get_plaintext_value(APlaintext* plaintext) {
    string ptx = plaintext->to_string();
    char *cpy = new char[ptx.size()+1] ;
    strcpy(cpy, ptx.c_str());
    return cpy;
}


ACiphertext* init_ciphertext(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new AsealCiphertext();
    default:
        throw runtime_error("No backend set");
    }
}

// const char* get_secret_key(Afhe* afhe)
// {
//     return afhe->get_secret_key().c_str();
// }

// const char* get_private_key(Afhe* afhe)
// {
//     return afhe->get_private_key().c_str();
// }

ACiphertext* encrypt(backend_t backend, Afhe* afhe, APlaintext* ptxt) {
    switch (backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctxt = init_ciphertext(backend);
        try {
            afhe->encrypt(*ptxt, *ctxt);
        }
        catch (invalid_argument &e) {
            cout << "error: [encrypt] " << e.what() << endl;
        }
        return ctxt;
    }
    default:
        return init_ciphertext(backend);
    }
}

APlaintext* decrypt(backend_t backend, Afhe* afhe, ACiphertext* ctxt) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        APlaintext* ptxt = init_plaintext(backend);
        try {
            afhe->decrypt(*ctxt, *ptxt);
        }
        catch (invalid_argument &e) {
            cout << "error: [decrypt] " << e.what() << endl;
        }
        return ptxt;
    }
    default:
        return init_plaintext(backend);
    }
}

int invariant_noise_budget(backend_t backend, Afhe* afhe, ACiphertext* ctxt) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        int noise = afhe->invariant_noise_budget(*ctxt);
        return noise;
        // string noise_str = to_string(noise);
        // char *cpy = new char[noise_str.size()+1] ;
        // strcpy(cpy, noise_str.c_str());
        // return cpy;
    }
    default:
        return -1; //"error: [invariant_noise_budget] No backend set";
    }
}

ACiphertext* add(backend_t backend, Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctxt = init_ciphertext(backend);
        try {
            afhe->add(*ctxt1, *ctxt2, *ctxt);
        }
        catch (invalid_argument &e) {
            cout << "error: [add] " << e.what() << endl;
        }
        return ctxt;
    }
    default:
        return init_ciphertext(backend);
    }
}

ACiphertext* add_plain(backend_t backend, Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctxt_res = init_ciphertext(backend);
        try {
            afhe->add(*ctxt, *ptxt, *ctxt_res);
        }
        catch (invalid_argument &e) {
            cout << "error: [add_plain] " << e.what() << endl;
        }
        return ctxt_res;
    }
    default:
        return init_ciphertext(backend);
    }
}

ACiphertext* subtract_plain(backend_t backend, Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctxt_res = init_ciphertext(backend);
        try {
            afhe->subtract(*ctxt, *ptxt, *ctxt_res);
        }
        catch (invalid_argument &e) {
            cout << "error: [subtract_plain] " << e.what() << endl;
        }
        return ctxt_res;
    }
    default:
        return init_ciphertext(backend);
    }
}

ACiphertext* subtract(backend_t backend, Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctxt = init_ciphertext(backend);
        try {
            afhe->subtract(*ctxt1, *ctxt2, *ctxt);
        }
        catch (invalid_argument &e) {
            cout << "error: [subtract] " << e.what() << endl;
        }
        return ctxt;
    }
    default:
        return init_ciphertext(backend);
    }
}

APlaintext* encode_int(backend_t backend, Afhe* afhe, uint64_t* data, int size) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        APlaintext* ptxt = init_plaintext(backend);
        try {
            // Convert array to vector
            vector<uint64_t> data_vec(data, data + size);
            afhe->encode_int(data_vec, *ptxt);
        }
        catch (invalid_argument &e) {
            cout << "error: [encode_int] " << e.what() << endl;
        }
        return ptxt;
    }
    default:
        return init_plaintext(backend);
    }
}

uint64_t* decode_int(backend_t backend, Afhe* afhe, APlaintext* ptxt) {
    switch(backend)
    {
    case backend_t::seal_t:
    {
        vector<uint64_t> data;
        try {
            afhe->decode_int(*ptxt, data);
        }
        catch (invalid_argument &e) {
            cout << "error: [decode_int] " << e.what() << endl;
        }
        // Extract vector contents to array
        uint64_t* result = new uint64_t[data.size()];
        copy(data.begin(), data.end(), result);
        return result;
    }
    default:
        return nullptr;
    }
}
