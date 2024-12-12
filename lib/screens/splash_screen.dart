import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  Future<void> _startSplashScreen() async {
    // Tambahkan delay selama 3 detik
    await Future.delayed(const Duration(seconds: 2));
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // Ambil data user yang disimpan
        String? userDataString = prefs.getString('userData');
        Map<String, dynamic> user =
            userDataString != null ? jsonDecode(userDataString) : {};

        // Pastikan data cabang selalu tersedia
        if (!user.containsKey('cabang') || user['cabang'] == null || user['cabang'].isEmpty) {
          user['cabang'] = user['role'] == "Damkar"
              ? (user['cabang_damkar'] ?? 'Damkar tidak ditemukan')
              : (user['cabang_polsek'] ?? 'Polsek tidak ditemukan');
        }

        debugPrint("UserData dibaca dari SharedPreferences: $user");

        // Navigasi ke HomePage dengan data user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user),
          ),
        );
      } else {
        // Arahkan ke LoginScreen jika belum login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error saat memeriksa login status: $e");
      // Kembali ke LoginScreen jika terjadi error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3C7E6),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Sesuaikan path dengan lokasi file logo Anda
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
