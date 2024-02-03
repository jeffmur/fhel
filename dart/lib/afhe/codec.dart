import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:fhe/afhe/type.dart' show BackendType;
import 'package:fhe/ffi.dart' show dylib;

// encode

typedef EncodeVectorIntC = Pointer Function(
    BackendType backend, Pointer library, Pointer<Uint64> vec, Int size);

typedef EncodeVectorInt = Pointer Function(
    int backend, Pointer library, Pointer<Uint64> vec, int size);

final EncodeVectorInt c_encode_vector_int =
    dylib.lookupFunction<EncodeVectorIntC, EncodeVectorInt>('encode_int');

Pointer<Uint64> intListToArray(List<int> list) {
  final length = list.length;
  final pointer = calloc<Uint64>(length + 1); // +1 if null-terminated.
  for (int index = 0; index < length; index++) {
    pointer[index] = list[index];
  }
  return pointer;
}

// decode

typedef DecodeVectorIntC = Pointer<Uint64> Function(
    BackendType backend, Pointer library, Pointer plaintext);

typedef DecodeVectorInt = Pointer<Uint64> Function(
    int backend, Pointer library, Pointer plaintext);

final DecodeVectorInt c_decode_vector_int =
    dylib.lookupFunction<DecodeVectorIntC, DecodeVectorInt>('decode_int');

List<int> arrayToIntList(Pointer<Uint64> ptr, int length) {
  final list = <int>[];
  for (var i = 0; i < length; i++) {
    list.add(ptr.elementAt(i).value);
  }
  return list;
}
