import 'dart:math';

import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;
import 'package:fhel/afhe.dart' show Plaintext, Ciphertext;
import 'dart:ffi' show Pointer, Uint8;
import 'test_utils.dart' show near;

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
      int ct_pi_size = ct_pi.saveSize;
      Pointer<Uint8> host_ct_pi = ct_pi.save();

      // Encrypt + Save an integer vector
      Plaintext vec = host.encodeVecInt([1, 2, 3, 4, 5]);
      Ciphertext ct_vec = host.encrypt(vec);
      int ct_vec_size = ct_vec.saveSize;
      Pointer<Uint8> host_ct_vec = ct_vec.save();

      // Initialize guest
      final guest = Seal.noScheme();
      String g_ctx = guest.genContextFromParameters(h_param);
      expect(g_ctx, 'success: valid');

      guest.genKeys();

      // Load the ciphertexts from host
      final ct_pi_g = guest.loadCiphertext(host_ct_pi, ct_pi_size);
      final ct_vec_g = guest.loadCiphertext(host_ct_vec, ct_vec_size);

      // Guest adds 1 to each ciphertext
      final ct_pi_g_1 = guest.addPlain(ct_pi_g, guest.plain(1.toRadixString(16)));
      final ct_vec_g_1 = guest.addPlain(ct_vec_g, guest.encodeVecInt([1, 1, 1, 1, 1]));

      // Guest should not be able to decrypt the ciphertexts
      final dec_pi = guest.decrypt(ct_pi_g_1);
      expect('3', isNot(equals(dec_pi.text)));

      final dec_vec = guest.decrypt(ct_vec_g_1);
      expect([1, 2, 3, 4, 5], isNot(equals(guest.decodeVecInt(dec_vec, 5))));

      // Host should be able to decrypt the loaded, modified, ciphertexts
      final dec_pi_h = host.decrypt(ct_pi_g_1);
      expect('4', equals(dec_pi_h.text));

      final dec_vec_h = host.decrypt(ct_vec_g_1);
      expect([2, 3, 4, 5, 6], equals(host.decodeVecInt(dec_vec_h, 5)));
    }

    final host = Seal('ckks');
    Map<String, dynamic> ckks = {
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 60),
      'qSizes': [60, 40, 40, 60]
    };
    String h_ctx = host.genContext(ckks);
    expect(h_ctx, 'success: valid');
    host.genKeys();

    // Encrypt + Save a double
    double addend = 1.2345;
    double pi = 3.14159;
    // CKKS generates a list of size host.slot_count doubles
    List<double> pi_res = List.filled(host.slotCount, pi + addend);
    Plaintext pt_pi = host.encodeDouble(pi);
    Ciphertext ct_pi = host.encrypt(pt_pi);

    // Save the ciphertext
    int ct_pi_size = ct_pi.saveSize;
    Pointer<Uint8> host_ct_pi = ct_pi.save();

    // Encrypt + Save a double vector
    List<double> vec = [1.0, 2.0, 3.0, 4.0, 5.0];
    List<double> vec_res = [for (var element in vec) element + addend];
    Plaintext pt_vec = host.encodeVecDouble(vec);
    Ciphertext ct_vec = host.encrypt(pt_vec);

    // Save the ciphertext
    int ct_vec_size = ct_vec.saveSize;
    Pointer<Uint8> host_vec_pi = ct_vec.save();

    // Initialize guest
    final guest = Seal('ckks');
    String g_ctx = guest.genContext(ckks);
    expect(g_ctx, 'success: valid');
    guest.genKeys();

    // Load the ciphertexts from host
    final ct_pi_g = guest.loadCiphertext(host_ct_pi, ct_pi_size);
    final ct_vec_g = guest.loadCiphertext(host_vec_pi, ct_vec_size);

    // Guest adds 1.2345 to each ciphertext
    final ct_pi_g_1 = guest.addPlain(ct_pi_g, guest.encodeDouble(addend));
    final ct_vec_g_1 = guest.addPlain(ct_vec_g, guest.encodeVecDouble(List.filled(5, addend)));

    // Guest should not be able to decrypt the ciphertexts
    final dec_pi = guest.decrypt(ct_pi_g_1);
    expect(pi_res, isNot(equals(dec_pi.text)));

    final dec_vec = guest.decrypt(ct_vec_g_1);
    expect(vec_res, isNot(equals(guest.decodeVecDouble(dec_vec, 5))));

    // Host should be able to decrypt the loaded, modified, ciphertexts
    final dec_pi_h = host.decrypt(ct_pi_g_1);
    final dec_vec_pi_h = host.decodeVecDouble(dec_pi_h, guest.slotCount); // only check first 5
    for (var i = 0; i < pi_res.length; i++) {
      near(pi_res[i], dec_vec_pi_h[i]);
    }

    final dec_vec_h = host.decrypt(ct_vec_g_1);
    final dec_vec_h_d = host.decodeVecDouble(dec_vec_h, 5);
    for (var i = 0; i < vec_res.length; i++) {
      near(vec_res[i], dec_vec_h_d[i]);
    }
  });
}
