import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../service/api_service.dart';
import 'settings_screen.dart';
import 'damkar_navigation.dart';
import 'komandan_navigation.dart';
import 'anggota_navigation.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _alatLocations = [];
  List<Map<String, dynamic>> _historyKebakaran = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentNotificationData;

  @override
  void initState() {
    super.initState();
    _fetchAlatLocations();
    _fetchKebakaranHistory();
    _setupFirebaseMessaging();
  }

  Future<void> _fetchAlatLocations() async {
    try {
      final alatData = await _apiService.getAllAlat();
      setState(() {
        _alatLocations = alatData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data alat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchKebakaranHistory() async {
    try {
      List<Map<String, dynamic>> history = await _apiService.getKebakaranHistory();
      setState(() {
        _historyKebakaran = history;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat histori kebakaran: $e';
      });
    }
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        try {
          final parsedData = _parseFCMData(message.data);
          if (parsedData.containsKey('status') && parsedData['status'] == 'padam') {
            _handleKebakaranPadam();
          } else {
            setState(() {
              _currentNotificationData = parsedData;
            });
          }
        } catch (e) {
          print("Error parsing FCM data: $e");
        }
      }

      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notifikasi: ${message.notification!.title}")),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        try {
          final parsedData = _parseFCMData(message.data);
          setState(() {
            _currentNotificationData = parsedData;
          });
          _navigateToRoleSpecificPage();
        } catch (e) {
          print("Error parsing FCM data on app open: $e");
        }
      }
    });
  }

  Map<String, dynamic> _parseFCMData(Map<String, dynamic> data) {
    final parsedData = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String && (value.startsWith('{') || value.startsWith('['))) {
        parsedData[key] = jsonDecode(value);
      } else {
        parsedData[key] = value;
      }
    });
    return parsedData;
  }

  void _handleKebakaranPadam() {
    Navigator.popUntil(context, (route) => route.isFirst);
    setState(() {
      _currentNotificationData = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kebakaran telah padam.')),
    );
  }

  void _navigateToRoleSpecificPage() {
    if (_currentNotificationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada data kebakaran saat ini.")),
      );
      return;
    }

    final role = widget.user['role'] ?? 'Unknown';
    final idCabangPolsek = widget.user['id_polsek'];

    if (role == 'Damkar') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DamkarNavigationScreen(
            routeData: _currentNotificationData?['coordinates'],
            idKebakaran: _currentNotificationData?['id_kebakaran'] ?? 0,
          ),
        ),
      );
    } else if (role == 'Komandan' && idCabangPolsek != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KomandanNavigationScreen(
            neutralizationPoints: _currentNotificationData?['data'],
            routeData: _currentNotificationData?['coordinates'],
            idCabangPolsek: idCabangPolsek,
          ),
        ),
      );
    } else if (role == 'Anggota') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnggotaNavigationScreen(
            assignedPoint: _currentNotificationData?['data']?[0],
            routeData: _currentNotificationData?['coordinates'],
          ),
        ),
      );
    }
  }

  ///////

  @override
  Widget build(BuildContext context) {
    String name = widget.user['nama'] ?? 'Guest';
    String role = widget.user['role'] ?? 'Unknown';
    String cabang = widget.user['cabang'] ?? 'Lokasi tidak ditemukan';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF4872B1)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFA1BED6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi $name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cabang,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4872B1),
                      ),
                    ),
                    if (role == 'Komandan' || role == 'Anggota')
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4872B1),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(-7.282219, 112.794676),
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                            additionalOptions: const {
                              'accessToken': 'pk.eyJ1IjoibmFmaXNhcnlhZGkzMiIsImEiOiJjbTNoZTFqNjIwZDdhMmpxenhwNjR4d3drIn0.oqCkTqILhSAP5qNjKCkV2g',
                            },
                          ),
                          MarkerLayer(
                            markers: _alatLocations.map((alat) {
                              return Marker(
                                point: LatLng(alat['latitude'], alat['longitude']),
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Histori Kebakaran",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4872B1),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFA1BED6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _historyKebakaran.isEmpty
                    ? const Center(
                        child: Text("Tidak ada histori kebakaran."),
                      )
                    : ListView.builder(
                        itemCount: _historyKebakaran.length,
                        itemBuilder: (context, index) {
                          final kebakaran = _historyKebakaran[index];
                          final alat = kebakaran['Alat'];
                          return ListTile(
                            title: Text(
                              "Lokasi: ${alat['alamat']}",
                              style: const TextStyle(color: Color(0xFF4872B1)),
                            ),
                            subtitle: Text(
                              "Tanggal: ${kebakaran['waktu_pelaporan']}",
                              style: const TextStyle(color: Color(0xFF4872B1)),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToRoleSpecificPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4872B1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Navigasi",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
