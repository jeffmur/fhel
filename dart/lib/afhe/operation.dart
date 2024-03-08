/// This file contains the FFI bindinds for operations on the plaintext and ciphertext objects.
part of '../afhe.dart';

// --- add ---

typedef _AddC = Pointer Function(Pointer library, Pointer a, Pointer b);
final _AddC _c_add = dylib.lookup<NativeFunction<_AddC>>('add').asFunction();
final _AddC _c_add_plain = dylib.lookup<NativeFunction<_AddC>>('add_plain').asFunction();

// --- subtract ---

typedef _SubC = Pointer Function(Pointer library, Pointer a, Pointer b);
final _SubC _c_subtract = dylib.lookup<NativeFunction<_SubC>>('subtract').asFunction();
final _SubC _c_subtract_plain = dylib.lookup<NativeFunction<_SubC>>('subtract_plain').asFunction();

// --- multiply ---

typedef _MultiplyC = Pointer Function(Pointer library, Pointer a, Pointer b);
final _MultiplyC _c_multiply = dylib.lookup<NativeFunction<_MultiplyC>>('multiply').asFunction();
final _MultiplyC _c_multiply_plain = dylib.lookup<NativeFunction<_MultiplyC>>('multiply_plain').asFunction();

// --- square ---

typedef _SquareC = Pointer Function(Pointer library, Pointer a);
final _SquareC _c_square = dylib.lookup<NativeFunction<_SquareC>>('square').asFunction();
