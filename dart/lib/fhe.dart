library fhe;

import 'dart:ffi';
import 'package:fhe/ciphertext.dart';
import 'package:fhe/plaintext.dart';
import 'package:fhe/ffi.dart' show dylib;
import 'package:fhe/backend.dart';

typedef InitBackendC = Pointer Function(BackendType backend);
typedef InitBackend = Pointer Function(int backend);

final InitBackend c_init_backend =
    dylib.lookup<NativeFunction<InitBackendC>>('init_backend').asFunction();

class FHE {
  Backend backend = Backend();
  Pointer library = nullptr;

  FHE(String name) {
    backend = Backend.set(name);
    library = c_init_backend(backend.value);
  }

  encrypt(Plaintext plaintext) {}

  decrypt(Ciphertext ciphertext) {}
}

void main() {
  final fhe = FHE('seal');
  print(fhe.backend.prettyName);
}
