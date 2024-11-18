import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnggotaNavigationScreen extends StatelessWidget {
  final LatLng? assignedPoint;
  final List<dynamic>? routeData;

  const AnggotaNavigationScreen({
    super.key,
    required this.assignedPoint,
    required this.routeData,
  });

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = routeData != null
        ? routeData!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigasi Anggota"),
        backgroundColor: const Color(0xFFA1BED6),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: assignedPoint ?? LatLng(-7.270607, 112.768229),
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
              if (assignedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: assignedPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.yellow,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (assignedPoint != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: const Text(
                  "Segera menuju lokasi netralisasi.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
