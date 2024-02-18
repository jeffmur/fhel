/// Adapter for Fully Homomorphic Encryption (FHE) libraries.
///
/// This library provides a flexible interface for users to interact with supported C++ FHE libraries.
/// Typically, the user will interact with an implementation of the [Afhe] class, rather than the abstract class directly.
///
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
part 'afhe/errors.dart';

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
    raiseForStatus();
    return ptr.toDartString();
  }

  // Generates a context for the Brakerski-Gentry-Vaikuntanathan (BGV) scheme.
  String _contextBGV(Map context) {
    // No parameter changes
    return _contextBFV(context);
  }

  /// Generates a context for the Cheon-Kim-Kim-Song (CKKS) scheme.
  String _contextCKKS(Map context) {
    throw (Exception("Unsupported scheme ckks"));
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
    raiseForStatus();
  }

  /// Generates the relinearization keys derived from the secret key.
  ///
  /// Requires the secret key to be generated first via genKeys().
  void genRelinKeys() {
    _c_gen_relin_keys(backend.value, library);
    raiseForStatus();
  }

  /// Encrypts the plaintext message.
  Ciphertext encrypt(Plaintext plaintext) {
    final ptr = _c_encrypt(backend.value, library, plaintext.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Decrypts the ciphertext message.
  Plaintext decrypt(Ciphertext ciphertext) {
    Pointer ptr = _c_decrypt(backend.value, library, ciphertext.obj);
    raiseForStatus();
    return Plaintext.fromPointer(backend, ptr);
  }

  /// Returns the invariant noise budget of the [Ciphertext].
  int invariantNoiseBudget(Ciphertext ciphertext) {
    int n = _c_invariant_noise_budget(backend.value, library, ciphertext.obj);
    raiseForStatus();
    return n;
  }

  /// Encodes a list of integers into a [Plaintext].
  Plaintext encodeVecInt(List<int> vec) {
    Pointer ptr = _c_encode_vector_int(
        backend.value, library, intListToArray(vec), vec.length);
    raiseForStatus();
    return Plaintext.fromPointer(backend, ptr);
  }

  /// Decodes a [Plaintext] into a list of integers.
  List<int> decodeVecInt(Plaintext plaintext, int arrayLength) {
    Pointer<Uint64> ptr = _c_decode_vector_int(backend.value, library, plaintext.obj);
    raiseForStatus();
    return arrayToIntList(ptr, arrayLength);
  }

  /// Relinearizes the [Ciphertext].
  ///
  /// Typically, the size of the ciphertext grows with each homomorphic operation.
  /// The relinearization process reduces the size of the ciphertext (2).
  Ciphertext relinearize(Ciphertext ciphertext) {
    Pointer ptr = _c_relin_ciphertext(backend.value, library, ciphertext.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Adds two [Ciphertext]s.
  Ciphertext add(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_add(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Adds value of [Plaintext] to the value of [Ciphertext].
  Ciphertext addPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_add_plain(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Subtracts two [Ciphertext]s.
  ///
  /// Results in a new [Ciphertext] with the value of [a] minus the value of [b].
  Ciphertext subtract(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_subtract(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Subtracts value of [Plaintext] from the value of [Ciphertext].
  ///
  /// Results in a new [Ciphertext] with the value of [a] minus the value of [b].
  Ciphertext subtractPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_subtract_plain(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Multiplies two [Ciphertext]s.
  Ciphertext multiply(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_multiply(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Multiplies a [Ciphertext] by a [Plaintext].
  Ciphertext multiplyPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_multiply_plain(backend.value, library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }
}
