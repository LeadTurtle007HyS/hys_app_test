import 'package:flutter/material.dart';

class MyNavigator {
  static void goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/home");
  }

  static void goToSignIn(BuildContext context,int index) {
    Navigator.popAndPushNamed(context, "/signin",arguments: index);
  }

  static void goToLoading(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/loading");
  }
}
