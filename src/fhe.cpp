#include "fhe.h"

const char* check_for_error() {
    ErrorTranslator& et = ErrorTranslator::getInstance();
    // cout << "check_for_error: " << et.get_error() << endl;
    return et.get_error();
}

const char* set_error(const std::exception& e) {
    ErrorTranslator& et = ErrorTranslator::getInstance();
    // cout << "set_error: " << e.what() << endl;
    et.set_error(e);
    return et.get_error();
}

void clear_error() {
    ErrorTranslator& et = ErrorTranslator::getInstance();
    et.clear();
}

backend_t backend_t_from_string(const char* backend)
{
    // Treat empty string as null
    if (strcmp(backend, "") == 0) { backend = "null"; }
    try {
        // cout << "backend_t_from_string: " << backend << endl;
        return backend_t_map.at(backend);
    }
    catch (out_of_range &e) { set_error(invalid_argument("Unsupported Backend: "+string(backend))); }
    return backend_t::no_b;
}

scheme_t scheme_t_from_string(const char* scheme)
{
    // Treat empty string as null
    if (strcmp(scheme, "") == 0) { scheme = "null"; }
    try {
        return scheme_t_map.at(scheme);
    }
    catch (out_of_range &e) { set_error(invalid_argument("Unsupported Scheme: "+string(scheme))); }
    return scheme_t::no_s;
}

const char* generate_context(Afhe* afhe, scheme_t scheme_type, long poly_mod_degree, long pt_mod_bit, long pt_mod, long sec_level)
{
    switch (afhe->backend_lib)
    {
    case backend_t::seal_b:
    {
        try {
            scheme a_scheme = scheme_t_map_scheme[scheme_type];
            string ctx = afhe->ContextGen(a_scheme, poly_mod_degree, pt_mod_bit, pt_mod, sec_level);
            // !Important: Must copy string to char* to avoid memory leak
            char *cpy = new char[ctx.size()+1] ;
            strcpy(cpy, ctx.c_str());
            return cpy;
        }
        catch (exception &e) { return set_error(e); }
    }
    default:
        return set_error(logic_error("[generate_context] No backend set"));
    }
}

void generate_keys(Afhe* afhe)
{
    switch (afhe->backend_lib)
    {
    case backend_t::seal_b:
    {
        try { afhe->KeyGen(); }
        catch (exception &e) { set_error(e); }
    }
    default:
        break;
    }
}

void generate_relin_keys(Afhe* afhe)
{
    switch (afhe->backend_lib)
    {
    case backend_t::seal_b:
    {
        try { afhe->RelinKeyGen(); }
        catch (exception &e) { set_error(e); }
    }
    default:
        break;
    }
}

Afhe* init_backend(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_b:
        return new Aseal();
    default:
        set_error(logic_error("[init_backend] No backend set"));
        return nullptr;
    }
}

APlaintext* init_plaintext(backend_t backend) {
    switch (backend)
    {
    case backend_t::seal_b:
        return new AsealPlaintext();
    default:
        set_error(logic_error("[init_plaintext] No backend set"));
        return nullptr;
    }
}

APlaintext* init_plaintext_value(backend_t backend, const char* value) {
    switch (backend)
    {
    case backend_t::seal_b:
        return new AsealPlaintext(value);
    default:
        set_error(logic_error("[init_plaintext_value] No backend set"));
        return nullptr;
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
    case backend_t::seal_b:
        return new AsealCiphertext();
    default:
        set_error(logic_error("[init_ciphertext] No backend set"));
        return nullptr;
    }
}

int get_ciphertext_size(ACiphertext* ciphertext) {
    return ciphertext->size();
}

ACiphertext* encrypt(Afhe* afhe, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt = init_ciphertext(lib);
        try {
            afhe->encrypt(*ptxt, *ctxt);
        }
        catch (exception &e) { set_error(e); }
        return ctxt;
    }
    default:
        set_error(logic_error("[encrypt] No backend set"));
        return nullptr;
    }
}

