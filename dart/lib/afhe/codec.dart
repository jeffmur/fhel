/// This file contains the FFI bindings for the encode and decode methods.
part of '../afhe.dart';

// --- encode ---

typedef _EncodeVectorIntC = Pointer Function(
    BackendType backend, Pointer library, Pointer<Uint64> vec, Int size);

typedef _EncodeVectorInt = Pointer Function(
    int backend, Pointer library, Pointer<Uint64> vec, int size);

final _EncodeVectorInt _c_encode_vector_int =
    dylib.lookupFunction<_EncodeVectorIntC, _EncodeVectorInt>('encode_int');

/// Convert Dart int list to C uint64 array.
Pointer<Uint64> intListToArray(List<int> list) {
  final length = list.length;
  final pointer = calloc<Uint64>(length + 1); // +1 if null-terminated.
  for (int index = 0; index < length; index++) {
    pointer[index] = list[index];
  }
  return pointer;
}

// --- decode ---

typedef _DecodeVectorIntC = Pointer<Uint64> Function(
    BackendType backend, Pointer library, Pointer plaintext);

typedef _DecodeVectorInt = Pointer<Uint64> Function(
    int backend, Pointer library, Pointer plaintext);

final _DecodeVectorInt _c_decode_vector_int =
    dylib.lookupFunction<_DecodeVectorIntC, _DecodeVectorInt>('decode_int');

/// Convert C uint64 array to Dart int list.
List<int> arrayToIntList(Pointer<Uint64> ptr, int length) {
  final list = <int>[];
  for (var i = 0; i < length; i++) {
    list.add(ptr.elementAt(i).value);
  }
  return list;
}
