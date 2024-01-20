library fhe;

import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

// // FFI signature of the hello_world C function
// typedef FactorialFunc = Int Function(Int);
// // Dart type definition for calling the C foreign function
// typedef Factorial = int Function(int);

typedef InitBackendC = Pointer Function(Int32 backend);
typedef InitBackend = Pointer Function(int backend);

typedef AddC = Int32 Function(Int32 a, Int32 b);
typedef Add = int Function(int a, int b);

var libraryPath =
    // from project root (parent of dart folder)
    path.join(Directory.current.parent.path, 'build', 'libfhel.dylib');

final dylib = DynamicLibrary.open(libraryPath);

final Add c_add = dylib.lookup<NativeFunction<AddC>>('add').asFunction();

// Look up the C function 'hello_world'
// final InitBackend c_init_backend =
//     dylib.lookup<NativeFunction<InitBackendC>>('init_backend').asFunction();

class FHE {
  int backend;

  FHE() : backend = c_add(1, 2);
}
