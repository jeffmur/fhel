import 'dart:math';
import 'package:fhel/seal.dart';
import 'package:fhel_calculator/page/settings.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const double WIDTH = 200;

const Color successColor = Color.fromARGB(255, 0, 84, 35);

const Color errorColor = Color.fromARGB(255, 148, 0, 0);

// Default context based on scheme
final Map ckks = {
  'polyModDegree': 8192,
  'encodeScalar': pow(2, 40),
  'qSizes': [60, 40, 40, 60]
};

// BFV / BGV with batching enabled
final Map batchingBV = {
  'polyModDegree': 4096,
  'ptModBit': 20,
  'secLevel': 128
};

// BFV / BGV with batching disabled
final Map noBatchingBV = {
  'polyModDegree': 4096,
  'ptMod': 4096,
  'secLevel': 128
};

/// Display a status banner and log [onFailure] message
/// 
/// If the operation is correct, display the actual result.
/// Otherwise, display the failure message.
ScaffoldFeatureController statusBanner(BuildContext context, SessionChanges session, bool isCorrect, String onSuccess, String onFailure) {
  if (!isCorrect) {
    session.log(onFailure);
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: isCorrect
        ? Text(onSuccess)
        : Text(onFailure),
      backgroundColor: isCorrect
        ? successColor
        : errorColor,
    )
  );
}

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
    ctxStatus = fhe.genContext(ctx);

    if (ctxStatus != 'success: valid') {
      throw Exception(ctxStatus);
    }

    // Generate Keys
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
Session globalSession = Session('bfv', {'polyModDegree': 4096, 'ptModBit': 20, 'secLevel': 128});
