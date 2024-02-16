/// This files contains types of schemes supported by backend libraries
part of '../afhe.dart';

typedef SchemeType = Int;

typedef _StringtoSchemeTypeC = SchemeType Function(Pointer<Utf8> scheme);
typedef _StringToSchemeType = int Function(Pointer<Utf8> scheme);

final _StringToSchemeType _c_string_to_scheme_type = dylib
    .lookup<NativeFunction<_StringtoSchemeTypeC>>('scheme_t_from_string')
    .asFunction();

/// Represents the supported schemes used by the backend.
///
/// Supported schemes:
///  * Brakerski-Fan-Vercauteren (BFV) scheme supports integer arithmetic, ciphertext coefficent uses Most Significant Bits (MSB).
///  * Brakerski-Gentry-Vaikuntanathan (BGV) scheme supports integer arithmetic, ciphertext coefficent uses Least Significant Bits (LSB).
///  * Cheon-Kim-Kim-Song (CKKS) scheme supports approximate real-number arithmetic.
///
class Scheme {
  /// The integer value of the scheme.
  int value = 0;
  /// The friendly name of the scheme.
  String name = "";

  /// Initializes an unspecified scheme.
  Scheme();

  /// Initializes a scheme using the provided name.
  ///
  /// The name is case-insensitive. Retrieves the integer value of the scheme from the C++ backend.
  Scheme.set(String fromName) {
    String lowerName = fromName.toLowerCase();
    value = _c_string_to_scheme_type(lowerName.toNativeUtf8());
    name = fromName;
  }
}
