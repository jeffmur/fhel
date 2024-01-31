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
    case backend_t::openfhe_t:
        return "warn: [generate_context] Not Implemented";
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
    case backend_t::openfhe_t:
        return new Aopenfhe();
    default:
        throw runtime_error("No backend set");
    }
}

APlaintext* init_plaintext(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new AsealPlaintext();
    case backend_t::openfhe_t:
        return new AopenfhePlaintext();
    default:
        throw runtime_error("No backend set");
    }
}

APlaintext* init_plaintext_value(backend_t backend, const char* value) {
    switch (backend)
    {
    case backend_t::seal_t:
        return new AsealPlaintext(value);
    case backend_t::openfhe_t:
        return new AopenfhePlaintext(value);
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
    case backend_t::openfhe_t:
        return new AopenfheCiphertext();
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