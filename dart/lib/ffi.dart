part of '../afhe.dart';

const String _libraryName = 'fhel';

// load native library
final DynamicLibrary dylib = () {
  if (Platform.isIOS) return DynamicLibrary.process();
  final defaultLibPath = switch (Platform.operatingSystem) {
    "windows" => "$_libraryName.dll",
    "linux" || "android" => "lib$_libraryName.so",
    "macos" => "lib$_libraryName.dylib",
    _ => throw UnsupportedError(
        "Platform ${Platform.operatingSystem} not supported",
      )
  };
  final libPath = path.absolute(
      Platform.environment["FHEL_C_LIB_PREFIX"] ?? '', defaultLibPath);
  return DynamicLibrary.open(libPath);
}();
