import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;

void main() {
  test('Backend Microsoft SEAL', () {
    final fhe = FHE('seal');
    expect(fhe.backend.value, 1);
    expect(fhe.backend.prettyName, 'seal');
  });

  test('Backend OpenFHE', () {
    final fhe = FHE('openfhe');
    expect(fhe.backend.value, 2);
    expect(fhe.backend.prettyName, 'openfhe');
  });
}
