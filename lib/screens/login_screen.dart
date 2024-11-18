import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../service/api_service.dart';
import 'home_page.dart';
import 'mode_app.dart';

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
  Future<void> _getFCMTokenAndSendToServer(int userId, String role, int? idPolsek) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("FCM Token: $token");

        if (role == "Damkar") {
          await _apiService.putTokenDamkar(userId, token);
        } else if (role == "Polisi") {
          await _apiService.putTokenPolisi(userId, token);
        }

        print("FCM token berhasil dikirim ke server.");
      } else {
        print("Gagal mendapatkan FCM token.");
      }
    } catch (e) {
      print("Error saat mengirim FCM token: $e");
    }
  }

  // Validasi email
  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return regex.hasMatch(email);
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

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = "Format email tidak valid.";
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
        int userId = response['id_damkar'] ?? response['id_polisi'] ?? 0;
        String role = response['role'];
        int? idPolsek = response['id_polsek'];

        // Dapatkan FCM token dan kirim ke server
        await _getFCMTokenAndSendToServer(userId, role, idPolsek);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: response),
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
    return Scaffold(
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
    );
  }
}
