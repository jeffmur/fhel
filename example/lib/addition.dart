import 'package:fhel/fhe.dart' show FHE;
import 'package:fhel/afhe/plaintext.dart';

List<int> addVector(Map<String,int> ctx, List<int> x, List<int> add) {
  final fhe = FHE.withScheme('seal', 'bfv');
  fhe.genContext(ctx);
  fhe.genKeys();

  final pt_x = fhe.encodeVecInt(x);
  final ct_x = fhe.encrypt(pt_x);

  final pt_add = fhe.encodeVecInt(add);
  final ct_add = fhe.encrypt(pt_add);

  final ct_res = fhe.add(ct_x, ct_add);
  final pt_res = fhe.decrypt(ct_res);

  return fhe.decodeVecInt(pt_res, x.length);
}

int addInt(Map<String, int> ctx, int x, int add) {
  final fhe = FHE.withScheme('seal', 'bfv');
  fhe.genContext(ctx);
  fhe.genKeys();

  // Convert to Hexidecimal
  final pt_x = Plaintext.withValue(fhe.backend, x.toRadixString(16));
  final ct_x = fhe.encrypt(pt_x);
  final pt_add = Plaintext.withValue(fhe.backend, add.toRadixString(16));
  final ct_add = fhe.encrypt(pt_add);
  final ct_res = fhe.add(ct_x, ct_add);
  final pt_res = fhe.decrypt(ct_res);

  return int.parse(pt_res.text, radix: 16);
}
