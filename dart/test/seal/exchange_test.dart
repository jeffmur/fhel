import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

void main() {
  group("Parameters", () {
    test("Batching Enabled", () {
      List<String> schemes = ['bgv', 'bfv'];
      Map<String, int> ctx = {
        'polyModDegree': 1024,
        'ptMod': 1024,
        'secLevel': 128
      };

      for (var sch in schemes) {
        final host = Seal(sch);
        String h_ctx = host.genContext(ctx);
        expect(h_ctx, 'success: valid');
        Map saved = host.saveParameters();

        final guest = Seal.noScheme();
        String g_ctx = guest.genContextFromParameters(saved);
        expect(g_ctx, 'success: valid');
      }
    });

    test("Batching Disabled", () {
      List<String> schemas = ['bgv', 'bfv'];
      Map<String, int> ctx = {
        'polyModDegree': 8192,
        'ptModBit': 20,
        'secLevel': 128
      };

      for (var sch in schemas) {
        final host = Seal(sch);
        String h_ctx = host.genContext(ctx);
        expect(h_ctx, 'success: valid');
        Map saved = host.saveParameters();

        final guest = Seal.noScheme();
        String g_ctx = guest.genContextFromParameters(saved);
        expect(g_ctx, 'success: valid');
      }
    });

    test("CKKS", () {
      final host = Seal('ckks');
      Map<String, dynamic> ctx = {
        'polyModDegree': 8192,
        'encodeScalar': 64,
        'qSizes': [60, 40, 40, 60]
      };
      String h_ctx = host.genContext(ctx);
      expect(h_ctx, 'success: valid');
      Map saved = host.saveParameters();

      final guest = Seal.noScheme();
      String g_ctx = guest.genContextFromParameters(saved);
      expect(g_ctx, 'success: valid');
    });
  });
}
