// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_notes_fn/screens/addnotes_screen.dart';
import 'package:flutter_notes_fn/screens/updatenotes_screen.dart';
// import 'package:flutter_notes/widgets/drawer.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:flutter_notes_fn/widgets/drawer.dart';
import 'package:velocity_x/velocity_x.dart';

class ShowNotes extends StatefulWidget {
  const ShowNotes({Key? key}) : super(key: key);

  @override
  _ShowNotesState createState() => _ShowNotesState();
}

class _ShowNotesState extends State<ShowNotes> {

  final _auth = FirebaseAuth.instance;

  late DatabaseReference _dbref;
  @override
  void initState() {
    _dbref = FirebaseDatabase.instance.reference();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
  var nmeail = _auth.currentUser!.email!.replaceAll(".", "");
  final Stream<Event> db = _dbref.child(nmeail).onValue; // onvalue listen whenever value of child changes

    return StreamBuilder<Event>(
      stream: db,
      builder: (BuildContext context,AsyncSnapshot<Event> snapshot){
        if(snapshot.hasError){
          return Scaffold(body: Center(child: "Error".text.make(),));
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            body: Center(child: CircularProgressIndicator(),));
        }

        final List storedocs = [];
        final issearch = ValueNotifier<String>("");
        var namedocs;
        List searchdocs = [];

        // this is how we can convert the data comming from realdatabase in the form of _InternalLinkedHashMap<Object?, Object?> into list
        Map<dynamic,dynamic> m = snapshot.data!.snapshot.value;

        m.forEach((key, value) {
          if(key != "account"){
            Map<String,dynamic> a = {
              "docs":[key,value]
            };
            storedocs.add(a);
          }
          else{
            Map<String,dynamic> a ={
              key:value
            };
            namedocs=a;
          }
        });

        showsearchdocs(searchvalue){
          searchdocs = [];
          for(var doc in storedocs){
            if(doc["docs"][1]["title"].toString().contains(searchvalue)){
              searchdocs.add(doc);
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 2,
            title: "Your Notes".text.xl3.black.make(),
          ),
          floatingActionButton: SizedBox(
            width: 55,
            height:55,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
                )),
                elevation: MaterialStateProperty.all(0),
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNotes()));
                // AuthenticationService().signout();
              },
              child: Icon(CupertinoIcons.add,size: 35,),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (e){
                    if(e.isNotEmpty){
                      showsearchdocs(e);
                      issearch.value = e;
                    }
                    else{
                      issearch.value = "";
                    }
                  },
                  cursorColor: Colors.black,
                  style: TextStyle(fontSize: 20, letterSpacing: 2),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(letterSpacing: 2, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          // use focused border to fix the border
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.black)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: "Search by title"),
                ).h(40).px16().py(3),
               storedocs.isEmpty? Column(
                 children: [
                   270.heightBox,
                   Center(
                     child: "You Have not added any notes yet...".text.gray500.xl2.make().py32().px12()
                   ),
                 ],
               ) :
               ValueListenableBuilder(
                 valueListenable:  issearch,
                 builder: (BuildContext context, String value, Widget? child) {
                   
                  return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: value.isNotEmpty? searchdocs.length : storedocs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2
                      ),
                      itemBuilder: (context,index){
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateNotes(id:value.isNotEmpty? searchdocs[index]["docs"][0] :storedocs[index]['docs'][0],)));
                          },
                          child: Card(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: value.isNotEmpty ?searchdocs[index]["docs"][1]["title"].toString().text.xl.make(): storedocs[index]["docs"][1]["title"].toString().text.xl.make(),
                                  ),
                                  Divider(),
                                  value.isNotEmpty? searchdocs[index]["docs"][1]["body"].toString().text.make().px(6) :storedocs[index]["docs"][1]["body"].toString().text.make().px(6)
                                ],
                              ),
                            ),
                            color: Vx.gray300,
                          ),
                        );
                      }).px(2).py(4);
                 },
               ),
               
              ],
            ),
          ),
          drawer: Drawerr(namedocs: namedocs,)
        );
  });

  }
}
