import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finel_project/PdfChatbotPage.dart';
import 'package:my_finel_project/Services/auth.dart';
import 'package:my_finel_project/SignUpPage.dart';
import 'package:my_finel_project/WelcomePage.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
  String email = '';
  String password = '';
  bool _obscurePassword = true; 



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      body:Center(
        child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), 
                  child: Image.asset('assets/images/logo.jpg', height: 100), 
                ),
                SizedBox(height: 20),
                
                Text(
                  "Welcome Back!", 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800], 
                  ),
                ),
                SizedBox(height: 20), 
                
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
                    }
                    return null;
                  },
                  onChanged: (value) => password = value,
                  controller: _passwordcontroller,
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: logIn, child: Text('Log In')),
                SizedBox(height: 20),
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),)
        ),

    ));
  }
   logIn() async{
     try {
       final user = await _auth.signInWithEmailAndPassword(_emailcontroller.text, _passwordcontroller.text);
       if (user != null) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logging In...')));
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()));
       }
     } on FirebaseAuthException catch (e) {
       
       String message;
       if (e.code == 'invalid-email') {
         message = 'The email address is not valid.';
       } else if (e.code == 'invalid-credential') {
         message = 'Wrong password.';
       } else {
         message = 'An error occurred. Please try again.';
       }

       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
     } catch (e) {
       
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred.')));
     }

}}