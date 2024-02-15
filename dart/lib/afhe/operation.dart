import 'dart:ffi';
// import 'package:ffi/ffi.dart'; // for Utf8
// import 'package:fhel/afhe/plaintext.dart';
import 'package:fhel/ffi.dart' show dylib;

// --- add ---

typedef AddC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

typedef Add = Pointer Function(
    int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

final Add c_add = dylib.lookup<NativeFunction<AddC>>('add').asFunction();

typedef AddPlainC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

typedef AddPlain = Pointer Function(
    int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

final AddPlain c_add_plain = dylib.lookup<NativeFunction<AddPlainC>>('add_plain').asFunction();

// --- subtract ---

typedef SubC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

typedef Sub = Pointer Function(
    int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

final Sub c_subtract = dylib.lookup<NativeFunction<SubC>>('subtract').asFunction();

typedef SubPlainC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

typedef SubPlain = Pointer Function(
    int backend, Pointer library, Pointer ciphertext, Pointer plaintext);

final SubPlain c_subtract_plain = dylib.lookup<NativeFunction<SubPlainC>>('subtract_plain').asFunction();
