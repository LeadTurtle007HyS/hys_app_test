import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:hys/notification_pages/notificationDB.dart';
import 'package:hys/utils/permissions.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MyNotifications extends StatefulWidget {
  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications>
    with SingleTickerProviderStateMixin {
  List<dynamic> allNotificationData = [];
  Box<dynamic> allNotificationLocalDB;
  Box<dynamic> userDataDB;
  ScrollController _scrollController;
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  TabController _tabController;
  NotificationDB notificationDB = NotificationDB();
  QuerySnapshot allConnections;
  CrudMethods crudobj = CrudMethods();
  DataSnapshot tokenData;

  void initState() {
    allNotificationLocalDB = Hive.box<dynamic>('allnotifications');
    userDataDB = Hive.box<dynamic>('userdata');
    _fetchData();
    crudobj.getUserConnection().then((value) {
      setState(() {
        allConnections = value;
      });
    });
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future _fetchData() async {
    if (allNotificationLocalDB.get("notifications") != null) {
      allNotificationData = allNotificationLocalDB.get("notifications");
    }
    final List<http.Response> response = await Future.wait([
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_notifications/$_currentUserId'),
      )
    ]);
    setState(() {
      if ((response[0].statusCode == 200) || (response[0].statusCode == 201)) {
        allNotificationData = json.decode(response[0].body);
        print(allNotificationData);
        allNotificationLocalDB.put(
            "notifications", json.decode(response[0].body));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    databaseReference.child("hysweb").once().then((snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            tokenData = snapshot.snapshot;
          });
        }
      });
    });
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Notifications",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 22,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              )),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: _body());
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

  int onlyOneLoop = 0;

  _body() {
    return ListView(
      children: [
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              labelColor: Color(0xff0C2551),
              isScrollable: true,
              labelPadding: EdgeInsets.only(right: 20.0),
              unselectedLabelColor: Color(0xFF6C8BC2),
              physics: BouncingScrollPhysics(),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('   All    ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('   Q/A    ',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('   Social    ',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('   Friends    ',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ]),
        ),
        Container(
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: TabBarView(
                physics: BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                  _allNotificationData(),
                  _qANDaNotifications(),
                  _smNotifications(),
                  _friendReqNotifications(),
                  // _socialNotification()
                ])),
      ],
    );
  }

  _allNotificationData() {
    return allNotificationData.length != 0
        ? Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.white10,
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allNotificationData.length,
              itemBuilder: (BuildContext context, int i) {
                return allNotificationData[i]["notify_type"] == "friendrequest"
                    ? friendRequestNotification(i)
                    : allNotificationData[i]["notify_type"] == "reaction"
                        ? _reaction(i)
                        : _others(i);
              },
            )) //
        : Center(
            child: Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 35,
                color: Color(0xFF737475),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  _qANDaNotifications() {
    return allNotificationData.length != 0
        ? Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.white10,
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allNotificationData.length,
              itemBuilder: (BuildContext context, int i) {
                return SizedBox();
              },
            )) //
        : Center(
            child: Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 35,
                color: Color(0xFF737475),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  _smNotifications() {
    return allNotificationData.length != 0
        ? Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.white10,
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allNotificationData.length,
              itemBuilder: (BuildContext context, int i) {
                return SizedBox();
              },
            )) //
        : Center(
            child: Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 35,
                color: Color(0xFF737475),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  _friendReqNotifications() {
    return allNotificationData.length != 0
        ? Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.white10,
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allNotificationData.length,
              itemBuilder: (BuildContext context, int i) {
                return SizedBox();
              },
            )) //
        : Center(
            child: Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 35,
                color: Color(0xFF737475),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  _reaction(int i) {
    return InkWell(
      onTap: () {
        // if ((allNotificationData[i]["section"] == 'question')) {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) =>
        //               PostAnswer(allNotificationData[i]["post_id"])));
        // } else if (allNotificationData[i]["section"] == 'answer') {}
        // notificationDB
        //     .updateNotificationDetails([allNotificationData[i]["notify_id"]]);
      },
      child: Container(
        decoration: BoxDecoration(
            color: allNotificationData[i]["is_clicked"] == "false"
                ? Color.fromRGBO(199, 234, 246, 1)
                : Colors.white,
            border: Border.all(color: Color(0xFFD2E2FF)),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                allNotificationData[i]["profilepic"].toString(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Container(
                    width: 230,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(allNotificationData[i]["title"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  fontWeight: FontWeight.w700,
                                )),
                            Container(
                              height: 20,
                              width: 20,
                              child: Center(
                                child:
                                    Icon(Icons.thumb_up_alt_outlined, size: 12),
                              ),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(1.0,
                                          1.0), // shadow direction: bottom right
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(allNotificationData[i]["message"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w500,
                            )),
                        SizedBox(height: 4),
                        Text(
                          allNotificationData[i]["createdate"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
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
      ),
    );
  }

  _others(int i) {
    return InkWell(
      // onTap: () {
      //   if ((allNotificationData[i]["section"] == 'question')) {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) =>
      //                 PostAnswer(allNotificationData[i]["post_id"])));
      //   } else if (allNotificationData[i]["section"] == 'answer') {}
      //   notificationDB
      //       .updateNotificationDetails([allNotificationData[i]["notify_id"]]);
      // },
      child: Container(
        decoration: BoxDecoration(
            color: allNotificationData[i]["is_clicked"] == "false"
                ? Color.fromRGBO(199, 234, 246, 1)
                : Colors.white,
            border: Border.all(color: Color(0xFFD2E2FF)),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                allNotificationData[i]["profilepic"].toString(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Container(
                    width: 230,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(allNotificationData[i]["title"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w700,
                            )),
                        SizedBox(height: 8),
                        Text(allNotificationData[i]["message"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w500,
                            )),
                        SizedBox(height: 4),
                        Text(
                          allNotificationData[i]["createdate"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
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
      ),
    );
  }

  friendRequestNotification(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Container(
            decoration: BoxDecoration(
                color: allNotificationData[i]["is_clicked"] == "false"
                    ? Color.fromRGBO(199, 234, 246, 1)
                    : Colors.white,
                border: Border.all(color: Color(0xFFD2E2FF)),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    // databaseReference
                    //     .child("hysweb")
                    //     .child("app_bar_navigation")
                    //     .child(FirebaseAuth.instance.currentUser.uid)
                    //     .update({
                    //   "$_currentUserId": 7,
                    //   "userid": allNotificationData[i]["sender_id"]
                    // });
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      allNotificationData[i]["profilepic"],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(allNotificationData[i]["title"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(height: 8),
                            Text(allNotificationData[i]["message"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 12,
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: 4),
                            Text(
                              allNotificationData[i]["createdate"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                              ),
                            ),
                            SizedBox(height: 10),
                            allNotificationData[i]["post_id"] == "sent" &&
                                    allNotificationData[i]["is_clicked"] ==
                                        "false"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 110,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color: Color(0xff0C2551),
                                            splashColor: Color(0xff0C2551),
                                            child: Center(
                                              child: Text(
                                                "Confirm",
                                                style: GoogleFonts.raleway(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            onPressed: () async {
                                              notificationDB
                                                  .updateNotificationDetails([
                                                allNotificationData[i]
                                                    ["notify_id"]
                                              ]);
                                              for (int k = 0;
                                                  k <
                                                      allConnections
                                                          .docs.length;
                                                  k++) {
                                                if ((allConnections.docs[k].get(
                                                            "otheruserid") ==
                                                        _currentUserId) &&
                                                    (allConnections.docs[k]
                                                            .get("userid") ==
                                                        allNotificationData[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .updateUserConnectionData(
                                                          allConnections
                                                              .docs[k].id,
                                                          {
                                                        "isfriend": true,
                                                        "isfollowing": true,
                                                        "onlyfollowing": false,
                                                        "isrequestaccepted":
                                                            true
                                                      });
                                                }
                                              }
                                              ////////////////////////////notification//////////////////////////////////////
                                              String notify_id =
                                                  "ntf${allNotificationData[i]["sender_id"]}frndacc$comparedate";
                                              notificationDB.sendNotification([
                                                notify_id,
                                                "friendrequest",
                                                "friend",
                                                _currentUserId,
                                                allNotificationData[i]
                                                    ["sender_id"],
                                                tokenData
                                                    .child(
                                                        "usertoken/${allNotificationData[i]["sender_id"]}/tokenid")
                                                    .value,
                                                "Listen!",
                                                "${userDataDB.get("first_name")} ${userDataDB.get("last_name")} accepted your friend request.",
                                                "accepted",
                                                "friend",
                                                "false",
                                                comparedate,
                                                "add"
                                              ]);
                                              //////////////////////////////////////////////////////////////////////////

                                              crudobj.addUserInConnection(
                                                  userDataDB.get("first_name") +
                                                      " " +
                                                      userDataDB
                                                          .get("last_name"),
                                                  userDataDB.get("profilepic"),
                                                  allNotificationData[i]
                                                      ["sender_id"],
                                                  true,
                                                  true,
                                                  true,
                                                  false,
                                                  current_date,
                                                  comparedate);
                                              allNotificationData = [];
                                              _allNotificationData();
                                            }),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 110,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color: Colors.white,
                                            splashColor: Colors.white,
                                            child: Center(
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.raleway(
                                                    color: Color(0xff0C2551),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            onPressed: () async {
                                              for (int k = 0;
                                                  k <
                                                      allConnections
                                                          .docs.length;
                                                  k++) {
                                                if ((allConnections.docs[k]
                                                            .get("userid") ==
                                                        _currentUserId) &&
                                                    (allConnections.docs[k].get(
                                                            "otheruserid") ==
                                                        allNotificationData[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .deleteUserConnectionData(
                                                          allConnections
                                                              .docs[k].id);
                                                }
                                                if ((allConnections.docs[k].get(
                                                            "otheruserid") ==
                                                        _currentUserId) &&
                                                    (allConnections.docs[k]
                                                            .get("userid") ==
                                                        allNotificationData[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .deleteUserConnectionData(
                                                          allConnections
                                                              .docs[k].id);
                                                }
                                              }
                                              notificationDB
                                                  .deleteNotificationDetails([
                                                allNotificationData[i]
                                                    ["notify_id"]
                                              ]);
                                              _fetchData();
                                            }),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> checkPermission() async {
    if (!await Permissions.cameraAndMicrophonePermissionsGranted()) {
      return false;
    }
    return true;
  }
}
