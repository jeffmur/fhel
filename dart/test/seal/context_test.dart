import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal;

// Least Significant Bit (LSB), Most Significant Bit (MSB)
const schemes = ['bgv', 'bfv'];

void main() {
  test('Valid Parameters', () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final context = fhe
          .genContext({'polyModDegree': 4096, 'ptMod': 1024, 'secLevel': 128});
      expect(context, "success: valid");
    }
  });

  test('Invalid Plaintext Mod Degree', () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final context =
          fhe.genContext({'polyModDegree': 0, 'ptMod': 1024, 'secLevel': 128});
      expect(context, "invalid_argument: non-standard poly_modulus_degree");
    }
  });

  // In Microsoft SEAL the degree of the polynomial modulus must be a power of 2
  // (e.g. 1024, 2048, 4096, 8192, 16384, or 32768).
  test('Invalid Plaintext Mod Bit Count', () {
    for (var sch in schemes) {
      final fhe = Seal(sch);
      final context =
          fhe.genContext({'polyModDegree': 4096, 'ptMod': 0, 'secLevel': 128});
      expect(
          context,
          "invalid_plain_modulus_bit_count: plain_modulus's bit count "
          "is not bounded by SEAL_PLAIN_MOD_BIT_COUNT_MIN(MAX)");
    }
  });

  test('CKKS not yet supported', () {
    final fhe = Seal('ckks');
    expect(
        () => fhe
            .genContext({'polyModDegree': 4096, 'ptMod': 0, 'secLevel': 128}),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString() == 'Exception: Unsupported scheme ckks')));
  });

  /* TODO: Security level is not checked during parameter validation */
  // However, there are only 3 options: 128, 192, 256 in SEAL
  // test('Invalid Security Level', () {
  //   final fhe = FHE.withScheme("seal", "bfv");
  //   final context =
  //       fhe.genContext({'polyModDegree': 4096, 'ptMod': 1024, 'secLevel': 127});
  //   fhe.genKeys();
  //   fhe.encrypt(Plaintext.withValue(fhe.backend, "1"));
  //   // expect(context, "invalid_argument: invalid security level");
  // });
}
