part of '../afhe.dart';

const String _libName = 'fhel';

/// Interop with the Abstract C FHE library via [dart:ffi](https://pub.dev/packages/ffi).
final DynamicLibrary dylib = () {
  var pathPrefix = "";
  // Development (test)
  // * Build from project root (parent of dart folder)
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    pathPrefix = path.join(Directory.current.parent.path, 'build');
  }
  // Release (pub)
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
