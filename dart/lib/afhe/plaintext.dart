/// This file contains the `Ciphertext` class and its associated FFI bindings.
part of '../afhe.dart';
// ignore_for_file: non_constant_identifier_names

typedef _InitPlaintextC = Pointer Function(BackendType backend);
typedef _InitPlaintext = Pointer Function(int backend);

final _InitPlaintext _c_init_plaintext =
    dylib.lookup<NativeFunction<_InitPlaintextC>>('init_plaintext').asFunction();

typedef _InitPlaintextValueC = Pointer Function(BackendType backend, Pointer<Utf8> text);
typedef _InitPlaintextValue = Pointer Function(int backend, Pointer<Utf8> text);

final _InitPlaintextValue _c_init_plaintext_value = dylib
    .lookup<NativeFunction<_InitPlaintextValueC>>('init_plaintext_value')
    .asFunction();

typedef _PlaintextC = Pointer<Utf8> Function(Pointer plaintext);

final _PlaintextC _c_get_plaintext = dylib
    .lookup<NativeFunction<_PlaintextC>>('get_plaintext_value')
    .asFunction();

/// Represents an underlying C plaintext object.
///
/// A plaintext is a message that has not been encrypted. It is the input to the encryption and
/// operation functions, and the output of the decryption function.
///
class Plaintext {
  /// Represents the value of the plaintext.
  String text = "";
  /// Selects the [Backend] used for the encryption scheme.
  Backend backend = Backend();
  /// A pointer to the memory address of the underlying C++ object.
  Pointer obj = nullptr;

  /// Initializes a plaintext using the provided backend.
  Plaintext(this.backend) {
    obj = _c_init_plaintext(backend.value);
  }

  /// Initializes a plaintext C [obj] with [text] using the provided [Backend].
  Plaintext.withValue(this.backend, this.text) {
    obj = _c_init_plaintext_value(backend.value, text.toNativeUtf8());
  }

  /// Initializes a plaintext from an existing C [obj].
  /// 
  /// If [extractStr] is true, the string [obj] is extracted from the memory address.
  Plaintext.fromPointer(this.backend, this.obj, {bool extractStr = true}) {
    if (extractStr)
    {
      text = _c_get_plaintext(obj).toDartString();
    }
  }
}
