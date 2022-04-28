import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'controllers/settings_controller.dart';
import 'create_podcast_page.dart';


class LoadingPage extends StatefulWidget {
  const LoadingPage({Key key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    Record().hasPermission();
    startTime();
    super.initState();

  }

    startTime() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, route);
  }
route() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => PodcastPage()
      )
    ); 
  }
  

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Provider.of<SettingsController>(context);
    settingsController.init();
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
