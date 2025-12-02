import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lt;

import '../../data/models/location_model.dart';
import '../../data/models/route_model.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../blocs/tracking_bloc.dart';
import '../widgets/bottom_info_sheet.dart';
import '../widgets/driver_marker.dart';

class TrackingPage extends StatefulWidget {
  final TrackingRepository repository;

  const TrackingPage({super.key, required this.repository});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final MapController _mapController = MapController();

  // CUSTOMER MARKER
  static const lt.LatLng customerLocation = lt.LatLng(17.424354, 78.473945);
  Marker? _customerMarker;

  // ROUTES
  List<lt.LatLng> _fullRoute = []; // complete predefined JSON route
  List<lt.LatLng> _driverTrail = []; // live driver trail along route

  // TRACKING
  late TrackingBloc _trackingBloc;
  LocationModel? _currentLocation;
  bool _isDelivered = false;

  static const lt.LatLng initialCenter = lt.LatLng(17.437462, 78.448288);
  static const double initialZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _createCustomerMarker();

    _trackingBloc = TrackingBloc(repository: widget.repository);
    _trackingBloc.add(LoadRoute());
    _trackingBloc.add(StartTracking());

    // LISTEN BLOCK STREAM (BEST PRACTICE)
    _trackingBloc.stream.listen((state) {
      if (state is RouteLoaded) {
        _loadFullRoute(state.route as RouteModel);
      } else if (state is LocationUpdated) {
        _handleLiveLocation(state.location);
      }
    });
  }

  // ---------------------------
  // CUSTOMER MARKER
  // ---------------------------
  void _createCustomerMarker() {
    _customerMarker = Marker(
      width: 40,
      height: 40,
      point: customerLocation,
      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
    );
  }

  // ---------------------------
  // LOAD FULL ROUTE FROM JSON
  // ---------------------------
  void _loadFullRoute(RouteModel route) {
    _fullRoute = route.routePoints.map((e) => lt.LatLng(e.lat, e.lng)).toList();

    setState(() {});
  }

  // ---------------------------
  // HANDLE LIVE LOCATION STREAM
  // ---------------------------
  void _handleLiveLocation(LocationModel loc) {
    final lt.LatLng pos = lt.LatLng(loc.lat, loc.lng);
    _currentLocation = loc;

    if (loc.status == "delivered") {
      _isDelivered = true;
    }

    // Find nearest index in full route (correct polyline path)
    int index = _findNearestRouteIndex(pos);

    if (index != -1) {
      // driver trail is from route[0] to route[index]
      _driverTrail = _fullRoute.sublist(0, index + 1);
    } else {
      // fallback (rare): append point
      if (_driverTrail.isEmpty || !_latLngClose(_driverTrail.last, pos)) {
        _driverTrail.add(pos);
      }
    }

    // Camera follow (until delivered)
    if (!_isDelivered) {
      try {
        _mapController.move(pos, 16);
      } catch (_) {}
    }

    setState(() {});
  }

  // ---------------------------
  // FINDING NEAREST POINT ON ROUTE
  // ---------------------------
  int _findNearestRouteIndex(lt.LatLng pos) {
    if (_fullRoute.isEmpty) return -1;

    const double thresholdMeters = 50;
    final dist = const lt.Distance();

    int bestIndex = -1;
    double bestDist = double.infinity;

    for (int i = 0; i < _fullRoute.length; i++) {
      double d = dist.as(
        lt.LengthUnit.Meter,
        pos,
        _fullRoute[i],
      );

      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }

    return (bestDist <= thresholdMeters) ? bestIndex : -1;
  }

  bool _latLngClose(lt.LatLng a, lt.LatLng b, {double eps = 0.00002}) {
    return ((a.latitude - b.latitude).abs() < eps &&
        (a.longitude - b.longitude).abs() < eps);
  }

  // ---------------------------
  // DRIVER MARKER WIDGET
  // ---------------------------
  Marker _buildDriverMarker() {
    final loc = _currentLocation!;
    return Marker(
      width: 45,
      height: 45,
      point: lt.LatLng(loc.lat, loc.lng),
      child: DriverMarker(
        color: _statusColor(loc.status),
        heading: loc.heading.toDouble(),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case "picked":
        return Colors.blue;
      case "en_route":
        return Colors.green;
      case "arriving":
        return Colors.orange;
      case "delivered":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _trackingBloc.add(StopTracking());
    _trackingBloc.close();
    _sheetController.dispose();
    super.dispose();
  }

  // ---------------------------
  // BUILD UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _trackingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Live Delivery Tracking"),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: false,
                ),
              ),
              children: [
                // --------------------- TILE LAYER (OSM)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.live_tracking',
                ),

                // --------------------- FULL ROUTE (GREY)
                PolylineLayer(
                  polylines: [
                    if (_fullRoute.isNotEmpty)
                      Polyline(
                        points: _fullRoute,
                        strokeWidth: 4,
                        color: Colors.grey.withOpacity(0.7),
                      ),

                    // --------------------- DRIVER TRAIL (BLUE)
                    if (_driverTrail.isNotEmpty)
                      Polyline(
                        points: _driverTrail,
                        strokeWidth: 6,
                        color: Colors.blue,
                      ),
                  ],
                ),

                // --------------------- MARKERS
                MarkerLayer(
                  markers: [
                    if (_customerMarker != null) _customerMarker!,
                    if (_currentLocation != null) _buildDriverMarker(),
                  ],
                ),
              ],
            ),

            // --------------------- BOTTOM SHEET
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomInfoSheet(controller: _sheetController),
            ),

            // --------------------- SHOW DELIVERY LOCATION BUTTON
            AnimatedBuilder(
              animation: _sheetController,
              builder: (context, child) {
                // Default size is 0.15 if not attached yet
                final double sheetSize =
                    _sheetController.isAttached ? _sheetController.size : 0.15;
                final double bottomPadding =
                    (MediaQuery.of(context).size.height * sheetSize) + 20;

                return Positioned(
                  bottom: bottomPadding,
                  right: 20,
                  child: child!,
                );
              },
              child: FloatingActionButton(
                heroTag: "delivery_loc_btn",
                backgroundColor: Colors.white,
                onPressed: () {
                  _mapController.move(customerLocation, 16);
                },
                child: const Icon(Icons.flag, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
