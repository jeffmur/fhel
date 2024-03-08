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

  /// Validates serialized encryption parameters and returns them as a map.
  ///
  /// This method overrides the [saveParameters] method in the [Afhe] class.
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
