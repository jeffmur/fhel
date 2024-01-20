library fhe;

import 'dart:ffi';
import 'dart:io' show Directory;
import 'package:ffi/ffi.dart'; // for Utf8

import 'package:path/path.dart' as path;

var libraryPath =
    // from project root (parent of dart folder)
    path.join(Directory.current.parent.path, 'build', 'libfhel.so');

final dylib = DynamicLibrary.open(libraryPath);

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

typedef InitBackendC = Pointer Function(BackendType backend);
typedef InitBackend = Pointer Function(int backend);

final InitBackend c_init_backend =
    dylib.lookup<NativeFunction<InitBackendC>>('init_backend').asFunction();

// TODO: wrap C backend struct

class FHE {
  int backend;
  String backendName;

  FHE()
      : backend = 0,
        backendName = '';

  init(String name) {
    backend = c_string_to_backend_type(name.toNativeUtf8());
    backendName = name;
  }
}
