/// This file contains the FFI bindings for encryption and decryption methods.
part of '../afhe.dart';

typedef KeyType = Int;

typedef _StringToKeyTypeC = KeyType Function(Pointer<Utf8> key);
typedef _StringToKeyType = int Function(Pointer<Utf8> key);
final _StringToKeyType _c_string_to_key_type = dylib
    .lookup<NativeFunction<_StringToKeyTypeC>>('key_t_from_string').asFunction();

// --- encryption keys ---

typedef _GenKeysC = Void Function(Pointer library);
typedef _GenKeys = void Function(Pointer library);
final _GenKeys _c_gen_keys = dylib
    .lookup<NativeFunction<_GenKeysC>>('generate_keys').asFunction();

// --- relinearization keys ---

typedef _GenRelinKeysC = Void Function(Pointer library);
typedef _GenRelinKeys = void Function(Pointer library);
final _GenRelinKeys _c_gen_relin_keys = dylib
    .lookup<NativeFunction<_GenRelinKeysC>>('generate_relin_keys').asFunction();

// --- save keys ---

typedef _SaveKeys = Pointer<Uint8> Function(Pointer key);
final _SaveKeys _c_save_key = dylib
    .lookup<NativeFunction<_SaveKeys>>('save_key').asFunction();

typedef _SaveKeysSizeC = Int32 Function(Pointer key);
typedef _SaveKeysSize = int Function(Pointer key);
final _SaveKeysSize _c_save_key_size = dylib
    .lookup<NativeFunction<_SaveKeysSizeC>>('save_key_size').asFunction();

// --- get keys ---

typedef _GetKey = Pointer Function(Pointer library);

final _GetKey _c_get_public_key = dylib
    .lookup<NativeFunction<_GetKey>>('get_public_key').asFunction();

final _GetKey _c_get_secret_key = dylib
    .lookup<NativeFunction<_GetKey>>('get_secret_key').asFunction();

final _GetKey _c_get_relin_keys = dylib
    .lookup<NativeFunction<_GetKey>>('get_relin_keys').asFunction();

// --- key data ---

typedef _GetKeyData = Pointer<Uint64> Function(Pointer key);
final _GetKeyData _c_get_key_data = dylib
    .lookup<NativeFunction<_GetKeyData>>('get_key_data').asFunction();

typedef _GetKeyDataSizeC = Int32 Function(Pointer key);
typedef _GetKeyDataSize = int Function(Pointer key);
final _GetKeyDataSize _c_get_key_data_size = dylib
    .lookup<NativeFunction<_GetKeyDataSizeC>>('get_key_data_size').asFunction();


// --- load keys ---

typedef _LoadKeyC = Pointer Function(KeyType keyType, Pointer library, Pointer<Uint8> serialized, Int32 size);
typedef _LoadKey = Pointer Function(int keyType, Pointer library, Pointer<Uint8> serialized, int size);

final _LoadKey _c_load_key = dylib
    .lookup<NativeFunction<_LoadKeyC>>('load_key').asFunction();

/// Represents an underlying key object in memory
/// 
/// A key is used to encrypt and decrypt data. Typically, keys are generated
/// within the [Backend] library and are immutable.
class Key {
  /// The memory address of the underlying C key object
  /// 
  /// This is used as a reference to the key in memory
  Pointer obj = nullptr;
  /// Type of key
  int type = -1;
  /// The friendly name of the key.
  String name = "";
  /// The memory address of the underlying C library
  /// 
  /// This is used to validate a serialized key
  Pointer library = nullptr;
  /// Byte array containing the key
  Pointer<Uint8> serialized = nullptr;
  /// Size of the serialized key
  int size = -1;

  /// Constructs a key referencing the underlying C [obj] in memory
  /// 
  /// The [type] and [name] are used to classify the type of key
  Key(this.name, this.obj) {
    type = _c_string_to_key_type(name.toNativeUtf8());
    raiseForStatus();
  }

  /// Constructs a key from the existing [Key]
  /// 
  /// Copying [type] and [name] of [from]
  Key.ofType(Key from) {
    type = from.type;
    name = from.name;
  }

  /// Loads a key from a byte array
  /// 
  /// [serialized] is the byte array containing the key of [size]
  /// validates new key with [library] during creation.
  load(Pointer fhe, Pointer<Uint8> serialData, int serialSize) {
    obj = _c_load_key(type, fhe, serialData, serialSize);
    raiseForStatus();
  }

  /// Saves the key to a byte array
  /// 
  /// The key is saved to [serialized] and [size] is updated
  void save() {
    if (obj == nullptr)
    {
      throw Exception("Cannot save key, as obj is not set");
    }
    serialized = _c_save_key(obj);
    size = _c_save_key_size(obj);
    raiseForStatus();
  }

  /// Returns the key data as a List<int>
  ///
  /// A key cannot be reconstructed from this data,
  /// as this is intended for uniquely identifying keys
  List<int> get data {
    if (obj == nullptr)
    {
      throw Exception("Cannot get key data, as obj is not set");
    }
    Pointer<Uint64> data = _c_get_key_data(obj);
    int length = _c_get_key_data_size(obj);
    List<int> keyData = data.asTypedList(length).toList();
    return keyData;
  }

  /// Returns [data] as a List<Hexadecimal>
  List<String> get hexData {
    return data.map((e) => e.toRadixString(16)).toList();
  }
}
