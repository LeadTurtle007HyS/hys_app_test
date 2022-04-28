import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hys/database/questionSection/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackGCause extends StatefulWidget {
  @override
  _BackGCauseState createState() => _BackGCauseState();
}

CrudMethods obj = CrudMethods();
var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;

class _BackGCauseState extends State<BackGCause> {
  QuerySnapshot userData;
  @override
  void initState() {
    obj.getUserData().then((value) {
      setState(() {
        userData = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  _body() {
    if (userData != null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: ListView(physics: BouncingScrollPhysics(), children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: null,
                icon: Tab(
                    child: Icon(Icons.cancel, color: Colors.black45, size: 20)),
              ),
              Text(
                'Create',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 17,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(88, 165, 196, 1),
                      borderRadius: BorderRadius.circular(3)),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.only(
                  left: (10.0), right: 10, top: 10, bottom: 10),
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(242, 246, 248, 1),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    child: Image.network(
                                        userData.docs[0].get('profilepic'))),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    userData.docs[0].get('firstname') +
                                        ' ' +
                                        userData.docs[0].get('lastname'),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    )),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color.fromRGBO(
                                                88, 165, 196, 1)),
                                        borderRadius: BorderRadius.circular(3)),
                                    margin: EdgeInsets.all(3),
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.group,
                                            color: Colors.black87,
                                            size: 11,
                                          ),
                                          Text(
                                            ' Friends ',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 12,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_downward,
                                            color: Colors.black87,
                                            size: 11,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 60,
                      child: TextField(
                        minLines: 2,
                        maxLines: 15,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Color.fromRGBO(88, 165, 196, 1),
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'Write about your cause...',
                            hintStyle: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 17,
                              color: Colors.black26,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ),
                  ],
                )
              ]))
        ]))
      ]);
    } else
      return _loading();
  }

  Widget _loading() {
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

  YYDialog moreButtonForViewer(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
          height: MediaQuery.of(context).size.height / 2,
          margin: EdgeInsets.only(left: 2, right: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(physics: BouncingScrollPhysics(), children: [
                InkWell(
                    onTap: null,
                    child: Container(
                      height: 65,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.ac_unit,
                            color: Color.fromRGBO(88, 165, 196, 1),
                            size: 25,
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mood',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Tell others about your mood!',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))
              ]))))
      ..show();
  }
}
