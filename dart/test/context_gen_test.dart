import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;

void main() {
  test('Valid Parameters', () {
    final fhe = FHE("seal");
    final context = fhe.genContext(4096, 20, 1024, 128);
    expect(context, "success: valid");
  });

  test('Invalid Plaintext Mod Degree', () {
    final fhe = FHE("seal");
    final context = fhe.genContext(0, 0, 0, 0);
    expect(context, "invalid_argument: non-standard poly_modulus_degree");
  });

  // In Microsoft SEAL the degree of the polynomial modulus must be a power of 2
  // (e.g. 1024, 2048, 4096, 8192, 16384, or 32768).
  test('Invalid Plaintext Mod Bit Count', () {
    final fhe = FHE("seal");
    final context = fhe.genContext(4096, 0, 0, 0);
    expect(context.split(':')[0], "invalid_plain_modulus_bit_count");
  });
}
