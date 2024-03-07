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
