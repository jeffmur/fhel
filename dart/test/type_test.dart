import 'package:test/test.dart';
import 'package:fhel/fhe.dart' show FHE;

void main() {
  group('Backend:', () {
    test('Microsoft SEAL', () {
      final fhe = FHE('seal');
      expect(fhe.backend.value, 1);
      expect(fhe.backend.name, 'seal');
    });

    test('OpenFHE', () {
      final fhe = FHE('openfhe');
      expect(fhe.backend.value, 2);
      expect(fhe.backend.name, 'openfhe');
    });
  });

  test('Schema are case in-senstitive', () {
    for (var name in ['BFV', 'BfV', 'bFv', 'bfv']) {
      final fhe = FHE.withScheme('seal', name);
      expect(fhe.scheme.value, 1);
      expect(fhe.scheme.name, name);
    }
  });

  test('Seal Schemes supports in-order', () {
    final schemes = {1: 'BFV', 2: 'CKKS', 3: 'BGV'};
    schemes.forEach((k, v) {
      final fhe = FHE.withScheme('seal', v);
      expect(fhe.scheme.value, k);
      expect(fhe.scheme.name, v);
    });
  });
}
