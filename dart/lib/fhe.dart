library fhe;

import 'dart:ffi';
import 'package:fhel/afhe/codec.dart';
import 'package:fhel/afhe/crypto.dart';
import 'package:fhel/ffi.dart' show dylib;
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhel/afhe/type.dart';
import 'package:fhel/afhe/plaintext.dart';
import 'package:fhel/afhe/ciphertext.dart';
import 'package:fhel/afhe/operation.dart';

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

typedef InvariantNoiseBudgetC = Int32 Function(
    BackendType backend, Pointer library, Pointer ciphertext);

typedef InvariantNoiseBudget = int Function(
    int backend, Pointer library, Pointer ciphertext);

final InvariantNoiseBudget c_invariant_noise_budget = dylib
    .lookup<NativeFunction<InvariantNoiseBudgetC>>('invariant_noise_budget')
    .asFunction();

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
        context['ptModBit'] ?? 0, // Only used when batching
        context['ptMod'] ?? 0, // Not used when batching
        context['secLevel']);

    return ptr.toDartString();
  }

  String genBGVContext(Map context) {
    return "Not Implemented";
  }

  String genCKKSContext(Map context) {
    return "Not Implemented";
  }

  String genContext(Map<String, int> context) {
    return switch (scheme.name) {
      "bfv" => genBFVContext(context),
      "bgv" => genBGVContext(context),
      "ckks" => genCKKSContext(context),
      _ => "error: Invalid Scheme"
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

  int invariantNoiseBudget(Ciphertext ciphertext) {
    return c_invariant_noise_budget(backend.value, library, ciphertext.library);
  }

  Plaintext encodeVecInt(List<int> vec) {
    Pointer ptr = c_encode_vector_int(
        backend.value, library, intListToArray(vec), vec.length);

    return Plaintext.fromObject(backend, ptr);
  }

  List<int> decodeVecInt(Plaintext plaintext, int arrayLength) {
    return arrayToIntList(
        c_decode_vector_int(backend.value, library, plaintext.obj),
        arrayLength);
  }

  Ciphertext add(Ciphertext a, Ciphertext b) {
    Pointer ptr = c_add(backend.value, library, a.library, b.library);

    Ciphertext ctx = Ciphertext(backend);
    ctx.library = ptr;
    return ctx;
  }
}
