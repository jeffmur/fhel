import 'package:test/test.dart';

/// Asserts that [a] and [b] are nearly equal.
/// 
/// The optional parameter [eps] is the maximum difference between [a] and [b].
/// The optional parameter [relative] is whether to use relative or absolute difference.
/// 
void near(double actual, double expected, {double eps = 1e-12, bool relative = false}) {
    var bound = relative ? eps*expected.abs() : eps;
    if (actual == expected) {
      expect(actual, expected);
    } else {
      expect(actual, greaterThanOrEqualTo(expected-bound));
      expect(actual, lessThanOrEqualTo(expected+bound));
    }
}
