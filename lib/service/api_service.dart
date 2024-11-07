import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://careful-stunning-snake.ngrok-free.app';

  // Login function with enhanced error handling and debugging
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/user/loginUser');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Login response: $data");  // Debugging line
        
        if (data.containsKey('token') && data.containsKey('role') && data.containsKey('nama')) {
          return data;
        } else {
          throw Exception('Unexpected response structure');
        }
      } else {
        throw Exception('Failed to login: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Login error: $e");  
      throw Exception('Login error: $e');
    }
  }


  // Function to register Damkar user
    Future<http.Response> registerDamkar(Map<String, dynamic> newUser) async {
      final url = Uri.parse('$baseUrl/user/registerDamkar'); // Endpoint untuk Damkar

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
        throw Exception("Registration error for Damkar: $e");
      }
    }

  // Function to register Polisi user
    Future<http.Response> registerPolisi(Map<String, dynamic> newUser) async {
      final url = Uri.parse('$baseUrl/user/registerPolisi'); // Endpoint untuk Polisi

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
        throw Exception("Registration error for Polisi: $e");
      }
    }

  // Function to get Damkar branches
  Future<List<Map<String, dynamic>>> getCabangDamkar() async {
    final url = Uri.parse('$baseUrl/Damkar/PosDamkar');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Damkar branches: $data");  
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch cabang damkar: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching Damkar branches: $e");
      rethrow;
    }
  }

  // Function to get Polsek branches
  Future<List<Map<String, dynamic>>> getCabangPolsek() async {
    final url = Uri.parse('$baseUrl/Polisi/Polsek');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Polsek branches: $data");  
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch cabang polsek: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching Polsek branches: $e");
      rethrow;
    }
  }

  // Function to get Damkar user by ID
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
      print("Error fetching Damkar by ID: $e");
      rethrow;
    }
  }

  // Function to get Polisi user by ID
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
      print("Error fetching Polisi by ID: $e");
      rethrow;
    }
  }

  // Function to get Kebakaran history
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
      print("Error fetching Kebakaran history: $e");
      rethrow;
    }
  }
}
