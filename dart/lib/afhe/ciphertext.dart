import 'dart:ffi';
import 'package:fhel/afhe/type.dart' show BackendType, Backend;
import 'package:fhel/ffi.dart' show dylib;

typedef InitCiphertextC = Pointer Function(BackendType backend);
typedef InitCiphertext = Pointer Function(int backend);

final InitCiphertext c_init_ciphertext = dylib
    .lookup<NativeFunction<InitCiphertextC>>('init_ciphertext')
    .asFunction();

class Ciphertext {
  String text = "";
  Backend backend = Backend();
  Pointer obj = nullptr;

  Ciphertext(this.backend) {
    obj = c_init_ciphertext(backend.value);
  }
}

// void main() {
//   final backend = Backend.set("seal");
//   final ciphertext = Ciphertext(backend);
//   print(ciphertext.backend.name);
//   print(ciphertext.text);
// }
