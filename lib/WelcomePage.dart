import 'package:flutter/material.dart';
import 'package:my_finel_project/SighInPage.dart';
import 'package:my_finel_project/PdfChatbotPage.dart';
import 'package:my_finel_project/SignUpPage.dart';

import 'Services/auth.dart';

class WelcomePage extends StatelessWidget {
  AuthServices _auth = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple[800], // AppBar color
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));

              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase(), // Use lowercase for consistency in handling
                  child: Text(choice), // Directly use the string without capitalization
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.jpg',
                height: 150,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Welcome to Your PDF Chatbot!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PdfChatbotPage())); // Navigate to PdfChatbotPage
              },
              child: Text('Ask Me...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200], // Button color
                foregroundColor: Colors.purple[700], // Text color on button
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
