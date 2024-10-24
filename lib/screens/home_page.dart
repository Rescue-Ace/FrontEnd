import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    String role = user['role']; // role bisa 'damkar' atau 'polisi'
    String name = user['name'];
    String cabang = user['cabang'];
    String? jabatan = user['jabatan']; // jabatan hanya ada jika role-nya polisi

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA1BED6),
        elevation: 0,
        title: Text('Hi $name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFA1BED6),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role == 'damkar' ? 'Damkar $cabang' : 'Polsek $cabang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (role == 'polisi')
                    Text(
                      jabatan ?? '',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Peta atau informasi lokasi
            Container(
              height: 200,
              color: Colors.blueGrey[100],
              child: Center(
                child: Text('Peta lokasi kebakaran atau alat'),
              ),
            ),
            SizedBox(height: 20),
            // Historis kebakaran
            Text(
              'Histori Kebakaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                _buildHistoryItem('Lokasi, Tanggal Kebakaran 1'),
                _buildHistoryItem('Lokasi, Tanggal Kebakaran 2'),
                _buildHistoryItem('Lokasi, Tanggal Kebakaran 3'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (role == 'damkar') {
                  // Navigasi ke halaman navigasi damkar
                } else if (role == 'polisi' && jabatan == 'Komandan') {
                  // Navigasi ke halaman navigasi komandan
                } else if (role == 'polisi' && jabatan == 'Anggota') {
                  // Navigasi ke halaman navigasi anggota
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4872B1),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text('Navigasi', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(title),
      ),
    );
  }
}
