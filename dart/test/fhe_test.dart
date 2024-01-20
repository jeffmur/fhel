import 'package:test/test.dart';

import 'package:fhe/fhe.dart' show FHE;

void main() {
  test('Default Backend Constructor', () {
    final fhe = FHE();
    expect(fhe.backend, 0);
  });

  test('Backend not supported', () {
    final fhe = FHE();
    fhe.init('not a backend');
    expect(fhe.backend, 0);
  });

  test('Backend seal', () {
    final fhe = FHE();
    fhe.init('seal');
    expect(fhe.backend, 1);
  });

  test('Backend openfhe', () {
    final fhe = FHE();
    fhe.init('openfhe');
    expect(fhe.backend, 2);
  });
}
