#include "fhe.h"

backend_t backend_t_from_string(const char* backend)
{
    return backend_t_map[backend];
}

scheme_t scheme_t_from_string(const char* scheme)
{
    return scheme_t_map[scheme];
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
        return "invalid: Not Implemented";
    default:
        return "error: No backend set";
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

// const char* get_secret_key(Afhe* afhe)
// {
//     return afhe->get_secret_key().c_str();
// }

// const char* get_private_key(Afhe* afhe)
// {
//     return afhe->get_private_key().c_str();
// }

ACiphertext* encrypt(backend_t backend, Afhe* afhe, APlaintext* plaintext) {
    switch (backend)
    {
    case backend_t::seal_t:
    {
        ACiphertext* ctx = init_ciphertext(backend);
        afhe->encrypt(*plaintext, *ctx);
        return ctx;
    }
    default:
        return init_ciphertext(backend);
    }
}
