import 'package:flutter/material.dart';

class DriverMarker extends StatelessWidget {
  final Color color;
  final double heading; // in degrees

  const DriverMarker({
    super.key,
    this.color = Colors.blue,
    this.heading = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading * 0.0174533, // Convert degrees to radians (pi/180)
      child: Icon(
        Icons.navigation,
        color: color,
        size: 40,
      ),
    );
  }
}
