library fhe;

import 'dart:ffi';
import 'package:fhe/afhe/crypto.dart';
import 'package:fhe/ffi.dart' show dylib;
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/afhe/type.dart';
import 'package:fhe/afhe/plaintext.dart';
import 'package:fhe/afhe/ciphertext.dart';
import 'package:fhe/afhe/operation.dart';

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

  String genBFVContext(Map context) {
    final ptr = c_gen_context(
        backend.value,
        library,
        scheme.value,
        context['polyModDegree'],
        context['ptModBit'] ?? 0, // Not used in BFV (maybe batching?)
        context['ptMod'],
        context['secLevel']);

    return ptr.toDartString();
  }

  String genBGVContext(Map context) {
    return "Not implemented";
  }

  String genCKKSContext(Map context) {
    return "Not implemented";
  }

  String genContext(Map<String, int> context) {
    return switch (scheme.name) {
      "" => "Scheme not set",
      "bfv" => genBFVContext(context),
      "bgv" => genBGVContext(context),
      "ckks" => genCKKSContext(context),
      _ => "Invalid scheme"
    };
  }

  void genKeys() {
    c_gen_keys(backend.value, library);
  }

  Ciphertext encrypt(Plaintext plaintext) {
    final ptr = c_encrypt(backend.value, library, plaintext.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.library = ptr;
    return ctx;
  }

  Plaintext decrypt(Ciphertext ciphertext) {
    Pointer ptr = c_decrypt(backend.value, library, ciphertext.library);

    Plaintext ptx = Plaintext.fromObject(backend, ptr);
    return ptx;
  }

  Ciphertext add(Ciphertext a, Ciphertext b) {
    Pointer ptr = c_add(backend.value, library, a.library, b.library);

    Ciphertext ctx = Ciphertext(backend);
    ctx.library = ptr;
    return ctx;
  }
}

// void main() {
//   final fhe = FHE.withScheme('seal', 'bfv');
//   print(fhe.genContext(4096, 20, 1024, 128));
//   fhe.genKeys();

//   // Max is 399. TODO: WHY?!
//   Plaintext pt_x = Plaintext.withValue(fhe.backend, "100");
//   Plaintext pt_add = Plaintext.withValue(fhe.backend, "80");

//   print("<dart> pt_x: ${pt_x.text}");
//   print("<dart> pt_add: ${pt_add.text}");

//   Ciphertext ct_x = fhe.encrypt(pt_x);
//   Ciphertext ct_add = fhe.encrypt(pt_add);

//   Ciphertext ct_res = fhe.add(ct_x, ct_add);

//   Plaintext res = fhe.decrypt(ct_res);

//   print(res.text);

//   // print(cipher.library);
// }
