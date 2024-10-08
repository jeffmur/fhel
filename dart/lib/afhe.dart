/// Adapter for Fully Homomorphic Encryption (FHE) libraries.
///
/// This library provides a flexible interface for users to interact with supported C++ FHE libraries.
/// Typically, the user will interact with an implementation of the [Afhe] class, rather than the abstract class directly.
///
library afhe;

import 'dart:ffi';
import 'dart:typed_data'; // For Uint8List
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
part 'afhe/key.dart';

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
    backend = Backend.set(backendName);
    scheme = Scheme.set(schemeName);
    library = _c_init_backend(backend.value);
    raiseForStatus();
  }

  /// Initializes the [Backend] without a [Scheme].
  ///
  /// Typically used for loading parameters from a shared session.
  Afhe.noScheme(String backendName) {
    backend = Backend.set(backendName);
    library = _c_init_backend(backend.value);
    scheme = Scheme();
  }

  /// Generates a context for the Brakerski-Fan-Vercauteren (BFV) scheme.
  String _contextBFV(Map context) {
    final ptr = _c_gen_context(
        library,
        scheme.value,
        context['polyModDegree'],
        context['ptModBit'] ?? 0, // Only used when batching
        context['ptMod'] ?? 0, // Not used when batching
        context['secLevel'],
        nullptr,
        0);
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
    if (context['encodeScalar'] == null) {
      throw ArgumentError('encodeScalar is a required parameter for CKKS');
    }
    if (context['qSizes'] == null) {
      throw ArgumentError('qSizes is a required parameter for CKKS');
    }
    if (context['qSizes'] is! List<int>) {
      throw ArgumentError('qSizes must be a list of integers');
    }
    List<int> primeSizes = context['qSizes'];
    final ptr = _c_gen_context(
        library,
        scheme.value,
        context['polyModDegree'],
        context['encodeScalar'],
        0, // Plain Modulus is not used
        0, // Security Level is not used
        intListToUint64Array(primeSizes),
        primeSizes.length);
    raiseForStatus();
    return ptr.toDartString();
  }

  /// Generates a context for the encryption scheme.
  ///
  /// The [context] is a map of parameters used to generate the encryption context for the [Scheme].
  String genContext(Map context) {
    return switch (scheme.name) {
      "bfv" => _contextBFV(context),
      "bgv" => _contextBGV(context),
      "ckks" => _contextCKKS(context),
      _ => "error: Invalid Scheme"
    };
  }

  /// Loads the encryption context from a string.
  ///
  /// Used for generating a shared session.
  String genContextFromParameters(Map parameters) {
    final ptr = _c_gen_context_from_str(
        library, parameters['header'], parameters['size']);
    raiseForStatus();
    return ptr.toDartString();
  }

  /// Returns the number of slots based on parameters.
  int get slotCount => _c_slot_count(library);

  /// Returns the string representation of FHE parameters.
  ///
  /// Useful for saving to disk or sending over the network.
  /// The `header` is the string representation of the parameters.
  /// The `size` is the length of the string.
  Map saveParameters() {
    final params = _c_save_params(library);
    final paramSize = _c_save_params_size(library);
    raiseForStatus();
    return {
      "header": params,
      "size": paramSize,
    };
  }

  /// Generates the public and secret keys for the encryption and decryption.
  void genKeys() {
    _c_gen_keys(library);
    raiseForStatus();
  }

  /// Generates the relinearization keys derived from the secret key.
  ///
  /// Requires the secret key to be generated first via genKeys().
  void genRelinKeys() {
    _c_gen_relin_keys(library);
    raiseForStatus();
  }

  /// Fetch the public key.
  Key get publicKey => Key("public", _c_get_public_key(library));

  /// Fetch the secret key.
  Key get secretKey => Key("secret", _c_get_secret_key(library));

  /// Fetch the relinearization keys.
  Key get relinKeys => Key("relin", _c_get_relin_keys(library));

  /// Encrypts the plaintext message.
  Ciphertext encrypt(Plaintext plaintext) {
    final ptr = _c_encrypt(library, plaintext.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Decrypts the ciphertext message.
  Plaintext decrypt(Ciphertext ciphertext) {
    Pointer ptr = _c_decrypt(library, ciphertext.obj);
    raiseForStatus();

    /// String cannot be extracted from C object
    if (scheme.name.toLowerCase() == "ckks") {
      return Plaintext.fromPointer(backend, ptr, extractStr: false);
    }
    return Plaintext.fromPointer(backend, ptr);
  }

  /// Returns the invariant noise budget of the [Ciphertext].
  int invariantNoiseBudget(Ciphertext ciphertext) {
    int n = _c_invariant_noise_budget(library, ciphertext.obj);
    raiseForStatus();
    return n;
  }

  /// Loads a [Ciphertext] from a non-human-readable format.
  ///
  /// Useful for loading from disk or receiving over the network.
  /// The [size] is the length of the data.
  /// The [data] is a pointer to the memory address of the data.
  Ciphertext loadCiphertext(Pointer<Uint8> data, int size) {
    Pointer ptr = _c_load_ciphertext(library, data, size);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Encodes a list of integers into a [Plaintext].
  Plaintext encodeVecInt(List<int> vec) {
    Pointer ptr =
        _c_encode_vector_int(library, intListToUint64Array(vec), vec.length);
    raiseForStatus();
    return Plaintext.fromPointer(backend, ptr);
  }

  /// Decodes a [Plaintext] into a list of integers.
  List<int> decodeVecInt(Plaintext plaintext, int arrayLength) {
    Pointer<Uint64> ptr = _c_decode_vector_int(library, plaintext.obj);
    raiseForStatus();
    return uint64ArrayToIntList(ptr, arrayLength);
  }

  /// Encodes a double into a [Plaintext].
  Plaintext encodeDouble(double value) {
    Pointer ptr = _c_encode_double(library, value);
    raiseForStatus();
    // String cannot be extracted from C object for CKKS
    return Plaintext.fromPointer(backend, ptr, extractStr: false);
  }

  /// Encodes a list of doubles into a [Plaintext].
  Plaintext encodeVecDouble(List<double> vec) {
    Pointer ptr =
        _c_encode_vector_double(library, doubleListToArray(vec), vec.length);
    raiseForStatus();
    // String cannot be extracted from C object for CKKS
    return Plaintext.fromPointer(backend, ptr, extractStr: false);
  }

  /// Decodes a [Plaintext] into a double.
  double decodeDouble(Plaintext plaintext) {
    Pointer<Double> ptr = _c_decode_vector_double(library, plaintext.obj);
    raiseForStatus();
    return ptr[0];
  }

  /// Decodes a [Plaintext] into a list of doubles.
  List<double> decodeVecDouble(Plaintext plaintext, int arrayLength) {
    Pointer<Double> ptr = _c_decode_vector_double(library, plaintext.obj);
    raiseForStatus();
    return arrayToDoubleList(ptr, arrayLength);
  }

  /// Relinearizes the [Ciphertext].
  ///
  /// Typically, the size of the ciphertext grows with each homomorphic operation.
  /// The relinearization process reduces the size of the ciphertext (2).
  Ciphertext relinearize(Ciphertext ciphertext) {
    Pointer ptr = _c_relin_ciphertext(library, ciphertext.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Modulus switches the [Ciphertext] to a next lower level.
  Ciphertext modSwitchNext(Ciphertext ciphertext) {
    _c_mod_switch_next(library, ciphertext.obj);
    raiseForStatus();
    return ciphertext;
  }

  /// Adds two [Ciphertext]s.
  Ciphertext add(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_add(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Adds value of [Plaintext] to the value of [Ciphertext].
  Ciphertext addPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_add_plain(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Subtracts two [Ciphertext]s.
  ///
  /// Results in a new [Ciphertext] with the value of [a] minus the value of [b].
  Ciphertext subtract(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_subtract(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Subtracts value of [Plaintext] from the value of [Ciphertext].
  ///
  /// Results in a new [Ciphertext] with the value of [a] minus the value of [b].
  Ciphertext subtractPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_subtract_plain(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Multiplies two [Ciphertext]s.
  Ciphertext multiply(Ciphertext a, Ciphertext b) {
    Pointer ptr = _c_multiply(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Multiplies a [Ciphertext] by a [Plaintext].
  Ciphertext multiplyPlain(Ciphertext a, Plaintext b) {
    Pointer ptr = _c_multiply_plain(library, a.obj, b.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Squares the [Ciphertext].
  Ciphertext square(Ciphertext a) {
    Pointer ptr = _c_square(library, a.obj);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }

  /// Raises the [Ciphertext] to a [power].
  ///
  /// Only supported for BFV/BGV [Scheme].
  /// The [power] must be a positive integer.
  /// Applies relinearization after each multiplication step.
  Ciphertext power(Ciphertext a, int power) {
    Pointer ptr = _c_power(library, a.obj, power);
    raiseForStatus();
    return Ciphertext.fromPointer(backend, ptr);
  }
}
