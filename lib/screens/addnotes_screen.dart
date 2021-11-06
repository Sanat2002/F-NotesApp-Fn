// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({ Key? key }) : super(key: key);

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {

  late DatabaseReference _dbref;
  
  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.reference();
  }

  var titlecont = TextEditingController();
  var bodycont = TextEditingController();

  var titlechanged = false;
  var bodychanged = false;
  var netchanged = false;

  checkchange(){
    if(titlechanged== true && bodychanged == true){
      netchanged = true;
    }
    else{
      netchanged = false;
    }
  }

  final _auth = FirebaseAuth.instance;

  addnotes(){
    var nemail = _auth.currentUser!.email!.replaceAll(".", "");
    _dbref.child(nemail).push().set({ // push() -> creats new child with unique key
      "title":titlecont.text,
       "body":bodycont.text
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        actions: [ // it displays at the right side
          netchanged? IconButton(// use icon button
            splashRadius: 1,
            icon: Icon(Icons.check),
            onPressed: (){
              addnotes();
              Navigator.pop(context);
            },
          ) : "null".text.make().centered().px(12.5),
        ],
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: "Add Notes".text.xl3.black.make().centered(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children:[
            TextFormField(
              controller: titlecont,
              onChanged: (e){
                if(e.isNotEmpty){
                  setState(() {
                    titlechanged = true; 
                    checkchange();     
                  });
                }
                else{
                  setState(() {
                    titlechanged = false;
                    checkchange();
                  });
                }
              },
              cursorColor: Colors.black,
              cursorRadius: Radius.circular(5),
              style: TextStyle(
                fontSize: 23
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent
                  )
                ),
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent
                  )) ,
                hintText: "Title : -"
              ),
            ),
            TextFormField(
              onChanged: (e){
                if(e.isNotEmpty){
                  setState(() {
                    bodychanged = true;
                    checkchange();
                  });
                }
                else{
                  setState(() {
                    bodychanged = false;
                    checkchange();
                  });
                }
              },
              controller:bodycont,
              style: TextStyle(
                fontSize: 19
              ),
              cursorColor: Colors.black45,
              cursorRadius: Radius.circular(8),
              maxLines: 30, // use it when to convert textfield into textarea
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent
                  )
                ),
                enabledBorder:  OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent
                  )
                ),
                hintText: "Body : -"
              ),
            )
          ]
        ).px(4),
      ), 
    );
  }
}