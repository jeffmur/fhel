import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/afhe/plaintext.dart';

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
}
