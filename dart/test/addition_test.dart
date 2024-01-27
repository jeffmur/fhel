import 'package:test/test.dart';
import 'package:fhe/fhe.dart' show FHE;
import 'package:fhe/afhe/plaintext.dart';

void main() {
  test("Addition", () {
    final fhe = FHE.withScheme('seal', 'bfv');
    String status = fhe.genContext(4096, 20, 1024, 128);
    expect(status, 'success: valid');
    fhe.genKeys();
    final pt_x = Plaintext.withValue(fhe.backend, '1');
    final ct_x = fhe.encrypt(pt_x);
    final pt_add = Plaintext.withValue(fhe.backend, '2');
    final ct_add = fhe.encrypt(pt_add);
    final ct_res = fhe.add(ct_x, ct_add);
    final pt_res = fhe.decrypt(ct_res);
    expect(pt_res.text, '3');
  });
}
