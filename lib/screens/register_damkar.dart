import 'package:flutter/material.dart';

class RegisterDamkar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Damkar'),
        backgroundColor: Color(0xFF4872B1), // Sesuaikan dengan tema
      ),
      body: Center(
        child: Text(
          'Halaman Register Damkar',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
