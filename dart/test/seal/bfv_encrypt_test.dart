import 'package:test/test.dart';
import 'package:fhel/fhe.dart' show FHE;
import 'package:fhel/afhe/plaintext.dart';

void main() {
  test('BFV Encrypt Hexidecimal', () {
    final fhe = FHE.withScheme("seal", "bfv");
    final context =
        fhe.genContext({'polyModDegree': 4096, 'ptMod': 4096, 'secLevel': 128});
    expect(context, "success: valid");
    fhe.genKeys();

    int pt_int = 2500;
    String pt = pt_int.toRadixString(16);
    final plaintext = Plaintext.withValue(fhe.backend, pt);
    final ciphertext = fhe.encrypt(plaintext);
    final decrypted = fhe.decrypt(ciphertext);

    // Check invariant noise budget
    expect(fhe.invariantNoiseBudget(ciphertext), lessThanOrEqualTo(53));

    // Validate that hexidecimal are equal
    expect(decrypted.text.toLowerCase(), pt.toLowerCase());

    // Validate that integers are equal
    expect(int.parse(decrypted.text, radix: 16), 2500);
  });

  test('BFV Encrypt List<int>', () {
    final fhe = FHE.withScheme('seal', 'bfv');
    fhe.genContext(
        {'polyModDegree': 8192, 'ptModBit': 20, 'ptMod': 0, 'secLevel': 128});
    fhe.genKeys();

    List<int> vec = [1, 2, 3, 4];

    final ptx = fhe.encodeVecInt(vec);

    final res = fhe.decodeVecInt(ptx, 4);

    for (int i = 0; i < res.length; i++) {
      expect(res[i], vec[i]);
    }
  });
}
