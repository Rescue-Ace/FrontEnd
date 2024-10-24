import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../service/api_service.dart'; 
import 'home_page.dart'; 
import 'mode_app.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); 

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      var response = await _apiService.loginUser(email, password);
      print('Login successful: $response');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: response['user']),
        ),
      );
    } catch (e) {
      print('Login failed: $e');
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
              SizedBox(height: 60),
              Center(
                child: Image.asset(
                  'assets/images/login.png', 
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4872B1), 
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF4872B1)), 
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color(0xFFA1BED6)), 
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color(0xFFA1BED6), width: 2.0), 
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true, 
                decoration: InputDecoration(
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4872B1), 
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
                    style: TextStyle(color: Color(0xFF4872B1)), 
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(color: Color(0xFFA1BED6)), 
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
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
