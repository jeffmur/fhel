import 'package:fhel/afhe.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_example/page/settings.dart';

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
    final cipherX = fhe.encrypt(plainX);

    final subRadix = sub.toRadixString(16);
    s.log('Hex: $sub -> $subRadix');
    final plainMult = fhe.plain(subRadix);
    final ciphersub = fhe.encrypt(plainMult);

    Ciphertext cipherResult;

    if (xEncrypted && subEncrypted) {
      s.log('Subtracts encrypt($x) + encrypt($sub)');
      cipherResult = fhe.subtract(cipherX, ciphersub);
    } else if (xEncrypted) {
      s.log('Subtracts encrypt($x) + plain($sub)');
      cipherResult = fhe.subtractPlain(cipherX, plainMult);
    } else if (subEncrypted) {
      s.log('Subtracts plain($x) + encrypt($sub)');
      cipherResult = fhe.subtractPlain(ciphersub, plainX);
    } else {
      s.log('Subtracts $x and $sub');
      final result = (x * sub).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }

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

/// Subtract two doubles
/// 
/// Encrypts, subtract, and decrypts the result,
String subtractDouble(SessionChanges s, double x, double sub, bool xEncrypted, bool subEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final plainX = fhe.encodeDouble(x);
    final cipherX = fhe.encrypt(plainX);

    final plainSub = fhe.encodeDouble(sub);
    final cipherSub = fhe.encrypt(plainSub);

    Ciphertext cipherResult;

    if (xEncrypted && subEncrypted) {
      s.log('Subtracts encrypt($x) - encrypt($sub)');
      cipherResult = fhe.subtract(cipherX, cipherSub);
    } else if (xEncrypted) {
      s.log('Subtracts encrypt($x) - plain($sub)');
      cipherResult = fhe.subtractPlain(cipherX, plainSub);
    } else if (subEncrypted) {
      s.log('Subtracts plain($x) - encrypt($sub)');
      // TODO: Results in a negative value, should we support plain - cipher?
      cipherResult = fhe.subtractPlain(cipherSub, plainX);
    } else {
      s.log('Subtracts $x and $sub');
      final result = (x * sub).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }

    s.log('Ciphertext size: ${cipherResult.size}');

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
