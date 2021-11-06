import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_realdb/main.dart';
import 'package:flutter_notes_realdb/screens/shownotes_screen.dart';
import 'package:flutter_notes_realdb/screens/signup_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';

class EmailVerify extends StatefulWidget {
  final String email;
  const EmailVerify({ Key? key , required this.email}) : super(key: key);

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {

  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkemailverify();
     });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  checkemailverify() async{
    var _auth = FirebaseAuth.instance;
    await _auth.currentUser!.reload();
    if(_auth.currentUser!.emailVerified){
      timer.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ShowNotes()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: "Email Verification Page".text.black.xl3.make().centered(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset("assests/images/Emailsent.png"),
              "Email Verification Link has been sent to your email address ".text.gray500.xl.make().px16().py12(),
              widget.email.text.color(Colors.blue).xl2.make().px16(),
              " Please, Verify the Email to Sign In...".text.xl.make().px16().py12(),
            ],
          ).py64(),
        ),
      ),
    );
  }
}