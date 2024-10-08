
## Fully Homomorphic Encryption Library

The Fully Homomorphic Encryption Library (fhel) is a powerful encryption library that enables fully homomorphic encryption (FHE) capabilities. It provides a seamless integration with Flutter, allowing developers to perform secure computations on encrypted data on resource constrained devices.

This library aims to expose basic functionalities to Flutter users to generate encryption context, derive keys, encrypt and decrypt data, and perform arithmetic operations on encrypted data. It provides a high-level abstraction for working with plaintext and ciphertext values, as well support for multiple encryption schemes.

With FHEL, developers can leverage the power of fully homomorphic encryption to perform computations on sensitive data while preserving privacy and security. It opens up new possibilities for secure data processing in applications built with Flutter.

For more information, see our [wiki](https://github.com/jeffmur/fhel/wiki)

## Development 🏗️

Compilation can become difficult when using multiple languages on multiple operating systems.

[Makefiles](https://www.gnu.org/software/make/manual/html_node/Introduction.html) are 🔑

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

## Distribution 📦

For distribution, we use [Conan](https://conan.io/) to manage C++ dependencies, wrapped with [Poetry](https://python-poetry.org/) to be run in a virtual environment.

From the root of the project:
```bash
pip install poetry
poetry config virtualenvs.create true
poetry install
conan create .
```
