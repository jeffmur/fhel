import 'package:test/test.dart';

/// Asserts that [a] and [b] are nearly equal.
/// 
/// The optional parameter [eps] is the maximum difference between [a] and [b].
/// The optional parameter [relative] is whether to use relative or absolute difference.
/// 
void near(double a, double b, {double eps = 1e-12, bool relative = false}) {
    var bound = relative ? eps*b.abs() : eps;
    if (a == b) {
      expect(a, b);
    } else {
      expect(a, greaterThanOrEqualTo(b-bound));
      expect(a, lessThanOrEqualTo(b+bound));
    }
}
