import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finel_project/PdfChatbotPage.dart';
import 'package:my_finel_project/Services/auth.dart';
import 'package:my_finel_project/WelcomePage.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  AuthServices _auth = AuthServices();


  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose

    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }




  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool _obscurePassword = true; // To toggle password visibility



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set a slightly darker background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:Center(// Use SingleChildScrollView to prevent overflow
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Return Arrow Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous page
                    },
                  ),
                ),
                // Displaying the chatbot image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Rounded corners for the image
                  child: Image.asset('assets/images/logo.jpg', height: 100), // Adjust height as needed
                ),
                SizedBox(height: 20),
                
                SizedBox(height: 16), // Space between fields
                // Email TextField with icon
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for text field
                    prefixIcon: Icon(Icons.email), // Icon for email
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                  controller: _emailcontroller,
                  onChanged: (value) => email = value,
                ),
                SizedBox(height: 16), // Space between fields
                // Password TextField with eye icon and prefix icon
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for text field
                    prefixIcon: Icon(Icons.lock), // Icon for password
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword, // Use the toggle for password visibility
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  controller: _passwordcontroller,
                  onChanged: (value) => password = value,
                ),
                SizedBox(height: 16), // Space between fields
                // Confirm Password TextField with eye icon and prefix icon
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for text field
                    prefixIcon:
                    Icon(Icons.lock_outline), // Icon for confirm password
                    suffixIcon:
                    IconButton(
                      icon:
                      Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed:
                          () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                  obscureText:
                  _obscurePassword, // Use the toggle for password visibility
                  validator:
                      (value) {
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height:
                20),
                ElevatedButton(onPressed:
                signUp, child:
                Text('Sign Up')),
              ],
            ),
          ),)
        ),
      ),
    );
  }
  signUp() async{
   final user = await _auth.signUpWithEmailAndPassword(_emailcontroller.text, _passwordcontroller.text);
   if (user != null) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signing Up...')));
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()));
   } else {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign up. Please try again.')));
   }
  }
}

