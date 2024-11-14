import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../service/api_service.dart';

class RegisterPolisi extends StatefulWidget {
  const RegisterPolisi({super.key});

  @override
  _RegisterPolisiState createState() => _RegisterPolisiState();
}

class _RegisterPolisiState extends State<RegisterPolisi> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  ApiService apiService = ApiService();

  List<Map<String, dynamic>> _cabangPolsek = [];
  int? _selectedCabangPolsekId;
  final List<String> _jabatan = ['Komandan', 'Anggota'];
  String? _selectedJabatan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCabangPolsek();
  }

  void _loadCabangPolsek() async {
    try {
      List<Map<String, dynamic>> cabang = await apiService.getCabangPolsek();
      setState(() {
        _cabangPolsek = cabang;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading Cabang Polsek: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      Map<String, dynamic> newUser = {
        'nama': _nameController.text,
        'telp': _telpController.text,
        'id_polsek': _selectedCabangPolsekId, // Menggunakan kunci yang benar untuk Polsek
        'komandan': _selectedJabatan == 'Komandan', // True jika "Komandan", false jika "Anggota"
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      print("Data dikirim: $newUser");

      try {
        final response = await apiService.registerPolisi(newUser);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          _showErrorDialog("Registration failed. Please try again.");
        }
      } catch (e) {
        print('Registration failed: $e');
        _showErrorDialog("Registration failed. Please try again.");
      }
    } else {
      _showErrorDialog("Password dan konfirmasi password tidak cocok.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF7F7F7);
    final Color boxBorderColor = const Color(0xFFA1BED6);
    final Color textColor = const Color(0xFF4872B1);
    const Color buttonTextColor = Colors.white;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo2.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _selectedCabangPolsekId,
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
                      items: _cabangPolsek.map((branch) {
                        return DropdownMenuItem<int>(
                          value: branch['id_polsek'],
                          child: Text(branch['nama'], style: TextStyle(color: textColor)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCabangPolsekId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih cabang polsek';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
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
                      items: _jabatan.map((value) {
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _register();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4872B1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
