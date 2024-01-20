import 'dart:ffi';
import 'dart:io' show Directory;
import 'package:path/path.dart' as path;

var libraryPath =
    // from project root (parent of dart folder)
    path.join(Directory.current.parent.path, 'build', 'libfhel.so');

final dylib = DynamicLibrary.open(libraryPath);
