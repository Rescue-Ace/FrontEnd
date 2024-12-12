// ignore_for_file: use_build_context_synchronously, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'login_screen.dart'; 
import '../service/api_service.dart'; 

class RegisterDamkar extends StatefulWidget {
  const RegisterDamkar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterDamkarState createState() => _RegisterDamkarState();
}

class _RegisterDamkarState extends State<RegisterDamkar> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  ApiService apiService = ApiService();

  List<Map<String, dynamic>> _cabangDamkar = [];
  int? _selectedCabangDamkarId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCabangDamkar();
  }

  void _loadCabangDamkar() async {
    try {
      List<Map<String, dynamic>> cabang = await apiService.getCabangDamkar();
      setState(() {
        _cabangDamkar = cabang;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading Damkar branches: $e");
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
        'id_pos_damkar': _selectedCabangDamkarId,
        'email': _emailController.text,
        'password': _passwordController.text,
      };


      try {
        final response = await apiService.registerDamkar(newUser);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Jika berhasil, navigasi ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Jika tidak berhasil, tampilkan dialog error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Registration failed. Please try again."),
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
      } catch (e) {
        debugPrint('Registration failed: $e');
      }
    } else {
      debugPrint('Password tidak cocok');
    }
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF7F7F7);
    const Color boxBorderColor = Color(0xFFA1BED6);
    const Color textColor = Color(0xFF4872B1);
    const Color buttonTextColor = Colors.white;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox.expand(
              child: SingleChildScrollView(
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
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'Registrasi Damkar',
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
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          value: _selectedCabangDamkarId,
                          decoration: InputDecoration(
                            labelText: 'Cabang Damkar',
                            labelStyle: const TextStyle(color: textColor),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: boxBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: boxBorderColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          items: _cabangDamkar.map((branch) {
                            return DropdownMenuItem<int>(
                              value: branch['id_pos_damkar'], 
                              child: Text(branch['nama'], style: const TextStyle(color: textColor, fontSize: 13)), 
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCabangDamkarId = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Pilih cabang damkar';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          child: const Text('Register', style: TextStyle(fontSize: 18, color: buttonTextColor)),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
