/// This file contains the FFI bindings for handling C errors and throwing Dart exceptions.
part of '../afhe.dart';
// ignore_for_file: non_constant_identifier_names

typedef _ErrorC = Pointer<Utf8> Function();

final _check_for_error = dylib.lookupFunction<_ErrorC, _ErrorC>('check_for_error');

typedef _ClearErrorC = Void Function();
typedef _ClearError = void Function();
final _clear_error = dylib.lookupFunction<_ClearErrorC, _ClearError>('clear_error');

/// Checks for errors in the C++ library and throws a Dart [Exception] if an error is found.
String raiseForStatus() {
  final error = _check_for_error();
  if (error == nullptr) {
    return ''; // No error
  }
  final message = error.toDartString();
  _clear_error();
  throw Exception(message);
}
