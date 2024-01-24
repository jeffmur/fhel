library fhe;

import 'dart:ffi';
// import 'package:fhe/ciphertext.dart';
// import 'package:fhe/plaintext.dart';
import 'package:fhe/ffi.dart' show dylib;
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/afhe/backend.dart';
import 'package:fhe/afhe/scheme.dart';

typedef InitBackendC = Pointer Function(BackendType backend);
typedef InitBackend = Pointer Function(int backend);

final InitBackend c_init_backend =
    dylib.lookup<NativeFunction<InitBackendC>>('init_backend').asFunction();

typedef GenContextC = Pointer<Utf8> Function(
    BackendType backend,
    Pointer library,
    Int32 scheme,
    Int64 poly_mod_degree,
    Int64 pt_mod_bit,
    Int64 pt_mod,
    Int64 sec_level);

typedef GenContext = Pointer<Utf8> Function(int backend, Pointer library,
    int scheme, int poly_mod_degree, int pt_mod_bit, int pt_mod, int sec_level);

final GenContext c_gen_context =
    dylib.lookup<NativeFunction<GenContextC>>('generate_context').asFunction();

typedef GenKeysC = Void Function(BackendType backend, Pointer library);
typedef GenKeys = void Function(int backend, Pointer library);

final GenKeys c_gen_keys =
    dylib.lookup<NativeFunction<GenKeysC>>('generate_keys').asFunction();

class FHE {
  Scheme scheme = Scheme();
  Backend backend = Backend();
  Pointer library = nullptr;
  String publicKey = "";
  String secretKey = "";

  FHE(String name) {
    scheme = Scheme.set(name);
    backend = Backend.set(name);
    library = c_init_backend(backend.value);
  }

  FHE.withScheme(String backendName, String schemeName) {
    scheme = Scheme.set(schemeName);
    backend = Backend.set(backendName);
    library = c_init_backend(backend.value);
  }

  String genContext(int polyModDegree, int ptModBit, int ptMod, int secLevel) {
    final ptr = c_gen_context(backend.value, library, scheme.value,
        polyModDegree, ptModBit, ptMod, secLevel);

    return ptr.toDartString();
  }

  void genKeys() {
    c_gen_keys(backend.value, library);
  }

  // encrypt(Plaintext plaintext) {}

  // decrypt(Ciphertext ciphertext) {}
}

void main() {
  final fhe = FHE.withScheme('seal', 'bfv');
  print(fhe.scheme.name);
  print(fhe.scheme.value);
  print(fhe.genContext(8192, 20, 0, 128));
  print(fhe.genContext(4096, 20, 1024, 128));
}
