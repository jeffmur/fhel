import 'package:fhel/afhe.dart';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;
import 'test_utils.dart';
import 'dart:math';

const schemes = ['bgv', 'bfv'];

void modSwitchTest(Seal fhe, Ciphertext ct) {
  int beforeSwitch = fhe.invariantNoiseBudget(ct);
  fhe.modSwitchNext(ct);
  int afterSwitch = fhe.invariantNoiseBudget(ct);
  // Noise budget should decrease after mod switch
  expect(beforeSwitch > afterSwitch, true);
}

Plaintext multiply(Seal fhe, Plaintext pt_x, Plaintext pt_m,
    {bool encryptMultiplier = true, bool modSwitch = true}) {
  fhe.genKeys();
  final ct_x = fhe.encrypt(pt_x);
  Ciphertext ct_res;
  // Relinearization is required for cipher x cipher multiplication
  if (encryptMultiplier) {
    fhe.genRelinKeys();
    final ct_m = fhe.encrypt(pt_m);
    Ciphertext ct_no_relin = fhe.multiply(ct_x, ct_m);
    expect(ct_no_relin.size, 3);
    ct_res = fhe.relinearize(ct_no_relin);
    expect(ct_res.size, 2);
  } else {
    ct_res = fhe.multiplyPlain(ct_x, pt_m);
    expect(ct_res.size, 2);
  }
  if (modSwitch) {
    modSwitchTest(fhe, ct_res);
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
      expect(100.toRadixString(16),
          multiply(fhe, pt_hex_10, pt_hex_10).text.toLowerCase());
      expect(
          100.toRadixString(16),
          multiply(fhe, pt_hex_10, pt_hex_10, encryptMultiplier: false)
              .text
              .toLowerCase());
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
      expect(
          product,
          fhe.decodeVecInt(
              multiply(fhe, pt_x, pt_m, encryptMultiplier: false), arr_len));
    }
  });

  test("List<double> Multiplication", () {
    Map ctx = {
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 40),
      'qSizes': [60, 40, 40, 60]
    };
    List<double> x = [1.1, 2.2, 3.3, 4.4];
    List<double> m = [2.2, 4.4, 6.6, 8.8];
    List<double> product = [2.42, 9.68, 21.78, 38.72];
    int arr_len = product.length;

    final fhe = Seal('ckks');
    String status = fhe.genContext(ctx);
    expect(status, 'success: valid');
    final pt_x = fhe.encodeVecDouble(x);
    final pt_m = fhe.encodeVecDouble(m);

    for (int i = 0; i < arr_len; i++) {
      near(
          eps: 1e-7,
          product[i],
          fhe.decodeVecDouble(
              multiply(fhe, pt_x, pt_m, modSwitch: false), arr_len)[i]);
      near(
          eps: 1e-7,
          product[i],
          fhe.decodeVecDouble(
              multiply(fhe, pt_x, pt_m,
                  modSwitch: false, encryptMultiplier: false),
              arr_len)[i]);
    }
  });

  test("List<double> Pi * x^2", () {
    Map ctx = {
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 40),
      'qSizes': [60, 40, 40, 60]
    };
    List<double> x = [1.1, 2.2, 3.3, 4.4];
    double pi = 3.14159265;
    int arr_len = x.length;

    final fhe = Seal('ckks');
    String status = fhe.genContext(ctx);
    expect(status, 'success: valid');
    final pt_x = fhe.encodeVecDouble(x);

    fhe.genKeys();
    fhe.genRelinKeys();

    final ct_x = fhe.encrypt(pt_x);
    Ciphertext ct_squared = fhe.multiply(ct_x, ct_x);
    final ct_squared_relin = fhe.relinearize(ct_squared);

    Plaintext pt_pi = fhe.encodeDouble(pi);
    Ciphertext ct_pi_squared = fhe.multiplyPlain(ct_squared_relin, pt_pi);
    Plaintext pt_pi_squared = fhe.decrypt(ct_pi_squared);

    List<double> product = [
      3.801327107,
      15.205308426,
      34.211943958,
      60.821233704
    ];
    for (int i = 0; i < arr_len; i++) {
      near(
          eps: 1e-7,
          product[i],
          fhe.decodeVecDouble(pt_pi_squared, arr_len)[i]);
      near(
          eps: 1e-7,
          product[i],
          fhe.decodeVecDouble(pt_pi_squared, arr_len)[i]);
    }
  });
}
