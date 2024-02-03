import 'dart:ffi';
import 'dart:io' show Directory;
import 'package:path/path.dart' as path;
import 'dart:io' show Platform;

String os = Platform.operatingSystem;

var file = switch (os) {
  'macos' => 'libfhel.dylib',
  'windows' => 'fhel.dll',
  _ => 'libfhel.so'
};

// from project root (parent of dart folder)
// var libraryPath = path.join(Directory.current.parent.path, 'build', file);
var libraryPath = path.join(Directory.current.path, 'bin', file);

final dylib = DynamicLibrary.open(libraryPath);
