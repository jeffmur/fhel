import 'dart:math';

import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel/afhe.dart' show Plaintext, Ciphertext;
import 'dart:ffi' show Pointer, Uint8;

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
  test("Ciphertext", () {
    List<String> schemes = ['bgv', 'bfv'];
    Map<String, int> ctx = {
      'polyModDegree': 8192,
      'ptModBit': 20,
      'secLevel': 128
    };

    for (var sch in schemes) {
      final host = Seal(sch);
      String h_ctx = host.genContext(ctx);
      expect(h_ctx, 'success: valid');
      host.genKeys();

      Map h_param = host.saveParameters();

      // Encrypt + Save a hexidecimal number
      Plaintext pi = host.plain(3.toRadixString(16));
      Ciphertext ct_pi = host.encrypt(pi);
      int ct_pi_size = ct_pi.save_size();
      Pointer<Uint8> host_ct_pi = ct_pi.save();

      // Encrypt + Save an integer vector
      Plaintext vec = host.encodeVecInt([1, 2, 3, 4, 5]);
      Ciphertext ct_vec = host.encrypt(vec);
      int ct_vec_size = ct_vec.save_size();
      Pointer<Uint8> host_ct_vec = ct_vec.save();

      // Initialize guest
      final guest = Seal.noScheme();
      String g_ctx = guest.genContextFromParameters(h_param);
      expect(g_ctx, 'success: valid');

      // Load the ciphertexts from host
      final ct_pi_g = guest.loadCiphertext(host_ct_pi, ct_pi_size);
      final ct_vec_g = guest.loadCiphertext(host_ct_vec, ct_vec_size);

      // TODO: We should NOT be able to decrypt the ciphertexts
      // Without the secret key
    }
  });
}
