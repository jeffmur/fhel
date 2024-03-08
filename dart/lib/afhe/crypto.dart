/// This file contains the FFI bindings for encryption and decryption methods.
part of '../afhe.dart';

// --- encryption parameters ---

typedef _SaveParamsC = Pointer<Uint8> Function(Pointer library);
typedef _SaveParams = Pointer<Uint8> Function(Pointer library);
final _SaveParams _c_save_params = dylib
    .lookup<NativeFunction<_SaveParamsC>>('save_parameters').asFunction();

typedef _SaveParamsSizeC = Int32 Function(Pointer library);
typedef _SaveParamsSize = int Function(Pointer library);
final _SaveParamsSize _c_save_params_size = dylib
    .lookup<NativeFunction<_SaveParamsSizeC>>('save_parameters_size')
    .asFunction();

typedef _SaveParamsBytesC = Pointer<Uint8> Function(Pointer library);
typedef _SaveParamsBytes = Pointer<Uint8> Function(Pointer library);
final _SaveParamsBytes _c_save_params_bytes = dylib
    .lookup<NativeFunction<_SaveParamsBytesC>>('save_parameters_bytes')
    .asFunction();

typedef _LoadParamsC = Void Function(Pointer library, Pointer<Uint8> params, Int size);
typedef _LoadParams = void Function(Pointer library, Pointer<Uint8> params, int size);
final _LoadParams _c_load_params_bytes = dylib
    .lookup<NativeFunction<_LoadParamsC>>('load_parameters_bytes').asFunction();

// --- context ---

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

typedef _GenContextFromStrC = Pointer<Utf8> Function(
    Pointer library, Pointer<Uint8> context_str, Int context_size);

typedef _GenContextFromStr = Pointer<Utf8> Function(
    Pointer library, Pointer<Uint8> context_str, int context_size);

final _GenContextFromStr _c_gen_context_from_str = dylib
    .lookup<NativeFunction<_GenContextFromStrC>>('generate_context_from_str')
    .asFunction();

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
