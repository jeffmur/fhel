# Implementation Layer

The [adapter](https://refactoring.guru/design-patterns/adapter) design of this library interfaces with the abstraction layer, [README.md](../include/README.md). Using [dart:ffi](https://pub.dev/packages/ffi), Dart can execute C functions, reference memory addresses of object, and convert primitive data types.

```mermaid

classDiagram
    class Plaintext {
        String text
        Backend backend
        Pointer obj

        Plaintext(Backend, String)
        Plaintext(Backend, Pointer)
    }

    class Ciphertext {
        Backend backend
        Pointer library

        Ciphertext(Backend)
    }

    class Backend {
        int value
        String name
        
        Backend(String)
    }

    class Scheme {
        int value
        String name

        Scheme(String)
    }

    Plaintext --> FHE
    Ciphertext --> FHE
    Backend --> FHE
    Scheme --> FHE

    class FHE {
        Backend backend
        Scheme scheme
        Pointer library

        FHE(String)

        FHE(String, String)

        genContext(Map): void
        genKeys()
        encrypt(Plaintext): Ciphertext
        decrypt(Ciphertext): Plaintext
        add(Ciphertext, Ciphertext): Ciphertext
    }

```

Legend:
* `Plaintext`: Represents a plaintext value and provides a `to_string()` method to convert it to a string.

* `Ciphertext`: Represents an encrypted ciphertext value and provides a `size()` method to get its size.

* `FHE`: Models the desired backend FHE library and encryption schemas. Enables callers execute basic FHE functionalities.

