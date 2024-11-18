import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/api_service.dart';

class DamkarNavigationScreen extends StatelessWidget {
  final List<dynamic>? routeData;
  final int idKebakaran; // ID kebakaran untuk update status

  const DamkarNavigationScreen({
    super.key,
    required this.routeData,
    required this.idKebakaran,
  });

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = routeData != null
        ? routeData!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigasi Damkar"),
        backgroundColor: const Color(0xFFA1BED6),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: routePoints.isNotEmpty ? routePoints.first : LatLng(-7.270607, 112.768229),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: const {'accessToken': 'pk.eyJ1IjoibmFmaXNhcnlhZGkzMiIsImEiOiJjbTNoZTFqNjIwZDdhMmpxenhwNjR4d3drIn0.oqCkTqILhSAP5qNjKCkV2g'},
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                final isConfirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Apakah api sudah dipadamkan?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Ya"),
                      ),
                    ],
                  ),
                );

                if (isConfirmed == true) {
                  final apiService = ApiService();
                  await apiService.updateStatusKebakaran(idKebakaran, "padam");
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Api Sudah Dipadamkan"),
            ),
          ),
        ],
      ),
    );
  }
}
