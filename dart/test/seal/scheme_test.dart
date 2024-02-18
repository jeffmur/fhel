import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

void main() {
  test('Schemes are case in-senstitive', () {
    for (var name in ['BFV', 'BfV', 'bFv', 'bfv']) {
      final fhe = Seal(name);
      expect(fhe.scheme.value, 1);
      expect(fhe.scheme.name, name);
    }
  });

  test('Schemes supports in-order', () {
    final schemes = {1: 'BFV', 2: 'CKKS', 3: 'BGV'};
    schemes.forEach((k, v) {
      final fhe = Seal(v);
      expect(fhe.scheme.value, k);
      expect(fhe.scheme.name, v);
    });
  });
}
