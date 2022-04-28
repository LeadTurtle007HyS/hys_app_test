import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hys/SocialPart/Cause/Calendar.dart';
import 'package:hys/SocialPart/FeedPost/AddCommentPage.dart';
import 'package:hys/SocialPart/FeedPost/shareFeedPost.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/SocialPart/database/SocialDiscussDB.dart';
import 'package:hys/SocialPart/database/SocialFeedCauseDB.dart';
import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/notificationdb.dart';
import 'package:hys/services/auth.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/FeedPost/CommentPage.dart';
import 'package:http/http.dart' as http;
class ViewFile extends StatefulWidget {
  String id;
  ViewFile(this.id);
  @override
  _ViewFileState createState() => _ViewFileState(this.id);
}




String date1 = "";
String fromtime1 = "";
String totime1 = "";
String from;
String to;
String freq1 = "";
String eventName1 = "";
// MeetingDataSource _dataSource;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
ScrollController _scrollController;
SocialFeedCreateCause socialobj = SocialFeedCreateCause();
File _image;
SocialMCommentsDB commentobj = SocialMCommentsDB();

class _ViewFileState extends State<ViewFile> {
  String id;
  _ViewFileState(this.id);
  DocumentSnapshot projectData;
  SocialDiscuss socialobj = SocialDiscuss();
  bool pdfFlag = false;
  String testLink = "";
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  QuerySnapshot allUserpersonaldata;
  QuerySnapshot allUserschooldata;
  SocialFeedPost socialFeed = SocialFeedPost();
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  QuerySnapshot socialfeed;
  final AuthService _auth = AuthService();
  ScrollController _scrollController;
  bool _showAppbar = true;
  bool isScrollingDown = false;
  DataSnapshot countData;

  DataSnapshot callStatusCheck;
  final databaseReference = FirebaseDatabase.instance.reference();
  Box<dynamic> socialFeedPostReactionsDB;
  Box<dynamic> socialFeedPostSavedDB;
  Box<dynamic> usertokendataLocalDB;
  List<int> _reactionIndex = [];
  SocialFeedNotification _notificationdb = SocialFeedNotification();
  QuerySnapshot notificationToken;
  List<int> indexcount = [];
  bool indexcountbool = false;

  PushNotificationDB myNotify = PushNotificationDB();

//event
  Box<dynamic> socialEventDB;
  Box<dynamic> eventReactions;
  Box<dynamic> userpersonaldataLocalDB;
  bool flag = false;
  String eventid;
  QuerySnapshot commentSnap;
  QuerySnapshot likesdetails;
  int count;
  Map<String, int> map = Map();
  List<int> likesID = List();
  Box<dynamic> socialEventSubCommLike;
  int reactIndex = 0;
Box<dynamic> allSocialPostLocalDB;
Box<dynamic> userDataDB;
List<dynamic> allPDiscussPostDetails=[];
  Future<void> _get_all_project_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_project_posts'),
    );

    print("get_all_sm_project_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB.put("projectpost", json.decode(response.body));
        print("fetched details of projects");
        _print_all_project_post_details();
      });
    }
  }
Map current_post;
Future<void> _print_all_project_post_details() async{
  setState(() {
      allPDiscussPostDetails = allSocialPostLocalDB.get("projectpost");
      print("proorororojects");
      print(allPDiscussPostDetails);
       for (int i = 0; i < allPDiscussPostDetails.length; i++) {
        setState(() {

          if(allPDiscussPostDetails[i]["post_id"]==this.id){
           current_post=allPDiscussPostDetails[i];
           print(current_post);
           print("current_post");
          }
          
        });
      }
  });
}

 List<dynamic> allTaggedUsersData=[];
