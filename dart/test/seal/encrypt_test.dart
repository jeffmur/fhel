// ignore_for_file: non_constant_identifier_names

import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

// Least Significant Bit (LSB), Most Significant Bit (MSB)
const schemes = ['bgv', 'bfv'];

void main() {
  test('Encrypt Hexidecimal', () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final context = fhe.genContext(
        {'polyModDegree': 4096, 'ptMod': 4096, 'secLevel': 128});
      expect(context, "success: valid");
      fhe.genKeys();

      int pt_int = 2500;
      String pt = pt_int.toRadixString(16);
      final plaintext = fhe.plain(pt);
      final ciphertext = fhe.encrypt(plaintext);
      final decrypted = fhe.decrypt(ciphertext);

      // Check invariant noise budget
      expect(fhe.invariantNoiseBudget(ciphertext), lessThanOrEqualTo(53));

      // Validate that hexidecimal are equal
      expect(decrypted.text.toLowerCase(), pt.toLowerCase());

      // Validate that integers are equal
      expect(int.parse(decrypted.text, radix: 16), 2500);
    }
  });

  test('Encrypt List<int>', () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final context = fhe.genContext(
        {'polyModDegree': 8192, 'ptModBit': 20, 'ptMod': 0, 'secLevel': 128});
      expect(context, "success: valid");
      fhe.genKeys();

      List<int> vec = [1, 2, 3, 4];

      // Encode + Decode Vector
      final ptx = fhe.encodeVecInt(vec);
      final res1 = fhe.decodeVecInt(ptx, 4);

      for (int i = 0; i < res1.length; i++) {
        expect(res1[i], vec[i]);
      }

      // Encrypt + Decrypt Vector
      final ctx = fhe.encrypt(ptx);
      final ptx_res = fhe.decrypt(ctx);
      final res2 = fhe.decodeVecInt(ptx_res, 4);

      for (int i = 0; i < res2.length; i++) {
        expect(res2[i], vec[i]);
      }
    }
  });
}
