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

// --- subtract ---

typedef SubC = Pointer Function(
    Int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

typedef Sub = Pointer Function(
    int backend, Pointer library, Pointer ciphertext1, Pointer ciphertext2);

final Sub c_subtract = dylib.lookup<NativeFunction<SubC>>('subtract').asFunction();
