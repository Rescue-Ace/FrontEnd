import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Center(
        child: Text(
          "Edit Profile Screen",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
