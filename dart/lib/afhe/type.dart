import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhel/ffi.dart' show dylib;

// ------------------ Backend FHE Libraries ------------------
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
    String lowerName = fromName.toLowerCase();
    value = c_string_to_backend_type(lowerName.toNativeUtf8());
    name = fromName;
  }
}

typedef InitBackendC = Pointer Function(BackendType backend);
typedef InitBackend = Pointer Function(int backend);

final InitBackend c_init_backend =
    dylib.lookup<NativeFunction<InitBackendC>>('init_backend').asFunction();

// --- Types of Schemes supported by Backend Libraries ---

typedef SchemeType = Int;

typedef StringtoSchemeTypeC = SchemeType Function(Pointer<Utf8> scheme);
typedef StringToSchemeType = int Function(Pointer<Utf8> scheme);

final StringToSchemeType c_string_to_scheme_type = dylib
    .lookup<NativeFunction<StringtoSchemeTypeC>>('scheme_t_from_string')
    .asFunction();

class Scheme {
  int value = 0;
  String name = "";

  Scheme();

  Scheme.set(String fromName) {
    String lowerName = fromName.toLowerCase();
    value = c_string_to_scheme_type(lowerName.toNativeUtf8());
    name = fromName;
  }
}
