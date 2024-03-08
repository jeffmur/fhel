## 0.0.4

CKKS Scheme
* Encode / Decode Vector<Float>
* Encrypt / Decrypt Plaintext

Save / Load Parameters and Ciphertext
* Pointer<Uin8> references serialized byte string

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
* Data Types: Integer, Hexadecimal, List<Int>
