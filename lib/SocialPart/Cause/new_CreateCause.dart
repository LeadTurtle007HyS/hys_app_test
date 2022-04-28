import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/Cause/MapLocation.dart';
import 'package:hys/SocialPart/database/SocialFeedCauseDB.dart';
import 'package:hys/utils/cropper.dart';
import 'package:hys/utils/options.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:hys/navBar.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:intl/intl.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hys/SocialPart/network_crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:async';

List imageList = [];
List videoList = [];
List selectedUserID = [];
String _currentUserId;
Box<dynamic> allSocialPostLocalDB;
List<dynamic> allCausePostData = [];
List<dynamic> allPostData = [];
List<int> allPostLikeCount = [];
List<int> allPostCommentCount = [];
List<int> allPostViewCount = [];
List<int> allPostImpressionCount = [];
List<dynamic> taggingData = [];
Box<dynamic> userDataDB;

List selectedUserflag = [];
FocusNode focusNode1 = FocusNode();
FocusNode focusNode2 = FocusNode();
FocusNode focusNode3 = FocusNode();
FocusNode focusNode4 = FocusNode();
FocusNode focusNode5 = FocusNode();
FocusNode focusNode = FocusNode();

bool showimgcontainer = false;
bool showvdocontainer = false;
String grade;
String subject;
String freq;
bool themeflag = false;
String date;
String from;
String to;
String loc;
String dropdownValueClass = '5';
String dropdownValueSubject = 'Mathematics';
String dropdownValueFreq = 'Weekly';
String dropdownValueFromSlot = 'AM';
String dropdownValueToSlot = 'AM';
String location = '';
String fullAddress = '';
String post = '';
String eventName = '';
String timeSlot1 = '';
String timeSlot2 = '';
double curr_lat = 0;
double curr_long;
DateTime _dTime;
String _selectedDate = '';
String dob = "";
bool dt = false;
TextEditingController _timeController1 = TextEditingController();
TextEditingController _timeController2 = TextEditingController();
String _fromselectedTime = "";
String _fromselectedTime24hrs = "";
TimeOfDay _time1;
String _toselectedTime = "";
String _toselectedTime24hrs = "";
TimeOfDay _time2;
TextEditingController _locController = TextEditingController();
TextEditingController _dobController = TextEditingController();
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
QuerySnapshot userfeedData;
final databaseReference = FirebaseDatabase.instance.reference();

List<String> themes = [
  "assets/theme1.jpeg",
  "assets/theme2.jpg",
  "assets/theme3.png",
  "assets/theme4.png",
  "assets/theme5.png",
  "assets/theme6.png",
  "assets/theme7.png"
];
int themeindex = 0;
final _formKey = GlobalKey<FormState>();
final picker = ImagePicker();
bool imgFlag = false;
bool uploaded = false;
File _image;
dynamic imgUrl;
bool flag1 = false;
File firstcrop;

Future<void> dismissKeyboard() async {
  flag1 = false;
  focusNode.unfocus();
}

Future<void> showKeyboard() async {
  flag1 = true;
  focusNode.requestFocus();
}

final _users = [
  {
    'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
    'display': 'Vivek Sharma',
    'full_name': 'DPS | Grade 7',
    'photo':
        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
  },
];

const kGoogleApiKey = "AIzaSyC2oRAljHGZArBeQc5OXY0MI5BBoQproWY";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

NetworkCRUD network_crud = NetworkCRUD();

class NewCreateCause extends StatefulWidget {
  String eventCategory;
  String eventSubCategory;
  String eventtype;
  NewCreateCause(this.eventCategory, this.eventSubCategory, this.eventtype);
  @override
  State<NewCreateCause> createState() => _NewCreateCauseState(
      this.eventCategory, this.eventSubCategory, this.eventtype);
}

class _NewCreateCauseState extends State<NewCreateCause> {
  String eventCategory;
  String eventSubCategory;
  String eventtype;
  _NewCreateCauseState(
      this.eventCategory, this.eventSubCategory, this.eventtype);

