import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hys/utils/mynavigator.dart';
import 'package:hys/authanticate/signin.dart';

class Splash extends StatefulWidget {

final int index;

  const Splash({Key key, this.index}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () => MyNavigator.goToSignIn(context,widget.index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(88, 165, 196, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/hysnew.png",
                height: 250,
                width: 250,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
