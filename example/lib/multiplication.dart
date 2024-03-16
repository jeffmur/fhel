import 'package:fhel/afhe.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel_example/page/settings.dart';

/// Multiply two integers
/// 
/// Encrypts, multiplies, and decrypts the result,
String multiplyAsHex(SessionChanges s, int x, int mult, bool xEncrypted, bool multEncrypted) {
  Seal fhe = s.fhe;

  // Convert to Hexidecimal
  try {
    s.logSession();
    final start = DateTime.now();
    final xRadix = x.toRadixString(16);
    s.log('Hex: $x -> $xRadix');
    final plainX = fhe.plain(xRadix);
    final cipherX = fhe.encrypt(plainX);

    final multRadix = mult.toRadixString(16);
    s.log('Hex: $mult -> $multRadix');
    final plainMult = fhe.plain(multRadix);
    final ciphermult = fhe.encrypt(plainMult);

    Ciphertext cipherResult;

    if (xEncrypted && multEncrypted) {
      s.log('Multiplying encrypt($x) + encrypt($mult)');
      cipherResult = fhe.multiply(cipherX, ciphermult);
      s.log('Ciphertext size: ${cipherResult.size}');
      cipherResult = fhe.relinearize(cipherResult);
      s.log('Ciphertext size (after relinearization): ${cipherResult.size}');
    } else if (xEncrypted) {
      s.log('Multiplying encrypt($x) + plain($mult)');
      cipherResult = fhe.multiplyPlain(cipherX, plainMult);
      s.log('Ciphertext size: ${cipherResult.size}');
    } else if (multEncrypted) {
      s.log('Multiplying plain($x) + encrypt($mult)');
      cipherResult = fhe.multiplyPlain(ciphermult, plainX);
      s.log('Ciphertext size: ${cipherResult.size}');
    } else {
      s.log('Multiplying $x and $mult');
      final result = (x * mult).toString();
      s.log('Elapsed: ${DateTime.now().difference(start).inMilliseconds} ms');
      return result;
    }

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
