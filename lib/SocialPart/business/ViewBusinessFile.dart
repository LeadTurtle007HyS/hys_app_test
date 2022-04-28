import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hys/SocialPart/FeedPost/AddCommentPage.dart';
import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/notificationdb.dart';
import 'package:hys/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/FeedPost/CommentPage.dart';
import 'package:http/http.dart' as http;

class ViewBusinessFile extends StatefulWidget {
  String id;
  ViewBusinessFile(this.id);
  @override
  _ViewBusinessState createState() => _ViewBusinessState(this.id);
}

// MeetingDataSource _dataSource;

File _image;
SocialMCommentsDB commentobj = SocialMCommentsDB();

class _ViewBusinessState extends State<ViewBusinessFile> {
  String id;
  _ViewBusinessState(this.id);

  bool pdfFlag = false;
  String testLink = "";
  List<dynamic> files;
  List<dynamic> filesformat;

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

  List<dynamic> allBIdeasPostData = [];
  List<dynamic> isBIdeasPostExpanded = [];
  Future<void> _get_all_bideas_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_bideas_posts'),
    );

    print("get_all_sm_bideas_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB.put("businesspost", json.decode(response.body));
      });
      _print_all_bideas_post_details();
    }
  }

  Map current_post;
  Future<void> _print_all_bideas_post_details() async {
    setState(() {
      allBIdeasPostData = allSocialPostLocalDB.get("businesspost");

      for (int i = 0; i < allBIdeasPostData.length; i++) {
        setState(() {
          if (allBIdeasPostData[i]["post_id"] == this.id) {
            current_post = allBIdeasPostData[i];
            print(current_post);
            print("current_post");
          }
          isBIdeasPostExpanded.add(false);
        });
      }
      // for (int i = 0; i < allBIdeasPostData.length; i++) {
      //   // for (int j = 0; j < allPostData.length; j++) {
      //   //   if (allPostData[j]["post_id"] == allBIdeasPostData[i]["post_id"]) {
      //   //     // setState(() {
      //   //     //   allPostLikeCount[j] = allBIdeasPostData[i]["like_count"];
      //   //     //   allPostCommentCount[j] = allBIdeasPostData[i]["comment_count"];
      //   //     //   allPostViewCount[j] = allBIdeasPostData[i]["view_count"];
      //   //     //   allPostImpressionCount[j] =
      //   //     //       allBIdeasPostData[i]["impression_count"];
      //   //     // });
      //   //   }
      //   // }
      // }
    });
  }

  List<dynamic> allTaggedUsersData = [];
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

  List<dynamic> taggingData = [];

// Future<void> _get_all_users_data_for_tagging() async {
//     final http.Response response = await http.get(
//       Uri.parse('https://hys-api.herokuapp.com/get_all_users_data_for_tagging'),
//     );

