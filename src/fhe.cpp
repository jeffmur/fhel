#include "fhe.h"

// Important: Must copy string to char* to avoid memory leak
// Optional ignores null-terminated strings
const char* to_char(string str, bool ignore_null_terminated=false) {
    int size = str.size();
    char *cpy = new char[size+1];
    // Convert string to char array
    // Regardless of null-terminated chars
    if (ignore_null_terminated) { str.copy(cpy, size); }
    // Up-to null-terminated char
    else { strcpy(cpy, str.c_str()); }
    return cpy;
}

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

const char* generate_context(Afhe* afhe, scheme_t scheme_type, uint64_t poly_mod_degree, uint64_t pt_mod_bit, uint64_t pt_mod, uint64_t sec_level, const uint64_t* qi_sizes, uint64_t qi_sizes_length)
{
    try {
        scheme a_scheme = scheme_t_map_scheme.at(scheme_type);
        vector<int> qi_sizes_vec(qi_sizes, qi_sizes + qi_sizes_length);
        string ctx = afhe->ContextGen(a_scheme, poly_mod_degree, pt_mod_bit, pt_mod, sec_level, qi_sizes_vec);
        return to_char(ctx);
    }
    catch (exception &e) { return set_error(e); }
}

const char* generate_context_from_str(Afhe* afhe, const char* params, int size)
{
    try {
        // Convert params to string
        string params_str(params, size);
        string ctx = afhe->ContextGen(params_str);
        return to_char(ctx);
    }
    catch (exception &e) { return set_error(e); }
}

const char* save_parameters(Afhe* afhe)
{
    try {
        string params = afhe->save_parameters();
        return to_char(params, true);
    }
    catch (exception &e) { set_error(e); return nullptr; }
}

int save_parameters_size(Afhe* afhe)
{
    try {
        int p_size = afhe->save_parameters_size();
        return p_size;
    }
    catch (exception &e) { set_error(e); return -1; }

}

byte* save_parameters_bytes(Afhe* afhe)
{
    try {
        vector<byte> byte_buffer(static_cast<size_t>(afhe->save_parameters_size()));
        afhe->save_parameters_inplace(reinterpret_cast<byte *>(byte_buffer.data()), byte_buffer.size());
        return byte_buffer.data();
    }
    catch (exception &e) { set_error(e); return nullptr; }
}

void load_parameters_bytes(Afhe* afhe, const byte* params, int size)
{
    try {
       afhe->load_parameters_inplace(params, size);
    }
    catch (exception &e) { set_error(e); }
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
    return to_char(plaintext->to_string());
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

const char* save_ciphertext(ACiphertext* ciphertext) {
    return to_char(ciphertext->save(), true);
}

int save_ciphertext_size(ACiphertext* ciphertext) {
    return ciphertext->save_size();
}

ACiphertext* load_ciphertext(Afhe* fhe, const char* data, int size) {
    backend_t lib = backend_map_backend_t[fhe->backend_lib];
    ACiphertext* ctxt = init_ciphertext(lib);
    try {
        string data_str(data, size);
        ctxt->load(fhe, data_str);
    }
    catch (exception &e) { set_error(e); }
    return ctxt;
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

ACiphertext* square(Afhe* afhe, ACiphertext* ctxt) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt_res = init_ciphertext(lib);
    try {
        afhe->square(*ctxt, *ctxt_res);
    }
    catch (exception &e) { set_error(e); }
    return ctxt_res;
}

ACiphertext* power(Afhe* afhe, ACiphertext* ctxt, int power) {
    backend_t lib = backend_map_backend_t[afhe->backend_lib];
    ACiphertext* ctxt_res = init_ciphertext(lib);
    try {
        afhe->power(*ctxt, power, *ctxt_res);
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
