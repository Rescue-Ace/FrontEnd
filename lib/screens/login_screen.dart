import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import untuk TapGestureRecognizer
import '../service/api_service.dart'; // Import API Service
import 'mode_app.dart'; // Import halaman ModeApp (Register)

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instance ApiService

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      var response = await _apiService.loginUser(email, password);
      print('Login successful: $response');
      // Setelah login berhasil, arahkan ke halaman lain atau simpan data
    } catch (e) {
      print('Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Agar layar bisa di-scroll ketika keyboard muncul
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60), // Memberi jarak dari atas layar
              Center(
                child: Image.asset(
                  'assets/images/login.png', // Gambar untuk login
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 10), // Jarak antara gambar dan teks "Login"
              Center(
                child: Text(
                  'Login', // Teks di bawah gambar
                  style: TextStyle(
                    fontSize: 24, // Ukuran teks
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4872B1), // Warna teks
                  ),
                ),
              ),
              SizedBox(height: 20), // Jarak antara teks "Login" dan form input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF4872B1)), // Warna teks label normal
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color(0xFFA1BED6)), // Garis biru saat tidak aktif
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color(0xFFA1BED6), width: 2.0), // Garis biru tebal saat aktif
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true, // Menyembunyikan teks saat mengetik password
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF4872B1)), // Warna teks hijau untuk Password
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA1BED6)), // Garis biru saat tidak aktif
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA1BED6), width: 1.5), // Garis biru tebal saat aktif
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login, // Memanggil fungsi login saat tombol ditekan
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4872B1), // Warna tombol
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  foregroundColor: Colors.white,
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Color(0xFF4872B1)), // Warna teks normal
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(color: Color(0xFFA1BED6)), // Warna "Sign Up"
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigasi ke halaman ModeApp (Register)
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ModeApp()),
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
