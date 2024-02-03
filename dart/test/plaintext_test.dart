import 'dart:ffi';
import 'package:test/test.dart';
import 'package:fhel/fhe.dart' show FHE;
import 'package:fhel/afhe/plaintext.dart';

void main() {
  group('Microsoft SEAL', () {
    final fhe = FHE('seal');

    test('Default Constructor', () {
      final seal_pt = Plaintext(fhe.backend);
      expect(seal_pt.text, "");
      expect(seal_pt.backend.name, 'seal');
      // Reference a new AsealPlaintext
      expect(seal_pt.obj.address, isNot(nullptr));
    });

    test('Constructor with Integer', () {
      final seal_pt_val = Plaintext.withValue(fhe.backend, "123");
      expect(seal_pt_val.text, "123");
      expect(seal_pt_val.backend.name, fhe.backend.name);
      expect(seal_pt_val.obj.address, isNot(nullptr));
    });

    test('Constructor with Hexadecimal', () {
      String hex = 123.toRadixString(16); /* 7b */
      final seal_pt_val = Plaintext.withValue(fhe.backend, hex);
      expect(seal_pt_val.text, "7b");
      expect(seal_pt_val.backend.name, fhe.backend.name);
      expect(seal_pt_val.obj.address, isNot(nullptr));
    });
  });
}
