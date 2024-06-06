import 'package:fhel/afhe.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_calculator/page/settings.dart';

/// Conditionally add two [Plaintext] objects
/// 
/// At least one of the two integers must be encrypted.
Ciphertext addCondition(SessionChanges s, Plaintext x, Plaintext add, bool xEncrypted, bool addEncrypted) {
  Seal fhe = s.fhe;
  Ciphertext cipherResult;
  
  if (xEncrypted && addEncrypted) {
    s.log('Adding Ciphertext + Ciphertext');
    cipherResult = fhe.add(fhe.encrypt(x), fhe.encrypt(add));
  } else if (xEncrypted) {
    s.log('Adding Ciphertext + Plaintext');
    cipherResult = fhe.addPlain(fhe.encrypt(x), add);
  } else if (addEncrypted) {
    s.log('Adding Plaintext + Ciphertext');
    cipherResult = fhe.addPlain(fhe.encrypt(add), x);
  } else {
    throw 'Both x and add cannot be plain'; // cannot return a Ciphertext
  }
  return cipherResult;
}

/// Add two integers
///
/// Encrypts, adds, and decrypts the result,
String addAsHex(SessionChanges s, int x, int add, bool xEncrypted, bool addEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final xRadix = x.toRadixString(16);
    s.log('$x.toRadixString(16) => $xRadix');
    final plainX = fhe.plain(xRadix);

    final addRadix = add.toRadixString(16);
    s.log('$add.toRadixString(16) => $addRadix');
    final plainAdd = fhe.plain(addRadix);

    if (!xEncrypted && !addEncrypted) {
      s.log('Adding Plaintext + Plaintext');
      final result = (x + add).toString();
      s.log('Result: $result');
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = addCondition(s, plainX, plainAdd, xEncrypted, addEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

    final plainResult = fhe.decrypt(cipherResult);
    final result = int.parse(plainResult.text, radix: 16).toString();
    s.log('Decrypted result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.toString();
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Add two doubles
String addDouble(SessionChanges s, double x, double add, bool xEncrypted, bool addEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double addition';
  }

  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeDouble(x);
    final plainAdd = fhe.encodeDouble(add);

    if (!xEncrypted && !addEncrypted) {
      s.log('Adding Plaintext + Plaintext');
      final result = (x + add).toString();
      s.log('Result: $result');
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }
    Ciphertext cipherResult = addCondition(s, plainX, plainAdd, xEncrypted, addEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

    final plainResult = fhe.decrypt(cipherResult);
    // Generates an array of doubles filled of size (slot count)
    final result = fhe.decodeVecDouble(plainResult, 1).first;
    s.log('Decrypted result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.toString();
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Add two vectors<int>
String addVectorInt(SessionChanges s, List<int> x, List<int> add, bool xEncrypted, bool addEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name == 'ckks') {
    return 'CKKS does not support integer addition';
  }

  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecInt(x);
    final plainAdd = fhe.encodeVecInt(add);

    if (!xEncrypted && !addEncrypted) {
      final result = [];
      s.log('Adding Plaintext + Plaintext');
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] + add[i]);
      }
      s.log('Result: $result');
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    Ciphertext cipherResult = addCondition(s, plainX, plainAdd, xEncrypted, addEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

    final plainResult = fhe.decrypt(cipherResult);
    final result = fhe.decodeVecInt(plainResult, x.length);
    s.log('Decrypted result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.join(',');
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}

/// Add two vectors<double>
String addVectorDouble(SessionChanges s, List<double> x, List<double> add, bool xEncrypted, bool addEncrypted) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double addition';
  }

  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeVecDouble(x);
    final plainAdd = fhe.encodeVecDouble(add);

    if (!xEncrypted && !addEncrypted) {
      s.log('Adding Plaintext + Plaintext');
      final result = [];
      for (int i = 0; i < x.length; i++) {
        result.add(x[i] + add[i]);
      }
      s.log('Result: $result');
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result.join(',');
    }
    Ciphertext cipherResult = addCondition(s, plainX, plainAdd, xEncrypted, addEncrypted);
    s.log('Ciphertext result size: ${cipherResult.size}');

    final plainResult = fhe.decrypt(cipherResult);
    final result = fhe.decodeVecDouble(plainResult, x.length);
    s.log('Decrypted result: $result');
    s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
    return result.join(',');
  } catch (e) {
    s.log(e.toString());
    return e.toString();
  }
}
