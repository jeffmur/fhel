import 'dart:ffi';
import 'dart:io' show Directory, Platform;
import 'package:path/path.dart' as path;

const String _libName = 'fhel';

final DynamicLibrary dylib = () {
  var pathPrefix = "";
  // Development
  // * Build from project root (parent of dart folder)
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    pathPrefix = path.join(Directory.current.parent.path, 'build');
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return DynamicLibrary.open(path.join(pathPrefix, 'lib$_libName.dylib'));
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open(path.join(pathPrefix, 'lib$_libName.so'));
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();