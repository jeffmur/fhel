/// This file contains the types of supported backend libraries.
part of '../afhe.dart';

typedef BackendType = Int;

typedef _StringToBackendTypeC = BackendType Function(Pointer<Utf8> backend);
typedef _StringToBackendType = int Function(Pointer<Utf8> backend);

final _StringToBackendType _c_string_to_backend_type = dylib
    .lookup<NativeFunction<_StringToBackendTypeC>>('backend_t_from_string')
    .asFunction();

/// Represents the backend library used for the encryption scheme.
///
/// Supported backends:
///  * Simple Encrypted Arithmetic Library (SEAL), Microsoft Research
///
class Backend {
  /// The integer value of the backend.
  int value = 0;
  /// The friendly name of the backend.
  String name = "";

  /// Initializes an unspecified backend.
  Backend();

  /// Initializes a backend using the provided name.
  ///
  /// The name is case-insensitive. Retrieves the integer value of the backend from the C++ backend.
  Backend.set(String fromName) {
    String lowerName = fromName.toLowerCase();
    value = _c_string_to_backend_type(lowerName.toNativeUtf8());
    name = fromName;
  }
}

typedef _InitBackendC = Pointer Function(BackendType backend);
typedef _InitBackend = Pointer Function(int backend);

final _InitBackend _c_init_backend =
    dylib.lookup<NativeFunction<_InitBackendC>>('init_backend').asFunction();
