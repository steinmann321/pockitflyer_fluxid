class Validity {
  Validity({
    required this.validFrom,
    required this.validUntil,
    required this.isValid,
  });

  factory Validity.fromJson(Map<String, dynamic> json) {
    return Validity(
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      isValid: json['is_valid'] as bool,
    );
  }

  final DateTime validFrom;
  final DateTime validUntil;
  final bool isValid;

  Map<String, dynamic> toJson() {
    return {
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_valid': isValid,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Validity &&
          runtimeType == other.runtimeType &&
          validFrom == other.validFrom &&
          validUntil == other.validUntil &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(validFrom, validUntil, isValid);
}
