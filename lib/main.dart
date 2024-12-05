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

// Handler untuk notifikasi di background atau terminated
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Pastikan Firebase diinisialisasi

  if (message.data.isNotEmpty) {
    try {
      // Simpan data notifikasi ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_data', jsonEncode(message.data));
    } catch (e) {
      print("Error handling background message: $e");
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

  Map<String, dynamic>? savedNotificationData =
      notificationData != null ? jsonDecode(notificationData) : null;
  Map<String, dynamic> userData =
      userDataString != null ? jsonDecode(userDataString) : {};

  runApp(MyApp(
    savedNotificationData: savedNotificationData,
    userData: userData,
  ));
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
      initialRoute = '/login'; // Jika user belum login, buka LoginScreen
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
