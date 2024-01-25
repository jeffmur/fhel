import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/ffi.dart' show dylib;
import 'package:fhe/afhe/type.dart' show BackendType, Backend;

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

class Plaintext {
  String text = "";
  Backend backend = Backend();
  Pointer library = nullptr;

  Plaintext(this.backend) {
    library = c_init_plaintext(backend.value);
  }

  Plaintext.withValue(this.backend, this.text) {
    set(text);
  }

  set(String text) {
    this.text = text;
    library = c_init_plaintext_value(backend.value, text.toNativeUtf8());
  }
}

// void main() {
//   final backend = Backend.set("seal");
//   final plaintext = Plaintext(backend);
//   print(plaintext.backend.name);
//   print(plaintext.text);

//   final plaintext2 = Plaintext.withValue(backend, "1234");
//   print(plaintext2.backend.name);
//   print(plaintext2.text);
// }
