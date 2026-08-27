// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Guid {
  final List<int> bytes;

  // Cached string forms. `bytes` is never mutated after construction
  // (FBP creates a Guid per platform message and only reads it), so the
  // representations can be computed once per instance.
  //
  // Without the cache, `str128` rebuilt the string (5 sublists + hex
  // encode + concat) on every call. `==`, `hashCode` and `toString()`
  // all go through it, and FBP evaluates them per delivered notification
  // for every subscribed characteristic (`lastValueStream` filters) and
  // for the last-value bookkeeping key. With many links streaming, that
  // string work alone was ~15% of the Dart main thread.
  String? _str128;
  String? _str;

  Guid.empty() : bytes = List.filled(16, 0);

  Guid.fromBytes(this.bytes) : assert(_checkLen(bytes.length), 'GUID must be 16, 32, or 128 bit.');

  Guid.fromString(String input) : bytes = _toBytes(input);

  Guid(String input) : bytes = _toBytes(input);

  static Guid? parse(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    } else {
      return Guid(input);
    }
  }

  static List<int> _toBytes(String input) {
    if (input.isEmpty) {
      return List.filled(16, 0);
    }

    input = input.replaceAll('-', '');

    List<int>? bytes = _tryHexDecode(input);
    if (bytes == null) {
      throw FormatException("GUID not hex format: $input");
    }

    _checkLen(bytes.length);

    return bytes;
  }

  static bool _checkLen(int len) {
    if (!(len == 16 || len == 4 || len == 2)) {
      throw FormatException("GUID must be 16, 32, or 128 bit, yours: ${len * 8}-bit");
    }
    return true;
  }

  // 128-bit representation
  String get str128 => _str128 ??= _buildStr128();

  // _hexEncode always yields lowercase, so no toLowerCase() pass is needed.
  String _buildStr128() {
    if (bytes.length == 2) {
      // 16-bit uuid
      return '0000${_hexEncode(bytes)}-0000-1000-8000-00805f9b34fb';
    }
    if (bytes.length == 4) {
      // 32-bit uuid
      return '${_hexEncode(bytes)}-0000-1000-8000-00805f9b34fb';
    }
    // 128-bit uuid: 8-4-4-4-12
    final h = _hexEncode(bytes);
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  // shortest representation
  String get str => _str ??= _buildStr();

  String _buildStr() {
    final s = str128;
    bool starts = s.startsWith('0000');
    bool ends = s.contains('-0000-1000-8000-00805f9b34fb');
    if (starts && ends) {
      // 16-bit
      return s.substring(4, 8);
    }
    if (ends) {
      // 32-bit
      return s.substring(0, 8);
    }
    // 128-bit
    return s;
  }

  @override
  String toString() => str;

  @override
  operator ==(other) => identical(this, other) || (other is Guid && str128 == other.str128);

  @override
  int get hashCode => str128.hashCode;

  @Deprecated('use str128 instead')
  String get uuid128 => str128;

  @Deprecated('use str instead')
  String get uuid => str;
}

// Lowercase hex encode / decode without per-byte substring, int.parse,
// toRadixString or map/join. These run for every Guid FBP builds out of a
// platform message (a few per delivered notification), so they are kept
// as plain loops over char codes.

const String _hexDigits = '0123456789abcdef';

String _hexEncode(List<int> numbers) {
  final codes = List<int>.filled(numbers.length * 2, 0);
  int j = 0;
  for (final n in numbers) {
    final b = n & 0xFF;
    codes[j++] = _hexDigits.codeUnitAt(b >> 4);
    codes[j++] = _hexDigits.codeUnitAt(b & 0x0F);
  }
  return String.fromCharCodes(codes);
}

int _hexValue(int c) {
  if (c >= 0x30 && c <= 0x39) return c - 0x30; // 0-9
  if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10; // a-f
  if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10; // A-F
  return -1;
}

List<int>? _tryHexDecode(String hex) {
  if (hex.length.isOdd) {
    return null;
  }
  final numbers = List<int>.filled(hex.length ~/ 2, 0);
  for (int i = 0; i < hex.length; i += 2) {
    final hi = _hexValue(hex.codeUnitAt(i));
    final lo = _hexValue(hex.codeUnitAt(i + 1));
    if (hi < 0 || lo < 0) {
      return null;
    }
    numbers[i ~/ 2] = (hi << 4) | lo;
  }
  return numbers;
}
