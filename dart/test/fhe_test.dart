import 'package:test/test.dart';

import 'package:fhe/fhe.dart' show FHE;

// void main() {
//   test('adds one to input values', () {
//     final calculator = Calculator();
//     expect(calculator.addOne(2), 3);
//     expect(calculator.addOne(-7), -6);
//     expect(calculator.addOne(0), 1);
//   });

//   test('factorial', () {
//     final calculator = Calculator();
//     expect(calculator.factorial(1), 1);
//     expect(calculator.factorial(2), 2);
//     expect(calculator.factorial(3), 6);
//   });
// }

void main() {
  test('FHE', () {
    final fhe = FHE();
    expect(fhe.backend, isNotNull);
  });
}
