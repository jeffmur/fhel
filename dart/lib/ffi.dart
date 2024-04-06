part of '../afhe.dart';

const String _libName = 'fhel';

/// Interop with the Abstract C FHE library via [dart:ffi](https://pub.dev/packages/ffi).
final DynamicLibrary dylib = () {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open(path.absolute("bin", 'lib$_libName.so'));
  }
  // if (Platform.isIOS || Platform.isMacOS) {
  //   return DynamicLibrary.open(path.absolute(pathPrefix, 'lib$_libName.dylib'));
  // }
  // if (Platform.isWindows) {
  //   return DynamicLibrary.open('$_libName.dll');
  // }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}();
