import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'dart:convert';

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
        print('Logout berhasil');
      } else {
        print('Tidak ada data user yang ditemukan di SharedPreferences.');
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
      print('Error saat logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Profile", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(fontSize: 18)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
