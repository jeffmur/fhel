library flutter_seal;

import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

// FFI signature of the hello_world C function
typedef HelloWorldFunc = Void Function();
// Dart type definition for calling the C foreign function
typedef HelloWorld = void Function();

var libraryPath =
    path.join(Directory.current.path, 'lib/hello_world/build', 'libhello.so');

final dylib = DynamicLibrary.open(libraryPath);

// Look up the C function 'hello_world'
final HelloWorld hello =
    dylib.lookup<NativeFunction<HelloWorldFunc>>('hello_world').asFunction();

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
