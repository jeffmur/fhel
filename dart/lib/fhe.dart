library fhe;

import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

// FFI signature of the hello_world C function
typedef FactorialFunc = Int Function(Int);
// Dart type definition for calling the C foreign function
typedef Factorial = int Function(int);

var libraryPath =
    // from project root (parent of dart folder)
    path.join(Directory.current.parent.path, 'examples/hello_world/build',
        'libhello.so');

final dylib = DynamicLibrary.open(libraryPath);

// Look up the C function 'hello_world'
final Factorial c_factorial =
    dylib.lookup<NativeFunction<FactorialFunc>>('factorial').asFunction();

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;

  int factorial(int value) => c_factorial(value);
}
