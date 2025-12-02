import 'driver_model.dart';
import 'location_model.dart';

class RouteModel {
  final String orderId;
  final DriverModel driver;
  final double customerLat;
  final double customerLng;
  final String customerAddress;
  final List<LocationModel> routePoints;

  RouteModel({
    required this.orderId,
    required this.driver,
    required this.customerLat,
    required this.customerLng,
    required this.customerAddress,
    required this.routePoints,
  });
}
