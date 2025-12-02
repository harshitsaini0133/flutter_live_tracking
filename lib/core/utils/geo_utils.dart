import 'dart:math';

double _deg2rad(double deg) => deg * (pi / 180.0);

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000.0; 
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

// ETA in minutes based on distance (meters) and speed (km/h)
double etaMinutes(double distanceMeters, double speedKph) {
  if (speedKph <= 0) return double.infinity;
  final speedMs = speedKph * 1000 / 3600;
  final secs = distanceMeters / speedMs;
  return secs / 60.0;
}
