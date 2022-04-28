import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/fontelico_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hys/SocialPart/Podcast/loading_page.dart';
import 'package:hys/liveBooks/live_book_list.dart';
import 'package:hys/providers/navproviders.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hys/notification_pages/MyNotifications.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart' as loc;
import 'SocialPart/Cause/new_CreateCause.dart';
import 'SocialPart/FeedPost/MoodPost.dart';
import 'SocialPart/FeedPost/SocialFeeds.dart';
import 'package:intl/intl.dart';
import 'package:hys/SocialPart/Blogs/BlogInfo.dart';
import 'package:flutter/services.dart';
import 'package:hys/SocialPart/project/Projects.dart';
import 'package:http/http.dart' as http;
import 'SocialPart/Podcast/services/locator_service.dart';
import 'SocialPart/business/new_CreateBusiness.dart';
import 'database/questionSection/crud.dart';
import 'liveBooks/live_book_class_subjects.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  int index;
  BottomNavigationBarWidget({Key key, this.index}) : super(key: key);
  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

const kGoogleApiKey = "AIzaSyC2oRAljHGZArBeQc5OXY0MI5BBoQproWY";
places.GoogleMapsPlaces _places =
    places.GoogleMapsPlaces(apiKey: kGoogleApiKey);
LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
GoogleMapController _controller;
loc.Location _location = loc.Location();
Map<String, double> currentLoc;