//     print("get_all_users_data_for_taggigng: ${response.statusCode}");
//     if ((response.statusCode == 200) || (response.statusCode == 201)) {
//       setState(() {
//         taggingData = json.decode(response.body);
//         for (int i = 0; i < taggingData.length; i++) {
//           if (taggingData[i]["user_id"].toString() !=
//               userDataDB.get("user_id")) {
//             _users.add({
//               'id': taggingData[i]["user_id"].toString(),
//               'display': taggingData[i]["first_name"].toString() +
//                   " " +
//                   taggingData[i]["last_name"].toString(),
//               'full_name': taggingData[i]["school_name"].toString() +
//                   " | " +
//                   taggingData[i]["grade"].toString(),
//               'photo': taggingData[i]["profilepic"].toString()
//             });
//           }
//           selectedUserflag.add(false);
//         }
//       });
//     }
//   }

  Box<dynamic> allSocialPostLocalDB;
  Box<dynamic> userDataDB;

  @override
  void initState() {
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    userDataDB = Hive.box<dynamic>('userdata');
 
    _get_all_bideas_post_details();
    _get_all_tagged_users();

    // userpersonaldataLocalDB = Hive.box<dynamic>('mypersonaldata');
    // socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
    // usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    // socialFeedPostSavedDB = Hive.box<dynamic>('socialfeedpostsaved');
    // _scrollController = ScrollController();
    // socialEventSubCommLike = Hive.box<dynamic>('sm_event_joins');
    // socialEventDB = Hive.box<dynamic>('sm_events');
    // eventReactions = Hive.box<dynamic>('sm_event_likes');

    // socialobj.getDiscussedBusinessIdeasWhere(this.id).then((value) {
    //   setState(() {
    //     projectData = value;
    //     if (projectData != null) {
    //       files = projectData.get("documents");
    //       filesformat = projectData.get("formats");
    //       print(files);
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

  int number = 0;

  _body() {
    // databaseReference
    //     .child("sm_feeds")
    //     .child("reactions")
    //     .once()
    //     .then((value) {
    //   setState(() {
    //     if (mounted) {
    //       setState(() {
    //         countData = value.snapshot;
    //       });
    //     }
    //   });
    // });
    // databaseReference
    //     .child("hys_calling_data")
    //     .child("usercallstatus")
    //     .once()
    //     .then((value) {
    //   setState(() {
    //     if (mounted) {
    //       setState(() {
    //         callStatusCheck = value.snapshot;
    //       });
    //     }
    //   });
    // });

    // for(int i=0;i<allTaggedUsersData.length;i++){
    //   if(allTaggedUsersData[i]["usertaglist_id"]==memberlist_id){
    //     tagids.add(allTaggedUsersData[i]["user_id"]);
    //   }
    // }

// for(int k=0;k<memberlist.length;k++){

// }

    if ((userDataDB != null) &&
        (allBIdeasPostData != null) &&
        (current_post != null)) {
      List<dynamic> allfiles = current_post["document_list"];
      List<dynamic> fileurl = [];
      List<dynamic> fileformats = [];

      for (int j = 0; j < allfiles.length; j++) {
        fileurl.add(allfiles[j]["file_url"]);
        fileformats.add(allfiles[j]["file_ext"]);
        print("file url added");
      }
      int totalDoc = allfiles.length;
      List<dynamic> memberlist = current_post["tag_list"];
      List<dynamic> tagids = [];
      // List<dynamic> taggedUsernames = projectData.get("membersname");
      // List<dynamic> taggedstring = projectData.get("taggedstring");
      // List<Widget> full = [];
      // String fullstring = taggedstring.join(' ');
      // print(taggedstring);
      // String prev = "";
      // for (int i = 0; i < taggedUsernames.length; i++) {
      //   int ind = fullstring.indexOf("@", 0);
      //   full.add(Text(fullstring.substring(0, ind)));
      //   full.add(InkWell(
      //       child: Text(taggedUsernames[number],
      //           style: TextStyle(color: Colors.blueAccent))));
      //   number = number + 1;
      //   fullstring = fullstring.substring(ind);
      // }
      // for (int i = 0; i < taggedstring.length; i++) {
      //   if (taggedstring[i] == "@") {
      //     String id = tagids[number];
      //     full.add(InkWell(
      //         onTap: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => OthersProfilePage(id, "")));
      //         },
      //         child: Text(
      //           taggedUsernames[number],
      //           style: TextStyle(
      //             fontFamily: 'Nunito Sans',
      //             color: Colors.blueAccent,
      //             fontSize: 14,
      //           ),
      //         )));
      //     number = number + 1;
      //   } else {
      //     full.add(Text(
      //       taggedstring[i],
      //       style: TextStyle(
      //         fontFamily: 'Nunito Sans',
      //         fontSize: 14,
      //         fontWeight: FontWeight.w500,
      //       ),
      //     ));
      //   }
      // }
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
                                  Text(
                                      current_post["first_name"] +
                                          " " +
                                          current_post["last_name"],
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(' has Discussed a Business Idea'),
                                  // Text(projectData.docs[i].get("title"),
                                  //     style: TextStyle(fontWeight: FontWeight.w500))
                                ]),
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
                                            ' Public ',
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
                          height: 17,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Attachments : ",
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                  child: (totalDoc == 1)
                                      ? InkWell(
                                          onTap: () {
                                            //   PdftronFlutter.openDocument(fileurl[0]);
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
                                                    child: (fileformats[0] ==
                                                            "pdf")
                                                        ? Icon(
                                                            Icons
                                                                .picture_as_pdf,
                                                            color: Colors.red,
                                                            size: 22)
                                                        : (fileformats[0] ==
                                                                "excel")
                                                            ? Icon(
                                                                FontAwesome5
                                                                    .file_excel,
                                                                color: Colors
                                                                    .red,
                                                                size: 22)
                                                            : (fileformats[0] ==
                                                                    "ppt")
                                                                ? Icon(
                                                                    FontAwesome5
                                                                        .file_powerpoint,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22)
                                                                : (fileformats[
                                                                            0] ==
                                                                        "word")
                                                                    ? Icon(
                                                                        FontAwesome5
                                                                            .file_word,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            22)
                                                                    : SizedBox())),
                                          ),
                                        )
                                      : (totalDoc > 1)
                                          ? Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // PdftronFlutter.openDocument(
                                                    //     fileurl[0]);
                                                  },
                                                  child: Material(
                                                    elevation: 1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          // color: Color(0xFFE9A81D)
                                                        ),
                                                        child: Center(
                                                            child: (fileformats[
                                                                        0] ==
                                                                    "pdf")
                                                                ? Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22)
                                                                : (fileformats[
                                                                            0] ==
                                                                        "excel")
                                                                    ? Icon(
                                                                        FontAwesome5
                                                                            .file_excel,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            22)
                                                                    : (fileformats[0] ==
                                                                            "ppt")
                                                                        ? Icon(
                                                                            FontAwesome5
                                                                                .file_powerpoint,
                                                                            color:
                                                                                Colors.red,
                                                                            size: 22)
                                                                        : (fileformats[0] == "word")
                                                                            ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                            : SizedBox())),
                                                  ),
                                                ),
                                                SizedBox(width: 7),
                                                InkWell(
                                                  onTap: () {
                                                    // PdftronFlutter.openDocument(
                                                    //    fileurl[1]);
                                                  },
                                                  child: Material(
                                                    elevation: 1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          // color: Color(0xFFE9A81D)
                                                        ),
                                                        child: Center(
                                                            child: (fileformats[
                                                                        1] ==
                                                                    "pdf")
                                                                ? Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22)
                                                                : (fileformats[
                                                                            1] ==
                                                                        "excel")
                                                                    ? Icon(
                                                                        FontAwesome5
                                                                            .file_excel,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            22)
                                                                    : (fileformats[1] ==
                                                                            "ppt")
                                                                        ? Icon(
                                                                            FontAwesome5
                                                                                .file_powerpoint,
                                                                            color:
                                                                                Colors.red,
                                                                            size: 22)
                                                                        : (fileformats[1] == "word")
                                                                            ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                            : SizedBox())),
                                                  ),
                                                ),
                                                SizedBox(width: 7),
                                                (totalDoc == 3)
                                                    ? InkWell(
                                                        onTap: () {
                                                          // PdftronFlutter
                                                          //     .openDocument(
                                                          //     fileurl[2]);
                                                        },
                                                        child: Material(
                                                          elevation: 1,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                // color: Color(0xFFE9A81D)
                                                              ),
                                                              child: Center(
                                                                  child: (fileformats[
                                                                              0] ==
                                                                          "pdf")
                                                                      ? Icon(
                                                                          Icons
                                                                              .picture_as_pdf,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              22)
                                                                      : (fileformats[2] ==
                                                                              "excel")
                                                                          ? Icon(
                                                                              FontAwesome5.file_excel,
                                                                              color: Colors.red,
                                                                              size: 22)
                                                                          : (fileformats[2] == "ppt")
                                                                              ? Icon(FontAwesome5.file_powerpoint, color: Colors.red, size: 22)
                                                                              : (fileformats[2] == "word")
                                                                                  ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                                  : SizedBox())),
                                                        ),
                                                      )
                                                    : SizedBox()
                                              ],
                                            )
                                          : SizedBox()),
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
                  //     image: AssetImage(projectData.docs[i].get("theme")),
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
                      (current_post["identification"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Identification of Problem  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["identification"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["solution"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Solution to identified Problem  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(
                          current_post["solution"],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["target"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Target Market  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(current_post["target"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["competitors"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Competitors  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(current_post["competitors"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["swot"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "SWOT Analysis  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(current_post["swot"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["funds"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Funds Required  ",
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
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        child: Text(current_post["funds"],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (current_post["memberlist_id"] != "")
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Team Members ",
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
                      // Container(
                      //     width: MediaQuery.of(context).size.width - 10,
                      //     child: Row(
                      //       children: [
                      //         (full.length >= 1) ? full[0] : SizedBox(),
                      //         (full.length >= 2) ? full[1] : SizedBox(),
                      //         (full.length >= 3) ? full[2] : SizedBox(),
                      //         (full.length >= 4) ? full[3] : SizedBox()
                      //       ],
                      //     )),
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
                                          Text(
                                            "2",
                                            // countData.child(projectData.id).child("likecount").value.toString(),
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
                                                      current_post[
                                                          "post_id"])));
                                    },
                                    child: Container(
                                      child: RichText(
                                        text: TextSpan(
                                            text: "2",
                                            // text: countData.child(projectData.id).child("commentcount").value.toString(),
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
                                        Text(
                                          "2",
                                          // countData.child(projectData.id).child("viewscount").value.toString(),
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
                                        //FlutterReactionButtonCheck(
                                        // onReactionChanged:
                                        //     (reaction, index, ischecked) {
                                        //   setState(() {
                                        //     _reactionIndex[reactIndex] =
                                        //         index;
                                        //   });

                                        //   if (socialFeedPostReactionsDB.get(
                                        //           _currentUserId +
                                        //               projectData.id) !=
                                        //       null) {
                                        //     if (index == -1) {
                                        //       setState(() {
                                        //         _reactionIndex[reactIndex] =
                                        //             -2;
                                        //       });
                                        //       _notificationdb
                                        //           .deleteSocialFeedReactionsNotification(
                                        //               projectData.id);
                                        //       socialFeedPostReactionsDB
                                        //           .delete(_currentUserId +
                                        //               projectData.id);
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) -
                                        //             1
                                        //       });
                                        //     } else {
                                        //       if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           0) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             projectData.get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " liked your post.",
                                        //             "You got a like!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Like",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Like");
                                        //       } else if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           1) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             projectData.get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " loved your post.",
                                        //             "You got a reaction!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Love",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Love");
                                        //       } else if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           2) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             projectData.get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " reacted haha on your post.",
                                        //             "You got a reaction!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Haha",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Haha");
                                        //       } else if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           3) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             socialfeed
                                        //                 .docs[reactIndex]
                                        //                 .get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " reacted yay on your post.",
                                        //             "You got a reaction!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Yay",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Yay");
                                        //       } else if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           4) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             socialfeed
                                        //                 .docs[reactIndex]
                                        //                 .get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " reacted wow on your post.",
                                        //             "You got a reaction!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Wow",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Wow");
                                        //       } else if (_reactionIndex[
                                        //               reactIndex] ==
                                        //           5) {
                                        //         _notificationdb.socialFeedReactionsNotifications(
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname"),
                                        //             personaldata.docs[0]
                                        //                 .get("profilepic"),
                                        //             projectData
                                        //                 .get("username"),
                                        //             projectData.get("userid"),
                                        //             personaldata.docs[0].get(
                                        //                     "firstname") +
                                        //                 " " +
                                        //                 personaldata.docs[0]
                                        //                     .get("lastname") +
                                        //                 " reacted angry on your post.",
                                        //             "You got a reaction!",
                                        //             current_date,
                                        //             usertokendataLocalDB.get(
                                        //                 projectData
                                        //                     .get("userid")),
                                        //             projectData.id,
                                        //             reactIndex,
                                        //             "Angry",
                                        //             comparedate);
                                        //         socialFeedPostReactionsDB.put(
                                        //             _currentUserId +
                                        //                 projectData.id,
                                        //             "Angry");
                                        //       }
                                        //     }
                                        //   } else {
                                        //     if (_reactionIndex[reactIndex] ==
                                        //         -1) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " liked your post.",
                                        //               "You got a like!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Like",
                                        //               comparedate);
                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Like");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         0) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " liked your post.",
                                        //               "You got a like!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Like",
                                        //               comparedate);
                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Like");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         1) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " loved your post.",
                                        //               "You got a reaction!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Love",
                                        //               comparedate);

                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Love");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         2) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " reacted haha on your post.",
                                        //               "You got a reaction!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Haha",
                                        //               comparedate);

                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Haha");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         3) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " reacted yay on your post.",
                                        //               "You got a reaction!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Yay",
                                        //               comparedate);
                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Yay");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         4) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " reacted wow on your post.",
                                        //               "You got a reaction!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Wow",
                                        //               comparedate);
                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Wow");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                 socialfeed
                                        //                     .docs[reactIndex]
                                        //                     .id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     } else if (_reactionIndex[
                                        //             reactIndex] ==
                                        //         5) {
                                        //       _notificationdb
                                        //           .socialFeedReactionsNotifications(
                                        //               personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "firstname") +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname"),
                                        //               personaldata.docs[
                                        //                       0]
                                        //                   .get("profilepic"),
                                        //               projectData.get(
                                        //                   "username"),
                                        //               projectData
                                        //                   .get("userid"),
                                        //               personaldata.docs[0].get(
                                        //                       "firstname") +
                                        //                   " " +
                                        //                   personaldata.docs[
                                        //                           0]
                                        //                       .get(
                                        //                           "lastname") +
                                        //                   " reacted angry on your post.",
                                        //               "You got a reaction!",
                                        //               current_date,
                                        //               usertokendataLocalDB
                                        //                   .get(projectData
                                        //                       .get("userid")),
                                        //               projectData.id,
                                        //               reactIndex,
                                        //               "Angry",
                                        //               comparedate);
                                        //       socialFeedPostReactionsDB.put(
                                        //           _currentUserId +
                                        //               projectData.id,
                                        //           "Angry");
                                        //       databaseReference
                                        //           .child("sm_feeds")
                                        //           .child("reactions")
                                        //           .child(projectData.id)
                                        //           .update({
                                        //         'likecount': int.parse(countData.child(
                                        //                     projectData.id).child("likecount").value.toString()) +
                                        //             1
                                        //       });
                                        //     }
                                        //     socialFeed.updateReactionCount(
                                        //         projectData.id, {
                                        //       "likescount": countData
                                        //               .child(projectData.id).child("likecount").value
                                        //     });
                                        //   }
                                        // },
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
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SocialFeedAddComments(
                                                      current_post[
                                                          "post_id"])));
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
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  current_post["post_id"]));
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
}
