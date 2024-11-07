import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'settings_screen.dart';
import 'damkar_navigation.dart';
import 'komandan_navigation.dart';
import 'anggota_navigation.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({required this.user});

  @override
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
                    icon: Icon(Icons.settings, color: Color(0xFF4872B1)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
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
                  color: Color(0xFFA1BED6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi $name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text(cabang, style: TextStyle(fontSize: 16, color: Color(0xFF4872B1))),
                    if (role == 'Komandan' || role == 'Anggota')
                      Text(role, style: TextStyle(fontSize: 16, color: Color(0xFF4872B1))),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Placeholder for map or other content
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Text("Map Placeholder")),
              ),
              SizedBox(height: 20),
              Text("Histori Kebakaran", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4872B1))),
              SizedBox(height: 10),
              // Box with scrollable list for history
              Container(
                height: 200, // Tentukan tinggi container untuk scroll list di dalamnya
                decoration: BoxDecoration(
                  color: Color(0xFFA1BED6), // Warna biru muda
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                        : ListView.builder(
                            itemCount: _historyKebakaran.length,
                            itemBuilder: (context, index) {
                              final kebakaran = _historyKebakaran[index];
                              return ListTile(
                                title: Text(
                                  "Lokasi: ${kebakaran['location']}",
                                  style: TextStyle(color: Color(0xFF4872B1)),
                                ),
                                subtitle: Text(
                                  "Tanggal: ${kebakaran['date']}",
                                  style: TextStyle(color: Color(0xFF4872B1)),
                                ),
                              );
                            },
                          ),
              ),
              SizedBox(height: 20),
              // Navigation button based on role
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (role == 'Damkar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DamkarNavigationScreen()),
                      );
                    } else if (role == 'Komandan') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KomandanNavigationScreen()),
                      );
                    } else if (role == 'Anggota') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnggotaNavigationScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4872B1),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text("Navigasi", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
