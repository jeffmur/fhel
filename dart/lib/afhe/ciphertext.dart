/// This file contains the `Ciphertext` class and its associated FFI bindings.
part of '../afhe.dart';
// ignore_for_file: non_constant_identifier_names

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

typedef _SaveCiphertextC = Pointer<Uint8> Function(Pointer ciphertext);
typedef _SaveCiphertext = Pointer<Uint8> Function(Pointer ciphertext);

final _SaveCiphertext _c_save_ciphertext = dylib
    .lookup<NativeFunction<_SaveCiphertextC>>('save_ciphertext')
    .asFunction();

typedef _SaveCipherSizeC = Int32 Function(Pointer ciphertext);
typedef _SaveCipherSize = int Function(Pointer ciphertext);

final _SaveCipherSize _c_get_ciphertext_save_size = dylib
    .lookup<NativeFunction<_SaveCipherSizeC>>('save_ciphertext_size')
    .asFunction();

typedef _LoadCiphertextC = Pointer Function(
    Pointer library, Pointer<Uint8> data, Int size);
typedef _LoadCiphertext = Pointer Function(
    Pointer library, Pointer<Uint8> data, int size);

final _LoadCiphertext _c_load_ciphertext = dylib
    .lookup<NativeFunction<_LoadCiphertextC>>('load_ciphertext')
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

  /// Returns the number of bytes of the ciphertext.
  int get size => _c_get_ciphertext_size(obj);

  /// Calculates the number of bytes of the serialized ciphertext.
  int get saveSize => _c_get_ciphertext_save_size(obj);

  /// Saves the [Ciphertext] to a non-human-readable format.
  /// Useful for saving to disk or sending over the network.
  Pointer<Uint8> save() => _c_save_ciphertext(obj);

  /// Converts a [Ciphertext] into a serialized binary format.
  Uint8List toBytes() => save().asTypedList(saveSize);

  /// Loads a [Ciphertext] from a serialized binary format.
  Ciphertext.fromBytes(Afhe fhe, Uint8List bytes) {
    final Pointer<Uint8> pointer = malloc.allocate<Uint8>(bytes.length);
    // Copy the bytes to the allocated memory
    final Uint8List pointerContent = pointer.asTypedList(bytes.length);
    pointerContent.setAll(0, bytes);
    obj = _c_load_ciphertext(fhe.library, pointer, bytes.length);
  }
}

// --- noise budget ---

typedef _InvariantNoiseBudgetC = Int32 Function(
    Pointer library, Pointer ciphertext);
typedef _InvariantNoiseBudget = int Function(
    Pointer library, Pointer ciphertext);

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
