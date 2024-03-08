// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

void main() {
  final fhe = Seal('bfv'); // cannot exist without a scheme

  test('Default Constructor', () {
    final seal_pt = fhe.plain("");
    expect(seal_pt.text, "");
    expect(seal_pt.backend.name, 'seal');
    // Reference a new AsealPlaintext
    expect(seal_pt.obj.address, isNot(nullptr));
  });

  test('Constructor with Integer', () {
    final seal_pt_val = fhe.plain("123");
    expect(seal_pt_val.text, "123");
    expect(seal_pt_val.backend.name, fhe.backend.name);
    expect(seal_pt_val.obj.address, isNot(nullptr));
  });

  test('Constructor with Hexadecimal', () {
    String hex = 123.toRadixString(16); /* 7b */
    final seal_pt_val = fhe.plain(hex);
    expect(seal_pt_val.text, "7b");
    expect(seal_pt_val.backend.name, fhe.backend.name);
    expect(seal_pt_val.obj.address, isNot(nullptr));
  });
}