Box<dynamic> userDataDB;
List<dynamic> userDatainit = [];
Map<dynamic, dynamic> userData = {};

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>
    with WidgetsBindingObserver {
  final _bottomNavigationBarColor = Colors.white;
  List<Widget> _dynamicPageList = [];
  int _index = 0;
  TextEditingController _timeController1 = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();
  String _fromselectedTime = "";
  TimeOfDay _time1;
  String _toselectedTime = "";
  TimeOfDay _time2;

  String current_date = DateTime.now().toString();
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  DataSnapshot currentstatus;
  final databaseReference = FirebaseDatabase.instance.reference();
  CrudMethods crudobj = CrudMethods();

  String post = "";
  String eventName = '';
  String timeSlot1 = '';
  String timeSlot2 = '';
  double curr_lat = 0;
  double curr_long;
  DateTime _dTime;
  String _selectedDate = '';
  String dob = "";
  bool dt = false;

  String _token;

  String current_datetime = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String current_time = DateTime.now().toString().substring(11, 19);
  String current_onlyDate =
      (DateFormat('yyyyMMddkkmm').format(DateTime.now())).substring(0, 8);
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  String starttime = DateTime.now().toString();

  TextEditingController _dobController = TextEditingController();
  TextEditingController _locController = TextEditingController();
  String dropdownValueClass = '5';
  String dropdownValueSubject = 'Mathematics';
  String dropdownValueFreq = 'Weekly';
  String dropdownValueFromSlot = 'AM';
  String dropdownValueToSlot = 'AM';
  String location = '';
  String fullAddress = '';
  FocusNode focusNode;
  FocusNode focusNode1;
  FocusNode focusNode2;
  FocusNode focusNode3;
  FocusNode focusNode4;
  bool checkConn = true;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('paused');
        databaseReference
            .child("usersloginstatus")
            .child(_currentUserId)
            .set({"currentstatus": "offline", "lastseentime": current_date});

        break;

      case AppLifecycleState.inactive:
        {
          print('inactive');
          databaseReference
              .child("usersloginstatus")
              .child(_currentUserId)
              .set({"currentstatus": "offline", "lastseentime": current_date});
          print(current_onlyDate);
          // for (int i = 0; i < userlogs.docs.length; i++) {
          //   if (userlogs.docs[i].get("onlydate") == current_onlyDate) {
          //     int timecount = DateTime.now()
          //         .difference(DateTime.parse(userlogs.docs[i].get("starttime")))
          //         .inSeconds;
          //     crudobj.updateUsersLogs(userlogs.docs[i].id, {
          //       "starttime": DateTime.now().toString(),
          //       "activetime": userlogs.docs[i].get("activetime") + timecount
          //     });
          //     break;
          //   }
          // }
        }
        break;

      case AppLifecycleState.resumed:
        {
          print('resumed');
          databaseReference
              .child("usersloginstatus")
              .child(_currentUserId)
              .set({"currentstatus": "online", "lastseentime": current_date});
          int count = 0;
          // for (int i = 0; i < userlogs.docs.length; i++) {
          //   if (userlogs.docs[i].get("onlydate") == current_onlyDate) {
          //     count++;
          //     print(DateTime.now().toString());
          //     crudobj.updateUsersLogs(userlogs.docs[i].id, {
          //       "starttime": DateTime.now().toString(),
          //       "numbersoflogins": userlogs.docs[i].get("numbersoflogins") + 1
          //     });
          //     break;
          //   }
          // }
          if (count == 0) {
            crudobj.addUserLogs(
                userDataDB.get("first_name") +
                    " " +
                    userDataDB.get("last_name"),
                1,
                current_onlyDate,
                0,
                DateTime.now().toString(),
                current_date,
                comparedate);
          }
        }

        break;

      case AppLifecycleState.detached:
        print('detached');
        break;
    }
  }

  Future<void> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        checkConn = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        checkConn = true;
      });
    } else {
      setState(() {
        checkConn = false;
      });
    }
  }

  @override
  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    focusNode = FocusNode();
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
    focusNode3 = FocusNode();
    focusNode4 = FocusNode();
    _fetchData();
    _getTokenForUser();
    checkConnection();
    if (widget.index != null) {
      _index = widget.index;
    }
    _dynamicPageList
      ..add(SOcialFeedPosts())
      ..add(SOcialFeedPosts())
      ..add(MyNotifications())
      ..add(SubjectListPage());
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future _fetchData() async {
    final results = await Future.wait([
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_user_data/$_currentUserId'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_user_preferred_languages_data/$_currentUserId'),
      ),
    ]);
    setState(() {
      userDatainit = json.decode(results[0].body);
      userData = userDatainit[0];
      //  userDataDB!.put("user_id", userData["user_id"]);
      userDataDB.put("first_name", userData["first_name"]);
      userDataDB.put("last_name", userData["last_name"]);
      userDataDB.put("email_id", userData["email_id"]);
      userDataDB.put("mobile_no", userData["mobile_no"]);
      userDataDB.put("address", userData["address"]);
      userDataDB.put("board", userData["board"]);
      userDataDB.put("city", userData["city"]);
      userDataDB.put("gender", userData["gender"]);
      userDataDB.put("grade", userData["grade"]);
      userDataDB.put("profilepic", userData["profilepic"]);
      userDataDB.put("school_address", userData["school_address"]);
      userDataDB.put("school_city", userData["school_city"]);
      userDataDB.put("school_name", userData["school_name"]);
      userDataDB.put("school_state", userData["school_state"]);
      userDataDB.put("school_street", userData["school_street"]);
      userDataDB.put("state", userData["state"]);
      userDataDB.put("stream", userData["stream"]);
      userDataDB.put("street", userData["street"]);
      userDataDB.put("user_dob", userData["user_dob"]);
      userDataDB.put("preferred_lang", json.decode(results[1].body));
    });
  }

  Future<void> _getTokenForUser() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      print('FCM TokenToken: $value');
      setState(() {
        _token = value;
        userDataDB.put("token", _token);
        databaseReference
            .child("hysweb")
            .child("usertoken")
            .child("$_currentUserId")
            .update({"tokenid": _token});
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int docPageIndex;
  @override
  Widget build(BuildContext context) {
    checkConnection();
    var indexCounter = locator<NavBarIndex>().getCounter;
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: _body(indexCounter),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Color.fromRGBO(88, 165, 196, 1),
                onPressed: () {
                  moreButtonForViewer(context);
                },
                tooltip: '',
                child: Icon(
                  Icons.add,
                  color: _bottomNavigationBarColor,
                )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
                color: Color.fromRGBO(88, 165, 196, 1),
                shape: CircularNotchedRectangle(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(FontAwesome5.home, size: 20),
                          color:
                              indexCounter == 0 ? Colors.white : Colors.black,
                          onPressed: () {
                            setNavBarIndex(context, 0);
                          }),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: IconButton(
                            icon: Icon(Icons.people, size: 20),
                            color:
                                indexCounter == 1 ? Colors.white : Colors.black,
                            onPressed: () {
                              setNavBarIndex(context, 1);
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: IconButton(
                            icon: Icon(FontAwesome5.bell, size: 17),
                            color:
                                indexCounter == 2 ? Colors.white : Colors.black,
                            onPressed: () {
                              setNavBarIndex(context, 2);
                            }),
                      ),
                      IconButton(
                          icon: Icon(FontAwesome5.book, size: 17),
                          color:
                              indexCounter == 3 ? Colors.white : Colors.black,
                          onPressed: () {
                            setNavBarIndex(context, 3);
                          })
                    ]))),
      ),
    );
  }

  _body(int index) {
    return checkConn == true
        ? (userDataDB.get("user_dob") != null
            ? _dynamicPageList[index]
            : _loading())
        : _connectionStatus();
  }

  void setNavBarIndex(BuildContext context, int index) {
    locator<NavBarIndex>().setTabCount(index);
  }

  YYDialog causeDialogBox(BuildContext context) {
    return YYDialog().build(context)
      ..barrierDismissible = false
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
                    onTap: () {
                      Navigator.of(context).pop();
                      causeUnderprivileged(context);
                    },
                    child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/CausePriv.png'),
                                radius: 20),
                            SizedBox(
                              width: 25,
                            ),
                            Expanded(
                                child: Text(
                                    'Create a Cause to Educate Underprivileged kids.',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ))),
                          ],
                        ))),
                Divider(
                  indent: 25,
                  color: Colors.black45,
                  endIndent: 25,
                ),
                InkWell(
                    onTap: null,
                    child: Container(
                        height: 55,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage('assets/girlChild1.png'),
                                  radius: 20),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                  child: Text(
                                      'Create a Cause to Educate Girl Child.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ))),
                            ],
                          ),
                        ))),
                Divider(
                  indent: 25,
                  color: Colors.black45,
                  endIndent: 25,
                ),
                InkWell(
                    onTap: null,
                    child: Container(
                        height: 65,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/Donation.jpg'),
                                  radius: 20),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                  child: Text(
                                      'Create a Cause to donate books/clothes/old tablets/smart phones/any other to underprivileged.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ))),
                            ],
                          ),
                        ))),
                Divider(
                  indent: 25,
                  color: Colors.black45,
                  endIndent: 25,
                ),
                InkWell(
                    onTap: null,
                    child: Container(
                        height: 55,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage('assets/others1.png'),
                                  radius: 20),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                  child:
                                      Text('Create a Cause for Something Else.',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ))),
                            ],
                          ),
                        ))),
              ]))))
      ..show();
  }

  YYDialog causeUnderprivileged(BuildContext context) {
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
              padding: const EdgeInsets.all(20.0),
              child: ListView(physics: BouncingScrollPhysics(), children: [
                InkWell(
                    onTap: () {},
                    child: Container(
                        height: 72,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/Teaching.jpg'),
                                  radius: 25),
                              SizedBox(
                                width: 25,
                              ),
                              Column(
                                children: [
                                  Text('Support By Teaching.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewCreateCause(
                                                          "Create a Cause to Educate Underprivileged kids",
                                                          "Support By Teaching",
                                                          "online")));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1)),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          margin: EdgeInsets.all(5),
                                          padding: EdgeInsets.all(6),
                                          child: Center(
                                            child: Text(
                                              'Online',
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewCreateCause(
                                                          "Create a Cause to Educate Underprivileged kids",
                                                          "Support By Teaching",
                                                          "online")));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1)),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          margin: EdgeInsets.all(5),
                                          padding: EdgeInsets.all(6),
                                          child: Center(
                                            child: Text(
                                              'Offline',
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ))),
                Divider(
                  indent: 25,
                  color: Colors.black45,
                  endIndent: 25,
                ),
                InkWell(
                    onTap: null,
                    child: Container(
                        height: 75,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage('assets/Donation.jpg'),
                                  radius: 25),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                  child: Text(
                                      'Support By Providing books and\nstationary.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ))),
                            ],
                          ),
                        ))),
                Divider(
                  indent: 25,
                  color: Colors.black45,
                  endIndent: 25,
                ),
                InkWell(
                    onTap: null,
                    child: Container(
                        height: 65,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/others2.jpg'),
                                  radius: 25),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                  child: Text('Support in any other ways.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ))),
                            ],
                          ),
                        ))),
              ]))))
      ..show();
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
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MakePostOfMyMood()));
                },
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_wink,
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
                ),
              ),
              ExpandablePanel(
                header: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_saint,
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
                            'Create',
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
                            'Make a difference in someone\'s life!',
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
                ),
                expanded: Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BlogInfo()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Blog',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          causeDialogBox(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Cause',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Help Group',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          storageAndMicrophonePermissionsGranted()
                              .then((value) {
                            setState(() {
                              flag = value;
                              if (flag == true) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoadingPage()));
                              }
                            });
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Podcast',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Rebel',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ExpandablePanel(
                header: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_coffee,
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
                            'Discuss',
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
                            'Share your interesting ideas with others',
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
                ),
                expanded: Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Books',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NEWCreateBusiness()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Bussiness Ideas',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Exam Questions',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DiscussProject()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Projects',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              ExpandablePanel(
                header: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.upload_file,
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
                            'Uploads',
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
                            'Upload Documents',
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
                ),
                expanded: Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            docPageIndex = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'School Exams',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            docPageIndex = 2;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Class Notes',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            docPageIndex = 3;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Competitive Exams',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            docPageIndex = 4;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Others',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_sunglasses,
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
                            'Showcase your talent',
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
                            'Let all knows about your hidden talent',
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
                ),
              ),
              InkWell(
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_thumbsup,
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
                            'Predict Questions',
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
                            'Guess the questions having high priority in exam',
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
                ),
              ),
            ],
          ),
        ),
      ))
      ..show();
  }

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

  _connectionStatus() {
    return Center(
        child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                ),
                Image.asset("assets/noconnection.png"),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "No Internet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 35,
                    color: Color(0xFFBAC0C5),
                    fontWeight: FontWeight.w800,
                  ),
                )
              ],
            )));
  }
}

