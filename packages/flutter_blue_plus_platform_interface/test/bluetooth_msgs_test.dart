import 'dart:typed_data';

import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BmCharacteristicData.fromMap', () {
    test('decodes an error response whose value is null (darwin sends NSNull)',
        () {
      final data = BmCharacteristicData.fromMap({
        'remote_id': 'D4570494-6F31-4D91-E422-3495F6DE5886',
        'primary_service_uuid': null,
        'service_uuid': '0000180f-0000-1000-8000-00805f9b34fb',
        'characteristic_uuid': 'ef24b236-2674-4302-9b8d-2c7082007e14',
        'instance_id': 0,
        'value': null,
        'success': 0,
        'error_code': 15,
        'error_string': 'Encryption is insufficient.',
      });

      expect(data.success, isFalse);
      expect(data.errorCode, 15);
      expect(data.value, isEmpty);
    });

    test('decodes a success response with a value', () {
      final data = BmCharacteristicData.fromMap({
        'remote_id': 'D4570494-6F31-4D91-E422-3495F6DE5886',
        'primary_service_uuid': null,
        'service_uuid': '0000180f-0000-1000-8000-00805f9b34fb',
        'characteristic_uuid': 'ef24b236-2674-4302-9b8d-2c7082007e14',
        'instance_id': 0,
        'value': Uint8List.fromList([1, 2, 3]),
        'success': 1,
        'error_code': 0,
        'error_string': 'success',
      });

      expect(data.success, isTrue);
      expect(data.value, [1, 2, 3]);
    });
  });

  group('BmDescriptorData.fromMap', () {
    test('decodes an error response whose value is null (darwin sends NSNull)',
        () {
      final data = BmDescriptorData.fromMap({
        'remote_id': 'D4570494-6F31-4D91-E422-3495F6DE5886',
        'primary_service_uuid': null,
        'service_uuid': '0000180f-0000-1000-8000-00805f9b34fb',
        'characteristic_uuid': 'ef24b236-2674-4302-9b8d-2c7082007e14',
        'instance_id': 0,
        'descriptor_uuid': '00002902-0000-1000-8000-00805f9b34fb',
        'value': null,
        'success': 0,
        'error_code': 15,
        'error_string': 'Encryption is insufficient.',
      });

      expect(data.success, isFalse);
      expect(data.errorCode, 15);
      expect(data.value, isEmpty);
    });
  });
}
