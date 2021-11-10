import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // getting current state of user
  Stream<User?> get userState {
    // <User?> -> this is to be used (it may shuffle b/w (<User> or <User?>))
    return _auth.userChanges();
  }

  // sign in with email
  Future signinemail(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return  "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided for that user.";
      }
      else{
        return "Error";
      }
    }
  }

  // sign up with email
  Future signupemail(email, password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _auth.currentUser!.sendEmailVerification();  // don't use await -> it causes error
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      }
      else{
        return "Error";
      }
    }
  }

  // updating email
  Future updateemail(nemail) async{
    try{
      await _auth.currentUser!.updateEmail(nemail);
      return "Success";
    } on FirebaseAuthException catch(e){
      if(e.code=="requires-recent-login"){
        return "ReSignin";
      }
      return "fail";
    }
  }

  // update password
  Future updatepass(npass) async{
    try {
      await _auth.currentUser!.updatePassword(npass);
      return "Success";
    }on FirebaseAuthException catch (e) {
      return "ReSign";
    }
  }

  // sign out
  Future signout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  // delete user
  Future deleteuser() async{
    try{
      await _auth.currentUser!.reload();
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch(e){
      if (e.code == 'requires-recent-login') {
        return "ReSign";
      }
    }
  }
}
