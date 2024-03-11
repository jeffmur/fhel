import 'dart:ffi';
import 'dart:math';
import 'package:test/test.dart';
import 'package:fhel/seal.dart' show Seal, SealKey;

// Scheme Parameters

Map ckks = {
  'polyModDegree': 8192,
  'encodeScalar': pow(2, 40),
  'qSizes': [60, 40, 40, 60]
};

Map bv = {
  'polyModDegree': 8192,
  'ptModBit': 20, // batching enabled
  'ptMod': 0,
  'secLevel': 128
};

Map scheme = {
  'ckks': ckks,
  'bfv': bv,
  'bgv': bv
};

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
    scheme.forEach((scheme, ctx) {
      final fhe = Seal(scheme);
      fhe.genContext(ctx);
      fhe.genKeys();
      fhe.genRelinKeys();

      // Retrieve the generated keys
      SealKey pk = fhe.publicKey;
      expect(pk.obj, isNot(null));
      expect(pk.type, 1);

      SealKey sk = fhe.secretKey;
      expect(sk.obj, isNot(null));
      expect(sk.type, 2);

      SealKey rk = fhe.relinKeys;
      expect(rk.obj, isNot(null));
      expect(rk.type, 3);

      // Save the keys
      pk.save();
      sk.save();
      rk.save();

      // Check the size of the saved, serialized strings, keys
      expect(pk.size, greaterThan(1));
      expect(sk.size, greaterThan(1));
      expect(rk.size, greaterThan(1));

      // Copy Public Key (Type)
      SealKey pkLoad = SealKey.ofType(pk);
      expect(pkLoad.obj, nullptr);
      expect(pkLoad.type, 1);
      expect(pkLoad.name, pk.name);

      // Load Public Key
      pkLoad.load(fhe.library, pk.serialized, pk.size);

      // Copy Secret Key (Type)
      SealKey skLoad = SealKey.ofType(sk);
      expect(skLoad.obj, nullptr);
      expect(skLoad.type, 2);
      expect(skLoad.name, sk.name);

      // Load Secret Key
      skLoad.load(fhe.library, sk.serialized, sk.size);

      // Copy Relin Key (Type)
      SealKey rkLoad = SealKey.ofType(rk);
      expect(rkLoad.obj, nullptr);
      expect(rkLoad.type, 3);
      expect(rkLoad.name, rk.name);

      // Load Relin Key
      rkLoad.load(fhe.library, rk.serialized, rk.size);
    });
  });

  test("Data", (){
    scheme.forEach((scheme, ctx) {
      final fhe = Seal(scheme);
      fhe.genContext(ctx);
      fhe.genKeys();
      fhe.genRelinKeys();

      // Retrieve the generated keys
      SealKey pk = fhe.publicKey;
      SealKey sk = fhe.secretKey;
      SealKey rk = fhe.relinKeys;

      // Test length of data array
      List<int> pkData = pk.data;
      expect(pkData.length, 2);

      List<int> skData = sk.data;
      expect(skData.length, 1);

      List<int> rkData = rk.data;
      if (scheme != 'ckks') {
        expect(rkData.length, 4); // BFV and BGV
      } else {
        expect(rkData.length, 3);
      }

      // Check that the data is not the same
      expect(pkData, isNot(skData));
      expect(rkData, isNot(skData));
      expect(rkData, isNot(pkData));
    });
  });
}
