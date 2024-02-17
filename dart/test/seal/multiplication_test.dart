import 'package:fhel/afhe.dart';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

const schemes = ['bgv', 'bfv'];

String multiply(String scheme, String a, String b, Map<String, int> ctx, {bool encryptMultiplier=true}) {
  final fhe = Seal(scheme);
  String status = fhe.genContext(ctx);
  expect(status, 'success: valid');
  fhe.genKeys();
  final pt_x = fhe.plain(a);
  final ct_x = fhe.encrypt(pt_x);
  final pt_m = fhe.plain(b);
  Ciphertext ct_res;
  // Relinearization is required for cipher x cipher multiplication
  if (encryptMultiplier) {
    fhe.genRelinKeys();
    final ct_m = fhe.encrypt(pt_m);
    Ciphertext ct_no_relin = fhe.multiply(ct_x, ct_m);
    expect(ct_no_relin.size(), 3);
    ct_res = fhe.relinearize(ct_no_relin);
    expect(ct_res.size(), 2);
  }
  else {
    ct_res = fhe.multiplyPlain(ct_x, pt_m);
    expect(ct_res.size(), 2);
  }

  final pt_res = fhe.decrypt(ct_res);
  return pt_res.text.toLowerCase();
}

void main() {
  test("Hexadecimal Multiplication", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    for (var sch in schemes) {
      expect(
        100.toRadixString(16),
        multiply(sch, 10.toRadixString(16), 10.toRadixString(16), ctx));
      expect(
        100.toRadixString(16),
        multiply(sch, 10.toRadixString(16), 10.toRadixString(16), ctx, encryptMultiplier: false));
    }
  });
}
