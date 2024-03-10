import 'dart:ffi';
import 'dart:math';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal, SealKey;

void main() {

  test("Invalid", () {
    try {
      SealKey("invalid", nullptr);
    } catch (e) {
      expect(e.toString(), "Exception: Unsupported Key Type: invalid");
    }
  });

  test("Cannot save key", () {
    SealKey pk = SealKey("public", nullptr);
    try {
      pk.save();
    } catch (e) {
      expect(e.toString(), "Exception: Cannot save key, as obj is not set");
    }
  });

  test("Save and Load", () {
    Map ctx = {
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 40),
      'qSizes': [60, 40, 40, 60]
    };
    final ckks = Seal('ckks');
    ckks.genContext(ctx);
    ckks.genKeys();
    ckks.genRelinKeys();

    // Retrieve the generated keys
    SealKey pk = ckks.publicKey;
    expect(pk.obj, isNot(null));
    expect(pk.type, 1);

    SealKey sk = ckks.secretKey;
    expect(sk.obj, isNot(null));
    expect(sk.type, 2);

    // Save the keys
    pk.save();
    sk.save();

    // Check the size of the saved, serialized strings, keys
    expect(pk.size, greaterThan(1));
    expect(sk.size, greaterThan(1));

    // Copy Public Key (Type)
    SealKey pkLoad = SealKey.ofType(pk);
    expect(pkLoad.obj, nullptr);
    expect(pkLoad.type, 1);
    expect(pkLoad.name, pk.name);

    // Load Public Key
    pkLoad.load(ckks.library, pk.serialized, pk.size);

    // Copy Secret Key (Type)
    SealKey skLoad = SealKey.ofType(sk);
    expect(skLoad.obj, nullptr);
    expect(skLoad.type, 2);
    expect(skLoad.name, sk.name);

    // Load Secret Key
    skLoad.load(ckks.library, sk.serialized, sk.size);
  });
}
