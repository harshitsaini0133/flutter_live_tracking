class LocationModel {
  final double lat;
  final double lng;
  final double speed; // km/h
  final int heading; // degrees
  final String status;
  final DateTime timestamp;

  LocationModel({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.status,
    required this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      speed:
          json.containsKey('speed') ? (json['speed'] as num).toDouble() : 0.0,
      heading:
          json.containsKey('heading') ? (json['heading'] as num).toInt() : 0,
      status: json['status'] ?? '',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'speed': speed,
        'heading': heading,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };
}
