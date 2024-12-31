import'package:firebase_auth/firebase_auth.dart';

class AuthServices{

  final FirebaseAuth  _auth = FirebaseAuth.instance; // This is an object to connect with the firebase

   Future<User?> signUpWithEmailAndPassword(String email,String password) async{

     try{
       UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
       return credential.user;

     } catch(e){
       print("Some Error Occured");
     }

     return null;
   }
  Future<User?> signInWithEmailAndPassword(String email,String password) async{

    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;

    } on FirebaseAuthException catch (e) {
    // Pass FirebaseAuthException back to the caller
    throw e;
    } catch (e) {
    // Handle any other errors (optional)
    throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> signOut() async{
     try{
      await _auth.signOut();
     } catch(e){
       print("Something Wrong!");
     }

  }

}