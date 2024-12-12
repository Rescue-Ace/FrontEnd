import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AnggotaNavigationScreen extends StatefulWidget {
  final LatLng? assignedPoint; // Titik netralisasi yang diutus
  final List<dynamic>? routeData; // Data rute yang diterima dari FCM

  const AnggotaNavigationScreen({
    super.key,
    required this.assignedPoint,
    required this.routeData,
  });

  @override
  _AnggotaNavigationScreenState createState() => _AnggotaNavigationScreenState();
}

class _AnggotaNavigationScreenState extends State<AnggotaNavigationScreen> {
  @override
  void initState() {
    super.initState();

    // Listener untuk notifikasi FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        try {
          final data = message.data['data'] != null
              ? Map<String, dynamic>.from(message.data['data'])
              : message.data;

          if (data['status'] == 'padam') {
            // Tampilkan SnackBar dan tutup layar navigasi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kebakaran telah padam, navigasi ditutup.")),
            );
            Navigator.pop(context); // Tutup layar navigasi
          }
        } catch (e) {
          print("Error handling FCM message: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Konversi data rute dari FCM ke format LatLng
    final List<LatLng> routePoints = widget.routeData != null
        ? widget.routeData!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    // Konversi assignedPoint jika ada
    final LatLng? assignedPointLocation = widget.assignedPoint;

    return SafeArea(
      child: Scaffold(
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
                    (routePoints.isNotEmpty ? routePoints.first : const LatLng(-7.270607, 112.768229)),
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
                        width: 30,
                        height: 30,
                        child: Transform.translate(
                          offset: const Offset(0, -10),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
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
                  color: Colors.white,
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
      ),
    );
  }
}
