// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class UpdateNotes extends StatefulWidget {

  final String id;
  const UpdateNotes({ Key? key,required this.id }) : super(key: key);

  @override
  _UpdateNotesState createState() => _UpdateNotesState();
}

class _UpdateNotesState extends State<UpdateNotes> {

  late DatabaseReference _dbref;

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.reference();
  }

  String titlec = "";
  String bodyc = "";
  String title = "";
  String body = "";


  var titlechanged = true;
  var bodychanged = true;

  // if to rebuild the single widget use valuenotifier
  //                                <type>(initial_value);
  final netchanged = ValueNotifier<bool>(true);

  @override
  void dispose() {
    netchanged.dispose();
    super.dispose();
  }


  checkchange(){
    if(titlechanged== true && bodychanged == true){
      netchanged.value = true; // value change
    }
    else{
      netchanged.value = false;
    }
  }

  final _auth = FirebaseAuth.instance;

  updatenote(){
    var nemail = _auth.currentUser!.email!.replaceAll(".", "");
    _dbref.child(nemail).child(widget.id).update({
      "title" : titlec,
      "body" : bodyc
    });
  }

  deletenote(){
    var nemail = _auth.currentUser!.email!.replaceAll(".", "");
    _dbref.child(nemail).child(widget.id).remove();
  }


  @override
  Widget build(BuildContext context) {
    var nemail = _auth.currentUser!.email!.replaceAll(".", "");
    return Scaffold(
      appBar:AppBar(
        actions: [ 
          ValueListenableBuilder( // use when to rebuild single widget
            valueListenable: netchanged,
            builder: (BuildContext context, dynamic value, Widget? child) {
              return  value? IconButton(
                splashRadius:1,
                onPressed: (){
                  updatenote();
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.check)) : "null".text.make().centered().px(12.5);
            },
          ),
          IconButton(
            splashRadius: 1,
            onPressed: (){
              deletenote();
              Navigator.pop(context);
          },
          icon: Icon(Icons.delete)),
        ],
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: "Update Notes".text.xl3.black.make().centered(),
      ),
      body: FutureBuilder<DataSnapshot>(
        future: _dbref.child(nemail).child(widget.id).once(),
        builder: (_,snapshot){
          if(snapshot.hasError){
            return Center(child: "Error".text.make(),);
          }

          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          var data = snapshot.data!.value;
          var title = data["title"];
          var body = data["body"];
          titlec = title;
          bodyc = body;

          return SingleChildScrollView(
                child: Column(
                  children:[
                    TextFormField(
                      initialValue: title,
                      onChanged: (e){
                        if(e.isNotEmpty){
                            titlechanged = true;
                            checkchange();
                        }
                        else{
                            titlechanged = false;
                            checkchange();
                        }
                        titlec = e;
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
                      initialValue: body,
                      onChanged: (e){
                        if(e.isNotEmpty){
                            bodychanged = true;
                            checkchange();
                        }
                        else{
                            bodychanged = false;
                            checkchange();
                        }
                        bodyc = e;
                      },
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
              );
        },),

    );
  }
}