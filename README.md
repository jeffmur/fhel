
## Fully Homomorphic Encryption Library

The Fully Homomorphic Encryption Library (FHEL) is a powerful encryption library that enables fully homomorphic encryption (FHE) capabilities. It provides a seamless integration with Flutter, allowing developers to perform secure computations on encrypted data on resource constrained devices.

At the core of this library is an abstract wrapper around existing FHE Libraries via AFHEL (Abstract FHE Library). The AFHEL exposes basic C functionalities to be consumed by Dart. The Dart adapter layer, FHE, acts as an consumer friendly API interface between Flutter and AFHEL. Using Object Oriented Programming, OOP, the FHE models itself as a library with basic functionalities of the desired backend library.

This library aims to expose basic functionalities to Flutter users to generate encryption context, derive keys, encrypt and decrypt data, and perform arithmetic operations on encrypted data. It provides a high-level abstraction for working with plaintext and ciphertext values, as well support for multiple encryption schemes.

With FHEL, developers can leverage the power of fully homomorphic encryption to perform computations on sensitive data while preserving privacy and security. It opens up new possibilities for secure data processing in applications built with Flutter.

## Development 🏗️

Compilation can become difficult when using multiple languages on multiple operating systems. [Makefiles](https://www.gnu.org/software/make/manual/html_node/Introduction.html) are 🔑.

In general commands denoted with `ci` should encompass all required action(s), while others should perform a single action.

### Compilation 👷

For compiliation, see backend [Makefile](./src/backend/Makefile) for library configuration.

From the root of the project:
```bash
make build-cmake
```

### Unit Testing 🧪

For C++, we have integrated [GoogleTest](https://github.com/google/googletest) as our testing framework.

From the root of the project:
```bash
make ctest
```

For Dart, the [SDK](https://dart.dev/tools/sdk) comes out-of-the-box with a comprehensive testing framework.

From the root of the projct:
```bash
make dtest
```

## Deployment 🚀

Currently configured to be manually deployed via:
```bash
dart pub publish
```

In the future, we may configure an [automated](https://dart.dev/tools/pub/automated-publishing) publishing.
