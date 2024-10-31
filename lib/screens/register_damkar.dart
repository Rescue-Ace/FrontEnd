import 'package:flutter/material.dart';
import 'login_screen.dart'; 
import '../service/api_service.dart'; 

class RegisterDamkar extends StatefulWidget {
  @override
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
      print("Cabang Damkar data: $cabang"); 
      setState(() {
        _cabangDamkar = cabang;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading Damkar branches: $e");
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

      print("Data dikirim: $newUser");

      try {
        final response = await apiService.registerDamkar(newUser);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Jika berhasil, navigasi ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // Jika tidak berhasil, tampilkan dialog error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("Registration failed. Please try again."),
                actions: [
                  TextButton(
                    child: Text("OK"),
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
        print('Registration failed: $e');
      }
    } else {
      print('Password tidak cocok');
    }
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        'Registrasi Damkar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
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
                    DropdownButtonFormField<int>(
                      value: _selectedCabangDamkarId,
                      decoration: InputDecoration(
                        labelText: 'Cabang Damkar',
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
                      items: _cabangDamkar.map((branch) {
                        return DropdownMenuItem<int>(
                          value: branch['id_pos_damkar'], 
                          child: Text(branch['alamat'], style: TextStyle(color: textColor)), 
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
                    SizedBox(height: 10),
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
