import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fungsi login mock
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    // Simulasi respons API
    if (email == "test@example.com" && password == "password123") {
      return {
        'status': 'success',
        'token': 'mock_token_12345', // Token dummy
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Fungsi untuk mock data user
  Future<Map<String, dynamic>> getUserData(String token) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    return {
      'name': 'John Doe',
      'email': 'test@example.com',
    };
  }

  // Fungsi untuk mendapatkan daftar Cabang Damkar (mock)
  Future<List<String>> getCabangDamkar() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    return ['Cabang A', 'Cabang B', 'Cabang C', 'Cabang D'];
  }

  // Fungsi untuk mendapatkan daftar Cabang Polsek (mock)
  Future<List<String>> getCabangPolsek() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    return ['Polsek A', 'Polsek B', 'Polsek C', 'Polsek D'];
  }
}