APlaintext* decrypt(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        APlaintext* ptxt = init_plaintext(lib);
        try {
            afhe->decrypt(*ctxt, *ptxt);
        }
        catch (exception &e) { set_error(e); }
        return ptxt;
    }
    default:
        set_error(logic_error("[decrypt] No backend set"));
        return nullptr;
    }
}

int invariant_noise_budget(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        int noise_budget = -1;
        try {
            noise_budget = afhe->invariant_noise_budget(*ctxt);
        }
        catch (exception &e) { set_error(e); }
        return noise_budget;
    }
    default:
        set_error(logic_error("[invariant_noise_budget] No backend set"));
        return -1;
    }
}

ACiphertext* relinearize(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        try {
            afhe->relinearize(*ctxt);
        }
        catch (exception &e) { set_error(e); }
        return ctxt;
    }
    default:
        set_error(logic_error("[relinearize] No backend set"));
        return nullptr;
    }
}

void mod_switch_to_next(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        try {
            afhe->mod_switch_to_next(*ctxt);
            return;
        }
        catch (exception &e) { set_error(e); }
    }
    default:
        set_error(logic_error("[mod_switch_to_next] No backend set"));
    }
}

ACiphertext* add(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt = init_ciphertext(lib);
        try {
            afhe->add(*ctxt1, *ctxt2, *ctxt);
        }
        catch (exception &e) { set_error(e); }
        return ctxt;
    }
    default:
        set_error(logic_error("[add] No backend set"));
        return nullptr;
    }
}

ACiphertext* add_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt_res = init_ciphertext(lib);
        try {
            afhe->add(*ctxt, *ptxt, *ctxt_res);
        }
        catch (exception &e) { set_error(e); }
        return ctxt_res;
    }
    default:
        set_error(logic_error("[add_plain] No backend set"));
        return nullptr;
    }
}

ACiphertext* subtract(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt = init_ciphertext(lib);
        try {
            afhe->subtract(*ctxt1, *ctxt2, *ctxt);
        }
        catch (exception &e) { set_error(e); }
        return ctxt;
    }
    default:
        set_error(logic_error("[subtract] No backend set"));
        return nullptr;
    }
}

ACiphertext* subtract_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt_res = init_ciphertext(lib);
        try {
            afhe->subtract(*ctxt, *ptxt, *ctxt_res);
        }
        catch (exception &e) { set_error(e); }
        return ctxt_res;
    }
    default:
        set_error(logic_error("[subtract_plain] No backend set"));
        return nullptr;
    }
}

ACiphertext* multiply(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt = init_ciphertext(lib);
        try {
            afhe->multiply(*ctxt1, *ctxt2, *ctxt);
        }
        catch (exception &e) { set_error(e); }
        return ctxt;
    }
    default:
        set_error(logic_error("[multiply] No backend set"));
        return nullptr;
    }
}

ACiphertext* multiply_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        ACiphertext* ctxt_res = init_ciphertext(lib);
        try {
            afhe->multiply(*ctxt, *ptxt, *ctxt_res);
        }
        catch (exception &e) { set_error(e); }
        return ctxt_res;
    }
    default:
        set_error(logic_error("[multiply_plain] No backend set"));
        return nullptr;
    }
}

APlaintext* encode_int(Afhe* afhe, uint64_t* data, int size) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        APlaintext* ptxt = init_plaintext(lib);
        try {
            // Convert array to vector
            vector<uint64_t> data_vec(data, data + size);
            afhe->encode_int(data_vec, *ptxt);
        }
        catch (exception &e) { set_error(e); }
        return ptxt;
    }
    default:
        set_error(logic_error("[encode_int] No backend set"));
        return nullptr;
    }
}

uint64_t* decode_int(Afhe* afhe, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    switch (lib)
    {
    case backend_t::seal_b:
    {
        vector<uint64_t> data;
        try {
            afhe->decode_int(*ptxt, data);
        }
        catch (exception &e) { set_error(e); }
        // Extract vector contents to array
        uint64_t* result = new uint64_t[data.size()];
        copy(data.begin(), data.end(), result);
        return result;
    }
    default:
        set_error(logic_error("[decode_int] No backend set"));
        return nullptr;
    }
}
