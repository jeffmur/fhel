/// This files contains serializable types used by the backend libraries
part of '../seal.dart';

/// Models a serialized byte array for Microsoft SEAL.
/// 
/// The SealHeader is a 16-byte header that is prepended to the serialized data.
/// Note that the header is not encrypted or authenticated in any way.
/// 
final class SealHeader extends Struct {
  /// 2-byte magic number 0xA15E
  @Array.multi([2])
  external Array<Uint8> sealMagic;
  /// 1-byte indicating the header size in bytes (always 16)
  @Array.multi([1])
  external Array<Uint8> size;
  /// 1-byte indicating the Microsoft SEAL major version number
  @Array.multi([1])
  external Array<Uint8> majorVersion;
  /// 1-byte indicating the Microsoft SEAL minor version number
  @Array.multi([1])
  external Array<Uint8> minorVersion;
  /// 1-byte indicating the compression mode type
  @Array.multi([1])
  external Array<Uint8> compressionMode;
  /// 2-byte reserved field (unused), null terminated
  @Array.multi([2])
  external Array<Uint8> reserved;
  /// 8-byte size in bytes of the serialized data, including the header
  @Array.multi([8])
  external Array<Uint8> dataSize;
}

/// Parse a serialized byte array and return the [SealHeader] object.
///
/// When a serialized byte array is loaded, the header is checked for the
/// SEAL magic number. If the magic number is not found, an exception is thrown.
SealHeader sealMagicNumber(Pointer<Uint8> raw, int length) {
  // Cast raw pointer to SealHeader
  final header = raw.cast<SealHeader>().ref;
  // Check SEAL Magic Number, A1 (161) 5E (94)
  if (header.sealMagic[0] != 94 || header.sealMagic[1] != 161) {
    throw Exception('Invalid SEAL Magic Number');
  }
  return header;
}
