import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../service/api_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Ambil data user dari SharedPreferences
      final String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final Map<String, dynamic> userData = jsonDecode(userDataString);

        // Buat request body sesuai role
        final String role = userData['role'];
        final int id = role == 'Damkar' ? userData['id_damkar'] : userData['id_polisi'];

        final Map<String, dynamic> requestBody = {
          'role': role,
          'id': id,
        };

        // Panggil endpoint logout
        final ApiService apiService = ApiService();
        await apiService.logoutUser(requestBody);
        debugPrint('Logout berhasil');
      } else {
        debugPrint('Tidak ada data user yang ditemukan di SharedPreferences.');
      }

      // Hapus data dari SharedPreferences
      await prefs.clear();

      // Navigasi kembali ke LoginScreen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Error saat logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4872B1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Edit Profile", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4872B1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Log out", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
