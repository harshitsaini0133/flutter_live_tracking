import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/repositories/tracking_repository.dart';
import '../models/location_model.dart';
import '../models/route_model.dart';
import '../models/driver_model.dart';
import '../sources/mock_stream_service.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final MockStreamService mockService;

  TrackingRepositoryImpl({required this.mockService});

  Stream<LocationModel>? _stream;

  @override
  Future<RouteModel> loadRouteFromAsset() async {
    final raw = await rootBundle.loadString('assets/mock/route_hyd.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final driver = DriverModel.fromJson(json['driver'] as Map<String, dynamic>);
    final customer = json['customer'] as Map<String, dynamic>;
    final routeList = (json['route'] as List<dynamic>).map((e) {
      final m = e as Map<String, dynamic>;
      return LocationModel(
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        speed: 0.0,
        heading: 0,
        status: m['status'] ?? '',
        timestamp: DateTime.now(),
      );
    }).toList();

    return RouteModel(
      orderId: json['orderId'] as String,
      driver: driver,
      customerLat: (customer['lat'] as num).toDouble(),
      customerLng: (customer['lng'] as num).toDouble(),
      customerAddress: customer['address'] as String,
      routePoints: routeList,
    );
  }

   @override
  Future<void> start() async {
    // ensure mock service prepared before anyone listens
    await mockService.init();
  }

  @override
  Stream<LocationModel> get locationStream {
    _stream ??= mockService.stream;
    return _stream!;
  }

  @override
  void stop() {
    mockService.dispose();
  }
}
