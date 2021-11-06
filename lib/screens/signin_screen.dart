// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_fn/screens/shownotes_screen.dart';
import 'package:flutter_notes_fn/screens/signup_screen.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:core';
import 'package:email_validator/email_validator.dart';

class SignIn extends StatefulWidget {
  const SignIn({ Key? key }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  var emailcont = TextEditingController();
  var passcont = TextEditingController();

  var _loading = false;

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _loading? Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ): Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            50.heightBox,
            "Welcome To NotesApp".text.textStyle(TextStyle(color: Colors.deepPurple,letterSpacing: 2,fontFamily: GoogleFonts.balooBhai().fontFamily)).xl4.make(),
            Image.asset("assests/images/Signin.png",),
            10.heightBox,
            "Sign In".text.textStyle(TextStyle(fontFamily: GoogleFonts.anticSlab().fontFamily)).xl4.make(),
            20.heightBox,
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: emailcont,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Enter email address";
                      }
                      else if(!EmailValidator.validate(value)){
                        return "Email is not valid";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.mail),
                      labelText: "Email Address",
                      hintText:"Enter your email"
                    ),
                  ),
                  10.heightBox,
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: passcont,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Enter password";
                      }
                      else if(value.length<6){
                        return "Length of password must be greater than 6";
                      }
                      return null;
                    },
                    autofocus: true,
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.lock_fill),
                      labelText: "Password",
                      hintText:"Enter your password"
                    ),
                  ),
                  30.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      "Don't have account?".text.xl.make(),
                      InkWell(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUp()));
                        },
                        child: " Sign Up".text.color(Colors.blue).xl.make(),
                      )
                    ],
                  ),
                  20.heightBox,
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                    ),
                    onPressed: () async{
                      if(_formkey.currentState!.validate()){
                        setState(() {
                          _loading = true;
                        });
                        var res = await AuthenticationService().signinemail(emailcont.text, passcont.text);
                        if(res=="Success"){
                          var _auth = FirebaseAuth.instance;
                          if(_auth.currentUser!.emailVerified){
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>AuthenticationWrapper())); // i have not used this because when i reflect the page to the authenwrapper then it gives error -> whenever we click on textformfield in updatenotes it refresh again and again  
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ShowNotes()),(route)=>false); 
                          }else{
                            await AuthenticationService().signout();
                            res = "Verify your Email";
                          }
                        }
                      setState(() {
                        _loading = false;
                      });   
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.toString().text.red400.make()));                 
                     }
                    },
                    child: "Sign In".text.xl.make()
                    ),
                ],
              ).px16()
              )  
          ],
        ),
      ),
    );
  }
}