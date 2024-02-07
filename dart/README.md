<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# FHEL

A Fully Homomorphic Encryption Library (FHEL) interface that exposes the basic functionalities of Microsoft [SEAL](https://github.com/microsoft/SEAL). Supports Android and Linux.

## Usage

To use this plugin, add `fhel` as a dependency in your pubspec.yaml

```dart

// SEALContext with BFV Scheme
final fhe = FHE.withScheme('seal', 'bfv');

// Generate context w/ parameters
Map<String, int> ctx = {
      'polyModDegree': 4096,
      'ptMod': 1024,
      'secLevel': 128
};
String status = fhe.genContext(context);
assert(status == 'success: valid', status)

// Generate public/private keys
fhe.genKeys();

// Create Plaintext obj, contain pointer SEALPlaintext
final pt_x = Plaintext.withValue(fhe.backend, '1');
final pt_add = Plaintext.withValue(fhe.backend, '2');

// Create Ciphertext obj, contain pointer to SEALCiphertext
final ct_x = fhe.encrypt(pt_x);
final ct_add = fhe.encrypt(pt_add);

// Add Ciphertexts, enc(1) + enc(2) = enc(3)
final ct_res = fhe.add(ct_x, ct_add);
final pt_res = fhe.decrypt(ct_res);

assert(pt_res.text == '3', 'Addition Failed')

```
