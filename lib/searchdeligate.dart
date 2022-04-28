import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Test1 extends StatefulWidget {
  @override
  _Test1State createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
          ))),
    );
  }

  File _image;
  bool isCamera;
  Future getImage(isCamera) async {
    File image;
    if (isCamera) {
      // ignore: deprecated_member_use
      image = (await ImagePicker.platform.getImage(source: ImageSource.camera)) as File;
      setState(() {
        _image = image;
      });
    }
    /* else {
      // ignore: deprecated_member_use
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }*/

    if (_image != null) {
      isCamera = false;
    }
  }

  int key = 0;
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'zero'),
    Tab(child: Icon(Icons.camera)),
    Tab(text: 'First'),
    Tab(text: 'Second'),
  ];
  _body() {
    return Stack(
      children: [
        TabBarView(
            children: myTabs.map((Tab tab) {
          if (key == 0) {
            return Container(child: Text("0 Page"));
          }
          if (key == 1) {
            if (_image != null) {
              return Container(child: Image.file(_image));
            } else {
              getImage(true);
              return Container(child: Text("heloo"));
            }
          }
          if (key == 2) {
            return Container(child: Text("Second Page"));
          }
          if (key == 3) {
            return Container(child: Text("3rd page"));
          }
          //final String label = tab.text.toString();
        }).toList())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var wd = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: myTabs.length,
        // The Builder widget is used to have a different BuildContext to access
        // closest DefaultTabController.
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              setState(() {
                key = tabController.index;
              });

              // Your code goes here.
              // To get index of current tab use tabController.index
            }
          });
          return Scaffold(
              appBar: AppBar(
                  title: Text("Home"),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(context: context, delegate: DataS());
                        })
                  ],
                  bottom: TabBar(
                    tabs: myTabs,
                  )),
              drawer: Drawer(),
              body: _body());
        }));
  }
}

class DataS extends SearchDelegate<String> {
  final list = [
    "Vivan",
    "Pratyush",
    "Prateek",
  ];
  final recent = ["Vivan"];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  // ignore: missing_return
  Widget buildResults(BuildContext context) {
    return Container(child: Text(query));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? recent
        : list.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
            onTap: () {
              showResults(context);
            },
            leading: Icon(Icons.people),
            title: RichText(
                text: TextSpan(
                    text: suggestions[index].substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                  TextSpan(
                      text: suggestions[index].substring(query.length),
                      style: TextStyle(color: Colors.grey))
                ]))),
        itemCount: suggestions.length);
  }
}
