class Location {
  Location({
    required this.address,
    required this.lat,
    required this.lng,
    this.distanceKm,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
    );
  }

  final String address;
  final double lat;
  final double lng;
  final double? distanceKm;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lat': lat,
      'lng': lng,
      'distance_km': distanceKm,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          lat == other.lat &&
          lng == other.lng &&
          distanceKm == other.distanceKm;

  @override
  int get hashCode => Object.hash(address, lat, lng, distanceKm);
}
