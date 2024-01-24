import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/ffi.dart' show dylib;

typedef BackendType = Int;

typedef StringToBackendTypeC = BackendType Function(Pointer<Utf8> backend);
typedef StringToBackendType = int Function(Pointer<Utf8> backend);

final StringToBackendType c_string_to_backend_type = dylib
    .lookup<NativeFunction<StringToBackendTypeC>>('backend_t_from_string')
    .asFunction();

class Backend {
  int value = 0;
  String name = "";

  Backend();

  Backend.set(String fromName) {
    value = c_string_to_backend_type(fromName.toNativeUtf8());
    name = fromName;
  }
}
