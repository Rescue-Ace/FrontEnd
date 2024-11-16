import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File hasil konfigurasi Firebase CLI
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/settings_screen.dart';
import 'screens/editprofile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase dengan error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'Rescue Ace', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema utama aplikasi
      ),
      // Rute awal aplikasi
      initialRoute: '/splash',
      // Definisi rute aplikasi
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(user: {}), // Parameter `user` default
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
      // Rute fallback jika rute tidak dikenal
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
