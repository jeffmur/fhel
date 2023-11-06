// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

// FFI signature of the hello_world C function
typedef HelloWorldFunc = Void Function();
// Dart type definition for calling the C foreign function
typedef HelloWorld = void Function();

void main() {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'lib/hello_world/build', 'libhello.so');

  final dylib = DynamicLibrary.open(libraryPath);

  // Look up the C function 'hello_world'
  final HelloWorld hello =
      dylib.lookup<NativeFunction<HelloWorldFunc>>('hello_world').asFunction();
  // Call the function
  hello();
}
