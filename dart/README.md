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

### Download Binaries

Stored in Github [Releases](https://github.com/jeffmur/fhel/releases)

```bash
flutter pub add fhel
dart run fhel:setup <platform> --arch <architecture>
```

| Platform | Architecture |
|----------|--------------|
| Android  | `x86_64` `arm64-v8a` `armeabi-v7a` |
| Linux    | `x64` |

```dart
import 'package:fhel/seal.dart';

// Generate context w/ parameters
Map<String, int> ctx = {
'polyModDegree': 4096,
'ptMod': 1024,
'secLevel': 128
};
// SEALContext with BFV Scheme
final bfv = Seal('bfv');

// Initialize context and verify
String status = bfv.genContext(ctx);
assert(status == 'success: valid', status);

// Generate public/private keys
bfv.genKeys();

// Create Plaintext obj, contains pointer C obj in memory
final plainOne = bfv.plain(2.toRadixString(16));
final plainTwo = bfv.plain(2.toRadixString(16));

// Create Ciphertext obj, contain pointer to SEALCiphertext
final cipherOne = bfv.encrypt(plainOne);

// Add Ciphertexts, enc(1) + 2 = enc(3)
final cipherAdd = bfv.addPlain(cipherOne, plainTwo);
final plainAdd = bfv.decrypt(cipherAdd);

// Decode Plaintext to int
final result = int.parse(plainAdd.text, radix: 16);
assert(result == 4, result);

```
