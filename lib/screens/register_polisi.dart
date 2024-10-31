import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import halaman login
import '../service/api_service.dart'; // Import API Service

class RegisterPolisi extends StatefulWidget {
  @override
  _RegisterPolisiState createState() => _RegisterPolisiState();
}

class _RegisterPolisiState extends State<RegisterPolisi> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telpController = TextEditingController(); // Tambahkan controller untuk nomor telepon
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  ApiService apiService = ApiService();

  List<String> _cabangPolsek = [];
  List<String> _jabatan = ['Komandan', 'Anggota'];
  String? _selectedCabangPolsek;
  String? _selectedJabatan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCabangPolsek();
  }

  void _loadCabangPolsek() async {
    List<String> cabang = await apiService.getCabangPolsek();
    setState(() {
      _cabangPolsek = cabang;
      _isLoading = false;
    });
  }

  void _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      Map<String, dynamic> newUser = {
        'nama': _nameController.text,
        'telp': _telpController.text, // Tambahkan nomor telepon
        'id_polsek': _selectedCabangPolsek,
        'komandan': _selectedJabatan == 'Komandan', // Komandan jika true, anggota jika false
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        await apiService.registerPolisi(newUser); // Gunakan API service untuk register
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        print('Registration failed: $e');
      }
    } else {
      // Handle error jika password tidak cocok
      print('Passwords do not match');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key untuk validasi form

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFFF7F7F7);
    final Color boxBorderColor = Color(0xFFA1BED6);
    final Color textColor = Color(0xFF4872B1);
    final Color buttonTextColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo2.png',
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
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Input Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
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
              // Input Nomor Telepon
              TextFormField(
                controller: _telpController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon wajib diisi';
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
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
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
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
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
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
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
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
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
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: boxBorderColor, width: 2),
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
                    _register();
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
