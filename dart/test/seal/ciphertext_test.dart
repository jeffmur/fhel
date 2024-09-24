// ignore_for_file: non_constant_identifier_names
import 'dart:math';
import 'package:test/test.dart';
import 'package:fhel/afhe.dart' show Ciphertext;
import 'package:fhel/seal.dart' show Seal;
import 'test_utils.dart';

void main() {
  group('BFV - String Ciphertext', () {
    test('toBytes', () {
      final fhe = Seal('bfv');
      fhe.genContext({
        'polyModDegree': 4096,
        'ptMod': 1024,
        'secLevel': 128,
      });
      fhe.genKeys();
      final pt = fhe.plain("123");
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();
      expect(ct_bin, isNotEmpty);
    });

    test('fromBytes', () {
      final fhe = Seal('bfv');
      fhe.genContext({
        'polyModDegree': 4096,
        'ptMod': 1024,
        'secLevel': 128,
      });
      fhe.genKeys();
      final pt = fhe.plain("123");
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();

      final ct2 = Ciphertext.fromBytes(fhe, ct_bin);
      final pt2 = fhe.decrypt(ct2);
      expect(pt2.text, pt.text);
    });
  });
  group('CKKS - double Ciphertext', () {
    test('toBytes', () {
      final fhe = Seal('ckks');
      fhe.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      fhe.genKeys();
      final pt = fhe.encodeDouble(1.0);
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();
      expect(ct_bin, isNotEmpty);
    });

    test('fromBytes', () {
      final fhe = Seal('ckks');
      fhe.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      fhe.genKeys();
      final pt = fhe.encodeDouble(1.0);
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();

      final ct2 = Ciphertext.fromBytes(fhe, ct_bin);
      final pt2 = fhe.decrypt(ct2);
      final pt2_double = fhe.decodeDouble(pt2);
      near(pt2_double, 1.0, eps: 1e-7);
    });
  });
  group('CKKS - List<double> Ciphertext', () {
    test('toBytes', () {
      final fhe = Seal('ckks');
      fhe.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      fhe.genKeys();
      final pt = fhe.encodeVecDouble([1.0, 2.0, 3.0]);
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();
      expect(ct_bin, isNotEmpty);
    });

    test('fromBytes', () {
      final fhe = Seal('ckks');
      fhe.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      fhe.genKeys();
      final pt = fhe.encodeVecDouble([1.0, 2.0, 3.0]);
      final ct = fhe.encrypt(pt);
      final ct_bin = ct.toBytes();

      final ct2 = Ciphertext.fromBytes(fhe, ct_bin);
      final pt2 = fhe.decrypt(ct2);
      final pt2_list = fhe.decodeVecDouble(pt2, 3);
      near(pt2_list[0], 1.0, eps: 1e-7);
      near(pt2_list[1], 2.0, eps: 1e-7);
      near(pt2_list[2], 3.0, eps: 1e-7);
    });
  });
}
