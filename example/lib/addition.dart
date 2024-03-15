import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_example/page/settings.dart';

/// Add two integers
///
/// Encrypts, adds, and decrypts the result,
/// Optionally, [addPlain] encrypts [x] and [add] as plain text
String addAsHex(SessionChanges s, int x, int add, {addPlain = false}) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    s.log('Adding $x and $add');
    final start = DateTime.now();
    final xRadix = x.toRadixString(16);
    final plainX = fhe.plain(xRadix);
    final cipherX = fhe.encrypt(plainX);

    final addRadix = add.toRadixString(16);
    final plainAdd = fhe.plain(addRadix);
    final cipherAdd = fhe.encrypt(plainAdd);

    s.log('$xRadix + $addRadix = ${(x + add).toRadixString(16)}');

    final cipherResult = addPlain
        ? fhe.addPlain(cipherX, plainAdd)
        : fhe.add(cipherX, cipherAdd);

    s.log('Ciphertext size: ${cipherResult.size}');

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

/// Add two vectors<int>
String addVectorInt(SessionChanges s, List<int> x, List<int> add, {addPlain = false}) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name == 'ckks') {
    return 'CKKS does not support integer addition';
  }

  try {
    s.logSession();
    s.log('Adding $x and $add');
    final start = DateTime.now();
    final plainX = fhe.encodeVecInt(x);
    final cipherX = fhe.encrypt(plainX);

    final plainAdd = fhe.encodeVecInt(add);
    final cipherAdd = fhe.encrypt(plainAdd);

    s.log('Ciphertext size: ${cipherX.size}');

    final cipherResult = addPlain
        ? fhe.addPlain(cipherX, plainAdd)
        : fhe.add(cipherX, cipherAdd);

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

/// Add two vectors<double>
String addVectorDouble(SessionChanges s, List<double> x, List<double> add, {addPlain = false}) {
  Seal fhe = s.fhe;

  if (fhe.scheme.name != 'ckks') {
    return '${fhe.scheme.name.toUpperCase()} does not support double addition';
  }

  try {
    s.logSession();
    s.log('Adding $x and $add');
    final start = DateTime.now();
    final plainX = fhe.encodeVecDouble(x);
    final cipherX = fhe.encrypt(plainX);

    final plainAdd = fhe.encodeVecDouble(add);
    final cipherAdd = fhe.encrypt(plainAdd);

    s.log('Ciphertext size: ${cipherX.size}');

    final cipherResult = addPlain
        ? fhe.addPlain(cipherX, plainAdd)
        : fhe.add(cipherX, cipherAdd);

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