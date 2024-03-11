/// This file contains the FFI bindings for encryption and decryption methods.
part of '../afhe.dart';
// ignore_for_file: non_constant_identifier_names

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

// --- slot count ---

typedef _SlotCountC = Int32 Function(Pointer library);
typedef _SlotCount = int Function(Pointer library);
final _SlotCount _c_slot_count = dylib
    .lookup<NativeFunction<_SlotCountC>>('get_slot_count').asFunction();

// --- relinearization ---

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
