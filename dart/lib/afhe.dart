/// Abstract Fully Homomorphic Encryption
library afhe;

import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'dart:io' show Directory, Platform;
import 'package:path/path.dart' as path;

/// Components
part 'ffi.dart';
part 'afhe/scheme.dart';
part 'afhe/backend.dart';
part 'afhe/plaintext.dart';
part 'afhe/ciphertext.dart';
part 'afhe/operation.dart';
part 'afhe/crypto.dart';
part 'afhe/codec.dart';

/// Abstract Fully Homomorphic Encryption
///
/// It provides the ability to generate encryption contexts, keys, and perform operations on plaintexts and ciphertexts.
///
class Afhe {
  /// The encryption scheme used by the backend.
  ///
  /// The [Scheme] is used to represent one of the supported fhe schemes.
  Scheme scheme = Scheme();
  /// The backend library used for the encryption scheme.
  ///
  /// The [Backend] is used to represent one of the supported fhe backends.
  Backend backend = Backend();
  /// A pointer to the memory address of the underlying C++ object.
  Pointer library = nullptr;

  /// Default Constructor initializes [Backend] with [Scheme].
  ///
  /// The [library] stores the memory address of the underlying C++ object.
  Afhe(String backendName, String schemeName) {
    scheme = Scheme.set(schemeName);
    backend = Backend.set(backendName);
    library = _c_init_backend(backend.value);
  }

  /// Generates a context for the Brakerski-Fan-Vercauteren (BFV) scheme.
  String _contextBFV(Map context) {
    final ptr = _c_gen_context(
        backend.value,
        library,
        scheme.value,
        context['polyModDegree'],
        context['ptModBit'] ?? 0, // Only used when batching
        context['ptMod'] ?? 0, // Not used when batching
        context['secLevel']);

    return ptr.toDartString();
  }

  // Generates a context for the Brakerski-Gentry-Vaikuntanathan (BGV) scheme.
  String _contextBGV(Map context) {
    // No parameter changes
    return _contextBFV(context);
  }

  /// Generates a context for the Cheon-Kim-Kim-Song (CKKS) scheme.
  String _contextCKKS(Map context) {
    return "Not Implemented";
  }

  /// Generates a context for the encryption scheme.
  ///
  /// The [context] is a map of parameters used to generate the encryption context for the [Scheme].
  String genContext(Map<String, int> context) {
    return switch (scheme.name) {
      "bfv" => _contextBFV(context),
      "bgv" => _contextBGV(context),
      "ckks" => _contextCKKS(context),
      _ => "error: Invalid Scheme"
    };
  }

  /// Generates the public and secret keys for the encryption and decryption.
  void genKeys() {
    _c_gen_keys(backend.value, library);
  }

  /// Generates the relinearization keys derived from the secret key.
  ///
  /// Requires the secret key to be generated first via genKeys().
  void genRelinKeys() {
    // TODO: Add check for secret key
    _c_gen_relin_keys(backend.value, library);
  }

  /// Encrypts the plaintext message.
  Ciphertext encrypt(Plaintext plaintext) {
    final ptr = _c_encrypt(backend.value, library, plaintext.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.obj = ptr;
    return ctx;
  }

  /// Decrypts the ciphertext message.
  Plaintext decrypt(Ciphertext ciphertext) {
    Pointer ptr = _c_decrypt(backend.value, library, ciphertext.obj);

    Plaintext ptx = Plaintext.fromPointer(backend, ptr);
    return ptx;
  }

  /// Returns the invariant noise budget of the ciphertext.
  int invariantNoiseBudget(Ciphertext ciphertext) {
    return _c_invariant_noise_budget(backend.value, library, ciphertext.obj);
  }

  /// Encodes a list of integers into a plaintext.
  Plaintext encodeVecInt(List<int> vec) {
    Pointer ptr = _c_encode_vector_int(
        backend.value, library, intListToArray(vec), vec.length);

    return Plaintext.fromPointer(backend, ptr);
  }

  /// Decodes a plaintext into a list of integers.
  List<int> decodeVecInt(Plaintext plaintext, int arrayLength) {
    return arrayToIntList(
        _c_decode_vector_int(backend.value, library, plaintext.obj),
        arrayLength);
  }

  /// Relinearizes the [Ciphertext].
  ///
  /// Typically, the size of the ciphertext grows with each homomorphic operation.
  /// The relinearization process reduces the size of the ciphertext (2).
  Ciphertext relinearize(Ciphertext ciphertext) {
    Pointer ptr = _c_relin_ciphertext(backend.value, library, ciphertext.obj);

    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Adds two ciphertexts.
  Ciphertext add(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_add(backend.value, library, a.obj, b.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.obj = ptr;
    return ctx;
  }

  /// Adds a plaintext to a ciphertext.
  Ciphertext addPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_add_plain(backend.value, library, a.obj, b.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.obj = ptr;
    return ctx;
  }

  /// Subtracts two ciphertexts.
  Ciphertext subtract(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_subtract(backend.value, library, a.obj, b.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.obj = ptr;
    return ctx;
  }

  /// Subtracts a plaintext from a ciphertext.
  Ciphertext subtractPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_subtract_plain(backend.value, library, a.obj, b.obj);

    Ciphertext ctx = Ciphertext(backend);
    ctx.obj = ptr;
    return ctx;
  }

  /// Multiplies two ciphertexts.
  Ciphertext multiply(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_multiply(backend.value, library, a.obj, b.obj);

    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Multiplies a ciphertext by a plaintext.
  Ciphertext multiplyPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_multiply_plain(backend.value, library, a.obj, b.obj);

    return Ciphertext.fromPointer(backend, ptr);
  }
}
