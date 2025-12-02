import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../models/location_model.dart';

class MockStreamService {
  final String assetPath;
  MockStreamService({required this.assetPath});

  late List<Map<String, dynamic>> _routePoints;
  StreamController<LocationModel>? _controller;
  Timer? _timer;
  int _index = 0;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final raw = await rootBundle.loadString(assetPath);
    _routePoints = [
      {
        "lat": 17.437462,
        "lng": 78.448288,
        "speed": 20.2,
        "heading": 90,
        "status": "picked"
      },
      {
        "lat": 17.435180,
        "lng": 78.452510,
        "speed": 25.1,
        "heading": 100,
        "status": "en_route"
      },
      {
        "lat": 17.432785,
        "lng": 78.455986,
        "speed": 27.0,
        "heading": 110,
        "status": "en_route"
      },
      {
        "lat": 17.431122,
        "lng": 78.458565,
        "speed": 29.5,
        "heading": 115,
        "status": "en_route"
      },
      {
        "lat": 17.430290,
        "lng": 78.463020,
        "speed": 31.0,
        "heading": 120,
        "status": "en_route"
      },
      {
        "lat": 17.429390,
        "lng": 78.466690,
        "speed": 26.8,
        "heading": 130,
        "status": "en_route"
      },
      {
        "lat": 17.426620,
        "lng": 78.469780,
        "speed": 18.4,
        "heading": 140,
        "status": "arriving"
      },
      {
        "lat": 17.425280,
        "lng": 78.471740,
        "speed": 15.2,
        "heading": 150,
        "status": "arriving"
      },
      {
        "lat": 17.424354,
        "lng": 78.473945,
        "speed": 0.0,
        "heading": 160,
        "status": "delivered"
      }
    ];
    _initialized = true;
  }

  Stream<LocationModel> get stream {
    _controller ??=
        StreamController<LocationModel>.broadcast(onListen: () async {
      // ensure init finished before starting emits
      if (!_initialized) {
        try {
          await init();
        } catch (_) {}
      }
      _start();
    }, onCancel: () {
      _stop();
    });
    return _controller!.stream;
  }

  void _start() {
    if (!_initialized) {
      // safety fallback: do nothing if not initialized
      return;
    }
    _index = 0;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_index >= _routePoints.length) {
        _controller?.close();
        _timer?.cancel();
        _timer = null;
        return;
      }
      final map = _routePoints[_index];
      final loc = LocationModel(
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        speed: (map['speed'] as num).toDouble(),
        heading: (map['heading'] as num).toInt(),
        status: map['status'] as String,
        timestamp: DateTime.now(),
      );
      _controller?.add(loc);
      _index++;
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _stop();
    _controller?.close();
    _controller = null;
  }
}
