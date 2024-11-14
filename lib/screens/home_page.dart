import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'settings_screen.dart';
import 'damkar_navigation.dart';
import 'komandan_navigation.dart';
import 'anggota_navigation.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _historyKebakaran = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchKebakaranHistory();
  }

  Future<void> _fetchKebakaranHistory() async {
    try {
      List<Map<String, dynamic>> history = await _apiService.getKebakaranHistory();
      setState(() {
        _historyKebakaran = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.user['nama'] ?? 'Guest';
    String role = widget.user['role'] ?? 'Unknown';
    String cabang = role == 'Damkar'
        ? 'Damkar Cabang ${widget.user['cabang_damkar'] ?? 'Unknown'}'
        : role == 'Komandan' || role == 'Anggota'
            ? 'Polsek ${widget.user['cabang_polsek'] ?? 'Unknown'}'
            : 'Unknown Location';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row with Settings Icon
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
              // User information section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA1BED6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi $name", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(cabang, style: const TextStyle(fontSize: 16, color: Color(0xFF4872B1))),
                    if (role == 'Komandan' || role == 'Anggota')
                      Text(role, style: const TextStyle(fontSize: 16, color: Color(0xFF4872B1))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Placeholder for map or other content
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text("Map Placeholder")),
              ),
              const SizedBox(height: 20),
              const Text("Histori Kebakaran", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4872B1))),
              const SizedBox(height: 10),
              // Box with scrollable list for history
              Container(
                height: 200, // Tentukan tinggi container untuk scroll list di dalamnya
                decoration: BoxDecoration(
                  color: const Color(0xFFA1BED6), // Warna biru muda
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                        : ListView.builder(
                            itemCount: _historyKebakaran.length,
                            itemBuilder: (context, index) {
                              final kebakaran = _historyKebakaran[index];
                              return ListTile(
                                title: Text(
                                  "Lokasi: ${kebakaran['location']}",
                                  style: const TextStyle(color: Color(0xFF4872B1)),
                                ),
                                subtitle: Text(
                                  "Tanggal: ${kebakaran['date']}",
                                  style: const TextStyle(color: Color(0xFF4872B1)),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 20),
              // Navigation button based on role
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (role == 'Damkar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DamkarNavigationScreen()),
                      );
                    } else if (role == 'Komandan') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KomandanNavigationScreen()),
                      );
                    } else if (role == 'Anggota') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnggotaNavigationScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4872B1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Navigasi", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
