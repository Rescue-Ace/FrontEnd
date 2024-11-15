import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/settings_screen.dart';
import 'screens/editprofile.dart';

Future<void> main() async {
  runApp(const MyApp());
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
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginScreen(), 
      ),
    );
  }
}
