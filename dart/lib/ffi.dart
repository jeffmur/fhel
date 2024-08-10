part of '../afhe.dart';

const String _libraryName = 'fhel';

// pub-cache directory
String get desktopPubCachePath {
  final homeDir =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  final pubCachePath =
      Platform.environment['PUB_CACHE'] ?? '$homeDir/.pub-cache';
  final pubHostedUrl = Platform.environment['PUB_HOSTED_URL'] ?? 'pub.dev';
  return "$pubCachePath/hosted/$pubHostedUrl";
}

// dynamic libfhel
final libfhel = switch (Platform.operatingSystem) {
  "windows" => "$_libraryName.dll",
  "linux" || "android" => "lib$_libraryName.so",
  "macos" => "lib$_libraryName.dylib",
  _ => throw UnsupportedError(
      "Platform ${Platform.operatingSystem} not supported",
    )
};

// Latest .pub-cache version
final version = () {
  final pubCachePath = desktopPubCachePath;
  final directory = Directory(pubCachePath);

  // Filter for relevant directories and extract versions
  final versions = directory
      .listSync()
      .whereType<Directory>() // Filter out non-directory entries
      .map((directory) {
        final name = path.basename(directory.path);
        final match = RegExp('$_libraryName-(.*)').firstMatch(name);
        return match != null
            ? match.group(1)!
            : '-1'; // Use null-aware operator and assert non-null group
      })
      .where((version) => version != '-1') // Filter out non-matching versions
      .toList();

  versions.sort(); // Sort versions in ascending order

  return versions.isEmpty
      ? null
      : versions.last; // Handle the case where no matching versions are found
}();

// load native library
final DynamicLibrary dylib = () {
  // Continuous integration
  if (Platform.environment.containsKey('FHEL_C_LIB_PREFIX')) {
    return DynamicLibrary.open(Platform.environment['FHEL_C_LIB_PREFIX']! + libfhel);
  }
  // Development environment
  if (Platform.environment.containsKey('FHEL_C_LIB_PATH')) {
    return DynamicLibrary.open(Platform.environment['FHEL_C_LIB_PATH']!);
  }
  // Android: packaged at runtime, see dart/android/build.gradle
  if (Platform.isAndroid) {
    return DynamicLibrary.open(libfhel);
  }
  return DynamicLibrary.open(
      '$desktopPubCachePath/$_libraryName-$version/${Platform.operatingSystem}/$libfhel');
}();
