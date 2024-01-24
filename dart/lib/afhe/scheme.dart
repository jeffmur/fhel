import 'dart:ffi';
import 'package:ffi/ffi.dart'; // for Utf8
import 'package:fhe/ffi.dart' show dylib;

typedef SchemeType = Int;

typedef StringtoSchemeTypeC = SchemeType Function(Pointer<Utf8> scheme);
typedef StringToSchemeType = int Function(Pointer<Utf8> scheme);

final StringToSchemeType c_string_to_scheme_type = dylib
    .lookup<NativeFunction<StringtoSchemeTypeC>>('scheme_t_from_string')
    .asFunction();

class Scheme {
  int value = 0;
  String name = "";

  Scheme();

  Scheme.set(String fromName) {
    String lowerName = fromName.toLowerCase();
    value = c_string_to_scheme_type(lowerName.toNativeUtf8());
    name = fromName;
  }
}
