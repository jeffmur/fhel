/// This file contains the FFI bindinds for operations on the plaintext and ciphertext objects.
part of '../afhe.dart';

// --- add ---

typedef _AddC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

typedef _Add = Pointer Function(
    int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

final _Add _c_add = dylib.lookup<NativeFunction<_AddC>>('add').asFunction();

typedef _AddPlainC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

typedef _AddPlain = Pointer Function(
    int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

final _AddPlain _c_add_plain = dylib.lookup<NativeFunction<_AddPlainC>>('add_plain').asFunction();

// --- subtract ---

typedef _SubC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

typedef _Sub = Pointer Function(
    int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

final _Sub _c_subtract = dylib.lookup<NativeFunction<_SubC>>('subtract').asFunction();

typedef _SubPlainC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

typedef _SubPlain = Pointer Function(
    int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

final _SubPlain _c_subtract_plain = dylib.lookup<NativeFunction<_SubPlainC>>('subtract_plain').asFunction();
