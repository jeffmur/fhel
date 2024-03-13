import 'dart:math';
import 'package:fhel/seal.dart';

// Default context based on scheme
Map ckks = {
  'polyModDegree': 8192,
  'encodeScalar': pow(2, 40),
  'qSizes': [60, 40, 40, 60]
};

// BFV / BGV with batching enabled
Map batching = {'polyModDegree': 4096, 'ptModBit': 20, 'secLevel': 128};

// BFV / BGV with batching disabled
Map plainModulus = {'polyModDegree': 4096, 'ptMod': 4096, 'secLevel': 128};

// Store the parameters that are used within the session

class Session {
  String scheme;
  Map ctx = {};
  Seal fhe = Seal.noScheme();
  String ctxStatus = 'Not set';

  void setScheme(String name) => scheme = name;

  /// Initialize the session with the scheme
  ///
  /// When [ctx] is empty, use default parameters based on the [scheme]
  Session(this.scheme, this.ctx) {
    fhe = Seal(scheme);
    print(ctx);
    ctxStatus = fhe.genContext(ctx);
    // Generate keys
    fhe.genKeys();
    fhe.genRelinKeys();
  }

  /// Retrieve the public key
  String get publicKey => fhe.publicKey.hexData.join(' ');

  /// Retrieve the secret key
  String get secretKey => fhe.secretKey.hexData.join(' ');

  /// Retrieve the relin keys
  String get relinKeys => fhe.relinKeys.hexData.join(' ');
}

/// Global session
Session globalSession = Session('bfv', batching);
