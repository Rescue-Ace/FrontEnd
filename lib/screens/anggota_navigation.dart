import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnggotaNavigationScreen extends StatelessWidget {
  final LatLng? assignedPoint; // Titik netralisasi yang diutus
  final List<dynamic>? routeData; // Data rute yang diterima dari FCM

  const AnggotaNavigationScreen({
    super.key,
    required this.assignedPoint,
    required this.routeData,
  });

  @override
  Widget build(BuildContext context) {
    // Konversi data rute dari FCM ke format LatLng
    final List<LatLng> routePoints = routeData != null
        ? routeData!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    // Konversi assignedPoint jika ada
    final LatLng? assignedPointLocation = assignedPoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigasi Anggota"),
        backgroundColor: const Color(0xFFA1BED6),
      ),
      body: Stack(
        children: [
          // Peta menggunakan FlutterMap
          FlutterMap(
            options: MapOptions(
              initialCenter: assignedPointLocation ??
                  (routePoints.isNotEmpty ? routePoints.first : LatLng(-7.270607, 112.768229)),
              initialZoom: 13.0,
            ),
            children: [
              // Layer untuk menampilkan map tiles
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: const {
                  'accessToken': 'pk.eyJ1IjoibmFmaXNhcnlhZGkzMiIsImEiOiJjbTNoZTFqNjIwZDdhMmpxenhwNjR4d3drIn0.oqCkTqILhSAP5qNjKCkV2g',
                },
              ),
              // Layer untuk menampilkan rute kebakaran
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
              // Layer untuk menampilkan titik assignedPoint
              if (assignedPointLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: assignedPointLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Informasi titik assignedPoint
          if (assignedPointLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFA1BED6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Anda telah diutus ke lokasi ini!",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Latitude: ${assignedPointLocation.latitude}, Longitude: ${assignedPointLocation.longitude}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
