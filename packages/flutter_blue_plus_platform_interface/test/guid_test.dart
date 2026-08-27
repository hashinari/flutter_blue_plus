import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guid', () {
    test('str128 / str are stable across repeated calls', () {
      final g = Guid('180a');
      expect(g.str128, '0000180a-0000-1000-8000-00805f9b34fb');
      expect(identical(g.str128, g.str128), isTrue);
      expect(g.str, '180a');
      expect(identical(g.str, g.str), isTrue);
    });

    test('16-bit and 128-bit spellings of the same uuid are equal', () {
      final short = Guid('180a');
      final long = Guid('0000180a-0000-1000-8000-00805f9b34fb');
      expect(short == long, isTrue);
      expect(short.hashCode, long.hashCode);
    });

    test('32-bit uuid', () {
      final g = Guid('12345678');
      expect(g.str128, '12345678-0000-1000-8000-00805f9b34fb');
      expect(g.str, '12345678');
    });

    test('128-bit uuid keeps its full form and is case-insensitive', () {
      final a = Guid('C84B995C-DFFB-40FB-A205-F342D4E8DC04');
      final b = Guid('c84b995c-dffb-40fb-a205-f342d4e8dc04');
      expect(a.str128, 'c84b995c-dffb-40fb-a205-f342d4e8dc04');
      expect(a.str, a.str128);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), a.str);
    });

    test('different uuids are not equal', () {
      expect(Guid('180a') == Guid('180f'), isFalse);
    });

    test('fromBytes round-trips', () {
      final g = Guid.fromBytes([0x18, 0x0a]);
      expect(g.str, '180a');
      expect(Guid.fromBytes(Guid('180a').bytes), g);
    });

    test('empty guid', () {
      expect(Guid.empty().str128, '00000000-0000-0000-0000-000000000000');
      expect(Guid.empty(), Guid.empty());
    });

    test('encodes every byte value as two lowercase hex digits', () {
      final g = Guid.fromBytes(List<int>.generate(16, (i) => i * 17));
      expect(g.str128, '00112233-4455-6677-8899-aabbccddeeff');
      expect(Guid.fromBytes([0x00, 0xff]).str, '00ff');
      expect(Guid('00FF'), Guid.fromBytes([0x00, 0xff]));
    });

    test('rejects invalid input', () {
      expect(() => Guid('zz'), throwsFormatException);
      expect(() => Guid('0g0'), throwsFormatException);
      expect(() => Guid('180'), throwsFormatException);
      expect(() => Guid('00112233'), returnsNormally);
      expect(() => Guid('001122'), throwsFormatException);
    });
  });
}
