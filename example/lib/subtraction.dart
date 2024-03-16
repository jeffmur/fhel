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
      s.log('Multiplying encrypt($x) + encrypt($sub)');
      cipherResult = fhe.subtract(cipherX, ciphersub);
    } else if (xEncrypted) {
      s.log('Multiplying encrypt($x) + plain($sub)');
      cipherResult = fhe.subtractPlain(cipherX, plainMult);
    } else if (subEncrypted) {
      s.log('Multiplying plain($x) + encrypt($sub)');
      cipherResult = fhe.subtractPlain(ciphersub, plainX);
    } else {
      s.log('Multiplying $x and $sub');
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
