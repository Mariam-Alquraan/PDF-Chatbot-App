import 'package:flutter/material.dart';
import 'package:my_finel_project/SighInPage.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyB6o5_H6t051asX8EtvHJCGmUUDS1QkWNY",
      appId: "1:674626588757:android:7905e6abdf5659044cc4dc",
      messagingSenderId: "674626588757",
      projectId: "pdf-chatbot-c7384",
      storageBucket: "pdf-chatbot-c7384.firebasestorage.app",
      databaseURL: "https://pdf-chatbot-c7384.firebaseio.com",
    ),);
  } catch(e){
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(secondary: Colors.purpleAccent),
        textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.purple[800]),
            bodyMedium: TextStyle(color: Colors.purple[600]),

        ),
      ),
      home: LoginPage(), // Set LoginPage as the first screen
    );
  }
}