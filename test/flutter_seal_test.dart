import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_seal/flutter_seal.dart';

void main() {
  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });

  test('factorial', () {
    final calculator = Calculator();
    expect(calculator.factorial(1), 1);
    expect(calculator.factorial(2), 2);
    expect(calculator.factorial(3), 6);
  });
}
