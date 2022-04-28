import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/FeedPost/shareFeedPost.dart';
import 'package:flutter/material.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hys/database/questionSection/crud.dart';

import '../FeedPost/CommentPage.dart';

class Ideas extends StatefulWidget {
  String id;
  Ideas(this.id);
  @override
  _IdeasState createState() => _IdeasState(this.id);
}

SocialFeedPost socialobj = SocialFeedPost();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
QuerySnapshot socialfeed;
ScrollController _controller;

class _IdeasState extends State<Ideas> {
  String id;
  _IdeasState(this.id);
  List<int> _reactionIndex = [];
  SocialFeedNotification _notificationdb = SocialFeedNotification();
  int calCulatedindex = 0;
  DataSnapshot countData;
  DataSnapshot callStatusCheck;
  Box<dynamic> socialFeedPostReactionsDB;
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  QuerySnapshot allUserpersonaldata;
  QuerySnapshot allUserschooldata;
  CrudMethods crudobj = CrudMethods();
  Box<dynamic> usertokendataLocalDB;
  SocialFeedPost socialFeed = SocialFeedPost();
  Box<dynamic> allSocialPostLocalDB;
  List<dynamic> allBlogPostData = [];
  Future<void> _get_all_blog_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_blog_posts'),
    );

    print("get_all_sm_blog_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB.put("blogpost", json.decode(response.body));
      });
    }
  }

  int blog_index;

  Future<void> _print_current_blog_post_details() async {
    allSocialPostLocalDB = await Hive.openBox('allsocialposts');
    setState(() {
      allBlogPostData = allSocialPostLocalDB.get("blogpost");
      print(allBlogPostData.length);
      for (int i = 0; i < allBlogPostData.length; i++) {
        if (allBlogPostData[i]["post_id"].toString() == id.toString()) {
          blog_index = i;
        }

        // for (int j = 0; j < allPostData.length; j++) {
        //   if (allPostData[j]["post_id"] == allBlogPostData[i]["post_id"]) {
        //     setState(() {
        //       allPostLikeCount[j] = allBlogPostData[i]["like_count"];
        //       allPostCommentCount[j] = allBlogPostData[i]["comment_count"];
        //       allPostViewCount[j] = allBlogPostData[i]["view_count"];
        //       allPostImpressionCount[j] =
        //           allBlogPostData[i]["impression_count"];
        //     });
        //   }
        // }
      }
    });
  }

  @override
  void initState() {
    _print_current_blog_post_details();

    usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    crudobj.getAllUserSchoolData().then((value) {
      setState(() {
        allUserschooldata = value;
      });
    });
    crudobj.getAllUserData().then((value) {
      setState(() {
        allUserpersonaldata = value;
      });
    });
    socialobj.getUserBlogData().then((value) {
      setState(() {
        socialfeed = value;
        if (socialfeed != null) {
          for (int i = 0; i < socialfeed.docs.length; i++) {
            if (socialfeed.docs[i].id == this.id) {
              setState(() {
                calCulatedindex = i;
              });
            }
            if (socialFeedPostReactionsDB
                    .get(_currentUserId + socialfeed.docs[i].id) !=
                null) {
              if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Like") {
                _reactionIndex.add(0);
              } else if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Love") {
                _reactionIndex.add(1);
              } else if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Haha") {
                _reactionIndex.add(2);
              } else if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Yay") {
                _reactionIndex.add(3);
              } else if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Wow") {
                _reactionIndex.add(4);
              } else if (socialFeedPostReactionsDB
                      .get(_currentUserId + socialfeed.docs[i].id) ==
                  "Angry") {
                _reactionIndex.add(5);
              }
            } else {
              _reactionIndex.add(-2);
            }
          }
        }
      });
    });

    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      // await showDialog or Show add banners or whatever
      // then
      return false; // return true if the route to be popped
    }

    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: _body(),
    ));
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

  _body() {
    databaseReference.child("sm_feeds").child("reactions").once().then((value) {
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
    if ((socialfeed != null) &&
        (countData != null) &&
        (callStatusCheck != null) &&
        (personaldata != null) &&
        (allUserpersonaldata != null) &&
        (allUserschooldata != null)) {
      print(socialfeed.docs.length);
      return _blog(blog_index);
    }
  }

  _blog(int i) {
    String jsonString = allBlogPostData[i]["blog_content"];
    //String contentValue = converter.encode(_loadDocument(jsonString).toDelta());

    return Container(
        padding: EdgeInsets.only(top: 5),
        margin: EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Color.fromRGBO(242, 246, 248, 1),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView(
          children: [
            Column(children: [
              Padding(
                  padding: const EdgeInsets.only(left: (5.0), right: 2),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Row(children: [
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    child: CachedNetworkImage(
                                      imageUrl: allBlogPostData[i]
                                          ['profilepic'],
                                    )
                                    // child: Image.network(
                                    //   socialfeed.docs[i].get("userprofilepic"),
                                    //   loadingBuilder: (BuildContext context,
                                    //       Widget child,
                                    //       ImageChunkEvent loadingProgress) {
                                    //     if (loadingProgress == null) return child;
                                    //     return Image.asset(
                                    //       "assets/maleicon.jpg",
                                    //     );
                                    //   },
                                    // ),
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
                                  Text(allBlogPostData[i]["blogger_name"],
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(' has Created a Blog. '),
                                ]),
                              ]))
                        ]))
                      ])),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 15,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(allBlogPostData[i]['blog_title'],
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black,
                              fontFamily: 'Nunito Sans',
                              fontSize: 18,
                              wordSpacing: 2)),
                    ),
                  )
                ],
              ),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(allBlogPostData[i]['blog_intro'],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.black,
                        fontFamily: 'Nunito Sans',
                        fontSize: 15,
                        wordSpacing: 1)),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text("~ ",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Nunito Sans',
                          wordSpacing: 1)),
                  Text(allBlogPostData[i]['blogger_name'],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          wordSpacing: 1)),
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              (allBlogPostData[i]["image_url"] != null)
                  ? Container(
                      child: CachedNetworkImage(
                          imageUrl: allBlogPostData[i]["image_url"],
                          fit: BoxFit.contain),
                      height: 200,
                      width: MediaQuery.of(context).size.width - 100)
                  : SizedBox(),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Html(data: jsonString)),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                      margin: EdgeInsets.all(8.0),
                      height: 140,
                      width: 120,
                      child: CachedNetworkImage(
                          imageUrl: allBlogPostData[i]['profilepic'])),
                  Container(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(allBlogPostData[i]["personal_bio"],
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontFamily: 'Nunito Sans',
                                      fontStyle: FontStyle.italic,
                                      wordSpacing: 1)),
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    allBlogPostData[i]["like_count"].toString(),
                                    style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        color: Color.fromRGBO(205, 61, 61, 1)),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Image.asset("assets/reactions/like.png",
                                      height: 15, width: 15),
                                  Image.asset("assets/reactions/laugh.png",
                                      height: 15, width: 15),
                                  Image.asset("assets/reactions/wow.png",
                                      height: 15, width: 15),
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
                                              socialfeed.docs[i].id)));
                            },
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                    text: allBlogPostData[i]["comment_count"]
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' Comments',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 12,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
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
                                  allBlogPostData[i]["view_count"].toString(),
                                  style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1)),
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
                        margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                        color: Colors.white54,
                        height: 1,
                        width: MediaQuery.of(context).size.width),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Row(
                              children: [
                                FlutterReactionButtonCheck(
                                  onReactionChanged:
                                      (reaction, index, ischecked) {
                                    setState(() {
                                      _reactionIndex[0] = index;
                                    });

                                    if (socialFeedPostReactionsDB.get(
                                            _currentUserId +
                                                socialfeed.docs[i].id) !=
                                        null) {
                                      if (index == -1) {
                                        setState(() {
                                          _reactionIndex[0] = -2;
                                        });
                                        _notificationdb
                                            .deleteSocialFeedReactionsNotification(
                                                socialfeed.docs[i].id);
                                        socialFeedPostReactionsDB.delete(
                                            _currentUserId +
                                                socialfeed.docs[i].id);
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) -
                                              1
                                        });
                                      } else {
                                        if (_reactionIndex[0] == 0) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[
                                                              0]
                                                          .get("firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata
                                                      .docs[0]
                                                      .get("profilepic"),
                                                  socialfeed
                                                      .docs[i]
                                                      .get("username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata.docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " liked your post.",
                                                  "You got a like!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Like",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Like");
                                        } else if (_reactionIndex[0] == 1) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[
                                                              0]
                                                          .get("firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata
                                                      .docs[0]
                                                      .get("profilepic"),
                                                  socialfeed
                                                      .docs[i]
                                                      .get("username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata.docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " loved your post.",
                                                  "You got a reaction!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Love",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Love");
                                        } else if (_reactionIndex[0] == 2) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[
                                                              0]
                                                          .get("firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata
                                                      .docs[0]
                                                      .get("profilepic"),
                                                  socialfeed
                                                      .docs[i]
                                                      .get("username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata.docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " reacted haha on your post.",
                                                  "You got a reaction!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Haha",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Haha");
                                        } else if (_reactionIndex[0] == 3) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[0].get(
                                                          "firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata.docs[
                                                          0]
                                                      .get("profilepic"),
                                                  socialfeed.docs[i].get(
                                                      "username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata
                                                          .docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " reacted yay on your post.",
                                                  "You got a reaction!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Yay",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Yay");
                                        } else if (_reactionIndex[0] == 4) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[0].get(
                                                          "firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata.docs[
                                                          0]
                                                      .get("profilepic"),
                                                  socialfeed.docs[i].get(
                                                      "username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata
                                                          .docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " reacted wow on your post.",
                                                  "You got a reaction!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Wow",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Wow");
                                        } else if (_reactionIndex[0] == 5) {
                                          _notificationdb
                                              .socialFeedReactionsNotifications(
                                                  personaldata.docs[
                                                              0]
                                                          .get("firstname") +
                                                      personaldata.docs[
                                                              0]
                                                          .get("lastname"),
                                                  personaldata
                                                      .docs[0]
                                                      .get("profilepic"),
                                                  socialfeed
                                                      .docs[i]
                                                      .get("username"),
                                                  socialfeed.docs[i]
                                                      .get("userid"),
                                                  personaldata.docs[0]
                                                          .get("firstname") +
                                                      " " +
                                                      personaldata.docs[0]
                                                          .get("lastname") +
                                                      " reacted angry on your post.",
                                                  "You got a reaction!",
                                                  current_date,
                                                  usertokendataLocalDB.get(
                                                      socialfeed.docs[i]
                                                          .get("userid")),
                                                  socialfeed.docs[i].id,
                                                  i,
                                                  "Angry",
                                                  comparedate);
                                          socialFeedPostReactionsDB.put(
                                              _currentUserId +
                                                  socialfeed.docs[i].id,
                                              "Angry");
                                        }
                                      }
                                    } else {
                                      if (_reactionIndex[0] == -1) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                socialfeed.docs[i]
                                                    .get("username"),
                                                socialfeed.docs[i]
                                                    .get("userid"),
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " liked your post.",
                                                "You got a like!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Like",
                                                comparedate);
                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Like");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 0) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                socialfeed.docs[i]
                                                    .get("username"),
                                                socialfeed.docs[i]
                                                    .get("userid"),
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " liked your post.",
                                                "You got a like!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Like",
                                                comparedate);
                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Like");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 1) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                socialfeed.docs[i]
                                                    .get("username"),
                                                socialfeed.docs[i]
                                                    .get("userid"),
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " loved your post.",
                                                "You got a reaction!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Love",
                                                comparedate);

                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Love");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 2) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                socialfeed.docs[i]
                                                    .get("username"),
                                                socialfeed.docs[i]
                                                    .get("userid"),
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " reacted haha on your post.",
                                                "You got a reaction!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Haha",
                                                comparedate);

                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Haha");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 3) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0].get(
                                                        "firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0].get(
                                                    "profilepic"),
                                                socialfeed.docs[i].get(
                                                    "username"),
                                                socialfeed
                                                    .docs[i]
                                                    .get("userid"),
                                                personaldata
                                                        .docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " reacted yay on your post.",
                                                "You got a reaction!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Yay",
                                                comparedate);
                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Yay");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 4) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0].get(
                                                        "firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0].get(
                                                    "profilepic"),
                                                socialfeed.docs[i].get(
                                                    "username"),
                                                socialfeed
                                                    .docs[i]
                                                    .get("userid"),
                                                personaldata
                                                        .docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " reacted wow on your post.",
                                                "You got a reaction!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Wow",
                                                comparedate);
                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Wow");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      } else if (_reactionIndex[0] == 5) {
                                        _notificationdb
                                            .socialFeedReactionsNotifications(
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                socialfeed.docs[i]
                                                    .get("username"),
                                                socialfeed.docs[i]
                                                    .get("userid"),
                                                personaldata.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    personaldata.docs[0]
                                                        .get("lastname") +
                                                    " reacted angry on your post.",
                                                "You got a reaction!",
                                                current_date,
                                                usertokendataLocalDB.get(
                                                    socialfeed.docs[i]
                                                        .get("userid")),
                                                socialfeed.docs[i].id,
                                                i,
                                                "Angry",
                                                comparedate);
                                        socialFeedPostReactionsDB.put(
                                            _currentUserId +
                                                socialfeed.docs[i].id,
                                            "Angry");
                                        databaseReference
                                            .child("sm_feeds")
                                            .child("reactions")
                                            .child(socialfeed.docs[i].id)
                                            .update({
                                          'likecount': int.parse(countData
                                                  .child(socialfeed.docs[i].id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) +
                                              1
                                        });
                                      }
                                      socialFeed.updateReactionCount(
                                          socialfeed.docs[i].id, {
                                        "likescount": int.parse(countData
                                            .child(socialfeed.docs[i].id)
                                            .child("likecount")
                                            .value
                                            .toString())
                                      });
                                    }
                                  },
                                  reactions: reactions,
                                  initialReaction: _reactionIndex[0] == -1
                                      ? Reaction(
                                          icon: Row(
                                            children: [
                                              Icon(FontAwesome5.thumbs_up,
                                                  color: Color(0xff0962ff),
                                                  size: 14),
                                              Text(
                                                "  Like",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xff0962ff)),
                                              )
                                            ],
                                          ),
                                        )
                                      : _reactionIndex[0] == -2
                                          ? Reaction(
                                              icon: Row(
                                                children: [
                                                  Icon(FontAwesome5.thumbs_up,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.8),
                                                      size: 14),
                                                  Text(
                                                    "  Like",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black45),
                                                  )
                                                ],
                                              ),
                                            )
                                          : reactions[_reactionIndex[0]],
                                  selectedReaction: Reaction(
                                    icon: Row(
                                      children: [
                                        Icon(FontAwesome5.thumbs_up,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 14),
                                        Text(
                                          "  Like",
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
                          InkWell(
                            onTap: () {
                             
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(FontAwesome5.comment,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
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
                                      builder: (context) => ShareFeedPost(
                                          socialfeed.docs[i].id)));
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(FontAwesome5.share,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
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
            ])
          ],
        ));
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
