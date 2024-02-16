import 'package:test/test.dart';
import 'package:fhel/afhe.dart' show Afhe;

void main() {
  test('Not Implemented', () {
      final fhe = Afhe("openfhe", "foo");
      final ctx = fhe.genContext({});
      expect(ctx, "error: Invalid Scheme");

      final fhe_val = Afhe("openfhe", "bfv");
      final ctx_val = fhe_val.genContext({'polyModDegree': 4096,
                                          'ptMod': 1024,
                                          'secLevel': 128});

      expect(ctx_val, "warn: [generate_context] Not Implemented");
    });
}
