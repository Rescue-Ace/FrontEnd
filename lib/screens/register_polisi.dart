import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import halaman login
import '../service/api_service.dart'; // Import API Service

class RegisterPolisi extends StatefulWidget {
  @override
  _RegisterPolisiState createState() => _RegisterPolisiState();
}

class _RegisterPolisiState extends State<RegisterPolisi> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Opsi statis untuk Jabatan
  List<String> _jabatan = ['Komandan', 'Anggota'];
  String? _selectedJabatan;

  // Opsi untuk Cabang Polsek dari API
  List<String> _cabangPolsek = ['Cabang A', 'Cabang B', 'Cabang C'];
  String? _selectedCabangPolsek;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key untuk validasi form

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFFF7F7F7); // Warna latar belakang
    final Color boxBorderColor = Color(0xFFA1BED6); // Warna border box
    final Color textColor = Color(0xFF4872B1); // Warna teks di dalam box
    final Color buttonTextColor = Colors.white; // Warna teks tombol register

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor, // Pastikan warna AppBar sama dengan background
        elevation: 0, // Hilangkan bayangan pada AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // Tombol back
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Menggunakan Form untuk validasi
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo2.png', // Pastikan gambar logo sudah ada di folder assets
                  width: 80,
                  height: 80,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Registrasi Polisi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor, // Warna teks judul
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Input Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam box
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2), // Warna border saat fokus
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Input Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam box
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2), // Warna border saat fokus
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Dropdown Cabang Polsek
              DropdownButtonFormField<String>(
                value: _selectedCabangPolsek,
                decoration: InputDecoration(
                  labelText: 'Cabang Polsek',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam dropdown
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: Colors.white,
                items: _cabangPolsek.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: textColor)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCabangPolsek = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih cabang polsek';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Dropdown Jabatan
              DropdownButtonFormField<String>(
                value: _selectedJabatan,
                decoration: InputDecoration(
                  labelText: 'Jabatan',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam dropdown
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: Colors.white,
                items: _jabatan.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: textColor)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJabatan = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jabatan';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam box
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2), // Warna border saat fokus
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Input Konfirmasi Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: textColor), // Warna teks dalam box
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor), // Warna border box
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2), // Warna border saat fokus
                  ),
                ),
                validator: (value) {
                  if (value == null || value != _passwordController.text) {
                    return 'Password konfirmasi harus sama';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Tombol Register
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Setelah validasi, arahkan ke halaman login dan simpan data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4872B1),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Register', style: TextStyle(fontSize: 18, color: buttonTextColor)),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
