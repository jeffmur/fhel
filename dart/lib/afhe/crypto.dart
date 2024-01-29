import 'dart:ffi';
// import 'package:ffi/ffi.dart'; // for Utf8
// import 'package:fhe/afhe/plaintext.dart';
import 'package:fhe/ffi.dart' show dylib;

// --- encrypt ---

typedef EncryptC = Pointer Function(
    Int backend, Pointer library, Pointer plaintext);

typedef Encrypt = Pointer Function(
    int backend, Pointer library, Pointer plaintext);

final Encrypt c_encrypt =
    dylib.lookup<NativeFunction<EncryptC>>('encrypt').asFunction();

// --- decrypt ---

typedef DecryptC = Pointer Function(
    Int backend, Pointer library, Pointer plaintext);

typedef Decrypt = Pointer Function(
    int backend, Pointer library, Pointer plaintext);

final Decrypt c_decrypt =
    dylib.lookup<NativeFunction<EncryptC>>('decrypt').asFunction();
