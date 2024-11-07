import 'package:flutter/material.dart';
import 'editprofile.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("Edit Profile", style: TextStyle(fontSize: 18)),
              onTap: () {
                // Navigasi ke UpdateProfileScreen
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(fontSize: 18)),
              onTap: () {
                // Navigasi ke LoginScreen dan menghapus semua halaman sebelumnya
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
