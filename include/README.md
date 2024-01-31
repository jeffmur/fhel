# Abstraction Layer

The [bridge](https://refactoring.guru/design-patterns/bridge) design of this library implements an abstraction layer over existing Fully Homomorphic Encryption (FHE) libraries. Through abstraction, we can interface with various backend libraries via the same function calls.

```mermaid

---
title: Figure 1 - UML Class Diagram
---
classDiagram
    Afhe <|-- SEAL

    class backend_t {
        <<Enumeration>>
        SEAL
        OpenFHE
    }

    class scheme_t {
        <<Enumeration>>
        NONE
        BFV
        BGV
        CKKS
    }

    class Plaintext{
        to_string(): String
    }

    class Ciphertext{
        size(): Int
    }

    scheme_t --> Afhe
    Plaintext --> Afhe
    Ciphertext --> Afhe

    class Afhe {
        <<Abstract>>
        scheme_t scheme

        ContextGen(scheme_t): string
        KeyGen(): void
        encrypt(Plaintext): Ciphertext
        decrypt(Ciphertext): Plaintext
        add(Ciphertext, Ciphertext): Ciphertext
    }

    class SEAL~Afhe~{
        get_context(): SEALContext
        encrypt(SEALPlaintext): SEALCiphertext
        decrypt(SEALCiphertext): SEALPlaintext
        add(SEALCiphertext, SEALCiphertext): SEALCiphertext
    }

    class FHE {
        <<interface>>
        backend_t_from_string(String): backend_t
        scheme_t_from_string(String): scheme_t
        init_backend(backend_t): Afhe
        init_plaintext(backend_t): Plaintext
        init_ciphertext(backend_t): Ciphertext
        generate_context(backend_t, Afhe, scheme_t): String
        generate_keys(backend_t, Afhe): void
        encrypt(backend_t, Afhe, Plaintext): Ciphertext
        decrypt(backend_t, Afhe, Ciphertext): Plaintext
        invariant_noise_budget(backend_t, Afhe, Ciphertext): string
        add(backend_t, Afhe, Ciphertext, Ciphertext): Ciphertext
    }

    Afhe --> FHE
    backend_t --> FHE

```

Legend:

* `Afhe`: An abstract class representing the main functionality of the library. It has an integer attribute scheme_t that determines the encryption scheme(s) are supported. It provides methods for generating keys, encrypting and decrypting data, and performing addition operations.

* `SEAL`: A concrete, refined abstraction, class that extends Afhe and represents a specific implementation of the library using the SEAL encryption scheme. It provides its own implementations of the encryption, decryption, and addition methods.

* `FHE`: An interface that defines a method get_backend for obtaining an instance of Afhe based on a given backend library type, SEAL, that will execute the appropriate function call.

* `Plaintext` & `Ciphertext`: An abstract class representing the basic functionality of text objects. Used as the main interface for backend required parameters.

* `backend_t`: An enumeration class representing different Fully Homomorphic Encryption libraries.

* `scheme_t`: An enumeration class representing different encryption schemes, including BFV, BGV, and CKKS.
