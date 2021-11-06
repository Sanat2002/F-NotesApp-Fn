// ignore_for_file: prefer_const_constructors
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_fn/main.dart';
import 'package:flutter_notes_fn/screens/emailverify_screen.dart';
import 'package:flutter_notes_fn/screens/signin_screen.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:core';
import 'package:email_validator/email_validator.dart';

class SignUp extends StatefulWidget {
  const SignUp({ Key? key }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

    late DatabaseReference _dbref;

  @override
  void initState() {
    _dbref = FirebaseDatabase.instance.reference();
    super.initState();
  }

  var emailcont = TextEditingController();
  var passcont = TextEditingController();
  var namecont = TextEditingController();

  var _loading = false;

  final _formkey = GlobalKey<FormState>();


  makenewchild(){
    var nemail = emailcont.text.replaceAll(".", "");
    _dbref.child(nemail).set({
      "account":{
        "name" : namecont.text,
        "password":passcont.text,
        "emailchangecount":0,
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    

    return _loading? Scaffold(
      body: Center(child: CircularProgressIndicator())
    ) : Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            50.heightBox,
            "Welcome To NotesApp".text.textStyle(TextStyle(color: Colors.deepPurple,letterSpacing: 2,fontFamily: GoogleFonts.balooBhai().fontFamily)).xl4.make(),
            Image.asset("assests/images/Signup.png",),
            10.heightBox,
            "Sign Up".text.textStyle(TextStyle(fontFamily: GoogleFonts.anticSlab().fontFamily)).xl4.make(),
            20.heightBox,
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: namecont,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Username shouldn't be empty";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    autofocus: true,
                    decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.person),
                      labelText: "Username",
                      hintText:"example : Sweeney Todd"
                    ),
                  ),
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
                      hintText:"someone@domain.ext"
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
                      icon:Icon(CupertinoIcons.lock_fill),
                      labelText: "Password",
                      hintText:"minimum 6 char.."
                    ),
                  ),
                  30.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      "Already have account?".text.xl.make(),
                      InkWell(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignIn()));
                        },
                        child: " Sign In".text.color(Colors.blue).xl.make(),
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
                          _loading=true;
                        });
                        var res = await AuthenticationService().signupemail(emailcont.text, passcont.text);
                        if(res=="Success"){
                          makenewchild();
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EmailVerify(email: emailcont.text)));
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>AuthenticationWrapper()));
                          // i have not used this because when i reflect the page to the authenwrapper then it gives error -> whenever we click on textformfield in updatenotes it refresh again and again 
                        }
                        setState(() {
                            _loading= false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.toString().text.red400.make())); 
                      }
                    },
                    child: "Sign Up".text.xl.make()),
                ],
              ).px16()
              )  
          ],
        ),
      ),
    );
  }
}