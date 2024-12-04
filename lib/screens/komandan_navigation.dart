import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/api_service.dart';

class KomandanNavigationScreen extends StatefulWidget {
  final List<dynamic>? neutralizationPoints; // List titik netralisasi
  final List<dynamic>? routeData; // Rute kebakaran
  final int idCabangPolsek;
  final int idKebakaran;

  const KomandanNavigationScreen({
    super.key,
    required this.neutralizationPoints,
    required this.routeData,
    required this.idCabangPolsek,
    required this.idKebakaran,
  });

  @override
  _KomandanNavigationScreenState createState() =>
      _KomandanNavigationScreenState();
}

class _KomandanNavigationScreenState extends State<KomandanNavigationScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _anggotaList = []; // Daftar anggota yang dapat diutus
  Map<int, LatLng> _assignedAnggota = {}; // Map untuk menyimpan ID anggota dan titik yang diutus
  Map<LatLng, List<String>> _anggotaPerTitik = {}; // Map untuk menyimpan nama anggota per titik
  bool _isLoading = true; // Indikator memuat data anggota
  LatLng? _selectedPoint; // Titik netralisasi yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchAnggotaByPolsek(); // Ambil anggota berdasarkan polsek
  }

  // Fetch anggota dari backend berdasarkan cabang polsek
  Future<void> _fetchAnggotaByPolsek() async {
    try {
      final anggota = await _apiService.getAnggotaByCabangPolsek(widget.idCabangPolsek);
      setState(() {
        _anggotaList = anggota; // Simpan daftar anggota
        _isLoading = false; // Set indikator selesai loading
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

  // Tampilkan dialog untuk memilih anggota
  void _onNeutralizationPointTapped(LatLng point) {
    setState(() {
      _selectedPoint = point; // Simpan titik netralisasi yang dipilih
    });

    _showAssignDialog(point.latitude, point.longitude); // Tampilkan dialog
  }

  void _showAssignDialog(double latitude, double longitude) {
    int? selectedAnggota; // ID anggota yang dipilih
    final LatLng currentPoint = LatLng(latitude, longitude);
    final assignedAnggotaNames = _anggotaPerTitik[currentPoint] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tentukan Anggota"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading
                      ? const CircularProgressIndicator() // Jika loading, tampilkan indikator
                      : DropdownButtonFormField<int>(
                          items: _anggotaList.map((anggota) {
                            return DropdownMenuItem<int>(
                              value: anggota['id_polisi'],
                              child: Text(anggota['nama']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAnggota = value; // Simpan anggota yang dipilih
                            });
                          },
                          decoration: const InputDecoration(labelText: "Pilih Anggota"),
                        ),
                  const SizedBox(height: 10),
                  if (assignedAnggotaNames.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Anggota yang telah diutus:",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        ...assignedAnggotaNames.map((name) => Text("- $name")).toList(),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedAnggota != null) {
                      try {
                        // Kirim data ke backend
                        await _apiService.utusAnggota(
                          idPolisi: selectedAnggota!,
                          idKebakaran: widget.idKebakaran, // Kirim ID kebakaran
                          latitude: latitude,
                          longitude: longitude,
                        );
                        final selectedAnggotaName = _anggotaList
                            .firstWhere((anggota) => anggota['id_polisi'] == selectedAnggota)['nama'];

                        // Update Map untuk titik sebelumnya dan titik baru
                        setState(() {
                          // Hapus anggota dari titik sebelumnya
                          if (_assignedAnggota.containsKey(selectedAnggota)) {
                            final previousPoint = _assignedAnggota[selectedAnggota];
                            _anggotaPerTitik[previousPoint]?.remove(selectedAnggotaName);
                          }

                          // Tambahkan anggota ke titik baru
                          _assignedAnggota[selectedAnggota!] = currentPoint;
                          if (!_anggotaPerTitik.containsKey(currentPoint)) {
                            _anggotaPerTitik[currentPoint] = [];
                          }
                          _anggotaPerTitik[currentPoint]!.add(selectedAnggotaName);
                        });

                        Navigator.pop(context); // Tutup dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Anggota berhasil diutus ke titik ($latitude, $longitude)")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal mengutus anggota: $e")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pilih anggota terlebih dahulu.")),
                      );
                    }
                  },
                  child: const Text("Konfirmasi"),
                ),
              ],
            );
          },
        );
      },
    );
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
              onTap: (tapPosition, point) {
                // Reset titik netralisasi yang dipilih jika area kosong ditekan
                setState(() {
                  _selectedPoint = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: const {'accessToken': 'your-mapbox-access-token'},
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
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onTap: () => _onNeutralizationPointTapped(point),
                      child: Transform.translate(
                        offset: Offset(0, -10),
                        child: Icon(
                          Icons.location_on,
                          color: _selectedPoint == point ? Colors.red : Colors.orange,
                          size: 30,
                        ), // Tangani klik titik netralisasi
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_selectedPoint != null)
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
                      "Titik netralisasi terpilih",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Latitude: ${_selectedPoint!.latitude}, Longitude: ${_selectedPoint!.longitude}",
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
