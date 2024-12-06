import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/api_service.dart';

class DamkarNavigationScreen extends StatelessWidget {
  final List<dynamic>? routeData; // Data rute yang diterima dari FCM
  final int idKebakaran; // ID kebakaran untuk update status
  final String lokasiKebakaran; // Lokasi kebakaran untuk ditampilkan

  const DamkarNavigationScreen({
    super.key,
    required this.routeData,
    required this.idKebakaran,
    required this.lokasiKebakaran,
  });

  @override
  Widget build(BuildContext context) {
    // Konversi data rute dari FCM ke format LatLng
    final List<LatLng> routePoints = routeData != null
        ? routeData!.map((point) {
            // Validasi format point
            if (point is List && point.length == 2) {
              return LatLng(point[1], point[0]);
            } else {
              throw Exception("Format rute tidak valid: $point");
            }
          }).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigasi Damkar"),
        backgroundColor: const Color(0xFFA1BED6),
      ),
      body: Stack(
        children: [
          // Peta menggunakan FlutterMap
          FlutterMap(
            options: MapOptions(
              initialCenter: routePoints.isNotEmpty
                  ? routePoints.first
                  : LatLng(-7.270607, 112.768229), // Default center jika rute kosong
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
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
          // Box informasi lokasi kebakaran dan tombol update status
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan lokasi kebakaran
                  Text(
                    lokasiKebakaran,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Menampilkan ID kebakaran
                  Text(
                    "ID Kebakaran: $idKebakaran",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Tombol untuk update status kebakaran
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Konfirmasi sebelum mengupdate status kebakaran
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
                    
                        // Jika konfirmasi "Ya"
                        if (isConfirmed == true) {
                          final apiService = ApiService();
                          try {
                            if (idKebakaran <= 0) {
                              throw Exception("ID kebakaran tidak valid: $idKebakaran");
                            }
                            // Update status kebakaran ke "padam"
                            await apiService.updateStatusKebakaran(idKebakaran, "padam");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Status kebakaran berhasil diperbarui."),
                              ),
                            );
                            Navigator.popUntil(context, (route) => route.isFirst);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal memperbarui status: $e")),
                    
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4872B1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Api Sudah Dipadamkan",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
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
