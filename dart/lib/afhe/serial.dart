/// This files contains serializable types used by the backend libraries
part of '../seal.dart';

/// Serialized byte array for Microsoft SEAL
/// 
/// The SEALHeader is a 16-byte header that is prepended to the serialized data.
/// Note that the header is not encrypted or authenticated in any way.
/// The header contains the following fields:
///
/// [sealMagic] 2-byte magic number 0xA15E
/// 
/// [size] 1-byte indicating the header size in bytes (always 16)
/// 
/// [majorVersion] 1-byte indicating the Microsoft SEAL major version number
/// 
/// [minorVersion] 1-byte indicating the Microsoft SEAL minor version number
/// 
/// [compressionMode] 1-byte indicating the compression mode type
/// 
/// [reserved] 2-byte reserved field (unused), null terminated
/// 
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

/// Check SEAL Magic Number
/// 
/// The SEAL Magic Number is a 2-byte sequence of 0xA15E.
SEALHeader sealMagicNumber(Pointer<Uint8> raw, int length) {
  // Cast raw pointer to SEALHeader
  final header = raw.cast<SEALHeader>().ref;
  // Check SEAL Magic Number, A1 (161) 5E (94)
  if (header.sealMagic[0] != 94 || header.sealMagic[1] != 161) {
    throw Exception('Invalid SEAL Magic Number');
  }
  return header;
}
