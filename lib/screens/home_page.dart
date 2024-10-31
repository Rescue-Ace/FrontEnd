import 'package:flutter/material.dart';
import '../service/api_service.dart';

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
      print('Failed to fetch history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String role = widget.user['role'];
    String name = widget.user['nama'];
    String cabang = (role == 'damkar') ? widget.user['id_pos_damkar'] : widget.user['id_pos_polsek'];
    String jabatan = role == 'polisi' ? (widget.user['komandan'] ? 'Komandan' : 'Anggota') : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4872B1),
        title: Text("Home Page", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFA1BED6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi $name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(role == 'damkar' ? 'Damkar Cabang $cabang' : 'Polsek $cabang'),
                  if (role == 'polisi') Text(jabatan, style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Map Section (Placeholder for now)
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text("Map Placeholder")),
            ),
            SizedBox(height: 20),
            // History Section
            Text("Histori Kebakaran", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _historyKebakaran.length,
                      itemBuilder: (context, index) {
                        final kebakaran = _historyKebakaran[index];
                        return ListTile(
                          title: Text("Lokasi: ${kebakaran['location']}"),
                          subtitle: Text("Tanggal: ${kebakaran['date']}"),
                        );
                      },
                    ),
            ),
            // Button for Navigation based on role
            ElevatedButton(
              onPressed: () {
                // Navigate based on role
                if (role == 'damkar') {
                  Navigator.pushNamed(context, '/damkarNavigation');
                } else if (role == 'polisi') {
                  if (widget.user['komandan']) {
                    Navigator.pushNamed(context, '/komandanNavigation');
                  } else {
                    Navigator.pushNamed(context, '/anggotaNavigation');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4872B1),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text("Navigasi", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
