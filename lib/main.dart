// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_fn/screens/shownotes_screen.dart';
import 'package:flutter_notes_fn/screens/signup_screen.dart';
import 'package:flutter_notes_fn/services/authentication.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ErrorWidget.builder = (FlutterErrorDetails details) => Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshots) {
          if (snapshots.hasError) {
            return MaterialApp(
              home: Scaffold(body: Center(child: Text("Error"))));
          }

          if (snapshots.connectionState == ConnectionState.done) {
            var streamProvider = StreamProvider<User?>.value(
                // if we use <User?> then we have to manually navigate the screen to AuthenticationWrapper because it does update by itself and if we use <User> then no need to navigate it will automatically happen
                value: AuthenticationService().userState,
                initialData: null,
                child: AuthenticationWrapper());
            return streamProvider;
          }

          return CircularProgressIndicator();
        });
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({ Key? key }) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {

  // @override
  // void initState() {
  //   super.initState();
  //   AuthenticationService().signout();
  // }
  @override
  Widget build(BuildContext context) {

    final _auth = FirebaseAuth.instance;
    final user = Provider.of<User?>(context);

    if (user == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false, 
        home: AnimatedSplashScreen(
          splashIconSize: 220,
          duration: 3500,
          splash: Lottie.asset("assets/images/notes_splash_ani.json"),
          splashTransition: SplashTransition.sizeTransition,
          animationDuration: Duration(seconds: 2),
          nextScreen: SignUp())
      ); 
    } 
    else if (_auth.currentUser!.emailVerified) { // use this condition here to prevent the user show the home screen when user back the screen
      return MaterialApp(
        themeMode: ThemeMode.light,
        darkTheme: ThemeData(brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        home: ShowNotes(),
      );
    } 
    else {
      return MaterialApp(debugShowCheckedModeBanner: false, 
      home: AnimatedSplashScreen(
          splashIconSize: 220,
          duration: 3500,
          splash: Lottie.asset("assets/images/notes_splash_ani.json"),
          splashTransition: SplashTransition.sizeTransition,
          animationDuration: Duration(seconds: 2),
          nextScreen: SignUp()));
    }
  }
}