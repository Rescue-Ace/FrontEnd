import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'settings_screen.dart';
import 'damkar_navigation.dart';
import 'komandan_navigation.dart';
import 'anggota_navigation.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? savedNotificationData;

  const HomePage({super.key, required this.user, this.savedNotificationData});

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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    print("Data user yang diterima di HomePage: ${widget.user}");

    _fetchAlatLocations();
    _fetchKebakaranHistory();
    _setupFirebaseMessaging();
    _initializeLocalNotifications();
    _checkNotificationData(); // Cek jika ada notifikasi tersimpan dari terminated state

    if (widget.savedNotificationData != null) {
      _currentNotificationData = widget.savedNotificationData;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToRoleSpecificPage();
      });
    }
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
      final history = await _apiService.getKebakaranHistory();
      setState(() {
        _historyKebakaran = history;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat histori kebakaran: $e';
      });
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _currentNotificationData = jsonDecode(response.payload!);
          _navigateToRoleSpecificPage();
        }
      },
    );
  }


  Future<void> _showNotification(String title, String body) async {
    if (_currentNotificationData?['status'] == 'padam') {
      title = "Kebakaran Telah Padam";
      body = "Tidak ada tindakan yang perlu dilakukan.";
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'RescueAce_fire_notification_channel',
      'RescueAce_fire_notification',
      channelDescription: 'This channel is used for fire alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'app_icon',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(_currentNotificationData),
    );
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        try {
          final parsedData = _parseFCMData(message.data);
          setState(() {
            _currentNotificationData = parsedData;
          });

          if (_currentNotificationData?['status'] == 'padam') {
            _showNotification("Kebakaran Telah Padam", "Tidak ada tindakan yang perlu dilakukan.");
            _closeAllNavigations();
          } else {
            _showNotification("TERJADI KEBAKARAN", "Segera lakukan penanganan");
          }

          _showKebakaranDialog();
        } catch (e) {
          print("Error parsing FCM data: $e");
        }
      }
    });


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.isNotEmpty) {
      try {
        final parsedData = _parseFCMData(message.data);
        setState(() {
          _currentNotificationData = parsedData;
        });

        if (_currentNotificationData?['status'] == 'padam') {
          _closeAllNavigations(); // Tutup semua navigasi jika padam
        } else {
          _navigateToRoleSpecificPage();
        }
      } catch (e) {
        print("Error handling onMessageOpenedApp: $e");
      }
    }
  });
}

  Future<void> _checkNotificationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notificationData = prefs.getString('notification_data');
    String? userDataString = prefs.getString('userData');

    if (notificationData != null) {
      try {
        final parsedData = jsonDecode(notificationData);
        setState(() {
          _currentNotificationData = parsedData;
        });

        if (userDataString != null) {
          widget.user.addAll(jsonDecode(userDataString));
        }

        _navigateToRoleSpecificPage();
        prefs.remove('notification_data');
      } catch (e) {
        print("Error processing notification data: $e");
      }
    }
  }

  Map<String, dynamic> _parseFCMData(Map<String, dynamic> data) {
    final parsedData = <String, dynamic>{};
    data.forEach((key, value) {
      if (key == 'data' && value is String) {
        try {
          parsedData.addAll(jsonDecode(value));
        } catch (e) {
          throw Exception("Payload FCM tidak valid: $data");
        }
      } else if (value is String && (value.startsWith('{') || value.startsWith('['))) {
        parsedData[key] = jsonDecode(value);
      } else {
        parsedData[key] = value;
      }
    });
    return parsedData;
  }

void _closeAllNavigations() {
  Navigator.popUntil(context, (route) => route.isFirst);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Kebakaran telah padam, semua navigasi ditutup.")),
  );
}


  void _showKebakaranDialog() {
  if (_currentNotificationData?['status'] == 'padam') {
    // Tampilkan dialog untuk status "padam"
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kebakaran Telah Padam"),
          content: const Text("Kebakaran telah padam, tidak ada navigasi yang perlu dilakukan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _closeAllNavigations(); // Tutup semua layar navigasi
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
    return;
  }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("TERJADI KEBAKARAN!!"),
          content: const Text("Segera buka navigasi untuk penanganan kebakaran."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToRoleSpecificPage();
              },
              child: const Text("Navigasi"),
            ),
          ],
        );
      },
    );
  }

 void _navigateToRoleSpecificPage() {
    if (_currentNotificationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada data kebakaran saat ini.")),
      );
      return;
    }

    var routeData = _currentNotificationData?['rute']?['coordinates'] ?? [];

    if (_currentNotificationData?['status'] == 'padam') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kebakaran telah padam, navigasi tidak tersedia.")),
      );
      _closeAllNavigations();
      return;
    }

    final role = widget.user['role'] ?? 'Unknown';
    final idCabangPolsek = widget.user['id_polsek'];
    final idKebakaran = _currentNotificationData?['kebakaran']?['id_kebakaran'] ?? 0;

    try {
      if (role == 'Damkar') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DamkarNavigationScreen(
              routeData: routeData,
              idKebakaran: _currentNotificationData?['kebakaran']?['id_kebakaran'] ?? 0,
              lokasiKebakaran: _currentNotificationData?['kebakaran']?['lokasi'] ?? 'Tidak diketahui',
            ),
          ),
        );
      } else if (role == 'Komandan' && idCabangPolsek != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KomandanNavigationScreen(
              neutralizationPoints: _currentNotificationData?['simpang'] ?? [],
              routeData: routeData,
              idCabangPolsek: idCabangPolsek,
              idKebakaran: idKebakaran,
            ),
          ),
        );
      } else if (role == 'Anggota') {
        final assignedPoint = _currentNotificationData?['utus'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnggotaNavigationScreen(
              assignedPoint: assignedPoint != null
                  ? LatLng(assignedPoint['latitude'], assignedPoint['longitude'])
                  : null,
              routeData: routeData,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error navigating to role-specific page: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat navigasi.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final name = widget.user['nama'] ?? 'Guest';
    final role = widget.user['role'] ?? 'Unknown';
    final cabang = widget.user['cabang'] ?? 'Lokasi tidak ditemukan';

    return SafeArea(
      child: Scaffold(
        body: SizedBox.expand(
          child: SingleChildScrollView(
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
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
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
                                  'accessToken':
                                      'pk.eyJ1IjoibmFmaXNhcnlhZGkzMiIsImEiOiJjbTNoZTFqNjIwZDdhMmpxenhwNjR4d3drIn0.oqCkTqILhSAP5qNjKCkV2g',
                                },
                              ),
                              MarkerLayer(
                                markers: _alatLocations.map((alat) {
                                  return Marker(
                                    point: LatLng(
                                        alat['latitude'], alat['longitude']),
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
                    height: 200,
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
                                  style: const TextStyle(
                                      color: Color(0xFF4872B1)),
                                ),
                                subtitle: Text(
                                  "Tanggal: ${kebakaran['waktu_pelaporan']}",
                                  style: const TextStyle(
                                      color: Color(0xFF4872B1)),
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
        ),
      ),
    );
  }

}


