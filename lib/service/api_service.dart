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
      if ((data.containsKey('id_damkar') || data.containsKey('id_polisi')) &&
          data.containsKey('role') &&
          data.containsKey('nama')) {
        // Return data dengan fallback untuk cabang
        return {
          'id_damkar': data['id_damkar'] ?? 0,
          'id_polisi': data['id_polisi'] ?? 0,
          'role': data['role'] ?? '',
          'nama': data['nama'] ?? '',
          'token': data['token'] ?? '',
          'cabang': data['role'] == 'Damkar'
              ? (data['cabang_damkar'] ?? 'Damkar tidak ditemukan')
              : (data['cabang_polsek'] ?? 'Polsek tidak ditemukan'),
          'id_polsek': data['id_polsek'] ?? 0,
        };
      } else {
        throw Exception('Struktur respons tidak sesuai.');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Email atau password salah.');
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
        body: json.encode({'id_polisi': idPolisi, 'token_user': token}), // Perbaiki dari id_damkar ke id_polisi
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

  // Update profile for Damkar
  Future<http.Response> updateDamkarProfile(Map<String, dynamic> updatedData, int idDamkar) async {
    final url = Uri.parse('$baseUrl/user/Damkar/$idDamkar');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to update Damkar profile: ${response.reasonPhrase}');
    }
  }

  // Update profile for Polisi (Komandan / Anggota)
  Future<http.Response> updatePolisiProfile(Map<String, dynamic> updatedData, int idPolisi) async {
    final url = Uri.parse('$baseUrl/user/Polisi/$idPolisi');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to update Polisi profile: ${response.reasonPhrase}');
    }
  }

  // Update Password for Damkar
  Future<void> updateDamkarPassword(int idDamkar, String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/Damkar/updatePassword/$idDamkar');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update Damkar password');
      }
    } catch (e) {
      throw Exception('Error updating Damkar password: $e');
    }
  }

  // Update Password for Polisi
  Future<void> updatePolisiPassword(int idPolisi, String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/Polisi/updatePassword/$idPolisi');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update Polisi password');
      }
    } catch (e) {
      throw Exception('Error updating Polisi password: $e');
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

  Future<List<Map<String, dynamic>>> getAllPolisi() async {
  final url = Uri.parse('$baseUrl/user/getAllPolisi');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch polisi data');
      }
    } catch (e) {
      throw Exception("Error fetching polisi data: $e");
    }
  }

    Future<List<Map<String, dynamic>>> getAllAlat() async {
    final url = Uri.parse('$baseUrl/Alat');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Gagal mengambil data alat: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

    // Mengutus anggota ke titik tertentu
  Future<void> utusAnggota({
      required int idPolisi,
      required int idKebakaran,
      required double latitude,
      required double longitude,
    }) async {
      final url = Uri.parse('$baseUrl/Polisi/utusPolisi');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id_polisi': idPolisi,
            'id_kebakaran': idKebakaran, // Tambahkan id_kebakaran
            'latitude': latitude,
            'longitude': longitude,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to utus anggota: ${response.body}');
        }
      } catch (e) {
        throw Exception('Error in utusAnggota: $e');
      }
    }


  // Mendapatkan anggota berdasarkan cabang polsek
  Future<List<Map<String, dynamic>>> getAnggotaByCabangPolsek(int idPolsek) async {
    final url = Uri.parse('$baseUrl/user/Anggota/$idPolsek');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Gagal mengambil data anggota: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Kesalahan mengambil data anggota: $e');
    }
  }

  Future<void> updateStatusKebakaran(int idKebakaran, String status) async {
    final url = Uri.parse('$baseUrl/Kebakaran/$idKebakaran');
    print("Endpoint: $url");
    print("Data: {status_kebakaran: $status}");
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status_kebakaran': status}),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Gagal memperbarui status kebakaran');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Kesalahan memperbarui status kebakaran: $e');
    }
  }


  Future<http.Response> logoutUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/user/logoutUser');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return response; // Pastikan kita mengembalikan response
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }


}
