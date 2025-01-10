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
  bool _obscurePassword = true; 



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                  ),
                ),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), 
                  child: Image.asset('assets/images/logo.jpg', height: 100), 
                ),
                SizedBox(height: 20),
                
                SizedBox(height: 16), 
                
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                    prefixIcon: Icon(Icons.email), 
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                  controller: _emailcontroller,
                  onChanged: (value) => email = value,
                ),
                SizedBox(height: 16), 
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                    prefixIcon: Icon(Icons.lock), 
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword; 
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
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
                SizedBox(height: 16), 
                
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                    prefixIcon:
                    Icon(Icons.lock_outline), 
                    suffixIcon:
                    IconButton(
                      icon:
                      Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed:
                          () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword; 
                        });
                      },
                    ),
                  ),
                  obscureText:
                  _obscurePassword, 
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

