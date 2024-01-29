import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/afhe/plaintext.dart';

String sealBFVAddition(String a, String b, Map<String,int> context) {
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
  return pt_res.text;
}

void main() {
  test("SEAL Addition", () {
    Map<String,int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    expect(sealBFVAddition('100', '80', ctx), '180');
  });

  test("SEAL Addition plaintext modulus affects decryption", () {
    Map<String,int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    // poly_modulus_degree : [ 1024, 2048, 4096, 8192, 16384, 32768 ]

    expect(sealBFVAddition('200', '80', ctx), '280'); 

    // Note: This may be due to invalid parameter validation
    ctx['ptMod'] = 4096;
    expect(sealBFVAddition('399', '80', ctx), '419');
  });
}
