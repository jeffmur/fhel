/// This file contains the FFI bindings for encryption and decryption methods.
part of '../afhe.dart';

// --- encryption parameters ---

typedef _GenContextC = Pointer<Utf8> Function(
    Pointer library,
    Int32 scheme,
    Uint64 poly_mod_degree,
    Uint64 pt_mod_bit,
    Uint64 pt_mod,
    Uint64 sec_level,
    Pointer<Uint64> prime_sizes,
    Uint64 prime_sizes_length);

typedef _GenContext = Pointer<Utf8> Function(
  Pointer library,
  int scheme,
  int poly_mod_degree,
  int pt_mod_bit,
  int pt_mod,
  int sec_level,
  Pointer<Uint64> prime_sizes,
  int prime_sizes_length);

final _GenContext _c_gen_context = dylib
    .lookup<NativeFunction<_GenContextC>>('generate_context').asFunction();

// --- encryption keys ---

typedef _GenKeysC = Void Function(Pointer library);
typedef _GenKeys = void Function(Pointer library);
final _GenKeys _c_gen_keys = dylib
    .lookup<NativeFunction<_GenKeysC>>('generate_keys').asFunction();

// --- relinearization ---

typedef _GenRelinKeysC = Void Function(Pointer library);
typedef _GenRelinKeys = void Function(Pointer library);
final _GenRelinKeys _c_gen_relin_keys = dylib
    .lookup<NativeFunction<_GenRelinKeysC>>('generate_relin_keys').asFunction();

typedef _RelinCiphertextC = Pointer Function(Pointer library, Pointer ciphertext);
final _RelinCiphertextC _c_relin_ciphertext = dylib
    .lookup<NativeFunction<_RelinCiphertextC>>('relinearize')
    .asFunction();

// --- encrypt ---

typedef _EncryptC = Pointer Function(Pointer library, Pointer plaintext);
final _EncryptC _c_encrypt = dylib
    .lookup<NativeFunction<_EncryptC>>('encrypt').asFunction();

// --- decrypt ---

typedef _DecryptC = Pointer Function(Pointer library, Pointer plaintext);

final _DecryptC _c_decrypt = dylib
    .lookup<NativeFunction<_DecryptC>>('decrypt').asFunction();
