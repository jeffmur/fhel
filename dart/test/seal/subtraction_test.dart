import 'package:test/test.dart';
import 'package:fhel/fhe.dart' show FHE;
import 'package:fhel/afhe/plaintext.dart';

// Least Significant Bit (LSB), Most Significant Bit (MSB)
const schemes = ['bgv', 'bfv'];

String sealSubtraction(String scheme, String a, String b, Map<String, int> ctx) {
  final fhe = FHE.withScheme('seal', scheme);
  String status = fhe.genContext(ctx);
  expect(status, 'success: valid');
  fhe.genKeys();
  final pt_x = Plaintext.withValue(fhe.backend, a);
  final ct_x = fhe.encrypt(pt_x);
  final pt_sub = Plaintext.withValue(fhe.backend, b);
  final ct_sub = fhe.encrypt(pt_sub);
  final ct_res = fhe.subtract(ct_x, ct_sub);
  final pt_res = fhe.decrypt(ct_res);
  return pt_res.text.toLowerCase();
}

void main() {
  test("SEAL Integer Subtraction", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    for (var sch in schemes) {
      expect(sealSubtraction(sch, '100', '100', ctx), '0');
    }
  });

  test("SEAL Hexadecimal Subtraction", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };

    for (var sch in schemes) {
      expect(120.toRadixString(16),
          sealSubtraction(sch, 200.toRadixString(16), 80.toRadixString(16), ctx));
    }

    // Otherwise, you are forced to increase plaintext modulus,
    // resulting in more noise growth and failed decryption
    ctx['ptMod'] = 67136;
    for (var sch in schemes) {
      expect(sealSubtraction(sch, '2000', '2000', ctx), '0');
    }

    // When using hexadecimal, plain modulus can be lower
    ctx['ptMod'] = 4196;
    for (var sch in schemes) {
      expect(
          1200.toRadixString(16).toLowerCase(),
          sealSubtraction(
              sch, 2000.toRadixString(16), 800.toRadixString(16), ctx));
    }
  });

  test("SEAL List<int> Subtraction", () {
    for (var sch in schemes) {
      final fhe = FHE.withScheme('seal', sch);
      Map<String, int> ctx = {
        'polyModDegree': 8192,
        'ptModBit': 20,
        'ptMod': 0,
        'secLevel': 128
      };
      fhe.genContext(ctx);
      fhe.genKeys();
      List<int> x = [1, 2, 3, 4];
      final pt_x = fhe.encodeVecInt(x);
      final ct_x = fhe.encrypt(pt_x);

      List<int> add = x;
      final pt_add = fhe.encodeVecInt(add);
      final ct_add = fhe.encrypt(pt_add);

      final ct_res = fhe.subtract(ct_x, ct_add);
      final pt_res = fhe.decrypt(ct_res);

      final expected = [0, 0, 0, 0];
      final actual = fhe.decodeVecInt(pt_res, 4);
      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i]);
      }
    }
  });
}
