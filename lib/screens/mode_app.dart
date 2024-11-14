import 'package:flutter/material.dart';
import 'register_polisi.dart';
import 'register_damkar.dart';

class ModeApp extends StatelessWidget {
  const ModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4872B1)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: 
      SingleChildScrollView(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset('assets/images/logo2.png', width: 60, height: 60),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Pilih Mode Aplikasi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4872B1)),
                  ),
                ),
                const SizedBox(height: 30),
                // Tombol untuk Polisi
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPolisi()));
                  },
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1BED6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/polisi.png', width: 100, height: 100),
                          const SizedBox(height: 10),
                          const Text('Polisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tombol untuk Damkar
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterDamkar()));
                  },
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1BED6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/damkar.png', width: 100, height: 100),
                          const SizedBox(height: 10),
                          const Text('Damkar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
