import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/afhe/plaintext.dart';

String sealBFVAddition(String a, String b, Map<String, int> context) {
  final fhe = FHE.withScheme('seal', 'bfv');
  String status = fhe.genContext(context);
  expect(status, 'success: valid');
  fhe.genKeys();
  final pt_x = Plaintext.withValue(fhe.backend, a);
  final ct_x = fhe.encrypt(pt_x);
  final pt_add = Plaintext.withValue(fhe.backend, b);
  final ct_add = fhe.encrypt(pt_add);
  final ct_res = fhe.add(ct_x, ct_add);
  final pt_res = fhe.decrypt(ct_res);
  return pt_res.text.toLowerCase();
}

void main() {
  test("SEAL Integer Addition", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    expect(sealBFVAddition('100', '80', ctx), '180');
  });

  test("SEAL Hexadecimal Addition", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };

    expect(280.toRadixString(16),
        sealBFVAddition(200.toRadixString(16), 80.toRadixString(16), ctx));

    // Otherwise, you are forced to increase plaintext modulus,
    // resulting in more noise growth and failed decryption
    ctx['ptMod'] = 67136;
    expect(sealBFVAddition('2000', '2000', ctx), '4000');

    // When using hexadecimal, plain modulus can be lower
    ctx['ptMod'] = 4196;
    expect(2800.toRadixString(16).toLowerCase(),
        sealBFVAddition(2000.toRadixString(16), 800.toRadixString(16), ctx));
  });

  test("SEAL List<int> Addition", () {
    final fhe = FHE.withScheme('seal', 'bfv');
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

    final ct_res = fhe.add(ct_x, ct_add);
    final pt_res = fhe.decrypt(ct_res);

    final expected = [2, 4, 6, 8];
    final actual = fhe.decodeVecInt(pt_res, 4);
    for (int i = 0; i < actual.length; i++) {
      expect(actual[i], expected[i]);
    }
  });
}
