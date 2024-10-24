import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Mock database for users
  List<Map<String, dynamic>> _userData = [
    {
      'email': 'john@example.com',
      'password': 'password123',
      'name': 'John',
      'role': 'damkar', // Bisa 'damkar', 'polisi_komandan', atau 'polisi_anggota'
      'cabang': 'Damkar Keputih'
    },
    {
      'email': 'polisi@example.com',
      'password': '123',
      'name': 'mida',
      'role': 'polisi_komandan',
      'cabang': 'Polsek Keputih',
      'jabatan': 'komandan'
    }
  ];

  // Fungsi login mock
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    // Cek apakah user sudah terdaftar
    final user = _userData.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {}); // Mengembalikan map kosong jika tidak ada user

    if (user.isNotEmpty) {
      return {
        'status': 'success',
        'token': 'mock_token_12345', // Token dummy
        'user': user
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Fungsi untuk simpan user saat registrasi
  Future<void> registerUser(Map<String, dynamic> newUser) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    _userData.add(newUser);
  }

  // Fungsi untuk mock data user (untuk keperluan register damkar/polisi)
  Future<List<String>> getCabangDamkar() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    return ['Cabang A', 'Cabang B', 'Cabang C'];
  }

  Future<List<String>> getCabangPolsek() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    return ['Polsek 1', 'Polsek 2', 'Polsek 3'];
  }
}
