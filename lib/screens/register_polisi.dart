import 'package:flutter/material.dart';

class RegisterPolisi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Polisi'),
        backgroundColor: Color(0xFF4872B1), // Sesuaikan dengan tema
      ),
      body: Center(
        child: Text(
          'Halaman Register Polisi',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
