import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://2551-182-253-50-100.ngrok-free.app';

  // Fungsi login dengan backend
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/loginUser');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }

  // Fungsi registrasi Damkar
  Future<void> registerDamkar(Map<String, dynamic> newUser) async {
    final url = Uri.parse('$baseUrl/user/registerDamkar');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register Damkar: ${response.reasonPhrase}');
    }
  }

  // Fungsi registrasi Polisi
  Future<void> registerPolisi(Map<String, dynamic> newUser) async {
    final url = Uri.parse('$baseUrl/user/registerPolisi');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register Polisi: ${response.reasonPhrase}');
    }
  }

  // Fungsi untuk mendapatkan cabang Damkar
  Future<List<Map<String, dynamic>>> getCabangDamkar() async {
    final url = Uri.parse('$baseUrl/Damkar/PosDamkar');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data); // Parsing jika cabang berupa objek
    } else {
      throw Exception('Failed to fetch cabang damkar: ${response.reasonPhrase}');
    }
  }

  // Fungsi untuk mendapatkan cabang Polsek
  Future<List<Map<String, dynamic>>> getCabangPolsek() async {
    final url = Uri.parse('$baseUrl/Polisi/PosPolisi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch cabang polsek');
    }
  }

    // Fungsi untuk mendapatkan data Damkar berdasarkan ID
  Future<Map<String, dynamic>> getDamkarById(int idDamkar) async {
    final url = Uri.parse('$baseUrl/user/Damkar/$idDamkar');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch Damkar data');
    }
  }

  // Fungsi untuk mendapatkan data Polisi berdasarkan ID
  Future<Map<String, dynamic>> getPolisiById(int idPolisi) async {
    final url = Uri.parse('$baseUrl/user/Polisi/$idPolisi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch Polisi data');
    }
  }

  // Fungsi untuk mendapatkan riwayat kebakaran
  Future<List<Map<String, dynamic>>> getKebakaranHistory() async {
    final url = Uri.parse('$baseUrl/Kebakaran');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch Kebakaran history');
    }
  }
  
}

////////////////////////////////////////////////////////////////////

