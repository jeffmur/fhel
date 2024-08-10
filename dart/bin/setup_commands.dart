// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:stack_trace/stack_trace.dart';

const setupPkgName = "fhel";
const baseUrl = "https://github.com/jeffmur/fhel/releases/download";
const ARCH_OPT_MAP = {
  "macos": ["arm64"],
  "windows": ["x64"],
  "linux": ["x64"],
  "android": ["x86_64", "arm64-v8a", "armeabi-v7a"],
  "ios": ["os64"],
};

abstract class BaseSetupCommand extends Command {
  @override
  String get description => "Setup";

  @override
  String get name => "base";

  String get arch {
    return argResults?["arch"] as String;
  }

  BaseSetupCommand() {
    argParser.addOption(
      "arch",
      abbr: "a",
      allowed: ARCH_OPT_MAP[name],
      defaultsTo: ARCH_OPT_MAP[name]!.first, // default to first arch
      mandatory: false,
    );
    argParser.addFlag("force", abbr: "f", help: "Force download and extract");
  }

  String get pkgRoot => Frame.caller().uri.resolve("..").toFilePath();

  bool get force => argResults?.flag("force") ?? false;
  String get os => name;

  Future<void> downloadAndExtract(String downArch,
      [String? extractPath]) async {
    print(asInfo('Using package:$setupPkgName from $pkgRoot'));

    // parse pubspec.yaml to get version
    final String version = File(p.join(pkgRoot, "pubspec.yaml"))
        .readAsStringSync()
        .split("\n")
        .firstWhere((line) => line.contains("version"))
        .split(":")[1]
        .trim()
        .replaceAll("'", "");
    final libTarName = "lib$setupPkgName-$os-$downArch.tar.gz";

    extractPath ??= switch (os) {
      OS.windows => p.join(pkgRoot, "windows"),
      OS.linux => p.join(pkgRoot, "linux"),
      OS.android =>
        p.join(pkgRoot, "android", "src", "main", "jniLibs", downArch),
      OS.macos => p.join(pkgRoot, "macos"),
      OS.ios => p.join(pkgRoot, "ios"),
      _ => throw UnsupportedError(asError("Platform $os not supported"))
    };

    if (!Directory(extractPath).existsSync()) {
      Directory(extractPath).createSync(recursive: true);
    }

    final cacheTarPath = p.join(pkgRoot, ".dart_tool", ".cache", libTarName);
    final saveFile = File(cacheTarPath);

    if (force || !saveFile.existsSync()) {
      if (!saveFile.parent.existsSync()) {
        saveFile.parent.createSync(recursive: true);
      }

      final String url = "$baseUrl/v$version/$libTarName";
      print(asInfo("Downloading $url"));
      try {
        final request = await HttpClient().getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode == 200) {
          await response.pipe(saveFile.openWrite());
          print(asWarning("Cached to $cacheTarPath"));
        } else {
          print(asError("Download Failed with status: ${response.statusCode}"));
          exit(1);
        }
      } catch (e) {
        print(asError(e.toString()));
        exit(1);
      }
    } else {
      print(asWarning("Using cached $cacheTarPath"));
      // Check if libs already existed, avoid double-extract
      if (Directory(extractPath)
          .listSync()
          .map(
            (e) =>
                e.path.endsWith(".so") ||
                e.path.endsWith(".dll") ||
                e.path.endsWith(".dylib") ||
                e.path.endsWith(".xcframework"),
          )
          .any((e) => e)) {
        print(asWarning("Libs already exists in $extractPath, Skipping..."));
        return;
      }
    }

    print(asInfo("Extracting to $extractPath"));
    final tarBytes = GZipDecoder().decodeBytes(saveFile.readAsBytesSync());
    final archive = TarDecoder().decodeBytes(tarBytes);
    await extractArchiveToDisk(archive, extractPath,
        bufferSize: 1024 * 1024 * 10); // 10MB
  }

  @override
  Future<void> run() async {
    print(asInfo("$setupPkgName: working for $os $arch"));
    await downloadAndExtract(arch);
    print(asInfo("Finished"));
    exit(0);
  }
}

class MacOsSetupCommand extends BaseSetupCommand {
  @override
  String get description => "Setup for macOS";

  @override
  String get name => "macos";
}

class WindowsSetupCommand extends BaseSetupCommand {
  @override
  String get description => "Setup for Windows";

  @override
  String get name => "windows";
}

class LinuxSetupCommand extends BaseSetupCommand {
  @override
  String get description => "Setup for Linux";

  @override
  String get name => "linux";
}

class AndroidSetupCommand extends BaseSetupCommand {
  @override
  String get description => "Setup for Android";

  @override
  String get name => "android";
}

class IosSetupCommand extends BaseSetupCommand {
  @override
  String get description => "Setup for IOS";

  @override
  String get name => "ios";
}

class OS {
  static const windows = "windows";
  static const linux = "linux";
  static const android = "android";
  static const ios = "ios";
  static const macos = "macos";
}

String asInfo(String text) => '✅\x1B[32m$text\x1B[0m';

String asWarning(String text) => '💡\x1B[33m$text\x1B[0m';

String asError(String text) => '⛔\x1B[31m$text\x1B[0m';
