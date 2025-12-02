import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tracking_bloc.dart';
import '../../data/models/location_model.dart';
import '../../core/utils/geo_utils.dart';

class BottomInfoSheet extends StatelessWidget {
  final DraggableScrollableController? controller;

  const BottomInfoSheet({super.key, this.controller});

  String _formatEta(double minutes) {
    if (minutes.isInfinite || minutes.isNaN) return '—';
    final m = minutes.round();
    if (m <= 0) return 'Arrived';
    return '$m min';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'picked':
        return Colors.blue;
      case 'en_route':
        return Colors.green;
      case 'arriving':
        return Colors.orange;
      case 'delivered':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'picked':
        return 'Order Picked Up';
      case 'en_route':
        return 'On the Way';
      case 'arriving':
        return 'Arriving Soon';
      case 'delivered':
        return 'Delivered!';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, dynamic>(
      buildWhen: (previous, current) {
        // Only rebuild when we get meaningful updates
        return current is RouteLoaded || current is LocationUpdated;
      },
      builder: (context, state) {
        String driverName = 'Loading...';
        String vehicle = 'Loading...';
        String status = 'initializing';
        String lastUpdated = '-';
        String eta = '-';
        String distanceRemaining = '-';

        if (state is RouteLoaded) {
          final route = state.route;
          driverName = route.driver.name;
          vehicle = route.driver.vehicle;
        }
        if (state is LocationUpdated) {
          final loc = state.location as LocationModel;
          status = loc.status;
          lastUpdated = TimeOfDay.fromDateTime(loc.timestamp).format(context);
          final distance =
              haversineDistance(loc.lat, loc.lng, 17.424354, 78.473945);
          distanceRemaining = '${(distance / 1000).toStringAsFixed(2)} km';
          final etaMinutesVal = etaMinutes(distance, loc.speed);
          eta = _formatEta(etaMinutesVal);

          // Get driver info from route
          if (state.route != null) {
            driverName = state.route.driver.name;
            vehicle = state.route.driver.vehicle;
          }
        }

        return DraggableScrollableSheet(
          controller: controller,
          minChildSize: 0.15,
          maxChildSize: 0.35,
          initialChildSize: 0.15,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 2,
                    color: Colors.black12,
                  )
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Driver info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _getStatusDisplayText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Vehicle info
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        vehicle,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        icon: Icons.access_time,
                        label: 'ETA',
                        value: eta,
                      ),
                      _buildStatColumn(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: distanceRemaining,
                      ),
                      _buildStatColumn(
                        icon: Icons.update,
                        label: 'Updated',
                        value: lastUpdated,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
