import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;

void main() {
  test('Backend Microsoft SEAL', () {
    final fhe = FHE('seal');
    expect(fhe.backend.value, 1);
    expect(fhe.backend.name, 'seal');
  });

  test('Backend OpenFHE', () {
    final fhe = FHE('openfhe');
    expect(fhe.backend.value, 2);
    expect(fhe.backend.name, 'openfhe');
  });

  test('Schema are case in-senstitive', () {
    for (var name in ['BFV', 'BfV', 'bFv', 'bfv']) {
      final fhe = FHE.withScheme('seal', name);
      expect(fhe.scheme.value, 1);
      expect(fhe.scheme.name, name);
    }
  });

  test('Seal supports in-order BFV, CKKS, BGV', () {
    int i = 1;
    for (var name in ['BFV', 'CKKS', 'BGV']) {
      final fhe = FHE.withScheme('seal', name);
      expect(fhe.scheme.value, i);
      expect(fhe.scheme.name, name);
      i++;
    }
  });
}
