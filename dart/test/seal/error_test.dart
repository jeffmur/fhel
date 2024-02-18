import 'package:test/test.dart';
import 'package:fhel/seal.dart';
import 'package:fhel/afhe.dart';

void main() {
  test('Unsupported Backend', () {
    expect(() => Afhe('invalid', 'BFV'),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Backend: invalid')));
  });

  test('Unsupported Scheme', () {
    expect(() => Seal('invalid'),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Scheme: invalid')));
  });

  test('Context is not initialized', () {
    final seal = Seal('BFV');
    expect(() => seal.genKeys(),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Context is not initialized')));
  });

  test('No backend set', () {
    var afhe = Afhe('', '');
    expect(() => afhe.genKeys(),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: [init_backend] No backend set')));
  });
}
