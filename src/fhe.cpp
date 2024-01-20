#include "fhe.h"

const char* backend_t_to_string(backend_t backend)
{
    return backend_t_str[backend];
}

backend_t backend_t_from_string(const char* backend)
{
    return backend_t_map[backend];
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