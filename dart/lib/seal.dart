/// Microsoft SEAL Library Wrapper
/// 
/// This Dart package provides a wrapper for the Microsoft SEAL library, a homomorphic encryption library developed by Microsoft Research.
/// This package allows developers to use the cryptographic tools provided by Microsoft SEAL to perform computations on encrypted data.
/// 
/// For more information about Microsoft SEAL, see: https://github.com/Microsoft/SEAL
library seal;

import 'package:fhel/afhe.dart';
import 'dart:ffi';

// Components
part 'afhe/serial.dart';

/// A wrapper for the Microsoft SEAL library.
/// 
/// This class extends [Afhe] and provides additional functionalities specific to Microsoft SEAL.
class Seal extends Afhe {
  /// Creates a new instance of the SEAL backend with a given scheme.
  ///
  /// The [scheme] parameter specifies the encryption scheme to use.
  Seal(String scheme) : super('seal', scheme);

  /// Creates a new instance of the SEAL backend without a scheme.
  ///
  /// This constructor is used when loading parameters from a saved context.
  Seal.noScheme() : super.noScheme('seal');

  /// Creates a new [Plaintext] object from a string.
  ///
  /// The [value] parameter specifies the string to encrypt.
  Plaintext plain(String value) => Plaintext.withValue(backend, value);

  /// Creates a new, empty [Ciphertext] object.
  Ciphertext cipher() => Ciphertext(backend);

  /// Generate a [SealKey] representing a publicKey.
  SealKey get publicKey => SealKey("public", super.publicKey.obj);

  /// Generate a [SealKey] representing a secretKey.
  SealKey get secretKey => SealKey("secret", super.secretKey.obj);

  /// Generate a [SealKey] representing a relinKeys.
  SealKey get relinKeys => SealKey("relin", super.relinKeys.obj);

  /// Validate Serialized Encryption Parameters
  @override
  Map saveParameters() {
    final params = super.saveParameters();
    sealMagicNumber(params['header'], params['size']);
    return params;
  }

  /// Validates a serialized ciphertext and returns it as a [Ciphertext] object.
  ///
  /// This method overrides the [loadCiphertext] method in the [Afhe] class.
  @override
  Ciphertext loadCiphertext(Pointer<Uint8> data, int size) {
    sealMagicNumber(data, size);
    return super.loadCiphertext(data, size);
  }
}

/// Represents an underlying key object in memory
///
/// Extends [Key] to perform SEAL validation on [save] and [load] operations.
/// Performs a magic number check on the serialized data.
///
class SealKey extends Key {
  /// Constructs a key referencing the underlying C [obj] in memory
  /// 
  /// The [type] and [name] are used to classify the type of key
  SealKey(super.name, super.obj);

  /// Constructs a key from the existing [SealKey]
  SealKey.ofType(SealKey key) : super(key.name, nullptr);

  /// Load a key from a serialized data
  /// 
  /// The [fhe] library is used to validate the serialized data
  /// The [serialData] is the serialized data of [serialSize] bytes
  @override
  void load(Pointer fhe, Pointer<Uint8> serialData, int serialSize) {
    sealMagicNumber(serialData, serialSize);
    super.load(fhe, serialData, serialSize);
  }

  /// Save the key to a serialized data
  @override
  void save() {
    super.save();
    sealMagicNumber(serialized, size);
  }
}
