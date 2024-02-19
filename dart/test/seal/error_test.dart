import 'package:test/test.dart';
import 'package:fhel/seal.dart';
import 'package:fhel/afhe.dart';

void main() {
  test('Unsupported Backend', () {
    expect(() => Afhe('', ''),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Backend: null')));
    expect(() => Afhe('invalid', 'BFV'),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Backend: invalid')));
  });

  test('Unsupported Scheme', () {
    expect(() => Seal(''),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Scheme: null')));
    expect(() => Seal('invalid'),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Unsupported Scheme: invalid')));
  });

  test('Context is not initialized', () {
    final seal = Seal('BFV');
    expect(() => seal.genKeys(),
      throwsA(predicate((e) => e is Exception && e.toString() == 'Exception: Context is not initialized')));
  });

}
