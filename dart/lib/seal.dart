/// Microsoft SEAL
library seal;

import 'package:fhel/afhe.dart';
import 'dart:ffi';

/// Expose basic functionalities of Microsoft SEAL.
///
/// “Microsoft SEAL (Release 4.1),” January 2023. https://github.com/Microsoft/SEAL.
///
class Seal extends Afhe {
  /// Instanciates SEAL [Backend] with [Scheme]
  Seal(String scheme) : super('seal', scheme);

  /// Instanciates SEAL [Backend] without [Scheme]
  /// Used for loading parameters from a saved context.
  Seal.noScheme() : super.noScheme('seal');

  /// Generate a [Plaintext] object from a string.
  Plaintext plain(String value) => Plaintext.withValue(backend, value);

  /// Generate a empty [Ciphertext] object.
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

  /// Validate Serialized Ciphertext
  @override
  Ciphertext loadCiphertext(Pointer<Uint8> data, int size) {
    sealMagicNumber(data, size);
    return super.loadCiphertext(data, size);
  }
}

/// Perform a magic number check on the serialized SEAL data
///
class SealKey extends Key {
  /// Constructs a key referencing the underlying C [obj] in memory
  /// 
  /// The [type] and [name] are used to classify the type of key
  SealKey(String name, Pointer obj) : super(name, obj);

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
