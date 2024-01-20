import 'dart:ffi';
import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/plaintext.dart';

void noValue(FHE fhe) {
  test('Plaintext No Value', () {
    final plaintext = Plaintext(fhe.backend);
    expect(plaintext.text, "");
    expect(plaintext.backend.prettyName, fhe.backend.prettyName);
    expect(plaintext.library.address, isNot(nullptr));
  });
}

void withValue(FHE fhe, String value) {
  test('Plaintext Value', () {
    final plaintext = Plaintext.withValue(fhe.backend, value);
    expect(plaintext.text, value);
    expect(plaintext.backend.prettyName, fhe.backend.prettyName);
    expect(plaintext.library.address, isNot(nullptr));
  });
}

void main() {
  group('Microsoft SEAL', () {
    final fhe = FHE('seal');
    noValue(fhe);
    // withValue(fhe, 'Hello, World!');
    withValue(fhe, '1234567890');
  });

  group('OpenFHE', () {
    final fhe = FHE('openfhe');
    noValue(fhe);
    withValue(fhe, 'Not Impelemented');
    withValue(fhe, '1234567890');
  });
}
