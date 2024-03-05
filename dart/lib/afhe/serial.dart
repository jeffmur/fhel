/// This files contains serializable types used by the backend libraries
part of '../afhe.dart';

/// A SEALHeader contains the following data:
///
/// [sealMagic] 2-byte magic number 0xA15E (Serialization.SEALMagic)
/// [size] 1-byte indicating the header size in bytes (always 16)
/// [majorVersion] 1-byte indicating the Microsoft SEAL major version number
/// [minorVersion] 1-byte indicating the Microsoft SEAL minor version number
/// [compressionMode] 1-byte indicating the compression mode type
/// [reserved] 2-byte reserved field (unused)
/// [dataSize] 8-byte size in bytes of the serialized data, including the header
/// 
final class SEALHeader extends Struct {
  @Array.multi([2])
  external Array<Uint8> sealMagic;
  @Array.multi([1])
  external Array<Uint8> size;
  @Array.multi([1])
  external Array<Uint8> majorVersion;
  @Array.multi([1])
  external Array<Uint8> minorVersion;
  @Array.multi([1])
  external Array<Uint8> compressionMode;
  @Array.multi([2])
  external Array<Uint8> reserved;
  @Array.multi([8])
  external Array<Uint8> dataSize;
}

SEALHeader parseHeader(Pointer<Uint8> raw, int length) {
  final Pointer<Uint8> ptr = calloc<Uint8>(length);
  final buffer = ptr.asTypedList(length);
  for (var i = 0; i < length; i++) {
    buffer[i] = raw[i];
  }
  final header = ptr.cast<SEALHeader>().ref;
  // Check SEAL Magic Number, A1 (161) 5E (94)
  if (header.sealMagic[0] != 94 || header.sealMagic[1] != 161) {
    throw Exception('Invalid SEAL Magic Number');
  }
  return header;
}
