import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/validity.dart';

void main() {
  group('Validity Model Tests', () {
    test('creates Validity with all fields', () {
      final validity = Validity(
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      expect(validity.validFrom, DateTime(2025, 1, 1));
      expect(validity.validUntil, DateTime(2025, 12, 31));
      expect(validity.isValid, true);
    }, tags: ['tdd_green']);

    test('creates Validity from JSON', () {
      final json = {
        'valid_from': '2025-01-01T00:00:00.000',
        'valid_until': '2025-12-31T00:00:00.000',
        'is_valid': true,
      };
      final validity = Validity.fromJson(json);

      expect(validity.validFrom, DateTime(2025, 1, 1));
      expect(validity.validUntil, DateTime(2025, 12, 31));
      expect(validity.isValid, true);
    }, tags: ['tdd_green']);

    test('converts Validity to JSON', () {
      final validity = Validity(
        validFrom: DateTime(2025, 6, 1),
        validUntil: DateTime(2025, 6, 30),
        isValid: false,
      );
      final json = validity.toJson();

      expect(json['valid_from'], validity.validFrom.toIso8601String());
      expect(json['valid_until'], validity.validUntil.toIso8601String());
      expect(json['is_valid'], false);
    }, tags: ['tdd_green']);

    test('equality works correctly', () {
      final v1 = Validity(
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
      final v2 = Validity(
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
      final v3 = Validity(
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: false,
      );

      expect(v1 == v2, isTrue);
      expect(v1.hashCode, v2.hashCode);
      expect(v1 == v3, isFalse);
    }, tags: ['tdd_green']);
  });
}
