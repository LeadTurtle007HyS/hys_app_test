import 'package:flutter/rendering.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hive/hive.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/SocialPart/FeedPost/shareFeedPost.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hys/SocialPart/FeedPost/CommentPage.dart';
import 'dart:math';
import 'package:story_view/story_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SocialFeedSavedPost extends StatefulWidget {
  @override
  _SocialFeedSavedPostState createState() => _SocialFeedSavedPostState();
}

class _SocialFeedSavedPostState extends State<SocialFeedSavedPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  QuerySnapshot savedPost;
  QuerySnapshot allUserpersonaldata;
  CrudMethods crudobj = CrudMethods();
  SocialFeedPost socialFeed = SocialFeedPost();
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  QuerySnapshot socialfeed;
  VideoPlayerController _controller;
  List<bool> _videControllerStatus = [];
  ScrollController _scrollController;
  bool _showAppbar = true;
  bool isScrollingDown = false;
  DataSnapshot countData;
  final databaseReference = FirebaseDatabase.instance.reference();
  Box<dynamic> socialFeedPostReactionsDB;
  Box<dynamic> socialFeedPostSavedDB;
  Box<dynamic> usertokendataLocalDB;
  List<int> _reactionIndex = [];
  SocialFeedNotification _notificationdb = SocialFeedNotification();
  QuerySnapshot notificationToken;
  List<int> indexcount = [];
  bool indexcountbool = false;

  @override
  void initState() {
    socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
    usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    socialFeedPostSavedDB = Hive.box<dynamic>('socialfeedpostsaved');
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    _notificationdb.getTokenData().then((value) {
      setState(() {
        notificationToken = value;
      });
      if (notificationToken != null) {
        for (int i = 0; i < notificationToken.docs.length; i++) {
          usertokendataLocalDB.put(notificationToken.docs[i].get("userid"),
              notificationToken.docs[i].get("token"));
        }
      }
    });
    socialFeed.getSocialFeedPosts().then((value) {
      setState(() {
        socialfeed = value;
        if (socialfeed != null) {
          for (int i = 0; i < socialfeed.docs.length; i++) {
            _videControllerStatus.add(false);
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
    crudobj.getAllUserData().then((value) {
      setState(() {
        allUserpersonaldata = value;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(() {});
    super.dispose();
  }

  var rng = new Random();
  List<String> _profileImg = [
    "assets/profile/profilem1.png",
    "assets/profile/profilem2.jpg",
    "assets/profile/profilem3.png",
    "assets/profile/profilef1.jpg",
    "assets/profile/profilef2.jpg",
    "assets/profile/profilef3.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Future<void> _pullRefresh() async {
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    _notificationdb.getTokenData().then((value) {
      setState(() {
        notificationToken = value;
      });
      if (notificationToken != null) {
        for (int i = 0; i < notificationToken.docs.length; i++) {
          usertokendataLocalDB.put(notificationToken.docs[i].get("userid"),
              notificationToken.docs[i].get("token"));
        }
      }
    });
    socialFeed.getSocialFeedPostSaved().then((value) {
      setState(() {
        savedPost = value;
      });
    });
    socialFeed.getSocialFeedPosts().then((value) {
      setState(() {
        socialfeed = value;
        if (socialfeed != null) {
          for (int i = 0; i < socialfeed.docs.length; i++) {
            _videControllerStatus.add(false);
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
  }

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
    if ((socialfeed != null) &&
        (countData != null) &&
        (savedPost != null) &&
        (personaldata != null) &&
        (allUserpersonaldata != null) &&
        (notificationToken != null)) {
      return RefreshIndicator(
        onRefresh: _pullRefresh,
        child: InViewNotifierList(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double vpHeight) {
            return deltaTop < (0.5 * vpHeight) &&
                deltaBottom > (0.5 * vpHeight);
          },
          itemCount: socialfeed.docs.length,
          builder: (BuildContext context, int i) {
            return InViewNotifierWidget(
                id: '$i',
                builder: (BuildContext context, bool isInView, Widget child) {
                  if (isInView) {
                    if (indexcount.isEmpty) {
                      print("empty $i");
                      indexcount.add(i);
                      databaseReference
                          .child("sm_feeds")
                          .child("reactions")
                          .child(socialfeed.docs[i].id)
                          .update({
                        'viewscount': int.parse(countData
                                .child(socialfeed.docs[i].id)
                                .child("viewscount")
                                .value) +
                            1
                      });

                      socialFeed.updateReactionCount(socialfeed.docs[i].id, {
                        'viewscount': countData
                            .child(socialfeed.docs[i].id)
                            .child("viewscount")
                      });
                    } else {
                      for (int j = 0; j < indexcount.length; j++) {
                        if (indexcount[j] == i) {
                          indexcountbool = true;
                          break;
                        }
                      }
                      if (indexcountbool == false) {
                        print("loop $i");
                        indexcount.add(i);

                        databaseReference
                            .child("sm_feeds")
                            .child("reactions")
                            .child(socialfeed.docs[i].id)
                            .update({
                          'viewscount': int.parse(countData
                                  .child(socialfeed.docs[i].id)
                                  .child("viewscount")
                                  .value) +
                              1
                        });
                        socialFeed.updateReactionCount(socialfeed.docs[i].id, {
                          'viewscount': int.parse(countData
                              .child(socialfeed.docs[i].id)
                              .child("viewscount")
                              .value)
                        });
                      }
                      indexcountbool = false;
                    }
                  }
                  return i == 0
                      ? when_I_is_Zero(i)
                      : socialfeed.docs[i].get("feedtype") == "shared"
                          ? _shareSocialFeed(i)
                          : _socialFeed(i);
                });
          },
        ),
      );
    } else
      return _loading();
  }

  when_I_is_Zero(int i) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Tab(
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black45, size: 23)),
                ),
                Text("Saved",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                SizedBox(
                  width: 40,
                )
              ],
            ),
          ),
          socialfeed.docs[i].get("feedtype") == "shared"
              ? _shareSocialFeed(i)
              : _socialFeed(i)
        ],
      ),
    );
  }

  Widget buildGridView(List imagesFile, int i) {
    return imagesFile.length == 1
        ? InkWell(
            onTap: () {
              // if (socialfeed.docs[i].get("feedtype") == "shared") {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => MultipleImagesPostInDetails(
              //               socialfeed.docs[i].get("sharefeedid"))));
              // } else {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => MultipleImagesPostInDetails(
              //               socialfeed.docs[i].id)));
              // }
            },
            child: Container(
                height: 300,
                width: 300,
                child: CachedNetworkImage(
                  imageUrl: imagesFile[0],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    "assets/loadingimg.gif",
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
          )
        : InkWell(
            onTap: () {
              // if (socialfeed.docs[i].get("feedtype") == "shared") {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => MultipleImagesPostInDetails(
              //               socialfeed.docs[i].get("sharefeedid"))));
              // } else {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => MultipleImagesPostInDetails(
              //               socialfeed.docs[i].id)));
              // }
            },
            child: Container(
              height: 300,
              child: GridView.count(
                controller: _scrollController,
                crossAxisCount: 2,
                childAspectRatio: imagesFile.length > 2 ? 1.3 : 0.65,
                children: List.generate(
                    imagesFile.length > 4 ? 4 : imagesFile.length, (index) {
                  return ((index == 3) && (imagesFile.length > 4))
                      ? Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: imagesFile[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset(
                                  "assets/loadingimg.gif",
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Positioned.fill(
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.black54,
                                  child: Text(
                                    '+' + "${imagesFile.length - 4}",
                                    style: TextStyle(
                                        fontSize: 32, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imagesFile[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            "assets/loadingimg.gif",
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        );
                }),
              ),
            ),
          );
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

  _socialFeed(int i) {
    List tagedusername = socialfeed.docs[i].get("tagedusername");
    List tageduserid = socialfeed.docs[i].get("tageduserid");
    List imagelist = socialfeed.docs[i].get("imagelist");
    String video = socialfeed.docs[i].get("videolist");

    return Container(
      padding: EdgeInsets.only(top: 5),
      margin: EdgeInsets.all(7),
      decoration: BoxDecoration(
          color: Color.fromRGBO(242, 246, 248, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: (5.0), right: 5),
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
                              width: MediaQuery.of(context).size.width / 10.34,
                              height: MediaQuery.of(context).size.width / 10.34,
                              child: CachedNetworkImage(
                                imageUrl:
                                    socialfeed.docs[i].get("userprofilepic"),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "assets/loadingimg.gif",
                                    )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      _chooseHeaderAccordingToMood(
                          socialfeed.docs[i].get("usermood"),
                          i,
                          tagedusername,
                          tageduserid),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(FontAwesome5.ellipsis_h,
                        color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                    onPressed: () {
                      moreOptionsSMPostViewer(context, i);
                    }),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
              child: ReadMoreText(
                socialfeed.docs[i].get("message"),
                textAlign: TextAlign.left,
                trimLines: 4,
                colorClickableText: Color(0xff0962ff),
                trimMode: TrimMode.Line,
                trimCollapsedText: 'read more',
                trimExpandedText: 'Show less',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.8),
                  fontWeight: FontWeight.w400,
                ),
                lessStyle: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 12,
                  color: Color(0xff0962ff),
                  fontWeight: FontWeight.w700,
                ),
                moreStyle: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 12,
                  color: Color(0xff0962ff),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          imagelist.length > 0 ? buildGridView(imagelist, i) : SizedBox(),
          video.length > 0 ? showSelectedVideos(i) : SizedBox(),
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
                                countData
                                    .child(socialfeed.docs[i].id)
                                    .child("likecount")
                                    .toString(),
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
                                  builder: (context) => ShowSocialFeedComments(
                                      socialfeed.docs[i].id)));
                        },
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                                text: countData
                                    .child(socialfeed.docs[i].id)
                                    .child("commentcount")
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
                              countData
                                  .child(socialfeed.docs[i].id)
                                  .child("viewscount")
                                  .toString(),
                              style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  color: Color.fromRGBO(205, 61, 61, 1)),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(FontAwesome5.eye,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 12),
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
                socialfeed.docs[i].get("usermood") == "Need people around me"
                    ? Padding(
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
                                        _reactionIndex[i] = index;
                                      });

                                      if (socialFeedPostReactionsDB.get(
                                              _currentUserId +
                                                  socialfeed.docs[i].id) !=
                                          null) {
                                        if (index == -1) {
                                          setState(() {
                                            _reactionIndex[i] = -2;
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
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) -
                                                1
                                          });
                                        } else {
                                          if (_reactionIndex[i] == 0) {
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
                                          } else if (_reactionIndex[i] == 1) {
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
                                          } else if (_reactionIndex[i] == 2) {
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
                                          } else if (_reactionIndex[i] == 3) {
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
                                          } else if (_reactionIndex[i] == 4) {
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
                                          } else if (_reactionIndex[i] == 5) {
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
                                          }
                                        }
                                      } else {
                                        if (_reactionIndex[i] == -1) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 0) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 1) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 2) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 3) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 4) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 5) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        }
                                        socialFeed.updateReactionCount(
                                            socialfeed.docs[i].id, {
                                          "likescount": countData
                                              .child(socialfeed.docs[i].id)
                                              .child("likecount")
                                        });
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: _reactionIndex[i] == -1
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xff0962ff)),
                                                )
                                              ],
                                            ),
                                          )
                                        : _reactionIndex[i] == -2
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
                                                          color:
                                                              Colors.black45),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : reactions[_reactionIndex[i]],
                                    selectedReaction: Reaction(
                                      icon: Row(
                                        children: [
                                          Icon(FontAwesome5.thumbs_up,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                              onTap: () {},
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(FontAwesome5.phone_alt,
                                        color: Color.fromRGBO(0, 0, 0, 0.8),
                                        size: 14),
                                    Text(
                                      "  Call",
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
                              onTap: () {},
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
                      )
                    : Padding(
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
                                        _reactionIndex[i] = index;
                                      });

                                      if (socialFeedPostReactionsDB.get(
                                              _currentUserId +
                                                  socialfeed.docs[i].id) !=
                                          null) {
                                        if (index == -1) {
                                          setState(() {
                                            _reactionIndex[i] = -2;
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
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) -
                                                1
                                          });
                                        } else {
                                          if (_reactionIndex[i] == 0) {
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
                                          } else if (_reactionIndex[i] == 1) {
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
                                          } else if (_reactionIndex[i] == 2) {
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
                                          } else if (_reactionIndex[i] == 3) {
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
                                          } else if (_reactionIndex[i] == 4) {
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
                                          } else if (_reactionIndex[i] == 5) {
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
                                          }
                                        }
                                      } else {
                                        if (_reactionIndex[i] == -1) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 0) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 1) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 2) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 3) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 4) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        } else if (_reactionIndex[i] == 5) {
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
                                          databaseReference
                                              .child("sm_feeds")
                                              .child("reactions")
                                              .child(socialfeed.docs[i].id)
                                              .update({
                                            'likecount': int.parse(countData
                                                    .child(
                                                        socialfeed.docs[i].id)
                                                    .child("likecount")
                                                    .value) +
                                                1
                                          });
                                        }
                                        socialFeed.updateReactionCount(
                                            socialfeed.docs[i].id, {
                                          "likescount": countData
                                              .child(socialfeed.docs[i].id)
                                              .child("likecount")
                                        });
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: _reactionIndex[i] == -1
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xff0962ff)),
                                                )
                                              ],
                                            ),
                                          )
                                        : _reactionIndex[i] == -2
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
                                                          color:
                                                              Colors.black45),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : reactions[_reactionIndex[i]],
                                    selectedReaction: Reaction(
                                      icon: Row(
                                        children: [
                                          Icon(FontAwesome5.thumbs_up,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                              onTap: () {},
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
        ],
      ),
    );
  }

  _shareSocialFeed(int i) {
    List tagedusername = socialfeed.docs[i].get("tagedusername");
    List tageduserid = socialfeed.docs[i].get("tageduserid");
    List imagelist = socialfeed.docs[i].get("imagelist");
    String video = socialfeed.docs[i].get("videolist");
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowSocialFeedComments(
                    socialfeed.docs[i].get("sharefeedid"))));
      },
      child: Container(
        padding: EdgeInsets.only(top: 5),
        margin: EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Color.fromRGBO(242, 246, 248, 1),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: (5.0), right: 5),
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
                                child: CachedNetworkImage(
                                  imageUrl:
                                      socialfeed.docs[i].get("userprofilepic"),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Image.asset(
                                    "assets/loadingimg.gif",
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _chooseHeaderAccordingToMood(
                            socialfeed.docs[i].get("usermood"),
                            i,
                            tagedusername,
                            tageduserid),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: Icon(FontAwesome5.ellipsis_h,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                      onPressed: () {
                        moreOptionsSMPostViewer(context, i);
                      }),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: ReadMoreText(
                  socialfeed.docs[i].get("message"),
                  textAlign: TextAlign.left,
                  trimLines: 4,
                  colorClickableText: Color(0xff0962ff),
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'read more',
                  trimExpandedText: 'Show less',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  lessStyle: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color(0xff0962ff),
                    fontWeight: FontWeight.w700,
                  ),
                  moreStyle: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color(0xff0962ff),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            imagelist.length > 0 ? buildGridView(imagelist, i) : SizedBox(),
            video.length > 0 ? showSelectedVideos(i) : SizedBox(),
            showshareFeedPost(i),
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
                                  countData
                                      .child(socialfeed.docs[i].id)
                                      .child("likecount")
                                      .toString(),
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
                                  text: countData
                                      .child(socialfeed.docs[i].id)
                                      .child("commentcount")
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
                                countData
                                    .child(socialfeed.docs[i].id)
                                    .child("viewscount")
                                    .toString(),
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
                                    _reactionIndex[i] = index;
                                  });

                                  if (socialFeedPostReactionsDB.get(
                                          _currentUserId +
                                              socialfeed.docs[i].id) !=
                                      null) {
                                    if (index == -1) {
                                      setState(() {
                                        _reactionIndex[i] = -2;
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
                                                .value) -
                                            1
                                      });
                                    } else {
                                      if (_reactionIndex[i] == 0) {
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
                                      } else if (_reactionIndex[i] == 1) {
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
                                      } else if (_reactionIndex[i] == 2) {
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
                                      } else if (_reactionIndex[i] == 3) {
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
                                      } else if (_reactionIndex[i] == 4) {
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
                                      } else if (_reactionIndex[i] == 5) {
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
                                      }
                                    }
                                  } else {
                                    if (_reactionIndex[i] == -1) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
                                              personaldata
                                                      .docs[0]
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 0) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
                                              personaldata
                                                      .docs[0]
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 1) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
                                              personaldata
                                                      .docs[0]
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 2) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
                                              personaldata
                                                      .docs[0]
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 3) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 4) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              socialfeed.docs[i]
                                                  .get("username"),
                                              socialfeed.docs[i].get("userid"),
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
                                                .value) +
                                            1
                                      });
                                    } else if (_reactionIndex[i] == 5) {
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
                                              socialfeed.docs[i].get("userid"),
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
                                                .value) +
                                            1
                                      });
                                    }
                                    socialFeed.updateReactionCount(
                                        socialfeed.docs[i].id, {
                                      "likescount": countData
                                          .child(socialfeed.docs[i].id)
                                          .child("likecount")
                                    });
                                  }
                                },
                                reactions: reactions,
                                initialReaction: _reactionIndex[i] == -1
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
                                    : _reactionIndex[i] == -2
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
                                        : reactions[_reactionIndex[i]],
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
                          onTap: () {},
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
                        Container(
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

  showshareFeedPost(int i) {
    List imagelist = socialfeed.docs[i].get("shareimagelist");
    String video = socialfeed.docs[i].get("sharevideolist");
    return Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black38)),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.only(
                    left: (5.0), right: 5, top: 5, bottom: 5),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 246, 248, 1),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  children: [
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
                                        imageUrl: socialfeed.docs[i]
                                            .get("shareuserprofilepic"),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          "assets/loadingimg.gif",
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
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
                                    _chooseShareFeedPostHeaderAccordingToMood(
                                        socialfeed.docs[i].get("shareusermood"),
                                        i),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                        child: ReadMoreText(
                          socialfeed.docs[i].get("sharemessage"),
                          textAlign: TextAlign.left,
                          trimLines: 4,
                          colorClickableText: Color(0xff0962ff),
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'read more',
                          trimExpandedText: 'Show less',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                          lessStyle: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 12,
                            color: Color(0xff0962ff),
                            fontWeight: FontWeight.w700,
                          ),
                          moreStyle: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 12,
                            color: Color(0xff0962ff),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    imagelist.length > 0
                        ? buildGridView(imagelist, i)
                        : SizedBox(),
                    video.length > 0 ? showSelectedVideos(i) : SizedBox()
                  ],
                )),
          ],
        ));
  }

  _chooseShareFeedPostHeaderAccordingToMood(String mood, int i) {
    List selectedUserName = socialfeed.docs[i].get("sharetagedusername");
    List selectedUserID = socialfeed.docs[i].get("sharetageduserid");
    String gender =
        socialfeed.docs[i].get("sharegender") == "Male" ? "him" : "her";
    String celebrategender =
        socialfeed.docs[i].get("sharegender") == "Male" ? "his" : "her";
    if (mood == "") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    } else if (mood == "Excited") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'excited ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Good") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'good ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Need people around me") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "need people around $gender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Certificate") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating $celebrategender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'achievement ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Performance") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating $celebrategender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'performance ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Friends") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("shareusername"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("shareuserarea")}',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("shareuserschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("shareusergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "want to introduce $celebrategender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'friends ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    }
  }

  _chooseHeaderAccordingToMood(
      String mood, int i, List selectedUserName, List selectedUserID) {
    String gender =
        socialfeed.docs[i].get("usergender") == "Male" ? "him" : "her";
    String celebrategender =
        socialfeed.docs[i].get("usergender") == "Male" ? "his" : "her";
    if (mood == "") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    } else if (mood == "Excited") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'excited ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Good") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'good ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Need people around me") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: 'need people around $gender ',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Certificate") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating $celebrategender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'achievement ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Performance") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating $celebrategender ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'performance ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "Friends") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', Delhi',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              socialfeed.docs[i].get("userschoolname") +
                  ", " +
                  "Grade " +
                  socialfeed.docs[i].get("usergrade"),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'friends ',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: 'with ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 1))
                        ? TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length > 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} others',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                    ((selectedUserName != null) &&
                            (selectedUserName.length == 2))
                        ? TextSpan(
                            text: '${selectedUserName.length - 1} other',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : TextSpan(),
                  ]),
            ),
          ],
        ),
      );
    }
  }

  Widget showSelectedVideos(int i) {
    // _onControllerChange(socialfeed.docs[i].get("videolist"), i);
    return Container(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: socialfeed.docs[i].get("videothumbnail"),
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset(
                "assets/loadingimg.gif",
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Positioned.fill(
              child: IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                ),
                iconSize: 64,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Video_Player(
                            socialfeed.docs[i].get("videothumbnail"),
                            socialfeed.docs[i].get("videolist"));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  YYDialog moreOptionsSMPostViewer(BuildContext context, int i) {
    String gender =
        socialfeed.docs[i].get("usergender") == "Male" ? "his" : "her";
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: 470,
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
                onTap: () async {},
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        color: ((socialFeedPostSavedDB.get(_currentUserId +
                                        socialfeed.docs[i].id) !=
                                    null) ||
                                (socialFeedPostSavedDB.get(_currentUserId +
                                        socialfeed.docs[i]
                                            .get("sharefeedid")) !=
                                    null))
                            ? Color(0xff0962ff)
                            : Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      InkWell(
                        onTap: () {
                          if (socialfeed.docs[i].get("feedtype") != "shared") {
                            setState(() {
                              if (socialFeedPostSavedDB.get(
                                      _currentUserId + socialfeed.docs[i].id) !=
                                  null) {
                                socialFeedPostSavedDB.delete(
                                    _currentUserId + socialfeed.docs[i].id);
                                socialFeed.deleteSocialFeedPostSaved(
                                    _currentUserId + socialfeed.docs[i].id);
                              } else {
                                socialFeed.saveFeedPost(
                                    personaldata.docs[0].get("firstname") +
                                        " " +
                                        personaldata.docs[0].get("lastname"),
                                    socialfeed.docs[i].get("userid"),
                                    socialfeed.docs[i].get("username"),
                                    socialfeed.docs[i].id,
                                    current_date,
                                    comparedate);
                                socialFeedPostSavedDB.put(
                                    _currentUserId + socialfeed.docs[i].id,
                                    "saved");
                                Navigator.of(context).pop();
                              }
                            });
                          } else {
                            setState(() {
                              if (socialFeedPostSavedDB.get(_currentUserId +
                                      socialfeed.docs[i].get("sharefeedid")) !=
                                  null) {
                                socialFeedPostSavedDB.delete(_currentUserId +
                                    socialfeed.docs[i].get("sharefeedid"));
                                socialFeed.deleteSocialFeedPostSaved(
                                    _currentUserId +
                                        socialfeed.docs[i].get("sharefeedid"));
                              } else {
                                socialFeed.saveFeedPost(
                                    personaldata.docs[0].get("firstname") +
                                        " " +
                                        personaldata.docs[0].get("lastname"),
                                    socialfeed.docs[i].get("shareuserid"),
                                    socialfeed.docs[i].get("shareusername"),
                                    socialfeed.docs[i].get("sharefeedid"),
                                    current_date,
                                    comparedate);
                                socialFeedPostSavedDB.put(
                                    _currentUserId +
                                        socialfeed.docs[i].get("sharefeedid"),
                                    "saved");
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Save post',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: ((socialFeedPostSavedDB.get(
                                                  _currentUserId +
                                                      socialfeed.docs[i].id) !=
                                              null) ||
                                          (socialFeedPostSavedDB.get(
                                                  _currentUserId +
                                                      socialfeed.docs[i].get(
                                                          "sharefeedid")) !=
                                              null))
                                      ? Color(0xff0962ff)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Add this to your saved items.',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  color: ((socialFeedPostSavedDB.get(
                                                  _currentUserId +
                                                      socialfeed.docs[i].id) !=
                                              null) ||
                                          (socialFeedPostSavedDB.get(
                                                  _currentUserId +
                                                      socialfeed.docs[i].get(
                                                          "sharefeedid")) !=
                                              null))
                                      ? Color(0xff0962ff)
                                      : Colors.black45,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                 
                  Navigator.pop(context);
                },
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.star_border,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add ${socialfeed.docs[i].get("username")} to favourites',
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
                            'Prioritise $gender post in News Feed.',
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
                onTap: () {},
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.cancel_presentation_outlined,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hide post',
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
                            'See fewer posts like this.',
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
                onTap: () {},
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.timelapse_outlined,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Snooze ${socialfeed.docs[i].get("username")} for 30 days',
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
                            'Temporarily stop seeing posts.',
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
                onTap: () {},
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.undo_outlined,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unfollow ${socialfeed.docs[i].get("username")}',
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
                            'Stop seeing posts but stay friend.',
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
                onTap: () {},
                child: Container(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.report_outlined,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find suppost or repost post',
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
                            'I\'m concerned about this post.',
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
              /*  InkWell(
                onTap: () {},
                child: Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why am i seeing this post?',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),*/
              InkWell(
                onTap: () {},
                child: Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_on_outlined,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turn on notifications for this post',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  YYDialog moreOptionsSMPostUser(int i) {
    return YYDialog().build()
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: 100,
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
                onTap: () {},
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.black87,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit',
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
                            'Edit the question or add more relative reference.',
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

  _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: new Text(
              "Pratik Ekghare",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            accountEmail: new Text(
              "ekghare31197@gmail.com",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new AssetImage("assets/maleicon.jpg"),
            ),
            decoration: new BoxDecoration(
              color: Color.fromRGBO(88, 165, 196, 1),
            ),
          ),
          ListTile(
            title: Text('Groups'),
            selectedTileColor: Color.fromRGBO(242, 246, 248, 1),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Library'),
            selectedTileColor: Color.fromRGBO(242, 246, 248, 1),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Events'),
            selectedTileColor: Color.fromRGBO(242, 246, 248, 1),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          Container(
            color: Color.fromRGBO(217, 217, 217, 1),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Terms and Conditions",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  "Privacy Policy",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {},
                  child: Container(
                    child: Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class StoryPageView extends StatefulWidget {
  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  final controller = StoryController();

  @override
  Widget build(BuildContext context) {
    final List<StoryItem> storyItems = [
      StoryItem.text(
          title: '''“When you talk, you are only repeating something you know.
       But if you listen, you may learn something new.” 
       – Dalai Lama''', backgroundColor: Colors.blueGrey),
      StoryItem.pageImage(
          url:
              "https://images.unsplash.com/photo-1553531384-cc64ac80f931?ixid=MnwxMjA3fDF8MHxzZWFyY2h8MXx8bW91bnRhaW58ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
          controller: controller),
      StoryItem.pageImage(
          url: "https://wp-modula.com/wp-content/uploads/2018/12/gifgif.gif",
          controller: controller,
          imageFit: BoxFit.contain),
    ];
    return Material(
      child: StoryView(
        storyItems: storyItems,
        controller: controller,
        inline: false,
        repeat: true,
      ),
    );
  }
}
