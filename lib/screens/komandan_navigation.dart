import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/api_service.dart';

class KomandanNavigationScreen extends StatefulWidget {
  final List<dynamic>? neutralizationPoints;
  final List<dynamic>? routeData;
  final int idCabangPolsek;

  const KomandanNavigationScreen({
    super.key,
    required this.neutralizationPoints,
    required this.routeData,
    required this.idCabangPolsek,
  });

  @override
  _KomandanNavigationScreenState createState() => _KomandanNavigationScreenState();
}

class _KomandanNavigationScreenState extends State<KomandanNavigationScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _anggotaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnggotaByPolsek();
  }

  Future<void> _fetchAnggotaByPolsek() async {
    try {
      final anggota = await _apiService.getAnggotaByCabangPolsek(widget.idCabangPolsek);
      setState(() {
        _anggotaList = anggota;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat anggota: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = widget.routeData != null
        ? widget.routeData!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    final List<LatLng> neutralizationPoints = widget.neutralizationPoints != null
        ? widget.neutralizationPoints!.map((point) => LatLng(point[1], point[0])).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigasi Komandan"),
        backgroundColor: const Color(0xFFA1BED6),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: routePoints.isNotEmpty ? routePoints.first : const LatLng(-7.270607, 112.768229),
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
              MarkerLayer(
                markers: neutralizationPoints.map((point) {
                  return Marker(
                    point: point,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showAssignDialog(point.latitude, point.longitude),
                      child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(double latitude, double longitude) {
    int? selectedAnggota;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tentukan Anggota"),
          content: _isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<int>(
                  items: _anggotaList.map((anggota) {
                    return DropdownMenuItem<int>(
                      value: anggota['id_polisi'],
                      child: Text(anggota['nama']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedAnggota = value;
                  },
                  decoration: const InputDecoration(labelText: "Pilih Anggota"),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAnggota != null) {
                  await _apiService.utusAnggota(selectedAnggota!, latitude, longitude);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Anggota berhasil diutus")),
                  );
                }
              },
              child: const Text("Konfirmasi"),
            ),
          ],
        );
      },
    );
  }
}
