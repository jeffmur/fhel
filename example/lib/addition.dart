import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_example/globals.dart';

/// Add two vectors
List<int> addVector(List<int> x, List<int> add) {
  final fhe = globalSession.fhe;

  final plainX = fhe.encodeVecInt(x);
  final cipherX = fhe.encrypt(plainX);

  final plainAddend = fhe.encodeVecInt(add);
  final cipherAddend = fhe.encrypt(plainX);

  final cipherRes = fhe.add(cipherX, cipherAddend);
  final plainRes = fhe.decrypt(cipherRes);

  return fhe.decodeVecInt(plainRes, x.length);
}

/// Add two integers
///
/// Encrypts, adds, and decrypts the result,
/// Optionally, [addPlain] encrypts [x] and [add] as plain text
String addAsHex(Seal fhe, int x, int add, {addPlain = false}) {
  // Convert to Hexidecimal
  try {
    final plainX = fhe.plain(x.toRadixString(16));
    final cipherX = fhe.encrypt(plainX);

    final plainAdd = fhe.plain(add.toRadixString(16));
    final cipherAdd = fhe.encrypt(plainAdd);

    final cipherResult = addPlain
        ? fhe.addPlain(cipherX, plainAdd)
        : fhe.add(cipherX, cipherAdd);

    final plainResult = fhe.decrypt(cipherResult);

    return int.parse(plainResult.text, radix: 16).toString();
  } catch (e) {
    return e.toString();
  }
}
