import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/afhe/plaintext.dart';

void main() {
  test("Addition", () {
    final fhe = FHE.withScheme('seal', 'bfv');
    String status = fhe.genContext(4096, 20, 1024, 128);
    expect(status, 'success: valid');
    fhe.genKeys();
    final plaintext1 = Plaintext.withValue(fhe.backend, '1');
    final plaintext2 = Plaintext.withValue(fhe.backend, '2');
    final ciphertext1 = fhe.encrypt(plaintext1);
    final ciphertext2 = fhe.encrypt(plaintext2);
    final ciphertext3 = fhe.add(ciphertext1, ciphertext2);
    final plaintext3 = fhe.decrypt(ciphertext3);
    expect(plaintext3.text, '3');
  });
}
