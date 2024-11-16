import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://careful-stunning-snake.ngrok-free.app';

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/user/loginUser');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validasi bahwa semua properti yang dibutuhkan tersedia
        if (data.containsKey('id_damkar') &&
            data.containsKey('role') &&
            data.containsKey('nama')) {
          return {
            'id_damkar': data['id_damkar'] ?? 0, // Gunakan default value jika `null`
            'role': data['role'] ?? '',
            'nama': data['nama'] ?? '',
            'token': data['token'] ?? '',
            'cabang_damkar': data['cabang_damkar'] ?? 'Unknown',
          };
        } else {
          throw Exception('Struktur respons tidak sesuai.');
        }
      } else {
        throw Exception('Gagal login: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Kesalahan login: $e');
    }
  }

  // Send FCM token for Damkar
  Future<void> putTokenDamkar(int idDamkar, String token) async {
    final url = Uri.parse('$baseUrl/user/Damkar/tokenFCM');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_damkar': idDamkar, 'token_user': token}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token for Damkar');
      }
    } catch (e) {
      throw Exception('Error updating FCM token for Damkar: $e');
    }
  }

  // Send FCM token for Polisi
  Future<void> putTokenPolisi(int idPolisi, String token) async {
    final url = Uri.parse('$baseUrl/user/Polisi/tokenFCM');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_polisi': idPolisi, 'token_user': token}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token for Polisi');
      }
    } catch (e) {
      throw Exception('Error updating FCM token for Polisi: $e');
    }
  }

  // Register Damkar
  Future<http.Response> registerDamkar(Map<String, dynamic> newUser) async {
    final url = Uri.parse('$baseUrl/user/registerDamkar');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to register Damkar: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Registration error for Damkar: $e');
    }
  }

  // Register Polisi
  Future<http.Response> registerPolisi(Map<String, dynamic> newUser) async {
    final url = Uri.parse('$baseUrl/user/registerPolisi');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to register Polisi: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Registration error for Polisi: $e');
    }
  }

  // Get Damkar branches
  Future<List<Map<String, dynamic>>> getCabangDamkar() async {
    final url = Uri.parse('$baseUrl/Damkar/PosDamkar');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch Damkar branches: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching Damkar branches: $e');
    }
  }

  // Get Polsek branches
  Future<List<Map<String, dynamic>>> getCabangPolsek() async {
    final url = Uri.parse('$baseUrl/Polisi/Polsek');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch Polsek branches: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching Polsek branches: $e');
    }
  }

  // Get Damkar by ID
  Future<Map<String, dynamic>> getDamkarById(int idDamkar) async {
    final url = Uri.parse('$baseUrl/user/Damkar/$idDamkar');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch Damkar data');
      }
    } catch (e) {
      throw Exception('Error fetching Damkar by ID: $e');
    }
  }

  // Get Polisi by ID
  Future<Map<String, dynamic>> getPolisiById(int idPolisi) async {
    final url = Uri.parse('$baseUrl/user/Polisi/$idPolisi');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch Polisi data');
      }
    } catch (e) {
      throw Exception('Error fetching Polisi by ID: $e');
    }
  }

  // Get Kebakaran history
  Future<List<Map<String, dynamic>>> getKebakaranHistory() async {
    final url = Uri.parse('$baseUrl/Kebakaran');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch Kebakaran history');
      }
    } catch (e) {
      throw Exception('Error fetching Kebakaran history: $e');
    }
  }
}
