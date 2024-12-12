import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../service/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _telpController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmNewPasswordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  int? _selectedCabangId;
  List<Map<String, dynamic>> _cabangList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      Map<String, dynamic> userData = json.decode(userDataString);
      _nameController.text = userData['nama'] ?? ''; // Default to empty string if null
      _emailController.text = userData['email'] ?? ''; // Default to empty string if null
      _telpController.text = userData['telp'] ?? '';

      // Check role and load the respective cabang data
      if (userData['role'] == 'Damkar') {
        _loadCabangDamkar();
      } else if (userData['role'] == 'Komandan' || userData['role'] == 'Anggota') {
        _loadCabangPolsek();
      }
    }
  }

  // Load Cabang Damkar
  Future<void> _loadCabangDamkar() async {
    try {
      List<Map<String, dynamic>> cabang = await apiService.getCabangDamkar();
      setState(() {
        _cabangList = cabang;
      });
    } catch (e) {
      debugPrint("Error loading Damkar branches: $e");
    }
  }

  // Load Cabang Polsek
  Future<void> _loadCabangPolsek() async {
    try {
      List<Map<String, dynamic>> cabang = await apiService.getCabangPolsek();
      setState(() {
        _cabangList = cabang;
      });
    } catch (e) {
      debugPrint("Error loading Polsek branches: $e");
    }
  }

  // Handle profile update
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        Map<String, dynamic> userData = json.decode(userDataString);
        int id = userData['role'] == 'Damkar' ? userData['id_damkar'] : userData['id_polisi'];

        Map<String, dynamic> updatedData = {
          'nama': _nameController.text,
          'email': _emailController.text,
          'telp': _telpController.text,
          'id_pos_damkar': userData['role'] == 'Damkar' ? _selectedCabangId : null,
          'id_polsek': userData['role'] != 'Damkar' ? _selectedCabangId : null,
        };

        try {
          final response = userData['role'] == 'Damkar'
              ? await apiService.updateDamkarProfile(updatedData, id)
              : await apiService.updatePolisiProfile(updatedData, id);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = json.decode(response.body);

            // Save updated user data
            prefs.setString('userData', json.encode(responseData['updateUser']));

            // Check if the user is inactive and handle logout
            if (responseData['updateUser']['aktif'] == false) {
              _logout(context);
              return;
            }

            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          } else {
            throw Exception('Failed to update profile');
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  // Logout method (reused from SettingsScreen)
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final Map<String, dynamic> userData = jsonDecode(userDataString);
        final String role = userData['role'];
        final int id = role == 'Damkar' ? userData['id_damkar'] : userData['id_polisi'];

        final Map<String, dynamic> requestBody = {
          'role': role,
          'id': id,
        };

        final ApiService apiService = ApiService();
        await apiService.logoutUser(requestBody);
      }

      await prefs.clear();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }


  // Handle change password
  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        Map<String, dynamic> userData = json.decode(userDataString);
        int id = userData['role'] == 'Damkar' ? userData['id_damkar'] : userData['id_polisi'];

        try {
          // Call API to update password based on user role
          if (userData['role'] == 'Damkar') {
            await apiService.updateDamkarPassword(id, _oldPasswordController.text, _newPasswordController.text);
          } else {
            await apiService.updatePolisiPassword(id, _oldPasswordController.text, _newPasswordController.text);
          }

          // Logout the user after successful password update
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully. Logging out...')),
          );

          _logout(context); // Call logout function
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to change password: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox.expand(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                    
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4872B1),
                            ),
                          ),
                    
                          const SizedBox(height: 10),
                    
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                    
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                    
                          // Phone Number Field
                          TextFormField(
                            controller: _telpController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                    
                          // Dropdown for Branch Selection (Damkar/Polsek)
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Select Branch',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedCabangId,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCabangId = newValue;
                              });
                            },
                            items: _cabangList.map((branch) {
                              return DropdownMenuItem<int>(
                                value: branch['id_pos_damkar'] ?? branch['id_polsek'],
                                child: Text(
                                  branch['nama'],
                                  style: const TextStyle(fontSize: 13),),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a branch';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                    
                          // Update Profile Button
                          SizedBox(
                            width: double.infinity, // Tombol memenuhi lebar layar
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              child: const Text(
                                'Update Profile',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4872B1),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                    
                          const SizedBox(height: 30),
                    
                          const Divider(),
                    
                          const SizedBox(height: 16),
                    
                          // Password Change Section
                          const Text(
                            "Ganti Password",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4872B1),
                            ),
                          ),
                          const SizedBox(height: 16),
                    
                          Form(
                            key: _passwordFormKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _oldPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Old Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your old password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                    
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'New Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your new password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                    
                                TextFormField(
                                  controller: _confirmNewPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                    
                                // Change Password Button
                                SizedBox(
                                  width: double.infinity, // Tombol memenuhi lebar layar
                                  child: ElevatedButton(
                                    onPressed: _changePassword,
                                    child: const Text(
                                      'Change Password',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4872B1),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
      ),
    );
  }
}
