import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/settings_screen.dart';
import 'screens/editprofile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rescue Ace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',  // Route awal ke SplashScreen
      routes: {
        '/splash': (context) => SplashScreen(),  // Pastikan SplashScreen ada
        '/login': (context) => LoginScreen(),     // Route untuk LoginScreen
        '/home': (context) => HomePage(user: {}), // Route untuk HomePage, user bisa diatur sesuai kebutuhan
        '/settings': (context) => SettingsScreen(), // Route untuk SettingsScreen
        '/edit_profile': (context) => EditProfileScreen(), // Route untuk UpdateProfileScreen
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => LoginScreen(), // Jika route tidak ditemukan, kembali ke LoginScreen
      ),
    );
  }
}
