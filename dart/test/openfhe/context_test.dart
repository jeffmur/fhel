import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;

void main() {
  test('Not Implemented', () {
      final fhe = FHE("openfhe");
      final ctx = fhe.genContext({});
      expect(ctx, "error: Invalid Scheme");

      final fhe_val = FHE.withScheme("openfhe", "bfv");
      final ctx_val = fhe_val.genContext({'polyModDegree': 4096,
                                          'ptMod': 1024, 
                                          'secLevel': 128});

      expect(ctx_val, "warn: [generate_context] Not Implemented");
    });
}
