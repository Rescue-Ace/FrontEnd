import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/editprofile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Handler untuk notifikasi yang diterima saat aplikasi di background atau terminated
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Pastikan Firebase diinisialisasi

  if (message.data.isNotEmpty) {
    try {
      // Simpan data notifikasi ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_data', jsonEncode(message.data));
      print("Data FCM berhasil disimpan di background: ${message.data}");
    } catch (e) {
      print("Error saat menyimpan data FCM di background: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registrasi handler untuk notifikasi latar belakang
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // Ambil data notifikasi dan user dari SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? notificationData = prefs.getString('notification_data');
  String? userDataString = prefs.getString('userData');

  // Jika ada data notifikasi, lakukan parsing
  Map<String, dynamic>? savedNotificationData;
  if (notificationData != null) {
    try {
      // Parsing data notifikasi menggunakan _parseFCMData
      savedNotificationData = _parseFCMData(jsonDecode(notificationData));
    } catch (e) {
      print("Error parsing FCM data: $e");
    }
  }

  // Parsing data user
  Map<String, dynamic> userData = userDataString != null ? jsonDecode(userDataString) : {};

  // Jalankan aplikasi
  runApp(MyApp(
    savedNotificationData: savedNotificationData,
    userData: userData,
  ));

  // Hapus data notifikasi setelah digunakan
  prefs.remove('notification_data');
}

// Fungsi untuk parsing data FCM
Map<String, dynamic> _parseFCMData(Map<String, dynamic> data) {
  final parsedData = <String, dynamic>{};
  data.forEach((key, value) {
    if (key == 'data' && value is String) {
      try {
        parsedData.addAll(jsonDecode(value));
      } catch (e) {
        throw Exception("Payload FCM tidak valid: $data");
      }
    } else if (value is String && (value.startsWith('{') || value.startsWith('['))) {
      parsedData[key] = jsonDecode(value);
    } else {
      parsedData[key] = value;
    }
  });
  return parsedData;
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? savedNotificationData;
  final Map<String, dynamic> userData;

  const MyApp({super.key, this.savedNotificationData, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Tentukan initial route berdasarkan kondisi
    String initialRoute = '/splash'; // Default ke splash screen
    if (savedNotificationData != null) {
      initialRoute = '/home'; // Jika ada notifikasi, buka HomePage dengan data notifikasi
    } else if (userData.isNotEmpty) {
      initialRoute = '/home'; // Jika user sudah login, buka HomePage
    } else {
      initialRoute = '/splash'; // Jika user belum login, buka LoginScreen
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rescue Ace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initialRoute, // Rute awal dinamis
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomePage(
              user: userData, // Data user jika sudah login
              savedNotificationData: savedNotificationData,
            ),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
