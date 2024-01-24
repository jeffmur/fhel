import 'dart:ffi';
import 'package:fhe/afhe/backend.dart' show BackendType, Backend;
import 'package:fhe/ffi.dart' show dylib;

typedef InitCiphertextC = Pointer Function(BackendType backend);
typedef InitCiphertext = Pointer Function(int backend);

final InitCiphertext c_init_ciphertext = dylib
    .lookup<NativeFunction<InitCiphertextC>>('init_ciphertext')
    .asFunction();

class Ciphertext {
  String text = "";
  Backend backend = Backend();
  Pointer library = nullptr;

  Ciphertext(this.backend) {
    library = c_init_ciphertext(backend.value);
  }
}

// void main() {
//   final backend = Backend.set("seal");
//   final ciphertext = Ciphertext(backend);
//   print(ciphertext.backend.name);
//   print(ciphertext.text);
// }
