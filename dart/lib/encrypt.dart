import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/ffi.dart' show dylib;
import 'package:fhe/backend.dart' show BackendType, Backend;

typedef InitPlaintextC = Pointer Function(BackendType backend);
typedef InitPlaintext = Pointer Function(int backend);

final InitPlaintext c_init_plaintext =
    dylib.lookup<NativeFunction<InitPlaintextC>>('init_plaintext').asFunction();

typedef InitPlaintextValueC = Pointer Function(
    BackendType backend, Pointer<Utf8> text);
typedef InitPlaintextValue = Pointer Function(int backend, Pointer<Utf8> text);

final InitPlaintextValue c_init_plaintext_value = dylib
    .lookup<NativeFunction<InitPlaintextValueC>>('init_plaintext_value')
    .asFunction();