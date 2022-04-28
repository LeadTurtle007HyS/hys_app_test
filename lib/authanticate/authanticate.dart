import 'package:flutter/material.dart';
import 'package:hys/authanticate/signin.dart';
import 'package:hys/authanticate/signup.dart';

//This page is used to toggle between two pages like sign in or sign up

class Authanticate extends StatefulWidget {
  @override
  _AuthanticateState createState() => _AuthanticateState();
}

class _AuthanticateState extends State<Authanticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  //Don't remove the bellow mentioned code which is commited. It is used for
  //release mode of apk where we need to use only phone authentication

//   @override
//   Widget build(BuildContext context) {
//     if (showSignIn) {
//       return SignInWithMobileNumber();
//     } else {
//       return SignInWithMobileNumber();
//     }
//   }
// }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignInPage(toggleView: toggleView);
    } else {
      return SignupPage(toggleView: toggleView);
    }
  }
}
