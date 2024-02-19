/// This file contains the FFI bindings for the encode and decode methods.
part of '../afhe.dart';

// --- encode ---

typedef _EncodeVectorIntC = Pointer Function(Pointer library, Pointer<Uint64> vec, Int size);
typedef _EncodeVectorInt = Pointer Function(Pointer library, Pointer<Uint64> vec, int size);

/// Encodes a list of integers into a [Plaintext].
final _EncodeVectorInt _c_encode_vector_int = dylib
    .lookupFunction<_EncodeVectorIntC, _EncodeVectorInt>('encode_int');

/// Convert Dart int list to C uint64 array.
Pointer<Uint64> intListToUint64Array(List<int> list) {
  final length = list.length;
  final pointer = calloc<Uint64>(length + 1); // +1 if null-terminated.
  for (int index = 0; index < length; index++) {
    pointer[index] = list[index];
  }
  return pointer;
}

Pointer<Int> intListToIntArray(List<int> list) {
  final length = list.length;
  final pointer = calloc<Int>(length + 1); // +1 if null-terminated.
  for (int index = 0; index < length; index++) {
    pointer[index] = list[index];
  }
  return pointer;
}

typedef _EncodeVectorDoubleC = Pointer Function(Pointer library, Pointer<Double> vec, Int size);
typedef _EncodeVectorDouble = Pointer Function(Pointer library, Pointer<Double> vec, int size);

/// Encodes a list of doubles into a [Plaintext].
final _EncodeVectorDouble _c_encode_vector_double = dylib
    .lookupFunction<_EncodeVectorDoubleC, _EncodeVectorDouble>('encode_double');

/// Convert Dart double list to C double array.
Pointer<Double> doubleListToArray(List<double> list) {
  final length = list.length;
  final pointer = calloc<Double>(length + 1); // +1 if null-terminated.
  for (int index = 0; index < length; index++) {
    pointer[index] = list[index];
  }
  return pointer;
}

// --- decode ---

typedef _DecodeVectorIntC = Pointer<Uint64> Function(Pointer library, Pointer plaintext);

/// Decodes a [Plaintext] into a list of integers.
final _DecodeVectorIntC _c_decode_vector_int = dylib
    .lookupFunction<_DecodeVectorIntC, _DecodeVectorIntC>('decode_int');

/// Convert C uint64 array to Dart int list.
List<int> arrayToIntList(Pointer<Uint64> ptr, int length) {
  final list = <int>[];
  for (var i = 0; i < length; i++) {
    list.add(ptr[i].toInt());
  }
  return list;
}

typedef _DecodeVectorDoubleC = Pointer<Double> Function(Pointer library, Pointer plaintext);

/// Decodes a [Plaintext] into a list of doubles.
final _DecodeVectorDoubleC _c_decode_vector_double = dylib
    .lookupFunction<_DecodeVectorDoubleC, _DecodeVectorDoubleC>('decode_double');

/// Convert C double array to Dart double list.
List<double> arrayToDoubleList(Pointer<Double> ptr, int length) {
  final list = <double>[];
  for (var i = 0; i < length; i++) {
    list.add(ptr[i].toDouble());
  }
  return list;
}
