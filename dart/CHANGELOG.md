## 0.0.7

Add support for macOS binary in github releases
* Setup script now supports macOS

Binary is pulled from the latest release on Github, cached in .pub-cache for desktop platforms.

## 0.0.6

Added setup script to automate the process of setting up the library for the first time.

```bash
dart run fhel:setup <platform> --arch <architecture>
```

## 0.0.5

Testing linux release

## 0.0.4

CKKS Scheme
* Encode / Decode Vector[Float]
* Encrypt / Decrypt Plaintext

Save / Load Parameters and Ciphertext
* Pointer[Uin8] references serialized byte string

## 0.0.3

Library Restructure
* Afhe: Adapter of fully homomorphic encryption. Exposes Classes
* Seal: Expose end user APIs. Extends Afhe

## 0.0.2

Android Release
* Supported Architectures: 'arm64-v8a', 'armeabi-v7a', 'x86_64'
* Will not support x86
* Does not include optimizations for Microsoft SEAL

## 0.0.1

Fully Homomorphic Encryption Library using [dart:ffi](https://dart.dev/interop/c-interop).

[Microsoft SEAL](https://github.com/microsoft/SEAL)
* Scheme: BFV
* Operation: Add
* Data Types: Integer, Hexadecimal, List[Int]
