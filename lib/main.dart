import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File hasil konfigurasi Firebase CLI
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/settings_screen.dart';
import 'screens/editprofile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.data}');
  
  // Menyimpan data notifikasi ke SharedPreferences agar bisa digunakan saat aplikasi dibuka kembali
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('notification_data', jsonEncode(message.data));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Menangani push notification saat aplikasi terbuka (foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground message: ${message.notification?.title}");
    if (message.data.isNotEmpty) {
      _navigateToRoleSpecificPage(message.data);
    }
  });

  // Menangani push notification saat aplikasi dibuka dari background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Opened from notification: ${message.notification?.title}");
    if (message.data.isNotEmpty) {
      _navigateToRoleSpecificPage(message.data);
    }
  });

  runApp(const MyApp());
}

void _navigateToRoleSpecificPage(Map<String, dynamic> notificationData) {
  final String role = notificationData['role'] ?? 'Unknown';
  
  // Navigate to the appropriate screen based on the role
  if (role == 'Damkar') {
    // Navigate to Damkar screen
    // Navigator.push(...);
  } else if (role == 'Komandan') {
    // Navigate to Komandan screen
    // Navigator.push(...);
  } else if (role == 'Anggota') {
    // Navigate to Anggota screen
    // Navigator.push(...);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rescue Ace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(user: {}),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
