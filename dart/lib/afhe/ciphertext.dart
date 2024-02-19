/// This file contains the `Ciphertext` class and its associated FFI bindings.
part of '../afhe.dart';

typedef _InitCiphertextC = Pointer Function(BackendType backend);
typedef _InitCiphertext = Pointer Function(int backend);

final _InitCiphertext _c_init_ciphertext = dylib
    .lookup<NativeFunction<_InitCiphertextC>>('init_ciphertext')
    .asFunction();

typedef _GetCiphertextSizeC = Int32 Function(Pointer ciphertext);
typedef _GetCiphertextSize = int Function(Pointer ciphertext);

final _GetCiphertextSize _c_get_ciphertext_size = dylib
    .lookup<NativeFunction<_GetCiphertextSizeC>>('get_ciphertext_size')
    .asFunction();


/// Represents an underlying C ciphertext object.
///
/// A ciphertext is an encrypted message. It is the output of the encryption function,
/// and the input to the decryption and operation functions.
///
class Ciphertext {
  /// Represents the string representation of the ciphertext.
  // String text = "";
  /// Selects the [Backend] used for the encryption scheme.
  Backend backend = Backend();
  /// A pointer to the memory address of the underlying C++ object.
  Pointer obj = nullptr;

  /// Initializes a ciphertext using the provided backend.
  Ciphertext(this.backend) {
    obj = _c_init_ciphertext(backend.value);
  }

  /// Initializes a ciphertext using the provided [Backend] and [Pointer].
  Ciphertext.fromPointer(this.backend, this.obj);

  /// Returns the size of the ciphertext.
  int size() {
    return _c_get_ciphertext_size(obj);
  }
}

// --- noise budget ---

typedef _InvariantNoiseBudgetC = Int32 Function(Pointer library, Pointer ciphertext);
typedef _InvariantNoiseBudget = int Function(Pointer library, Pointer ciphertext);

/// Returns the invariant noise budget of the ciphertext.
final _InvariantNoiseBudget _c_invariant_noise_budget = dylib
    .lookup<NativeFunction<_InvariantNoiseBudgetC>>('invariant_noise_budget')
    .asFunction();

typedef _ModSwitchNextC = Void Function(Pointer library, Pointer ciphertext);
typedef _ModSwitchNext = void Function(Pointer library, Pointer ciphertext);

/// Modulus switches the ciphertext to the next level.
final _ModSwitchNext _c_mod_switch_next = dylib
    .lookup<NativeFunction<_ModSwitchNextC>>('mod_switch_to_next')
    .asFunction();
