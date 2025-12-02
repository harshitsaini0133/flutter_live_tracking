import '../../data/models/location_model.dart';
import '../../data/models/route_model.dart';

abstract class TrackingRepository {
  Future<RouteModel> loadRouteFromAsset();
  Stream<LocationModel> get locationStream;
  Future<void> start();
  void stop();
}