Future<bool> storageAndMicrophonePermissionsGranted() async {
  PermissionStatus storagePermissionStatus = await _getStoragePermission();
  PermissionStatus microphonePermissionStatus =
      await _getMicrophonePermission();

  if (storagePermissionStatus == PermissionStatus.granted &&
      microphonePermissionStatus == PermissionStatus.granted) {
    return true;
  } else {
    _handleInvalidPermissions(
        storagePermissionStatus, microphonePermissionStatus);
    return false;
  }
}

void _handleInvalidPermissions(
  PermissionStatus cameraPermissionStatus,
  PermissionStatus microphonePermissionStatus,
) {
  if (cameraPermissionStatus == PermissionStatus.denied &&
      microphonePermissionStatus == PermissionStatus.denied) {
    throw new PlatformException(
        code: "PERMISSION_DENIED",
        message: "Access to camera and microphone denied",
        details: null);
  } else if (cameraPermissionStatus == PermissionStatus.disabled &&
      microphonePermissionStatus == PermissionStatus.disabled) {
    throw new PlatformException(
        code: "PERMISSION_DISABLED",
        message: "Location data is not available on device",
        details: null);
  }
}

Future<PermissionStatus> _getMicrophonePermission() async {
  PermissionStatus permission = await PermissionHandler()
      .checkPermissionStatus(PermissionGroup.microphone);
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.disabled) {
    Map<PermissionGroup, PermissionStatus> permissionStatus =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.microphone]);
    return permissionStatus[PermissionGroup.microphone] ??
        PermissionStatus.unknown;
  } else {
    return permission;
  }
}

Future<PermissionStatus> _getStoragePermission() async {
  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.disabled) {
    Map<PermissionGroup, PermissionStatus> permissionStatus =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    return permissionStatus[PermissionGroup.storage] ??
        PermissionStatus.unknown;
  } else {
    return permission;
  }
}
