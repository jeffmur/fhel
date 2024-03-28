import 'package:fhel/afhe.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_calculator/page/settings.dart';

/// Conditionally multiply two [Plaintext] objects
/// 
/// At least one of the two integers must be encrypted.
Ciphertext multiplyCondition(SessionChanges s, Plaintext x, Plaintext mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;
  Ciphertext cipherResult;

  if (xEncrypted && multEncrypted) {
    s.log('Multiplying Ciphertext x Ciphertext');
    cipherResult = fhe.multiply(fhe.encrypt(x), fhe.encrypt(mult));
    s.log('Ciphertext size: ${cipherResult.size}');
    cipherResult = fhe.relinearize(cipherResult);
    s.log('Ciphertext size (after relinearization): ${cipherResult.size}');
  } else if (xEncrypted) {
    s.log('Multiplying Ciphertext x Plaintext');
    cipherResult = fhe.multiplyPlain(fhe.encrypt(x), mult);
    s.log('Ciphertext size: ${cipherResult.size}');
  } else if (multEncrypted) {
    s.log('Multiplying Plaintext x Ciphertext');
    cipherResult = fhe.multiplyPlain(fhe.encrypt(mult), x);
    s.log('Ciphertext size: ${cipherResult.size}');
  } else {
    throw 'Both x and mult cannot be plain'; // cannot return a Ciphertext
  }
  return cipherResult;
}

/// Multiply two integers
/// 
/// Encrypts, multiplies, and decrypts the result,
String multiplyAsHex(SessionChanges s, int x, int mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    String xRadix = x.toRadixString(16);
    s.log('Hex: $x -> $xRadix');
    Plaintext plainX = fhe.plain(xRadix);

    String multRadix = mult.toRadixString(16);
    s.log('Hex: $mult -> $multRadix');
    Plaintext plainMult = fhe.plain(multRadix);

    if (!xEncrypted && !multEncrypted) {
      s.log('Multiplying $x and $mult');
      final result = (x * mult).toString();
      s.log('Result: $result');
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = multiplyCondition(s, plainX, plainMult, xEncrypted, multEncrypted);

    final plainResult = fhe.decrypt(cipherResult);
    final result = int.parse(plainResult.text, radix: 16).toString();
    s.log('Result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.toString();
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Multiply two doubles
/// 
/// Encrypts, multiplies, and decrypts the result,
String multiplyDouble(SessionChanges s, double x, double mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double multiplication';
  }

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    Plaintext plainX = fhe.encodeDouble(x);
    Plaintext plainMult = fhe.encodeDouble(mult);

    if (!xEncrypted && !multEncrypted) {
      s.log('Multiplying $x and $mult');
      final result = (x * mult).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = multiplyCondition(s, plainX, plainMult, xEncrypted, multEncrypted);

    final plainResult = fhe.decrypt(cipherResult);
    final result = fhe.decodeVecDouble(plainResult, 1)[0];
    s.log('Result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.toString();
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Multiply two lists of integers
/// 
/// Encrypts, multiplies, and decrypts the result,
String multiplyVecInt(SessionChanges s, List<int> x, List<int> mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecInt(x);
    final plainMult = fhe.encodeVecInt(mult);

    if (!xEncrypted && !multEncrypted) {
      s.log('Multiplying $x x $mult');
      final result = [];
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] * mult[i]);
      }
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    Ciphertext cipherResult = multiplyCondition(s, plainX, plainMult, xEncrypted, multEncrypted);

    final plainResult = fhe.decrypt(cipherResult);
    final result = fhe.decodeVecInt(plainResult, x.length);
    s.log('Result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.join(',');
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Multiply two lists of doubles
/// 
/// Encrypts, multiplies, and decrypts the result,
String multiplyVecDouble(SessionChanges s, List<double> x, List<double> mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double multiplication';
  }

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecDouble(x);
    final plainMult = fhe.encodeVecDouble(mult);

    if (!xEncrypted && !multEncrypted) {
      s.log('Multiplying $x x $mult');
      final result = [];
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] * mult[i]);
      }
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    Ciphertext cipherResult = multiplyCondition(s, plainX, plainMult, xEncrypted, multEncrypted);

    final plainResult = fhe.decrypt(cipherResult);
    final result = fhe.decodeVecDouble(plainResult, x.length);
    s.log('Result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.join(',');
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}
