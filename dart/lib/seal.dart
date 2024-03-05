/// Microsoft SEAL
library seal;

import 'package:fhel/afhe.dart';

/// Expose basic functionalities of Microsoft SEAL.
///
/// “Microsoft SEAL (Release 4.1),” January 2023. https://github.com/Microsoft/SEAL.
///
class Seal extends Afhe {
  /// Instanciates SEAL [Backend] with [Scheme]
  Seal(String scheme) : super('seal', scheme);

  Seal.noScheme() : super.noScheme('seal');

  /// Generate a [Plaintext] object from a string.
  Plaintext plain(String value) => Plaintext.withValue(backend, value);

  /// Generate a empty [Ciphertext] object.
  Ciphertext cipher() => Ciphertext(backend);
}
