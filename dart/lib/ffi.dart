part of '../afhe.dart';

const String _libName = 'fhel';

/// Interop with the Abstract C FHE library via [dart:ffi](https://pub.dev/packages/ffi).
final DynamicLibrary dylib = () {
  // const pathPrefix = "bin";
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
    // return DynamicLibrary.open(path.absolute(pathPrefix, 'lib$_libName.so'));
  }
  if (Platform.isMacOS) {
    return DynamicLibrary.open('lib$_libName.dylib');
    // return DynamicLibrary.open(path.absolute(pathPrefix, 'lib$_libName.dylib'));
  }
  // if (Platform.isWindows) {
  //   return DynamicLibrary.open('$_libName.dll');
  // }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}();
