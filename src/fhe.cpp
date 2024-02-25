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

const char* generate_context(Afhe* afhe, scheme_t scheme_type, int poly_mod_degree, int pt_mod_bit, int pt_mod, int sec_level, const int* qi_sizes, int qi_sizes_length)
{
    try {
        scheme a_scheme = scheme_t_map_scheme.at(scheme_type);
        vector<int> qi_sizes_vec(qi_sizes, qi_sizes + qi_sizes_length);
        string ctx = afhe->ContextGen(a_scheme, poly_mod_degree, pt_mod_bit, pt_mod, sec_level, qi_sizes_vec);
        // !Important: Must copy string to char* to avoid memory leak
        char *cpy = new char[ctx.size()+1] ;
        strcpy(cpy, ctx.c_str());
        return cpy;
    }
    catch (exception &e) { return set_error(e); }
}

void generate_keys(Afhe* afhe)
{
    try { afhe->KeyGen(); }
    catch (exception &e) { set_error(e); }
}

void generate_relin_keys(Afhe* afhe)
{
    try { afhe->RelinKeyGen(); }
    catch (exception &e) { set_error(e); }
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
    ACiphertext* ctxt = init_ciphertext(lib);
    try {
        afhe->encrypt(*ptxt, *ctxt);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
}

APlaintext* decrypt(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    APlaintext* ptxt = init_plaintext(lib);
    try {
        afhe->decrypt(*ctxt, *ptxt);
    }
    catch (exception &e) { set_error(e); }
    return ptxt;
}

int invariant_noise_budget(Afhe* afhe, ACiphertext* ctxt) {
    int noise_budget = -1;
    try {
        noise_budget = afhe->invariant_noise_budget(*ctxt);
    }
    catch (exception &e) { set_error(e); }
    return noise_budget;
}

ACiphertext* relinearize(Afhe* afhe, ACiphertext* ctxt) {
    try {
        afhe->relinearize(*ctxt);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
}

void mod_switch_to_next(Afhe* afhe, ACiphertext* ctxt) {
    try {
        afhe->mod_switch_to_next(*ctxt);
    }
    catch (exception &e) { set_error(e); }
}

ACiphertext* add(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt = init_ciphertext(lib);
    try {
        afhe->add(*ctxt1, *ctxt2, *ctxt);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
}

ACiphertext* add_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt_res = init_ciphertext(lib);
    try {
        afhe->add(*ctxt, *ptxt, *ctxt_res);
    }
    catch (exception &e) { set_error(e); }
    return ctxt_res;
}

ACiphertext* subtract(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt = init_ciphertext(lib);
    try {
        afhe->subtract(*ctxt1, *ctxt2, *ctxt);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
}

ACiphertext* subtract_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt_res = init_ciphertext(lib);
    try {
        afhe->subtract(*ctxt, *ptxt, *ctxt_res);
    }
    catch (exception &e) { set_error(e); }
    return ctxt_res;
}

ACiphertext* multiply(Afhe* afhe, ACiphertext* ctxt1, ACiphertext* ctxt2) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt = init_ciphertext(lib);
    try {
        afhe->multiply(*ctxt1, *ctxt2, *ctxt);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
}

ACiphertext* multiply_plain(Afhe* afhe, ACiphertext* ctxt, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt_res = init_ciphertext(lib);
    try {
        afhe->multiply(*ctxt, *ptxt, *ctxt_res);
    }
    catch (exception &e) { set_error(e); }
    return ctxt_res;
}

APlaintext* encode_int(Afhe* afhe, uint64_t* data, int size) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    APlaintext* ptxt = init_plaintext(lib);
    try {
        // Convert array to vector
        vector<uint64_t> data_vec(data, data + size);
        afhe->encode_int(data_vec, *ptxt);
    }
    catch (exception &e) { set_error(e); }
    return ptxt;
}

uint64_t* decode_int(Afhe* afhe, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
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

APlaintext* encode_double(Afhe* afhe, double* data, int size) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    APlaintext* ptxt = init_plaintext(lib);
    try {
        // Convert array to vector
        vector<double> data_vec(data, data + size);
        afhe->encode_double(data_vec, *ptxt);
    }
    catch (exception &e) { set_error(e); }
    return ptxt;
}

APlaintext* encode_double_value(Afhe* afhe, double data) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    APlaintext* ptxt = init_plaintext(lib);
    try {
        afhe->encode_double(data, *ptxt);
    }
    catch (exception &e) { set_error(e); }
    return ptxt;
}

double* decode_double(Afhe* afhe, APlaintext* ptxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    vector<double> data;
    try {
        afhe->decode_double(*ptxt, data);
    }
    catch (exception &e) { set_error(e); }
    // Extract vector contents to array
    double* result = new double[data.size()];
    copy(data.begin(), data.end(), result);
    return result;
}
