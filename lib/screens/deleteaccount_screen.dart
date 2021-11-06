// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_notes_fn/screens/signin_screen.dart';
import 'package:flutter_notes_fn/screens/signup_screen.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:velocity_x/velocity_x.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({ Key? key }) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {

  late DatabaseReference _dbref;
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.reference();
  }

  final _formkey = GlobalKey<FormState>();

  var _loading = false;

  final _auth = FirebaseAuth.instance; // _auth cannot be accessed in initializer

  deleteimage(useremail) async{
    var nemail = useremail.toString().replaceAll(".", "");

    try{
      await storage.ref("Notes/$nemail").delete();
    } on FirebaseException catch(e){
      print(e);
    }
  }

  deleteaccount(useremail){
    var nemail = useremail.toString().replaceAll(".", "");

    _dbref.child(nemail).remove();
  }

  @override
  Widget build(BuildContext context) {   
    return _loading? Scaffold(body:Center(child: CircularProgressIndicator(),))
    :Scaffold(
      backgroundColor: Vx.gray400,
      body: Center(
        child: Card(
          child: Column(
            children: [
              "Delete Account".text.xl4.make(),
              Divider(thickness: 3,),
              "Are you serious about deleting account ? 🤨".text.textStyle(TextStyle(fontSize: 16)).make(),
              20.heightBox,
              "Enter your mail id to confirm deletion...".text.xl.make(),
              20.heightBox,
              Form(
                key: _formkey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your email"
                  ),
                  validator: (value){
                    if(value!=_auth.currentUser!.email){
                      return "Check email address";
                    }
                    return null;
                  },
                ).px(20 ),
              ),
              40.heightBox,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: "Cancle".text.make()
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)
                    ),
                    onPressed: () async {
                      if(_formkey.currentState!.validate()){
                        setState(() {
                          _loading = true;
                        });
                        final useremail = _auth.currentUser!.email;
                        var res = await AuthenticationService().deleteuser();
                        if(res=="ReSign"){
                          AuthenticationService().signout();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: "You have to SignIn again to Delete Account...".text.red400.make()));  
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignIn()), (route) => false);
                        }
                        else{
                          await deleteimage(useremail);
                          deleteaccount(useremail);
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignUp()),(route)=>false);
                        }
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
                    child: "Delete".text.white.make()
                  ),
                ],
              )
            ],
          ).px(10),
        ).wh(350, 300),
      ),
    );
  }
}