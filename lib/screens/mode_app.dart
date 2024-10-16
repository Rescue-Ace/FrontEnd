import 'package:flutter/material.dart';
import 'register_polisi.dart'; // Import halaman Register Polisi
import 'register_damkar.dart'; // Import halaman Register Damkar

class ModeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Warna AppBar sama dengan background
        elevation: 0, // Menghilangkan bayangan AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4872B1)), // Tombol back berwarna sesuai
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, // Memusatkan isi secara horizontal
          children: [
            SizedBox(height: 20), // Jarak agar logo lebih naik ke atas
            // Logo di atas
            Center(
              child: Image.asset(
                'assets/images/logo2.png', // Gambar logo di assets
                width: 60,
                height: 60,
              ),
            ),
            SizedBox(height: 20), // Jarak antara logo dan teks
            // Teks Pilih Mode Aplikasi
            Center(
              child: Text(
                'Pilih Mode Aplikasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4872B1), // Warna teks sesuai tema
                ),
              ),
            ),
            SizedBox(height: 30), // Jarak antara teks dan kotak aplikasi
            // Tombol untuk Polisi
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman register polisi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPolisi()),
                );
              },
              child: Center(
                child: Container(
                  width: 200, // Lebar dan tinggi dibuat sama untuk kotak persegi
                  height: 200, // Membuat kotak menjadi persegi
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFA1BED6), // Warna background kotak
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/polisi.png', // Gambar Polisi
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Polisi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Warna teks putih
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tombol untuk Damkar
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman register damkar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterDamkar()),
                );
              },
              child: Center(
                child: Container(
                  width: 200, // Lebar dan tinggi dibuat sama untuk kotak persegi
                  height: 200, // Membuat kotak menjadi persegi
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFA1BED6), // Warna background kotak
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/damkar.png', // Gambar Damkar
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Damkar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Warna teks putih
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Background layar putih
    );
  }
}