  Future<void> _get_all_users_data_for_tagging() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_users_data_for_tagging'),
    );

    print("get_all_users_data_for_tagging: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        taggingData = json.decode(response.body);
        for (int i = 0; i < taggingData.length; i++) {
          if (taggingData[i]["user_id"].toString() !=
              _currentUserId.toString()) {
            _users.add({
              'id': taggingData[i]["user_id"].toString(),
              'display': taggingData[i]["first_name"].toString() +
                  " " +
                  taggingData[i]["last_name"].toString(),
              'full_name': taggingData[i]["school_name"].toString() +
                  " | " +
                  taggingData[i]["grade"].toString(),
              'photo': taggingData[i]["profilepic"].toString()
            });
          } else {
            print("found");
            userDataDB.put("user_id", taggingData[i]["user_id"]);
            userDataDB.put("first_name", taggingData[i]["first_name"]);
            userDataDB.put("last_name", taggingData[i]["last_name"]);
            userDataDB.put("school_name", taggingData[i]["school_name"]);
            userDataDB.put("profilepic", taggingData[i]["profilepic"]);
          }
          selectedUserflag.add(false);
        }
      });
    }
  }

  @override
  void initState() {
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    userDataDB = Hive.box<dynamic>('userdata');
    _currentUserId = FirebaseAuth.instance.currentUser.uid;
    _get_all_users_data_for_tagging();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(body: _body()),
        onTap: () {
          focusNode1.unfocus();
          focusNode2.unfocus();
          focusNode3.unfocus();
          focusNode4.unfocus();
          focusNode5.unfocus();
          dismissKeyboard();
        });
  }

  _body() {
    String processStepSM = "";

    String mood = "";
    bool excited = false;
    bool abletopost = false;
    bool good = false;
    bool needpeople = false;
    bool certificate = false;
    bool performance = false;
    bool friends = false;
    String post_type = "Mood";
    if (userDataDB != null) {
      return Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: ListView(physics: BouncingScrollPhysics(), children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BottomNavigationBarWidget()));
                    },
                    icon: Tab(
                        child: Icon(Icons.cancel,
                            color: Colors.black45, size: 20)),
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
                    onTap: () async {
                      Dialogs.showLoadingDialog(context, _formKey);
                      comparedate =
                          DateFormat('yyyyMMddkkmm').format(DateTime.now());
                      String postID = "sm${_currentUserId}${comparedate}";
                      String imgID = "imgsm${_currentUserId}${comparedate}";
                      String videoID = "vdosm${_currentUserId}${comparedate}";
                      String userTagID =
                          "usrtgsm${_currentUserId}${comparedate}";
                      bool isImagesPosted = false;
                      bool isVideosPosted = false;
                      bool isUserTaggedPosted = false;
                      bool isFinalPostDone = false;
                      bool ispostIDCreated =
                          await network_crud.addsmPostDetails([
                        postID,
                        _currentUserId,
                        "cause|teachunprevilagedKids",
                        post //sharecomment,
                        ,
                        comparedate
                      ]);
                      allPostData.insert(0, {
                        "first_name": userDataDB.get("first_name"),
                        "last_name": userDataDB.get("last_name"),
                        "profilepic": userDataDB.get("profilepic"),
                        "school_name": userDataDB.get("school_name"),
                        "post_id": postID,
                        "user_id": _currentUserId,
                        "post_type": "cause|teachunprevilagedKids",
                        "comment": post,
                        "compare_date": comparedate
                      });
                      // allSocialPostLocalDB.put(
                      //     "allpost",
                      //     allPostData);
                      if (ispostIDCreated == true) {
                        if (imageList.isNotEmpty) {
                          for (int i = 0; i < imageList.length; i++) {
                            isImagesPosted = await network_crud
                                .addsmPostImageDetails([imgID, imageList[i]]);
                          }
                        }
                        if (videoList.isNotEmpty) {
                          for (int i = 0; i < videoList.length; i++) {
                            isVideosPosted = await network_crud
                                .addsmPostVideoDetails(
                                    [videoID, videoList[i], ""]);
                          }
                        }
                        if (selectedUserID.isNotEmpty) {
                          for (int i = 0; i < selectedUserID.length; i++) {
                            isUserTaggedPosted = await network_crud
                                .addsmPostUserTaggedDetails(
                                    [userTagID, selectedUserID[i]]);
                          }
                        }
                        List<dynamic> data = [
                          postID != null ? postID : "",
                          _currentUserId != null ? _currentUserId : "",
                          post != null ? post : "",
                          _dTime.toString() != null ? _dTime.toString() : "",
                          location != null ? location : "",
                          dob != null ? dob : "",
                          eventCategory != null ? eventCategory : "",
                          eventName != null ? eventName : "",
                          eventSubCategory != null ? eventSubCategory : "",
                          eventtype != null ? eventtype : "",
                          "EventUnderprivilegeByTeaching",
                          dropdownValueFreq != null ? dropdownValueFreq : "",
                          _fromselectedTime != null ? _fromselectedTime : "",
                          _fromselectedTime24hrs != null
                              ? _fromselectedTime24hrs
                              : "",
                          _time1.toString() != null ? _time1.toString() : "",
                          dropdownValueClass != null ? dropdownValueClass : "",
                          curr_lat != null ? curr_lat : "",
                          curr_long != null ? curr_long : "",
                          _currentUserId.substring(0, 10),
                          dropdownValueSubject != null
                              ? dropdownValueSubject
                              : "",
                          themes[themeindex],
                          themeindex,
                          _toselectedTime != null ? _toselectedTime : "",
                          _toselectedTime24hrs != null
                              ? _toselectedTime24hrs
                              : "",
                          _time2.toString() != null ? _time2.toString() : "",
                          imageList.isNotEmpty ? imgID : "",
                          videoList.isNotEmpty ? videoID : "",
                          selectedUserID.isNotEmpty ? userTagID : "",
                          "hyspostprivacy01",
                          0,
                          0,
                          0,
                          0,
                          comparedate
                        ];
                        databaseReference
                            .child("sm_feeds")
                            .child("cause_test")
                            .child(postID)
                            .update({'data': data});
                        isFinalPostDone =
                            await network_crud.addsmCausePostDetails(data);
                        databaseReference
                            .child("sm_feeds")
                            .child("cause_test1")
                            .child(postID)
                            .update({'data': isFinalPostDone});
                        if (isFinalPostDone == true) {
                          allCausePostData.insert(0, {
                            "first_name": userDataDB.get("first_name"),
                            "last_name": userDataDB.get("last_name"),
                            "profilepic": userDataDB.get("profilepic"),
                            "school_name": userDataDB.get("school_name"),
                            "post_id": data[0],
                            "user_id": data[1],
                            "message": data[2],
                            "datetime": data[3],
                            "address": data[4],
                            "date": data[5],
                            "eventcategory": data[6],
                            "eventname": data[7],
                            "eventsubcategory": data[8],
                            "eventtype": data[9],
                            "feedtype": data[10],
                            "frequency": data[11],
                            "from_": data[12],
                            "from24hrs": data[13],
                            "fromtime": data[14],
                            "grade": data[15],
                            "latitude": data[16],
                            "longitude": data[17],
                            "meetingid": data[18],
                            "subject": data[19],
                            "theme": data[20],
                            "themeindex": data[21],
                            "to_": data[22],
                            "to24hrs": data[23],
                            "totime": data[24],
                            "imagelist_id": data[25],
                            "videolist_id": data[26],
                            "usertaglist_id": data[27],
                            "privacy": data[28],
                            "like_count": data[29],
                            "comment_count": data[30],
                            "view_count": data[31],
                            "impression_count": data[32],
                            "compare_date": data[33]
                          });
                          allSocialPostLocalDB.put(
                              "causepost", allCausePostData);
                          for (int k = 0; k < selectedUserflag.length; k++) {
                            setState(() {
                              selectedUserflag[k] = false;
                            });
                          }

                          ElegantNotification.success(
                            title: Text("Congrats"),
                            description:
                                Text("Your post created successfully."),
                          );
                          Navigator.of(_formKey.currentContext,
                                  rootNavigator: true)
                              .pop();
                          Navigator.of(context).pop();
                        } else {
                          ElegantNotification.error(
                            title: Text("Error..."),
                            description: Text("Something wrong."),
                          );
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          color: (post != "")
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(3)),
                      child: Text(
                        (post != "") ? 'Post' : "Wait",
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
                                      height:
                                          MediaQuery.of(context).size.width /
                                              10.34,
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              userDataDB.get('profilepic'))),
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
                                  Row(children: [
                                    Text(
                                        userDataDB
                                                .get('first_name')
                                                .toString() +
                                            userDataDB
                                                .get('last_name')
                                                .toString(),
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text(' has Created a Cause '),
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: Image.asset(
                                            'assets/causeEmoji.png')),
                                  ]),
                                  Row(
                                    children: [
                                      Text(
                                          'to Educate UnderPrivileged Childrens.',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color.fromRGBO(
                                                  88, 165, 196, 1)),
                                          borderRadius:
                                              BorderRadius.circular(3)),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 60,
                        child: TextField(
                          focusNode: focusNode,
                          onChanged: (val) {
                            setState(() {
                              post = val;
                            });
                          },
                          onTap: () {
                            showKeyboard();
                          },
                          minLines: 2,
                          maxLines: 15,
                          keyboardType: TextInputType.multiline,
                          cursorColor: Color.fromRGBO(88, 165, 196, 1),
                          style: TextStyle(
                              fontSize: 15,
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
                                fontSize: 16,
                                color: Colors.black26,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      (showimgcontainer == true) ? _imgContainer() : SizedBox(),
                      (uploaded == true)
                          ? Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(10),
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.cancel,
                                              color: Colors.black),
                                          onPressed: () {
                                            setState(() {
                                              imgFlag = false;
                                              uploaded = false;
                                              _image.delete();
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  (imgFlag == true)
                                      ? _loading()
                                      : Image.file(firstcrop,
                                          fit: BoxFit.contain),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  )
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text('Fill Event Details.',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 15,
                        color: Color.fromRGBO(78, 160, 193, 2),
                        fontWeight: FontWeight.w500,
                      ))),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      (themeflag == true)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text('Selected Theme',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Stack(children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        height: 100,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: AssetImage(
                                                    themes[themeindex])))),
                                    IconButton(
                                      icon: Icon(Icons.cancel,
                                          color: Colors.black),
                                      onPressed: () {
                                        setState(() {
                                          themeflag = false;
                                          themeindex = 0;
                                        });
                                      },
                                    )
                                  ])
                                ])
                          : SizedBox(
                              height: 1,
                            )
                    ])),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 40, bottom: 10),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                        Container(
                          child: Text('Event Name',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        SizedBox(width: 20),
                        Container(
                            width: 150,
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please Enter Name.';
                                } else
                                  return null;
                              },
                              onTap: () async {
                                focusNode1.requestFocus();
                              },
                              focusNode: focusNode1,
                              onChanged: (value) {
                                setState(() {
                                  eventName = value;
                                });
                              },
                            ))
                      ]),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text('Class',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            width: 50,
                            child: DropdownButton<String>(
                              value: dropdownValueClass,
                              icon: const Icon(Icons.expand_more),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 1,
                                color: Colors.black38,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  dropdownValueClass = value;
                                });
                              },
                              items: <String>[
                                '5',
                                '6',
                                '7',
                                '8',
                                '9',
                                '10',
                                '11',
                                '12'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ]),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Text('Subject',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ))),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            width: 120,
                            child: DropdownButton<String>(
                              value: dropdownValueSubject,
                              icon: const Icon(Icons.expand_more),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 1,
                                color: Colors.black38,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  dropdownValueSubject = value;
                                });
                              },
                              items: <String>[
                                'Mathematics',
                                'Physics',
                                'Chemistry',
                                'English',
                                'Hindi',
                                'Moral Science',
                                'Social Studies'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ]),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Text('Frequency',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ))),
                        SizedBox(width: 20),
                        Container(
                            width: 85,
                            child: DropdownButton<String>(
                              value: dropdownValueFreq,
                              icon: const Icon(Icons.expand_more),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 1,
                                color: Colors.black38,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  dropdownValueFreq = value;
                                });
                              },
                              items: <String>[
                                'Weekly',
                                'BiWeekly',
                                'Monthly'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ]),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Text('Date',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ))),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            width: 100,
                            child: TextFormField(
                                readOnly: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter Event Date.';
                                  } else
                                    return null;
                                },
                                controller: _dobController,
                                onChanged: (value) {
                                  setState(() {
                                    dob = value;
                                  });
                                },
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2024))
                                      .then((value) {
                                    setState(() {
                                      dt = false;
                                      _dTime = value;
                                      print(_dTime.toString());
                                      _selectedDate = DateFormat("dd/MM/yyyy")
                                          .format(_dTime);
                                      print(
                                        _selectedDate.substring(0, 10),
                                      );
                                      _dobController.text = _selectedDate;
                                      dob = _selectedDate;
                                      return _selectedDate;
                                    });
                                  });
                                },
                                decoration:
                                    InputDecoration(labelText: 'DD//MM//YY'))),
                      ]),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text('Time Slot',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ))),
                      SizedBox(
                        width: 60,
                      ),
                      Container(
                          width: 70,
                          child: TextFormField(
                              readOnly: true,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '*';
                                } else
                                  return null;
                              },
                              controller: _timeController1,
                              onChanged: (value) {
                                setState(() {
                                  _fromselectedTime = value;
                                });
                              },
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  setState(() {
                                    _time1 = value;
                                    print(_time1.toString());
                                    _fromselectedTime =
                                        _time1.format(context).toString();
                                    print(_time1.hour.toString());
                                    print(_time1.minute.toString());
                                    print(_fromselectedTime);
                                    _timeController1.text = _fromselectedTime;
                                    _fromselectedTime24hrs =
                                        _time1.hour.toString() +
                                            ":" +
                                            _time1.minute.toString();
                                    return _fromselectedTime;
                                  });
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'HH:MM',
                                  labelStyle: TextStyle(fontSize: 10)))),
                      SizedBox(width: 4),
                      Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text(' - ')])),
                      SizedBox(
                        width: 4,
                      ),
                      InkWell(
                        child: Container(
                            width: 70,
                            child: TextFormField(
                                readOnly: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '*';
                                  } else
                                    return null;
                                },
                                controller: _timeController2,
                                onChanged: (value) {
                                  setState(() {
                                    _toselectedTime = value;
                                  });
                                },
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    setState(() {
                                      _time2 = value;
                                      print(_time2.toString());
                                      _toselectedTime =
                                          _time2.format(context).toString();
                                      _toselectedTime24hrs =
                                          _time2.hour.toString() +
                                              ":" +
                                              _time2.minute.toString();
                                      _timeController2.text = _toselectedTime;

                                      return _toselectedTime;
                                    });
                                  });
                                },
                                decoration: InputDecoration(
                                    labelText: 'HH:MM',
                                    labelStyle: TextStyle(fontSize: 10)))),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  this.eventtype == "offline"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Text('Location',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ))),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                                width: 200,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Enter Address.';
                                    } else
                                      return null;
                                  },
                                  controller: _locController,
                                  onTap: () {
                                    if (location == '') {
                                      _handlePressButton();
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      location = value;
                                    });
                                  },
                                )),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Text('Meeting ID',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ))),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                                width: 100,
                                child: Text(_currentUserId.substring(0, 10),
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    )))),
                          ],
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  (fullAddress != '')
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MapLocation(curr_lat, curr_long)));
                          },
                          child: Text('Google Map',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 15)))
                      : SizedBox(),
                  SizedBox(height: 30),
                ]),
              ),
            ])),
            (flag1 == true)
                ? Column(children: [
                    Container(
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(
                                      top: 5, bottom: 8, left: 8, right: 8),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 0;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme1.jpeg'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 1;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme2.jpg'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 2;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme3.png'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 3;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme4.png'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 4;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme5.png'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 5;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme6.png'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                        InkWell(
                                            onTap: () {
                                              themeflag = true;
                                              setState(() {
                                                themeindex = 6;
                                              });
                                            },
                                            child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/theme7.png'),
                                                radius: 17)),
                                        SizedBox(width: 7),
                                      ]))
                            ])),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 10, left: 15, right: 15),
                                    child: Center(
                                      child: Image.asset("assets/keyboard.png",
                                          color: Colors.blue,
                                          height: 22,
                                          width: 21),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 10, right: 15),
                                    child: Center(
                                      child: Image.asset(
                                          "assets/videorecord.jpg",
                                          height: 25,
                                          width: 25),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      dismissKeyboard();
                                      showvdocontainer = false;
                                      showimgcontainer = !showimgcontainer;
                                      print(showimgcontainer);
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 10, right: 15),
                                    child: Center(
                                      child: Image.asset("assets/gallery.png",
                                          height: 22, width: 21),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 10, right: 15),
                                    child: Center(
                                      child: Icon(FontAwesome5.user_tag,
                                          size: 18, color: Colors.deepPurple),
                                    ),
                                  ),
                                ),

                                //   InkWell(
                                //     onTap: () {},
                                //     child: Container(
                                //       padding: EdgeInsets.only(top: 10, left: 20),
                                //       child: Center(
                                //         child: Text(
                                //           "@",
                                //           style: TextStyle(
                                //               fontWeight: FontWeight.w700,
                                //               fontSize: 22,
                                //               color: Colors.black54),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ])
                : SizedBox(),
          ]));
    } else
      return _loading();
  }

  Future<void> _handlePressButton() async {
    try {
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.overlay,
          types: ["establishment"],
          components: [Component(Component.country, "in")],
          language: "en",
          strictbounds: false);

      PlacesDetailsResponse place =
          await _places.getDetailsByPlaceId(p.placeId);
      final placeDetail = place.result;
      setState(() {
        curr_lat = placeDetail.geometry.location.lat;
        curr_long = placeDetail.geometry.location.lng;
      });

      fullAddress = placeDetail.formattedAddress;
      _locController.text = fullAddress;

      print(fullAddress);
    } catch (e) {
      return;
    }
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

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }

  Future _imgFromCamera(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        if (_image != null) {
          getEventImgURL(_image);
        }
      });
    }
  }

  Future _imgFromGallery(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);

        if (_image != null) {
          getEventImgURL(_image);
        }
      });
    }
  }

  SocialFeedCreateCause socialobj = SocialFeedCreateCause();

  Future getEventImgURL(File _image) async {
    setState(() {
      print(_image);
      socialobj.uploadEventPic(_image).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            imgUrl = value[1];
            uploaded = true;
            imgFlag = false;
            print(imgUrl);
            imageList.add(imgUrl);
          } else
            _showAlertDialog(value[1]);
        });
      });
    });
  }

  void _showAlertDialog(String message) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        'Error',
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat'),
      ),
      content: Text(
        message,
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat'),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future getProfilePic(ImageSource source) async {
    final pickedfile = await picker.getImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _image = File(pickedfile.path);
        print(_image);
      });
    }

    if (_image != null) {
      setState(() {
        imgFlag = true;
      });
      firstcrop = await ImageCropper.cropImage(
          sourcePath: _image.path,
          compressQuality: 90,
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: Colors.white,
              hideBottomControls: true,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.ratio3x2,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: 'Crop',
          ));

      if (firstcrop != null) {
        getEventImgURL(firstcrop);
        /*setState(() {
          imageFile = croppedFile;
          print(imageFile);
          base64Image = base64Encode(imageFile.readAsBytesSync());
          print(base64Image);
          imagereading = true;
          uploadImage(base64Image, imageFile);
        });*/
      } else {
        setState(() {
          imgFlag = false;
        });
      }
    }
  }

  _imgContainer() {
    return Container(
      height: 250,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Upload Poster",
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showimgcontainer = false;
                          showvdocontainer = false;
                          dismissKeyboard();
                          getProfilePic(ImageSource.camera);
                        });
                      },
                      icon: Tab(
                          child: Icon(Icons.camera_alt_outlined,
                              color: Color(0xff0962ff), size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color(0xff0C2551),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showimgcontainer = false;
                          showvdocontainer = false;
                          dismissKeyboard();
                          getProfilePic(ImageSource.gallery);
                        });
                      },
                      icon: Tab(
                          child: Icon(Icons.image,
                              color: Color(0xff0962ff), size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Images",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color(0xff0C2551),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