Future<void> _get_all_tagged_users() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_usertagged'),
    );

    print("get_all_sm_usertagged: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allTaggedUsersData = json.decode(response.body);
      });
    }
  }






  List<Reaction> reactions = <Reaction>[
    Reaction(
        id: 1,
        previewIcon:
            Image.asset("assets/reactions/like.gif", height: 50, width: 50),
        icon: Row(
          children: [
            Icon(FontAwesome5.thumbs_up, color: Color(0xff0962ff), size: 14),
            Text(
              "  Like",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0962ff)),
            )
          ],
        ),
        title: Text(
          "Like",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
    Reaction(
        id: 2,
        previewIcon:
            Image.asset("assets/reactions/love.gif", height: 50, width: 50),
        icon: Row(
          children: [
            Image.asset("assets/reactions/love.png", height: 20, width: 20),
            Text(
              "  Love",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(244, 8, 82, 1)),
            )
          ],
        ),
        title: Text(
          "Love",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
    Reaction(
        id: 3,
        previewIcon:
            Image.asset("assets/reactions/laugh.gif", height: 50, width: 50),
        icon: Row(
          children: [
            Image.asset("assets/reactions/laugh.png", height: 20, width: 20),
            Text(
              "  Haha",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(242, 177, 76, 1)),
            )
          ],
        ),
        title: Text(
          "Haha",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
    Reaction(
        id: 4,
        previewIcon: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Image.asset("assets/reactions/yay.gif", height: 40, width: 40),
          ],
        ),
        icon: Row(
          children: [
            Image.asset("assets/reactions/yay.png", height: 20, width: 20),
            Text(
              "  Yay",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(242, 177, 76, 1)),
            )
          ],
        ),
        title: Text(
          "Yay",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
    Reaction(
        id: 5,
        previewIcon:
            Image.asset("assets/reactions/wow.gif", height: 50, width: 50),
        icon: Row(
          children: [
            Image.asset("assets/reactions/wow.png", height: 20, width: 20),
            Text(
              "  Wow",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(242, 177, 76, 1)),
            )
          ],
        ),
        title: Text(
          "Wow",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
    Reaction(
        id: 5,
        previewIcon:
            Image.asset("assets/reactions/angry.gif", height: 50, width: 50),
        icon: Row(
          children: [
            Image.asset("assets/reactions/angry.png", height: 20, width: 20),
            Text(
              "  Angry",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(222, 37, 35, 1)),
            )
          ],
        ),
        title: Text(
          "Angry",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
  ];

  @override
  void initState() {
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
      userDataDB = Hive.box<dynamic>('userdata');
    _get_all_project_post_details();


    // userpersonaldataLocalDB = Hive.box<dynamic>('mypersonaldata');
    // socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
    // usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    // socialFeedPostSavedDB = Hive.box<dynamic>('socialfeedpostsaved');
    // _scrollController = ScrollController();
    // socialEventSubCommLike = Hive.box<dynamic>('sm_event_joins');
    // socialEventDB = Hive.box<dynamic>('sm_events');
    // eventReactions = Hive.box<dynamic>('sm_event_likes');
    // print(this.id);
    // socialobj.getDiscussedProjectsWhere(this.id).then((value) {
    //   setState(() {
    //     projectData = value;
    //     if (projectData != null) {
    //       if ((projectData.get("summarydoc") != null)) {
    //         testLink = projectData.get("summarydoc");
    //         if (testLink.contains(" ")) {
    //           pdfFlag = false;
    //         } else
    //           pdfFlag = true;
    //       }
    //     }
    //   });
    // });
    // socialFeed.getSocialFeedPosts().then((value) {
    //   setState(() {
    //     socialfeed = value;
    //     if (socialfeed != null) {
    //       for (int i = 0; i < socialfeed.docs.length; i++) {
    //         if (socialfeed.docs[reactIndex].id == this.id) {
    //           reactIndex = i;
    //         }
    //         if (socialFeedPostReactionsDB
    //                 .get(_currentUserId + socialfeed.docs[reactIndex].id) !=
    //             null) {
    //           if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Like") {
    //             _reactionIndex.add(0);
    //           } else if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Love") {
    //             _reactionIndex.add(1);
    //           } else if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Haha") {
    //             _reactionIndex.add(2);
    //           } else if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Yay") {
    //             _reactionIndex.add(3);
    //           } else if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Wow") {
    //             _reactionIndex.add(4);
    //           } else if (socialFeedPostReactionsDB
    //                   .get(_currentUserId + socialfeed.docs[reactIndex].id) ==
    //               "Angry") {
    //             _reactionIndex.add(5);
    //           }
    //         } else {
    //           _reactionIndex.add(-2);
    //         }
    //       }
    //     }
    //   });
    // });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: _body()));
    // return Scaffold(
    //     body: FileReaderView(
    //   filePath: fileUrl,
    // ));
  }

  _body() {
    databaseReference
        .child("sm_feeds")
        .child("reactions")
        .once()
        .then((value) {
      setState(() {
        if (mounted) {
          setState(() {
            countData = value.snapshot;
          });
        }
      });
    });
    databaseReference
        .child("hys_calling_data")
        .child("usercallstatus")
        .once()
        .then((value) {
      setState(() {
        if (mounted) {
          setState(() {
            callStatusCheck = value.snapshot;
          });
        }
      });
    });
    if (
        (current_post!= null)) {
      return ListView(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 18,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]),
        SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(top: 5),
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Color.fromRGBO(242, 246, 248, 1),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: (5.0), right: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 10.34,
                                  height:
                                      MediaQuery.of(context).size.width / 10.34,
                                  child: Image.network(
                                    current_post["profilepic"],
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Image.asset(
                                        "assets/maleicon.jpg",
                                      );
                                    },
                                  ),
                                ),
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
                                  Text(current_post["first_name"]+" "+current_post["last_name"],
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(' has Discussed a Project on '),
                                  // Text(projectData.docs[reactIndex].get("title"),
                                  //     style: TextStyle(fontWeight: FontWeight.w500))
                                ]),
                                Row(
                                  children: [
                                    Text(current_post["title"],
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500))
                                  ],
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
              SizedBox(
                height: 20,
              ),
              Container(
                  padding: EdgeInsets.all(7),
                  width: MediaQuery.of(context).size.width - 10,
                  child: Text(current_post["content"])),
              SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.dstATop),
                        image: AssetImage(current_post["theme"]),
                        fit: BoxFit.cover),
                  ),
                  width: MediaQuery.of(context).size.width - 10,
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Title : ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              current_post["title"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Class : ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              current_post["grade"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Subject : ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              current_post["subject"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Topic : ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              current_post["topic"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 17,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  child: Row(children: [
                                (current_post["projectvideourl"] != "")
                                    ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Video_Player(
                                                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                    current_post["projectvideourl"]);
                                              },
                                            ),
                                          );
                                        },
                                        child: Material(
                                          elevation: 1,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color(0xFFE9A81D)),
                                              child: Center(
                                                  child: Icon(Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 15))),
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(width: 5),
                                (current_post["reqvideourl"] != "")
                                    ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Video_Player(
                                                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                   current_post["reqvideourl"]);
                                              },
                                            ),
                                          );
                                        },
                                        child: Material(
                                          elevation: 1,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color(0xFFE9A81D)),
                                              child: Center(
                                                  child: Icon(Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 15))),
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(width: 5),
                                (current_post["summarydoc"] != "")
                                    ? InkWell(
                                        onTap: () {
                                          // PdftronFlutter.openDocument(
                                          //     projectData.get("summarydoc"));
                                          // OpenFile.open(projectData.docs[reactIndex]
                                          //     .get("summarydoc"));
                                          // _launchURL(projectData.docs[reactIndex]
                                          //     .get("summarydoc"));
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => ViewFile(
                                          //             projectData.docs[reactIndex]
                                          //                 .get("summarydoc"))));

                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) {
                                          //       return Video_Player(
                                          //           "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                          //           projectData.docs[reactIndex].get("reqvideourl"));
                                          //     },
                                          //   ),
                                          // );
                                        },
                                        child: Material(
                                          elevation: 1,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                // color: Color(0xFFE9A81D)
                                              ),
                                              child: Center(
                                                  child: Icon(
                                                      Icons.picture_as_pdf,
                                                      color: Colors.red,
                                                      size: 15))),
                                        ),
                                      )
                                    : SizedBox()
                              ])),
                              // InkWell(
                              //   onTap: () {
                              //     // Navigator.push(
                              //     //     context,
                              //     //     MaterialPageRoute(
                              //     //         builder: (context) =>
                              //     //             ViewFile(projectData.docs[reactIndex].id)));
                              //   },
                              //   child: Container(
                              //     child: Text("....See More",
                              //         style: TextStyle(
                              //             fontFamily: 'Nunito Sans',
                              //             fontSize: 14,
                              //             fontWeight: FontWeight.w600,
                              //             color: Colors.blue)),
                              //   ),
                              // )
                            ])
                      ],
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  // image: DecorationImage(
                  //     colorFilter: new ColorFilter.mode(
                  //         Colors.black.withOpacity(0.3), BlendMode.dstATop),
                  //     image: AssetImage(projectData.docs[reactIndex].get("theme")),
                  //     fit: BoxFit.cover),
                ),
                width: MediaQuery.of(context).size.width - 10,
                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: [
                      SizedBox(
                        height: 4,
                      ),
                      (current_post["requirements"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Requirement's  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 4,
                      ),
                      (current_post["requirements"] != "")?Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["requirements"].toString(),
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["theory"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Theory  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                      (current_post["theory"] != "")?Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["theory"].toString(),
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["procedure_"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Procedure  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                    (current_post["procedure_"] != "")? Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(current_post["procedure_"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                            )),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["summarydoc"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Brief's and Insights ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                      (pdfFlag == false)
                          ? Container(
                              width: MediaQuery.of(context).size.width - 10,
                              child:
                                  Text(current_post["summarydoc"],
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                      )),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // PdftronFlutter.openDocument(
                                    //     projectData.get("summarydoc"));
                                  },
                                  child: Column(children: [
                                    Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/fileuploadicon.png')))),
                                    // Text("Briefs and insights",
                                    //     style: TextStyle(
                                    //         color: Colors.black54,
                                    //         fontSize: 14,
                                    //         fontWeight: FontWeight.w500))
                                  ]),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["purchasedfrom"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Materials Can be Purchased From  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                     (current_post["purchasedfrom"] != "")? Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["purchasedfrom"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["findings"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Findings  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                      (current_post["findings"] != "")?Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["findings"].toString(),
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["otherdoc"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "References  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                        (current_post["otherdoc"] != "")?Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["otherdoc"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["similartheory"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Similar Projects  ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 4),
                      (current_post["similartheory"] != "")?
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["similartheory"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                          color: Colors.white54,
                          height: 1,
                          width: MediaQuery.of(context).size.width),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("2",
                                            // countData.child(projectData.id).child("likecount").value
                                            //     .toString(),
                                            style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                color: Color.fromRGBO(
                                                    205, 61, 61, 1)),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Image.asset(
                                              "assets/reactions/like.png",
                                              height: 15,
                                              width: 15),
                                          Image.asset(
                                              "assets/reactions/laugh.png",
                                              height: 15,
                                              width: 15),
                                          Image.asset(
                                              "assets/reactions/wow.png",
                                              height: 15,
                                              width: 15),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShowSocialFeedComments(
                                                      current_post["post_id"])));
                                    },
                                    child: Container(
                                      child: RichText(
                                        text: TextSpan(text:"2",
                                            // text: countData.child(projectData.id).child("commentcount").value
                                            //     .toString(),
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              color: Color.fromRGBO(
                                                  205, 61, 61, 1),
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: ' Comments',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.8),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Text("2",
                                          // countData.child(projectData.id).child("viewscount").value
                                          //     .toString(),
                                          style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              color: Color.fromRGBO(
                                                  205, 61, 61, 1)),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(FontAwesome5.eye,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 12),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                margin:
                                    EdgeInsets.only(left: 2, right: 2, top: 5),
                                color: Colors.white54,
                                height: 1,
                                width: MediaQuery.of(context).size.width),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 15),
                                    child: Row(
                                      children: [
                                        
                                        // FlutterReactionButtonCheck(
                                        //   // onReactionChanged:
                                        //   //     (reaction, index, ischecked) {
                                        //   //   setState(() {
                                        //   //     _reactionIndex[reactIndex] =
                                        //   //         index;
                                        //   //   });

                                        //   //   if (socialFeedPostReactionsDB.get(
                                        //   //           _currentUserId +
                                        //   //               projectData.id) !=
                                        //   //       null) {
                                        //   //     if (index == -1) {
                                        //   //       setState(() {
                                        //   //         _reactionIndex[reactIndex] =
                                        //   //             -2;
                                        //   //       });
                                        //   //       _notificationdb
                                        //   //           .deleteSocialFeedReactionsNotification(
                                        //   //               projectData.id);
                                        //   //       socialFeedPostReactionsDB
                                        //   //           .delete(_currentUserId +
                                        //   //               projectData.id);
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) -
                                        //   //             1
                                        //   //       });
                                        //   //     } else {
                                        //   //       if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           0) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             projectData.get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " liked your post.",
                                        //   //             "You got a like!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Like",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Like");
                                        //   //       } else if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           1) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             projectData.get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " loved your post.",
                                        //   //             "You got a reaction!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Love",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Love");
                                        //   //       } else if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           2) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             projectData.get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " reacted haha on your post.",
                                        //   //             "You got a reaction!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Haha",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Haha");
                                        //   //       } else if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           3) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             socialfeed
                                        //   //                 .docs[reactIndex]
                                        //   //                 .get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " reacted yay on your post.",
                                        //   //             "You got a reaction!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Yay",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Yay");
                                        //   //       } else if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           4) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             socialfeed
                                        //   //                 .docs[reactIndex]
                                        //   //                 .get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " reacted wow on your post.",
                                        //   //             "You got a reaction!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Wow",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Wow");
                                        //   //       } else if (_reactionIndex[
                                        //   //               reactIndex] ==
                                        //   //           5) {
                                        //   //         _notificationdb.socialFeedReactionsNotifications(
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname"),
                                        //   //             personaldata.docs[0]
                                        //   //                 .get("profilepic"),
                                        //   //             projectData
                                        //   //                 .get("username"),
                                        //   //             projectData.get("userid"),
                                        //   //             personaldata.docs[0].get(
                                        //   //                     "firstname") +
                                        //   //                 " " +
                                        //   //                 personaldata.docs[0]
                                        //   //                     .get("lastname") +
                                        //   //                 " reacted angry on your post.",
                                        //   //             "You got a reaction!",
                                        //   //             current_date,
                                        //   //             usertokendataLocalDB.get(
                                        //   //                 projectData
                                        //   //                     .get("userid")),
                                        //   //             projectData.id,
                                        //   //             reactIndex,
                                        //   //             "Angry",
                                        //   //             comparedate);
                                        //   //         socialFeedPostReactionsDB.put(
                                        //   //             _currentUserId +
                                        //   //                 projectData.id,
                                        //   //             "Angry");
                                        //   //       }
                                        //   //     }
                                        //   //   } else {
                                        //   //     if (_reactionIndex[reactIndex] ==
                                        //   //         -1) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " liked your post.",
                                        //   //               "You got a like!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Like",
                                        //   //               comparedate);
                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Like");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString())+
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         0) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " liked your post.",
                                        //   //               "You got a like!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Like",
                                        //   //               comparedate);
                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Like");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         1) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " loved your post.",
                                        //   //               "You got a reaction!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Love",
                                        //   //               comparedate);

                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Love");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         2) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " reacted haha on your post.",
                                        //   //               "You got a reaction!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Haha",
                                        //   //               comparedate);

                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Haha");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         3) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " reacted yay on your post.",
                                        //   //               "You got a reaction!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Yay",
                                        //   //               comparedate);
                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Yay");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         4) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " reacted wow on your post.",
                                        //   //               "You got a reaction!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Wow",
                                        //   //               comparedate);
                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Wow");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                 socialfeed
                                        //   //                     .docs[reactIndex]
                                        //   //                     .id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     } else if (_reactionIndex[
                                        //   //             reactIndex] ==
                                        //   //         5) {
                                        //   //       _notificationdb
                                        //   //           .socialFeedReactionsNotifications(
                                        //   //               personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "firstname") +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname"),
                                        //   //               personaldata.docs[
                                        //   //                       0]
                                        //   //                   .get("profilepic"),
                                        //   //               projectData.get(
                                        //   //                   "username"),
                                        //   //               projectData
                                        //   //                   .get("userid"),
                                        //   //               personaldata.docs[0].get(
                                        //   //                       "firstname") +
                                        //   //                   " " +
                                        //   //                   personaldata.docs[
                                        //   //                           0]
                                        //   //                       .get(
                                        //   //                           "lastname") +
                                        //   //                   " reacted angry on your post.",
                                        //   //               "You got a reaction!",
                                        //   //               current_date,
                                        //   //               usertokendataLocalDB
                                        //   //                   .get(projectData
                                        //   //                       .get("userid")),
                                        //   //               projectData.id,
                                        //   //               reactIndex,
                                        //   //               "Angry",
                                        //   //               comparedate);
                                        //   //       socialFeedPostReactionsDB.put(
                                        //   //           _currentUserId +
                                        //   //               projectData.id,
                                        //   //           "Angry");
                                        //   //       databaseReference
                                        //   //           .child("sm_feeds")
                                        //   //           .child("reactions")
                                        //   //           .child(projectData.id)
                                        //   //           .update({
                                        //   //         'likecount': int.parse(countData.child(
                                        //   //                     projectData.id).child("likecount").value.toString()) +
                                        //   //             1
                                        //   //       });
                                        //   //     }
                                        //   //     socialFeed.updateReactionCount(
                                        //   //         projectData.id, {
                                        //   //       "likescount": countData.child(projectData.id).child("likecount").value
                                        //   //     });
                                        //   //   }
                                        //   // },
                                        //   reactions: reactions,
                                        //   initialReaction: _reactionIndex[
                                        //               reactIndex] ==
                                        //           -1
                                        //       ? Reaction(
                                        //           icon: Row(
                                        //             children: [
                                        //               Icon(
                                        //                   FontAwesome5
                                        //                       .thumbs_up,
                                        //                   color:
                                        //                       Color(0xff0962ff),
                                        //                   size: 14),
                                        //               Text(
                                        //                 "  Like",
                                        //                 style: TextStyle(
                                        //                     fontSize: 13,
                                        //                     fontWeight:
                                        //                         FontWeight.w700,
                                        //                     color: Color(
                                        //                         0xff0962ff)),
                                        //               )
                                        //             ],
                                        //           ),
                                        //         )
                                        //       : _reactionIndex[reactIndex] == -2
                                        //           ? Reaction(
                                        //               icon: Row(
                                        //                 children: [
                                        //                   Icon(
                                        //                       FontAwesome5
                                        //                           .thumbs_up,
                                        //                       color: Color
                                        //                           .fromRGBO(
                                        //                               0,
                                        //                               0,
                                        //                               0,
                                        //                               0.8),
                                        //                       size: 14),
                                        //                   Text(
                                        //                     "  Like",
                                        //                     style: TextStyle(
                                        //                         fontSize: 13,
                                        //                         fontWeight:
                                        //                             FontWeight
                                        //                                 .w700,
                                        //                         color: Colors
                                        //                             .black45),
                                        //                   )
                                        //                 ],
                                        //               ),
                                        //             )
                                        //           : reactions[_reactionIndex[
                                        //               reactIndex]],
                                        //   selectedReaction: Reaction(
                                        //     icon: Row(
                                        //       children: [
                                        //         Icon(FontAwesome5.thumbs_up,
                                        //             color: Color.fromRGBO(
                                        //                 0, 0, 0, 0.8),
                                        //             size: 14),
                                        //         Text(
                                        //           "  Like",
                                        //           style: TextStyle(
                                        //               fontSize: 13,
                                        //               fontWeight:
                                        //                   FontWeight.w700,
                                        //               color: Colors.black45),
                                        //         )
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             SocialFeedAddComments(
                                      //                 projectData.id)));
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(FontAwesome5.comment,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              size: 14),
                                          Text(
                                            "  Comment",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black45),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             ShareFeedPost(
                                      //                 projectData.id)));
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(FontAwesome5.share,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              size: 14),
                                          Text(
                                            "  Share",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black45),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                         
                          ],
                        ),
                      ),
                   
                    ])),
              )
            ])),
      ]);
    }
  }
}
