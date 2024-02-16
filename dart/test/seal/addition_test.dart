import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

const schemes = ['bgv', 'bfv'];

String add(String scheme, String a, String b, Map<String, int> ctx, {bool encryptAddend=true}) {
  final fhe = Seal(scheme);
  String status = fhe.genContext(ctx);
  expect(status, 'success: valid');
  fhe.genKeys();
  final pt_x = fhe.plain(a);
  final ct_x = fhe.encrypt(pt_x);
  final pt_add = fhe.plain(b);

  // Optionally, addend can be plaintext
  var ct_res;
  if (encryptAddend) {
    final ct_add = fhe.encrypt(pt_add);
    ct_res = fhe.add(ct_x, ct_add);
  } else {
    ct_res = fhe.addPlain(ct_x, pt_add);
  }
  final pt_res = fhe.decrypt(ct_res);
  return pt_res.text.toLowerCase();
}

void main() {
  test("Integer Addition", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    for (var sch in schemes) {
      expect('280', add(sch, '200', '80', ctx));
      expect('280', add(sch, '200', '80', ctx, encryptAddend: false));
    }
  });

  test("Hexadecimal Addition", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };

    for (var sch in schemes) {
      expect(
        280.toRadixString(16),
        add(sch, 200.toRadixString(16), 80.toRadixString(16), ctx));
      expect(
        280.toRadixString(16),
        add(sch, 200.toRadixString(16), 80.toRadixString(16), ctx, encryptAddend: false));
    }

    // Otherwise, you are forced to increase plaintext modulus,
    // resulting in more noise growth and failed decryption
    ctx['ptMod'] = 67136;
    for (var sch in schemes) {
      expect('4000', add(sch, '2000', '2000', ctx));
      expect('4000', add(sch, '2000', '2000', ctx, encryptAddend: false));
    }

    // When using hexadecimal, plain modulus can be lower
    ctx['ptMod'] = 4196;
    for (var sch in schemes) {
      expect(
        2800.toRadixString(16).toLowerCase(),
        add(sch, 2000.toRadixString(16), 800.toRadixString(16), ctx));
      expect(
        2800.toRadixString(16).toLowerCase(),
        add(sch, 2000.toRadixString(16), 800.toRadixString(16), ctx, encryptAddend: false));
    }
  });

  test("List<int> Addition", () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
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

      // Optionally, addend can be plaintext
      final ct_res = fhe.addPlain(ct_x, pt_add);
      final pt_res = fhe.decrypt(ct_res);
      final actual = fhe.decodeVecInt(pt_res, 4);

      final expected = [2, 4, 6, 8];
      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i]);
      }

      // Traditionally, add two ciphertexts
      final ct_add_cipher = fhe.encrypt(pt_add);

      final ct_res_cipher = fhe.add(ct_x, ct_add_cipher);
      final pt_res_cipher = fhe.decrypt(ct_res_cipher);
      final actual_cipher = fhe.decodeVecInt(pt_res_cipher, 4);

      for (int i = 0; i < actual.length; i++) {
        expect(actual_cipher[i], expected[i]);
      }
    }
  });
}
