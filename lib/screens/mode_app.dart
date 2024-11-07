import 'package:flutter/material.dart';
import 'register_polisi.dart';
import 'register_damkar.dart';

class ModeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4872B1)),
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
                SizedBox(height: 20),
                Center(
                  child: Image.asset('assets/images/logo2.png', width: 60, height: 60),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Pilih Mode Aplikasi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4872B1)),
                  ),
                ),
                SizedBox(height: 30),
                // Tombol untuk Polisi
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPolisi()));
                  },
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFA1BED6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/polisi.png', width: 100, height: 100),
                          SizedBox(height: 10),
                          Text('Polisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tombol untuk Damkar
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterDamkar()));
                  },
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFA1BED6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/damkar.png', width: 100, height: 100),
                          SizedBox(height: 10),
                          Text('Damkar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
