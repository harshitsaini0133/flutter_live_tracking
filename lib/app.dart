import 'package:flutter/material.dart';
import 'presentation/pages/tracking_page.dart';
import 'data/sources/mock_stream_service.dart';
import 'data/repositories/tracking_repository_impl.dart';

class App extends StatelessWidget {
  App({super.key});

  final MockStreamService mockService =
      MockStreamService(assetPath: 'assets/mock/route_hyd.json');

  @override
  Widget build(BuildContext context) {
    final repo = TrackingRepositoryImpl(mockService: mockService);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Delivery Tracking',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TrackingPage(repository: repo),
    );
  }
}
