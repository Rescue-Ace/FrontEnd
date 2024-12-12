import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../service/api_service.dart';
import 'home_page.dart';
import 'mode_app.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  // Mendapatkan FCM Token dan mengirimnya ke server
  Future<void> _getFCMTokenAndSendToServer({
    required int idDamkar,
    required int idPolisi,
    required String role,
  }) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("Mengirim FCM Token: $token untuk Role: $role");

        if (role == "Damkar" && idDamkar > 0) {
          await _apiService.putTokenDamkar(idDamkar, token);
        } else if ((role == "Komandan" || role == "Anggota") && idPolisi > 0) {
          await _apiService.putTokenPolisi(idPolisi, token);
        } else {
          print("Role atau ID tidak valid. Token tidak dikirim.");
        }
      } else {
        print("Gagal mendapatkan FCM token.");
      }
    } catch (e) {
      print("Error saat mengirim FCM token: $e");
    }
  }

  // Logika untuk login
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Email dan password tidak boleh kosong.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Kirim permintaan login ke server
      final response = await _apiService.loginUser(email, password);

      if (response.containsKey('role') && response.containsKey('nama')) {
        // Ambil data pengguna
        String role = response['role'];
        int idDamkar = response['id_damkar'] ?? 0;
        int idPolisi = response['id_polisi'] ?? 0;
        String cabang = response['cabang'] ?? 'Lokasi tidak ditemukan';
        int idPolsek = response['id_polsek'] ?? 0;

        // Buat map data pengguna untuk disimpan
        Map<String, dynamic> userData = {
          'id_damkar': idDamkar,
          'id_polisi': idPolisi,
          'role': role,
          'nama': response['nama'],
          'cabang': cabang,
          'id_polsek': idPolsek,
          'email' : email,
          'telp': response['telp'],
        };

        // Dapatkan FCM token dan kirim ke server
        await _getFCMTokenAndSendToServer(
          idDamkar: idDamkar,
          idPolisi: idPolisi,
          role: role,
        );

        // Simpan data pengguna ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('userData', jsonEncode(userData));
        // prefs.setString('role', role); // Simpan role
        // prefs.setInt('id_polisi', idPolisi); // Simpan id_polisi
        // prefs.setInt('id_damkar', idDamkar); // Simpan data pengguna
        print("UserData disimpan ke SharedPreferences: $userData");

        // Navigasi ke halaman utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: userData),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Login gagal: Struktur respons tidak valid.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login gagal: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4872B1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF4872B1)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFA1BED6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFA1BED6), width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0xFF4872B1)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFA1BED6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFA1BED6), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4872B1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 10),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Color(0xFF4872B1)),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(color: Color(0xFFA1BED6)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ModeApp()),
                              );
                            },
                        ),
                      ],
                    ),
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
