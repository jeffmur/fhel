import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhel/ffi.dart' show dylib;
import 'package:fhel/afhe/type.dart' show BackendType, Backend;

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

typedef GetPlaintextC = Pointer<Utf8> Function(Pointer plaintext);
typedef GetPlaintext = Pointer<Utf8> Function(Pointer plaintext);

final GetPlaintext c_get_plaintext = dylib
    .lookup<NativeFunction<GetPlaintextC>>('get_plaintext_value')
    .asFunction();

class Plaintext {
  String text = "";
  Backend backend = Backend();
  Pointer obj = nullptr;

  Plaintext(this.backend) {
    obj = c_init_plaintext(backend.value);
  }

  Plaintext.withValue(this.backend, this.text) {
    // print(obj);
    obj = c_init_plaintext_value(backend.value, text.toNativeUtf8());
    // print(obj);
  }

  Plaintext.fromObject(this.backend, this.obj) {
    text = c_get_plaintext(obj).toDartString();
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
