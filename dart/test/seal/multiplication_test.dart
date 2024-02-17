import 'package:fhel/afhe.dart';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

const schemes = ['bgv', 'bfv'];

Plaintext multiply(Seal fhe, Plaintext pt_x, Plaintext pt_m, {bool encryptMultiplier=true}) {
  fhe.genKeys();
  final ct_x = fhe.encrypt(pt_x);
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

  return fhe.decrypt(ct_res);
}

void main() {
  test("Hexadecimal Multiplication", () {
    Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
    };
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final pt_hex_10 = fhe.plain(10.toRadixString(16));
      String status = fhe.genContext(ctx);
      expect(status, 'success: valid');
      expect(
        100.toRadixString(16),
        multiply(fhe, pt_hex_10, pt_hex_10).text.toLowerCase());
      expect(
        100.toRadixString(16),
        multiply(fhe, pt_hex_10, pt_hex_10, encryptMultiplier: false).text.toLowerCase());
    }
  });

  test("List<int> Multiplication", () {
    Map<String, int> ctx = {
      'polyModDegree': 8192,
      'ptModBit': 20,
      'secLevel': 128
    };
    List<int> x = [1, 2, 3, 4];
    List<int> m = [2, 4, 6, 8];
    List<int> product = [2, 8, 18, 32];
    int arr_len = product.length;

    for (var sch in schemes) {
      final fhe = Seal(sch);
      String status = fhe.genContext(ctx);
      expect(status, 'success: valid');
      final pt_x = fhe.encodeVecInt(x);
      final pt_m = fhe.encodeVecInt(m);

      expect(product, fhe.decodeVecInt(multiply(fhe, pt_x, pt_m), arr_len));
      expect(product, fhe.decodeVecInt(multiply(fhe, pt_x, pt_m, encryptMultiplier: false), arr_len));
    }
  });
}
