/// This file contains the FFI bindings for encryption and decryption methods.
part of '../afhe.dart';

// --- encryption parameters ---

typedef _GenContextC = Pointer<Utf8> Function(
    BackendType backend,
    Pointer library,
    Int32 scheme,
    Int64 poly_mod_degree,
    Int64 pt_mod_bit,
    Int64 pt_mod,
    Int64 sec_level);

typedef _GenContext = Pointer<Utf8> Function(int backend, Pointer library,
    int scheme, int poly_mod_degree, int pt_mod_bit, int pt_mod, int sec_level);

final _GenContext _c_gen_context =
    dylib.lookup<NativeFunction<_GenContextC>>('generate_context').asFunction();

// --- encryption keys ---

typedef _GenKeysC = Void Function(BackendType backend, Pointer library);
typedef _GenKeys = void Function(int backend, Pointer library);

final _GenKeys _c_gen_keys =
    dylib.lookup<NativeFunction<_GenKeysC>>('generate_keys').asFunction();

// --- relinearization ---

typedef _GenRelinKeysC = Void Function(BackendType backend, Pointer library);
typedef _GenRelinKeys = void Function(int backend, Pointer library);

final _GenRelinKeys _c_gen_relin_keys =
    dylib.lookup<NativeFunction<_GenRelinKeysC>>('generate_relin_keys').asFunction();

typedef _RelinCiphertextC = Pointer Function(
    BackendType backend, Pointer library, Pointer ciphertext);
typedef _RelinCiphertext = Pointer Function(
    int backend, Pointer library, Pointer ciphertext);

final _RelinCiphertext _c_relin_ciphertext = dylib
    .lookup<NativeFunction<_RelinCiphertextC>>('relinearize')
    .asFunction();

// --- encrypt ---

typedef _EncryptC = Pointer Function(
    Int backend, Pointer library, Pointer plaintext);

typedef _Encrypt = Pointer Function(
    int backend, Pointer library, Pointer plaintext);

final _Encrypt _c_encrypt =
    dylib.lookup<NativeFunction<_EncryptC>>('encrypt').asFunction();

// --- decrypt ---

typedef _DecryptC = Pointer Function(
    Int backend, Pointer library, Pointer plaintext);

typedef _Decrypt = Pointer Function(
    int backend, Pointer library, Pointer plaintext);

final _Decrypt _c_decrypt =
    dylib.lookup<NativeFunction<_EncryptC>>('decrypt').asFunction();
