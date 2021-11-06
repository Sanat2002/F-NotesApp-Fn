// ignore_for_file: prefer_const_constructors

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_fn/screens/emailverify_screen.dart';
import 'package:flutter_notes_fn/screens/signin_screen.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({ Key? key }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  late DatabaseReference _dbref;
  late FirebaseStorage storage;

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.reference();
    storage = FirebaseStorage.instance;
  }

  final _auth =  FirebaseAuth.instance;

  var cname = "";
  var cemail = "";
  var cpass = "";
  var changed = "";
  var tochangeemail = "";
  var tochangepass = "";
  var emailchangecount=0;
  var name = "";
  var password = "";
  var filepath = null;

 final _formkey = GlobalKey<FormState>();


  updateaccount(){
    var nemail = _auth.currentUser!.email!.replaceAll(".", "");
    _dbref.child(nemail).child("account").update({
      "name" : cname,
      "password":cpass,
      "emailchangecount" : emailchangecount
    });
  }

  changeemail() async{
    var nemail = tochangeemail.replaceAll(".", "");
    var ncemail = _auth.currentUser!.email!.replaceAll(".", "");
    await _dbref.child(nemail).once().then((DataSnapshot dataSnapshot) {
      _dbref.child(ncemail).set(dataSnapshot.value);
    });
    _dbref.child(nemail).remove();
  }

  imagepick() async{
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions:['png','jpg'],
      type: FileType.custom
    );
    if(result == null){
      return null;
    }
    filepath = result.files.single.path;
  }

  uploadimage() async{
    var nemail = tochangeemail.replaceAll(".", "");

    try{
      await storage.ref("Notes/$nemail").delete();
    } on FirebaseException catch(e){
      print(e); // return statement is not used here because if we use then function will exit here and rest code will we dead
    }

    File file = File(filepath);

    try{
      await storage.ref("Notes/$nemail").putFile(file);
    } on FirebaseException catch(e){
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
  var nemail = _auth.currentUser!.email!.replaceAll(".", "");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 1,
          onPressed: (){
            Navigator.pop(context);
          },
          icon:Icon(CupertinoIcons.multiply )),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor:Colors.white,
        title: "Edit Profile".text.xl3.black.make().centered(),
        actions: [
          IconButton(
            splashRadius: 1,
            onPressed: () async{
              var res1="",res2="";
              if(_formkey.currentState!.validate()){
                if(filepath!=null){
                  await uploadimage();
                }
                updateaccount();
                if(cemail!=tochangeemail && emailchangecount==0){
                  res1 = await AuthenticationService().updateemail(cemail);
                  emailchangecount = 1;
                }
                if(cpass!=tochangepass){
                  res2 = await AuthenticationService().updatepass(cpass);
                }
                if(res2=="ReSign"){
                  await AuthenticationService().signout();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignIn()), (route) => false);
                }
                if(res1 == "Success"){
                   await changeemail();
                    updateaccount();
                    _auth.currentUser!.sendEmailVerification();
                    
                    // watch the video saved in app-development-> there are many more method of changing routes
                    // this method push to the given context and remove all the other routes instead of first route
                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>EmailVerify(email: cemail)), (route) => route.isFirst);

                    // this method push to the given context and remove all the other routes
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>EmailVerify(email: cemail)), (route) => false);
                    
                    // this method replace the current route with given route
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmailVerify(email: cemail)));

                    changed = "Profile Updation is in Process";
                }
                else if(res1==""){
                  changed = "Profile Updated";
                }
                else if(res1!="Success"){
                  changed = "Provided Email may be already registered...";
                }
                else{
                  changed = "Profile Updated";
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: changed.text.red400.make())); 
              Navigator.pop(context);
            },
             icon: Icon(Icons.check))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: storage.ref("Notes/$nemail").getDownloadURL(),
              builder: (BuildContext context,AsyncSnapshot<String> snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                  return  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        child: CircleAvatar(
                          backgroundImage:NetworkImage(snapshot.data!),
                          backgroundColor: Colors.white,),
                      ).py32(),
                      Padding(
                        padding: const EdgeInsets.only(top: 180,right: 0),
                        child: IconButton(
                          splashRadius: 1,
                          onPressed: () async{
                            await imagepick();
                            if(filepath!=null){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: "Image Selected! Press tick button to upload image...".text.red400.make())); 
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: "Please Select image...".text.red400.make())); 
                            }
                          },
                           icon: Icon(Icons.camera,size: 40,)),
                      )
                    ],
                  );
                }
                if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        child: CircleAvatar(
                          backgroundColor:Colors.white,
                          backgroundImage:NetworkImage('https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/05/21/17/workworkwork.jpg'),
                      )).py32(),
                      Padding(
                        padding: const EdgeInsets.only(top: 180,right: 0),
                        child: IconButton(
                          splashRadius: 1,
                          onPressed: () async{
                            await imagepick();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: "Image Selected! Press tick button to upload image...".text.red400.make()));
                          },
                           icon: Icon(Icons.camera,size: 40,)),
                      )
                    ],
                  );
                }

                return CircularProgressIndicator();
              }),

            FutureBuilder<DataSnapshot>(
              future: _dbref.child(nemail).child("account").get(),
              builder: (_,snapshot){
                if(snapshot.hasError){
                  return Center(child: "Error".text.make(),);
                }

                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }

                if(snapshot.connectionState==ConnectionState.done){
                var data = snapshot.data!.value;
                var name = data["name"];
                var password = data["password"];
                emailchangecount = data["emailchangecount"];

                cname = name;
                cpass = password;
                cemail = _auth.currentUser!.email.toString();
                tochangeemail = _auth.currentUser!.email.toString();
                tochangepass = password;

                return SingleChildScrollView(
                      child:Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (e){
                                cname = e;
                              },
                              initialValue:name,
                              cursorColor: Vx.gray400,
                              autovalidateMode:AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                label: "Edit Username".text.black.make(),
                                hintText: "New username"
                              ),
                              validator: (value){
                                if(value!.isEmpty){
                                  return "Username shouldn't be empty";
                                }
                                return null;
                              },
                            ),
                            20.heightBox,
                            TextFormField(
                              enabled: emailchangecount == 0 ? true : false,
                              initialValue: _auth.currentUser!.email,
                              onChanged: (e){
                                cemail = e;
                              },
                              cursorColor: Vx.gray400,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                label: "Edit Email".text.black.make(),
                                hintText: "New email"
                              ),
                              validator: (value){
                                if(!EmailValidator.validate(value.toString())){
                                  return "Enter correct email";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              width: 320,
                              child: emailchangecount == 0? "Note : You can only change the email once".text.red400.xs.make(): "You are not able to change the email".text.red400.xs.make()),
                            30.heightBox,
                            TextFormField(
                              onChanged: (e){
                                cpass = e;
                              },
                              cursorColor: Vx.gray400,
                              initialValue: password,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent
                                  )
                                ),
                                label: "Edit Password".text.black.make(),
                                hintText: "New password"
                              ),
                              validator: (value){
                                if(value!.isEmpty){
                                  return "New password";
                                }
                                else if(value.length<6){
                                  return "Length of password must be greater than 6";
                                }
                                return null;
                              },
                            )
                          ],
                        ).px24().py24(),
                      )
                    );
                }
                return Center(child: CircularProgressIndicator(),);
              },),
          ],
        ),
      ),
    );
  }
}