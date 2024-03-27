import 'package:fhel/afhe.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_example/page/settings.dart';

/// Conditionally subtract two [Plaintext] objects
/// 
/// At least one of the two integers must be encrypted.
Ciphertext subtractCondition(SessionChanges s, Plaintext x, Plaintext sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;
  Ciphertext cipherResult;
  
  if (xEncrypted && subEncrypted) {
    s.log('Subtracts Ciphertext - Ciphertext');
    cipherResult = fhe.subtract(fhe.encrypt(x), fhe.encrypt(sub));
  } else if (xEncrypted) {
    s.log('Subtracts Ciphertext - Plaintext');
    cipherResult = fhe.subtractPlain(fhe.encrypt(x), sub);
  } else if (subEncrypted) {
    s.log('Subtracts Plaintext - Ciphertext');
    // TODO: Results in a negative value, should we support plain - cipher?
    // cipherResult = fhe.subtractFromPlain(x, fhe.encrypt(sub));
    cipherResult = fhe.subtractPlain(fhe.encrypt(sub), x);
  } else {
    throw 'Both x and sub cannot be plain'; // cannot return a Ciphertext
  }
  return cipherResult;
}

/// Subtract two integers
/// 
/// Encrypts, subtract, and decrypts the result,
String subtractAsHex(SessionChanges s, int x, int sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final xRadix = x.toRadixString(16);
    s.log('Hex: $x -> $xRadix');
    final plainX = fhe.plain(xRadix);

    final subRadix = sub.toRadixString(16);
    s.log('Hex: $sub -> $subRadix');
    final plainSub = fhe.plain(subRadix);

    if (!xEncrypted && !subEncrypted) {
      s.log('Subtracts $x and $sub');
      final result = (x - sub).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = subtractCondition(s, plainX, plainSub, xEncrypted, subEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

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

/// Subtract two doubles
/// 
/// Encrypts, subtract, and decrypts the result,
String subtractDouble(SessionChanges s, double x, double sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double subtraction';
  }

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeDouble(x);
    final plainSub = fhe.encodeDouble(sub);

    if (!xEncrypted && !subEncrypted) {
      s.log('Subtracts $x and $sub');
      final result = (x - sub).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = subtractCondition(s, plainX, plainSub, xEncrypted, subEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

    final plainResult = fhe.decrypt(cipherResult);
    // Generates an array of doubles filled of size (slot count)
    final result = fhe.decodeVecDouble(plainResult, 1).first;
    s.log('Result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.toString();
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Subtract two vectors of integers
/// 
/// Encrypts, subtract, and decrypts the result,
String subtractVecInt(SessionChanges s, List<int> x, List<int> sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecInt(x);
    final plainSub = fhe.encodeVecInt(sub);

    Ciphertext cipherResult;

    if (!xEncrypted && !subEncrypted) {
      s.log('Subtracts $x and $sub');
      final result = [];
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] - sub[i]);
      }
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    cipherResult = subtractCondition(s, plainX, plainSub, xEncrypted, subEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

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

/// Subtract two vectors of doubles
/// 
/// Encrypts, subtract, and decrypts the result,
String subtractVecDouble(SessionChanges s, List<double> x, List<double> sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double subtraction';
  }

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecDouble(x);
    final plainSub = fhe.encodeVecDouble(sub);

    if (!xEncrypted && !subEncrypted) {
      s.log('Subtracts $x and $sub');
      final result = [];
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] - sub[i]);
      }
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    Ciphertext cipherResult = subtractCondition(s, plainX, plainSub, xEncrypted, subEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

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