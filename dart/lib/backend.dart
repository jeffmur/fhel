import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/ffi.dart' show dylib;

typedef BackendType = Int;

typedef StringToBackendTypeC = BackendType Function(Pointer<Utf8> backend);
typedef StringToBackendType = int Function(Pointer<Utf8> backend);

final StringToBackendType c_string_to_backend_type = dylib
    .lookup<NativeFunction<StringToBackendTypeC>>('backend_t_from_string')
    .asFunction();

typedef BackendTypeToStringC = Pointer<Utf8> Function(BackendType backend);
typedef BackendTypeToString = Pointer<Utf8> Function(int backend);

final BackendTypeToString c_backend_type_to_string = dylib
    .lookup<NativeFunction<BackendTypeToStringC>>('backend_t_to_string')
    .asFunction();

class Backend {
  int value = 0;
  String prettyName = "";

  Backend();

  Backend.set(String name) {
    value = c_string_to_backend_type(name.toNativeUtf8());
    prettyName = name;
  }
}
