  // ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_realdb/screens/deleteaccount_screen.dart';
import 'package:flutter_notes_realdb/screens/editprofile_screen.dart';
import 'package:flutter_notes_realdb/screens/signin_screen.dart';
import 'package:flutter_notes_realdb/services/authentication.dart';
import 'package:velocity_x/velocity_x.dart';

class Drawerr extends StatefulWidget {

  final  namedocs;

  const Drawerr({ Key? key ,required this.namedocs}) : super(key: key);

  @override
  _DrawerrState createState() => _DrawerrState();
}


class _DrawerrState extends State<Drawerr> {

  final _auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
                    decoration: BoxDecoration(color: Vx.gray100),
                    child: FutureBuilder(
                      future: storage.ref("Notes/${_auth.currentUser!.email.toString().replaceAll(".", "")}").getDownloadURL(),
                      builder: (BuildContext context,AsyncSnapshot<String> snapshot){
                        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                          return UserAccountsDrawerHeader(
                              decoration: BoxDecoration(color: Colors.white),
                              currentAccountPicture: CircleAvatar(
                                // backgroundImage: NetworkImage(
                                //     'https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/05/21/17/workworkwork.jpg'),
                                backgroundImage: NetworkImage(
                                    snapshot.data!),
                              ),
                              accountName: Container(
                                      height: 30,
                                      alignment: Alignment.topRight,
                                      child: widget.namedocs["account"]["name"].toString().text.xl2.black.make())
                                  .px(4),
                              accountEmail: Container(
                                      height: 40,
                                      alignment: Alignment.topRight,
                                      child: _auth.currentUser!.email.toString().text.black.make()).px(4)
                          );
                        }
                        if(snapshot.connectionState==ConnectionState.done && !snapshot.hasData){
                          return UserAccountsDrawerHeader(
                              decoration: BoxDecoration(color: Colors.white),
                              currentAccountPicture: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/05/21/17/workworkwork.jpg'),
                                // backgroundImage: NetworkImage(
                                //     snapshot.data!),
                              ),
                              accountName: Container(
                                      height: 30,
                                      alignment: Alignment.topRight,
                                      child: widget.namedocs["account"]["name"].toString().text.xl2.black.make())
                                  .px(4),
                              accountEmail: Container(
                                      height: 40,
                                      alignment: Alignment.topRight,
                                      child: _auth.currentUser!.email.toString().text.black.make()).px(4)
                          );
                        }
                        return Container(
                          child: "Loading...".text.make(),
                        ).centered();
                      }
                    )
                       ).h(212),
            ListTile(
              leading:
                  Icon(CupertinoIcons.profile_circled, color: Colors.black),
              title: "Profile".text.xl.black.make().px24(),
              tileColor: Vx.gray200,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile()));
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.delete, color: Colors.black),
              title: "Delete Account".text.xl.black.make().px24(),
              tileColor: Vx.gray200,
              onTap: () {
                Navigator.pop(context);
                // AuthenticationService().deleteuser();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccount()));
              },
            ).py2(),
            ListTile(
              leading: Icon(CupertinoIcons.person_2, color: Colors.black),
              title: "Sign out".text.xl.black.make().px24(),
              tileColor: Vx.gray200,
              onTap: () {
                AuthenticationService().signout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignIn()),(route)=>false);
              },
            )
          ],
        ).py16(),
      ),
    );
  }
}