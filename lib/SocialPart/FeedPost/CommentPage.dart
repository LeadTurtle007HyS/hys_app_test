import 'dart:convert';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/Blogs/viewAllBlogs.dart';
import 'package:hys/SocialPart/Cause/MapLocation.dart';
import 'package:hys/SocialPart/FeedPost/shareFeedPost.dart';
import 'package:hys/SocialPart/ImageView/SingleImageView.dart';
import 'package:hys/SocialPart/Podcast/MediaPlayerTrial.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/SocialPart/business/ViewBusinessFile.dart';
import 'package:hys/SocialPart/business/ViewFile.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'package:hys/SocialPart/database/SocialMSubCommentsDB.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:hys/database/notificationdb.dart';
import 'package:hys/utils/permissions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:story_designer/story_designer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:hys/SocialPart/FeedPost/subCommentPage.dart';

class ShowSocialFeedComments extends StatefulWidget {
  String feedID;

  ShowSocialFeedComments(this.feedID);

  @override
  _ShowSocialFeedCommentsState createState() =>
      _ShowSocialFeedCommentsState(this.feedID);
}

class _ShowSocialFeedCommentsState extends State<ShowSocialFeedComments> {
  static const MethodChannel _channel = MethodChannel('epub_viewer');

  String feedID;

  _ShowSocialFeedCommentsState(this.feedID);

  String current_date = DateTime.now().toString();
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  CrudMethods crudobj = CrudMethods();
  SocialFeedPost socialFeed = SocialFeedPost();
  QuerySnapshot socialfeed;
  SocialMCommentsDB socialFeedComment = SocialMCommentsDB();
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  int feedindex = 0;
  VideoPlayerController _controller;
  List<bool> _videControllerStatus = [];
  ScrollController _scrollController;
  DataSnapshot countData;
  DataSnapshot countData2;
  DataSnapshot countData3;
  final databaseReference = FirebaseDatabase.instance.reference();
  Box<dynamic> socialFeedPostReactionsDB;
  Box<dynamic> socialFeedCommentsReactionsDB;
  Box<dynamic> socialFeedSubCommentsReactionsDB;
  Box<dynamic> usertokendataLocalDB;
  List<int> _reactionIndex = [];
  SocialFeedNotification _notificationdb = SocialFeedNotification();
  SocialMSubCommentsDB socialFeedSubComment = SocialMSubCommentsDB();
  QuerySnapshot smReplies;
  QuerySnapshot notificationToken;
  QuerySnapshot smComments;

  //QuerySnapshot commentsData;
  QuerySnapshot allUserschooldata;
  QuerySnapshot allUserpersonaldata;

  PushNotificationDB myNotify = PushNotificationDB();
  String textshow = "";
  int tagcount = 0;
  List<String> tagids = [];
  List<String> tagedUsersName = [];
  String sharesubcomment = "";
  bool imageupload = false;
  bool showimgcontainer = false;
  bool showvdocontainer = false;
  FocusNode focusNode;
  String markupptext = '';
  String sharecomment = "";
  String markuppcommenttext = '';
  String comment = "";
  List<List<int>> subcommarray = [];
  List<bool> subcommarrayshow = [];

  File _image;
  File imageFile;
  final picker = ImagePicker();
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  GlobalKey<FlutterMentionsState> key2 = GlobalKey<FlutterMentionsState>();
  GlobalKey<FlutterMentionsState> key3 = GlobalKey<FlutterMentionsState>();
  bool _showList = false;
  String imgUrl = "";
  var _users = [
    {
      'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
      'display': 'Vivek Sharma',
      'full_name': 'DPS | Grade 7',
      'photo':
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
    },
  ];
  String finalVideos = "";
  String finalVideosUrl = "";
  bool videoUploaded = false;
  String _error = 'No Error Dectected';
  String thumbURL = "";
  File commentImageFile;
  bool commentImg = false;
  int calculatedfeedindex = -1;

  getThumbnail(String videURL) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videURL,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 200,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 30,
    );
    print(fileName);
    socialFeed.uploadSocialMediaFeedImages(File(fileName)).then((value) {
      setState(() {
        print(value);
        if (value[0] == true) {
          thumbURL = value[1];
          videoUploaded = false;
          print(thumbURL);
        } else
          _showAlertDialog(value[1]);
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

  @override
  void initState() {
    focusNode = FocusNode();
    socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
    socialFeedCommentsReactionsDB =
        Hive.box<dynamic>('socialfeedcommentsreactions');
    socialFeedSubCommentsReactionsDB =
        Hive.box<dynamic>('socialfeedsubcommentsreactions');
    usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    _scrollController = ScrollController();
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    socialFeed.getSocialFeedPosts().then((value) {
      setState(() {
        socialfeed = value;
        if (socialfeed != null) {
          for (int i = 0; i < socialfeed.docs.length; i++) {
            if (socialfeed.docs[i].id == this.feedID) {
              _mediaPlayerFlags.add(false);
              calculatedfeedindex = i;
              feedindex = i;
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
        }
      });
    });
    crudobj.getAllUserSchoolData().then((value) {
      setState(() {
        allUserschooldata = value;
        crudobj.getAllUserData().then((value) {
          setState(() {
            allUserpersonaldata = value;
            if ((allUserpersonaldata != null) && (allUserschooldata != null)) {
              for (int i = 0; i < allUserpersonaldata.docs.length; i++) {
                for (int j = 0; j < allUserschooldata.docs.length; j++) {
                  if (allUserpersonaldata.docs[i].get("userid") ==
                      allUserschooldata.docs[j].get("userid")) {
                    _users.add({
                      'id': allUserpersonaldata.docs[i].get("userid"),
                      'display': allUserpersonaldata.docs[i].get("firstname") +
                          " " +
                          allUserpersonaldata.docs[i].get("lastname"),
                      'full_name': allUserschooldata.docs[j].get("schoolname") +
                          " | " +
                          allUserschooldata.docs[j].get("grade"),
                      'photo': allUserpersonaldata.docs[i].get("profilepic")
                    });
                  }
                }
              }
            }
          });
        });
      });
    });
    socialFeedComment.getSocialFeedComments(this.feedID).then((value) {
      setState(() {
        smComments = value;
        socialFeedSubComment
            .getAllSocialFeedSubComments(this.feedID)
            .then((value) {
          setState(() {
            smReplies = value;
            if (smComments != null && smReplies != null) {
              for (int i = 0; i < smComments.docs.length; i++) {
                List<int> subcomm = [];
                for (int j = 0; j < smReplies.docs.length; j++) {
                  if (smComments.docs[i].id ==
                      smReplies.docs[j].get("commentid")) {
                    subcomm.add(j);
                  }
                }
                subcommarray.add(subcomm);
                subcommarrayshow.add(false);
              }
              print(subcommarray);
            }
          });
        });
      });
    });

    crudobj.getUserSchoolData().then((value) {
      setState(() {
        schooldata = value;
      });
    });
    super.initState();
  }

  Future<void> showKeyboard() async {
    FocusScope.of(context).requestFocus();
  }

  Future<void> dismissKeyboard() async {
    FocusScope.of(context).unfocus();
  }

  String getTimeDifferenceFromNow(String dateTime) {
    DateTime todayDate = DateTime.parse(dateTime);
    Duration difference = DateTime.now().difference(todayDate);
    if (difference.inSeconds < 5) {
      return "Just now";
    } else if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h";
    } else {
      return "${difference.inDays} d";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  _body() {
    print(calculatedfeedindex);
    if ((socialfeed != null) &&
        (personaldata != null) &&
        (allUserpersonaldata != null) &&
        (schooldata != null) &&
        (allUserschooldata != null) &&
        (smComments != null) &&
        (smReplies != null)) {
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
          .child("sm_feeds_comments")
          .child("reactions")
          .once()
          .then((value) {
        setState(() {
          if (mounted) {
            setState(() {
              countData2 = value.snapshot;
            });
          }
        });
      });
      databaseReference
          .child("sm_feeds_reply")
          .child("reactions")
          .once()
          .then((value) {
        setState(() {
          if (mounted) {
            setState(() {
              countData3 = value.snapshot;
            });
          }
        });
      });
      if ((countData != null) && (countData2 != null) && (countData3 != null)) {
        return Column(
          children: [
            Expanded(
              child: Material(
                child: smComments.docs.length == 0
                    ? when_no_comment()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: smComments.docs.length,
                        itemBuilder: (BuildContext context, int i) {
                          return i == 0 ? when_I_is_Zero() : _comment(i);
                        },
                      ),
              ),
            ),
          ],
        );
      } else
        return _loading();
    } else
      return _loading();
  }

  when_I_is_Zero() {
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
                )
              ],
            ),
          ),
          socialfeed.docs[calculatedfeedindex].get("feedtype") == "shared"
              ? _shareSocialFeed(calculatedfeedindex)
              : socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                      "EventUnderprivilegeByTeaching"
                  ? _event(calculatedfeedindex,
                      socialfeed.docs[calculatedfeedindex].id)
                  : (socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                              "Mood") &&
                          (socialfeed.docs[calculatedfeedindex]
                                  .get("usermood") ==
                              "Need people around me")
                      ? _peopleNeedAroundMesocialFeed(calculatedfeedindex)
                      : socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                              "projectdiscuss"
                          ? _projectDiscussed(calculatedfeedindex)
                          : socialfeed.docs[calculatedfeedindex]
                                      .get("feedtype") ==
                                  "businessideas"
                              ? _businessIdeas(calculatedfeedindex,
                                  socialfeed.docs[calculatedfeedindex].id)
                              : socialfeed.docs[calculatedfeedindex]
                                          .get("feedtype") ==
                                      "Mood"
                                  ? _socialFeed(calculatedfeedindex)
                                  : socialfeed.docs[calculatedfeedindex]
                                              .get("feedtype") ==
                                          "podcast"
                                      ? _podcast(calculatedfeedindex)
                                      : socialfeed.docs[calculatedfeedindex]
                                                  .get("feedtype") ==
                                              "blog"
                                          ? _blog(calculatedfeedindex)
                                          : SizedBox(),
          _comment(0)
        ],
      ),
    );
  }

  when_no_comment() {
    return ListView(
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
              )
            ],
          ),
        ),
        socialfeed.docs[calculatedfeedindex].get("feedtype") == "shared"
            ? _shareSocialFeed(calculatedfeedindex)
            : socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                    "EventUnderprivilegeByTeaching"
                ? _event(calculatedfeedindex,
                    socialfeed.docs[calculatedfeedindex].id)
                : (socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                            "Mood") &&
                        (socialfeed.docs[calculatedfeedindex].get("usermood") ==
                            "Need people around me")
                    ? _peopleNeedAroundMesocialFeed(calculatedfeedindex)
                    : socialfeed.docs[calculatedfeedindex].get("feedtype") ==
                            "projectdiscuss"
                        ? _projectDiscussed(calculatedfeedindex)
                        : socialfeed.docs[calculatedfeedindex]
                                    .get("feedtype") ==
                                "businessideas"
                            ? _businessIdeas(calculatedfeedindex,
                                socialfeed.docs[calculatedfeedindex].id)
                            : socialfeed.docs[calculatedfeedindex]
                                        .get("feedtype") ==
                                    "Mood"
                                ? _socialFeed(calculatedfeedindex)
                                : socialfeed.docs[calculatedfeedindex]
                                            .get("feedtype") ==
                                        "podcast"
                                    ? _podcast(calculatedfeedindex)
                                    : socialfeed.docs[calculatedfeedindex]
                                                .get("feedtype") ==
                                            "blog"
                                        ? _blog(calculatedfeedindex)
                                        : SizedBox(),
      ],
    );
  }

  Future uploadSocialFeedImages(ImageSource source) async {
    imageupload = true;
    File editedFile;
    final pickedfile = await picker.getImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _image = File(pickedfile.path);
        print(_image);
      });
      if (_image != null) {
        editedFile = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => StoryDesigner(
                  filePath: _image.path,
                )));
      }
      commentImageFile = File(editedFile.path);
      commentImg = true;
    }
    if (editedFile != null) {
      setState(() {
        imageFile = editedFile;
        print(imageFile);
        _loading();
      });
      socialFeed.uploadSocialMediaFeedImages(imageFile).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            imgUrl = value[1];
            print(imgUrl);

            imageupload = false;

            dismissKeyboard();
          } else
            _showAlertDialog(value[1]);
        });
      });
    }
  }

  Future uploadSocialFeedVideo(ImageSource source) async {
    videoUploaded = true;
    String path = "";
    final file = await picker.getVideo(
        source: source, maxDuration: Duration(minutes: 15));
    if (file == null) {
      return;
    }
    finalVideos = file.path;
    await VideoCompress.setLogLevel(0);
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    print(info.path);
    if (info != null) {
      setState(() {
        path = info.path;
      });
    }

    print(path);
    if (path != "") {
      socialFeed.uploadReferenceVideo(path).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            print(value[1]);
            finalVideosUrl = value[1];
            print(finalVideosUrl);

            getThumbnail(finalVideosUrl);
            //Navigator.pop(context);
            dismissKeyboard();
          } else
            _showAlertDialog(value[1]);
        });
      });
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
            Text("Click answer pic and upload",
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
                          uploadSocialFeedImages(ImageSource.camera);
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
                          uploadSocialFeedImages(ImageSource.gallery);
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

  _vdoContainer() {
    return Container(
      height: 250,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Record video and upload",
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
                          uploadSocialFeedVideo(ImageSource.camera);
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
                          uploadSocialFeedVideo(ImageSource.gallery);
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
                      "Gallery",
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
                                imageUrl: socialfeed.docs[feedindex]
                                    .get("userprofilepic"),
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
                          socialfeed.docs[feedindex].get("usermood"),
                          feedindex,
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
                socialfeed.docs[feedindex].get("message"),
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
          imagelist.length > 0
              ? buildGridView(imagelist, feedindex)
              : SizedBox(),
          video.length > 0 ? showSelectedVideos(i) : SizedBox(),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            FlutterReactionButtonCheck(
                              onReactionChanged: (reaction, index, ischecked) {
                                setState(() {
                                  _reactionIndex[0] = index;
                                });

                                if (socialFeedPostReactionsDB.get(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id) !=
                                    null) {
                                  if (index == -1) {
                                    setState(() {
                                      _reactionIndex[0] = -2;
                                    });
                                    _notificationdb
                                        .deleteSocialFeedReactionsNotification(
                                            socialfeed.docs[feedindex].id);
                                    socialFeedPostReactionsDB.delete(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id);
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
                                              .child("likecount")
                                              .value
                                              .toString()) -
                                          1
                                    });
                                  } else {
                                    if (_reactionIndex[0] == 0) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("userid"),
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Like",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
                                          "Like");
                                    } else if (_reactionIndex[0] == 1) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("userid"),
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Love",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
                                          "Love");
                                    } else if (_reactionIndex[0] == 2) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("userid"),
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Haha",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
                                          "Haha");
                                    } else if (_reactionIndex[0] == 3) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed.docs[
                                                      feedindex]
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Yay",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
                                          "Yay");
                                    } else if (_reactionIndex[0] == 4) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed.docs[
                                                      feedindex]
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Wow",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
                                          "Wow");
                                    } else if (_reactionIndex[0] == 5) {
                                      _notificationdb
                                          .socialFeedReactionsNotifications(
                                              personaldata.docs[0].get(
                                                      "firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              personaldata.docs[0].get(
                                                  "profilepic"),
                                              socialfeed.docs[
                                                      feedindex]
                                                  .get("username"),
                                              socialfeed
                                                  .docs[feedindex]
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
                                                  socialfeed.docs[feedindex]
                                                      .get("userid")),
                                              socialfeed.docs[feedindex].id,
                                              i,
                                              "Angry",
                                              comparedate);
                                      socialFeedPostReactionsDB.put(
                                          _currentUserId +
                                              socialfeed.docs[feedindex].id,
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
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Like");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
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
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Like");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
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
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " loved your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Love",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Love");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
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
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted haha on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Haha",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Haha");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
                                              .child("likecount")
                                              .value
                                              .toString()) +
                                          1
                                    });
                                  } else if (_reactionIndex[0] == 3) {
                                    _notificationdb
                                        .socialFeedReactionsNotifications(
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted yay on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Yay",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Yay");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
                                              .child("likecount")
                                              .value
                                              .toString()) +
                                          1
                                    });
                                  } else if (_reactionIndex[0] == 4) {
                                    _notificationdb
                                        .socialFeedReactionsNotifications(
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted wow on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Wow",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Wow");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
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
                                            socialfeed.docs[feedindex]
                                                .get("username"),
                                            socialfeed.docs[feedindex]
                                                .get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted angry on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[feedindex]
                                                .get("userid")),
                                            socialfeed.docs[feedindex].id,
                                            i,
                                            "Angry",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId +
                                            socialfeed.docs[feedindex].id,
                                        "Angry");
                                    databaseReference
                                        .child("sm_feeds")
                                        .child("reactions")
                                        .child(socialfeed.docs[feedindex].id)
                                        .update({
                                      'likecount': int.parse(countData
                                              .child(
                                                  socialfeed.docs[feedindex].id)
                                              .child("likecount")
                                              .value
                                              .toString()) +
                                          1
                                    });
                                  }
                                  socialFeed.updateReactionCount(
                                      socialfeed.docs[feedindex].id, {
                                    "likescount": int.parse(countData
                                        .child(socialfeed.docs[feedindex].id)
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
                                                    fontWeight: FontWeight.w700,
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.comment,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    color: Colors.white54,
                    height: 1,
                    width: MediaQuery.of(context).size.width),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/reactions/like.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/laugh.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/wow.png",
                                  height: 15, width: 15),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                countData
                                    .child(socialfeed.docs[feedindex].id)
                                    .child("likecount")
                                    .value
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color.fromRGBO(205, 61, 61, 1)),
                              ),
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

  Future<bool> checkPermission() async {
    if (!await Permissions.cameraAndMicrophonePermissionsGranted()) {
      return false;
    }
    return true;
  }

  gotoCallingPage(
      bool isVideo, String userID, String userName, String profilePic) async {
    Map<String, dynamic> agrs = {
      "IS_VIDEO": isVideo,
      "USER_ID": userID,
      "userName": userName,
      "profilePic": profilePic,
      "LOGGED_IN_userName": personaldata.docs[0].get("firstname"),
      "LOGGED_IN_profilePic": personaldata.docs[0].get("profilepic"),
      "LOGGED_IN_USER_ID": personaldata.docs[0].get("userid")
    };
    await _channel.invokeMethod('outgoing_calling', agrs);
  }

  void _showCallingDialog(int i) {
    AlertDialog alertDialog = AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Container(
            height: 100,
            color: Color.fromRGBO(242, 246, 248, 1),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                onTap: () async {
                  for (int j = 0; j < notificationToken.docs.length; j++) {
                    if (notificationToken.docs[j].get("userid") ==
                        socialfeed.docs[i].get("userid")) {
                      print(socialfeed.docs[i].get("userid"));
                      String channelid = socialfeed.docs[i].id +
                          socialfeed.docs[i].get("userid");
                      bool hasPermission = await checkPermission();
                      String message =
                          "${personaldata.docs[0].get("firstname")} ${personaldata.docs[0].get("lastname")} Calling you";
                      if (hasPermission) {
                        // String notifyId =
                        // await myNotify.incomingCalNotificationToSuperUser(
                        //     personaldata.docs[0].get("firstname") +
                        //         " " +
                        //         personaldata.docs[0].get("lastname"),
                        //     socialfeed.docs[i].get("username"),
                        //     socialfeed.docs[i].get("userid"),
                        //     message,
                        //     current_date,
                        //     notificationToken.docs[j].get("token"),
                        //     socialfeed.docs[i].id,
                        //     "2",
                        //     channelid,
                        //     "SocailFeedCall",
                        //     comparedate);
                        Navigator.of(context).pop();

                        gotoCallingPage(
                            true,
                            socialfeed.docs[feedindex].get("userid"),
                            socialfeed.docs[feedindex].get("username"),
                            socialfeed.docs[feedindex].get("userprofilepic"));

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           VideoCallingCallerScreen(
                        //               channelid,
                        //               socialfeed.docs[i].get("username"),
                        //               "",
                        //               ""),
                        //     ));
                      }
                    }
                  }
                },
                child: Container(
                  child: Center(
                    child: Text("Video\nCall",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Container(
                  height: 100,
                  width: 100,
                  child: Image.asset("assets/calling.gif", fit: BoxFit.cover)),
              InkWell(
                onTap: () async {
                  for (int j = 0; j < notificationToken.docs.length; j++) {
                    if (notificationToken.docs[j].get("userid") ==
                        socialfeed.docs[i].get("userid")) {
                      print(socialfeed.docs[i].get("userid"));
                      String channelid = socialfeed.docs[i].id +
                          socialfeed.docs[i].get("userid");
                      bool hasPermission = await checkPermission();
                      String message =
                          "${personaldata.docs[0].get("firstname")} ${personaldata.docs[0].get("lastname")} Calling you";
                      if (hasPermission) {
                        // myNotify.incomingCalNotificationToSuperUser(
                        //     personaldata.docs[0].get("firstname") +
                        //         " " +
                        //         personaldata.docs[0].get("lastname"),
                        //     socialfeed.docs[i].get("username"),
                        //     socialfeed.docs[i].get("userid"),
                        //     message,
                        //     current_date,
                        //     notificationToken.docs[j].get("token"),
                        //     socialfeed.docs[i].id,
                        //     "3",
                        //     channelid,
                        //     "SocailFeedCall",
                        //     comparedate);
                        // Navigator.of(context).pop();

                        gotoCallingPage(
                            false,
                            socialfeed.docs[feedindex].get("userid"),
                            socialfeed.docs[feedindex].get("username"),
                            socialfeed.docs[feedindex].get("userprofilepic"));

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           AudioCallingCallerScreen(
                        //               channelid,
                        //               socialfeed.docs[i].get("username"),
                        //               socialfeed.docs[i].get("userid"),
                        //               ""),
                        //     ));
                      }
                    }
                  }
                },
                child: Container(
                  child: Center(
                    child: Text("Audio\nCall",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ])));
    showDialog(context: context, builder: (_) => alertDialog);
  }

  _peopleNeedAroundMesocialFeed(int i) {
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
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            FlutterReactionButtonCheck(
                              onReactionChanged: (reaction, index, ischecked) {
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
                                        _currentUserId + socialfeed.docs[i].id);
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
                                    } else if (_reactionIndex[0] == 1) {
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
                                    } else if (_reactionIndex[0] == 2) {
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
                                    } else if (_reactionIndex[0] == 3) {
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
                                    } else if (_reactionIndex[0] == 4) {
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " loved your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Love",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted haha on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Haha",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted yay on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Yay",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted wow on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Wow",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted angry on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Angry",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                    "likescount": countData
                                        .child(socialfeed.docs[i].id)
                                        .child("likecount")
                                        .value
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
                                                    fontWeight: FontWeight.w700,
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.comment,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    color: Colors.white54,
                    height: 1,
                    width: MediaQuery.of(context).size.width),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/reactions/like.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/laugh.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/wow.png",
                                  height: 15, width: 15),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                countData
                                    .child(socialfeed.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color.fromRGBO(205, 61, 61, 1)),
                              ),
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

  _event(int i, String id) {
    bool whiteflag = false;
    dynamic poster = socialfeed.docs[i].get('poster');
    if (socialfeed.docs[i].get('themeindex') == 0 ||
        socialfeed.docs[i].get('themeindex') == 2 ||
        socialfeed.docs[i].get('themeindex') == 4 ||
        socialfeed.docs[i].get('themeindex') == 5) {
      whiteflag = true;
    }
    return Container(
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
                              width: MediaQuery.of(context).size.width / 10.34,
                              height: MediaQuery.of(context).size.width / 10.34,
                              child: Image.network(
                                socialfeed.docs[i].get("userprofilepic"),
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
                              Text(socialfeed.docs[i].get('username'),
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
                                  child: Image.asset('assets/causeEmoji.png')),
                            ]),
                            Row(
                              children: [
                                Text('to Educate UnderPrivileged Childrens.',
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
                                        color: Color.fromRGBO(88, 165, 196, 1)),
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
                IconButton(
                    icon: Icon(FontAwesome5.ellipsis_h,
                        color: Color.fromRGBO(0, 0, 0, 0.8), size: 10),
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
          SizedBox(height: 10),
          (socialfeed.docs[i].get('poster') != null)
              ? Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(socialfeed.docs[i].get('poster'),
                      fit: BoxFit.contain))
              : SizedBox(),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.8), BlendMode.dstATop),
                    image: AssetImage(socialfeed.docs[i].get('theme')),
                    fit: BoxFit.fill)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        child: Text('Class :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        child: Text('Subject :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        child: Text('Frequency :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        child: Text('Date :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        child: Text('Time :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        child: Text('Venue :',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: whiteflag == true
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ]),
                SizedBox(width: 4),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 5),
                  Container(
                      width: 100,
                      height: 20,
                      child: Text(
                        socialfeed.docs[i].get('grade'),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: whiteflag == true
                                ? Colors.white
                                : Colors.black87),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 20,
                      width: 100,
                      child: Text(
                        socialfeed.docs[i].get('subject'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: whiteflag == true
                                ? Colors.white
                                : Colors.black87),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 20,
                      width: 100,
                      child: Text(
                        socialfeed.docs[i].get('frequency'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: whiteflag == true
                                ? Colors.white
                                : Colors.black87),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 20,
                      width: 100,
                      child: Text(
                        socialfeed.docs[i].get('date'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: whiteflag == true
                                ? Colors.white
                                : Colors.black87),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      width: 100,
                      child: Text(
                        socialfeed.docs[i].get('from') +
                            ' to ' +
                            socialfeed.docs[i].get('to'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: whiteflag == true
                                ? Colors.white
                                : Colors.black87),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Row(children: [
                    Container(
                        width: 150,
                        child: Text(
                          socialfeed.docs[i].get('address'),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: whiteflag == true
                                  ? Colors.white
                                  : Colors.black87),
                          textAlign: TextAlign.start,
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapLocation(
                                      socialfeed.docs[i].get('latitude'),
                                      socialfeed.docs[i].get('longitude'))));
                        },
                        child: Text(
                          '(Map to Venue)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.blue),
                        )),
                  ]),
                  SizedBox(height: 10),
                ]),
              ]),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(socialfeed.docs[i].get('eventname'),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color.fromRGBO(88, 165, 196, 1))),
            Container(
                child: Row(children: [
              Text(
                  socialfeed.docs[i].get('date') +
                      ' ' +
                      socialfeed.docs[i].get('from') +
                      ' to ' +
                      socialfeed.docs[i].get('to'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1))),
            ]))
          ]),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            FlutterReactionButtonCheck(
                              onReactionChanged: (reaction, index, ischecked) {
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
                                        _currentUserId + socialfeed.docs[i].id);
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
                                    } else if (_reactionIndex[0] == 1) {
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
                                    } else if (_reactionIndex[0] == 2) {
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
                                    } else if (_reactionIndex[0] == 3) {
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
                                    } else if (_reactionIndex[0] == 4) {
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " loved your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Love",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted haha on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Haha",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted yay on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Yay",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted wow on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Wow",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted angry on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Angry",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                    "likescount": countData
                                        .child(socialfeed.docs[i].id)
                                        .child("likecount")
                                        .value
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
                                                    fontWeight: FontWeight.w700,
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.comment,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    color: Colors.white54,
                    height: 1,
                    width: MediaQuery.of(context).size.width),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/reactions/like.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/laugh.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/wow.png",
                                  height: 15, width: 15),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                countData
                                    .child(socialfeed.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color.fromRGBO(205, 61, 61, 1)),
                              ),
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
        ]));
  }

  _blog(int i) {
    return InkWell(
      onTap: () {},
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
                            socialfeed.docs[i].get("feedtype"), i, [], []),
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Ideas(socialfeed.docs[i].id)));
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: ReadMoreText(
                  socialfeed.docs[i].get('blogtitle'),
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
            blogPost(
                socialfeed.docs[i].get('createdate'),
                socialfeed.docs[i].get('blogtitle'),
                socialfeed.docs[i].get('image'),
                socialfeed.docs[i].get('blogintro'),
                socialfeed.docs[i].id),
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
                                      .value
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
                                      .value
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
                                    .value
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
                                      }
                                    }
                                  } else {
                                    if (_reactionIndex[0] == -1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 0) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 2) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    }
                                    socialFeed.updateReactionCount(
                                        socialfeed.docs[i].id, {
                                      "likescount": countData
                                          .child(socialfeed.docs[i].id)
                                          .child("likecount")
                                          .value
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

  blogPost(String time, String tittle, String imgurl, String desc, String id) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Ideas(id)));
      },
      child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black38)),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(
                      left: (10.0), right: 5, top: 10, bottom: 5),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(242, 246, 248, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Ideas(id)));
                                },
                                child: Container(
                                  child: Text(time,
                                      style: TextStyle(
                                          color: Color(0xFF3B3B3B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400)),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    2) +
                                                30,
                                        child: Text(tittle,
                                            style: TextStyle(
                                                color: Color(0xFFFA6F40),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Material(
                                        elevation: 3,
                                        shadowColor: Color(0xFFF0F0F0),
                                        child: Container(
                                          padding: EdgeInsets.all(3),
                                          width: 70,
                                          height: 70,
                                          child: CachedNetworkImage(
                                            imageUrl: imgurl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                    height: 70,
                                                    width: 70,
                                                    child: Image.asset(
                                                      "assets/loadingimg.gif",
                                                    )),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                135,
                                        child: Text(desc,
                                            style: TextStyle(
                                                color: Color(0xFF3B3B3B),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15, bottom: 15),
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Color(0xFFF0F0F0),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
            ],
          )),
    );
  }

  _podcast(int i) {
    String userprofilepic = "";
    for (int j = 0; j < allUserpersonaldata.docs.length; j++) {
      if (allUserpersonaldata.docs[j].get("userid") ==
          socialfeed.docs[i].get("userid")) {
        userprofilepic = allUserpersonaldata.docs[j].get("profilepic");
      }
    }

    if ((userprofilepic != "")) {
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
                                  width:
                                      MediaQuery.of(context).size.width / 10.34,
                                  height:
                                      MediaQuery.of(context).size.width / 10.34,
                                  child: CachedNetworkImage(
                                    imageUrl: userprofilepic,
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
                              socialfeed.docs[i].get("feedtype"), i, [], []),
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
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.dstATop),
                        image: AssetImage('assets/podcastBackground1.png'),
                        fit: BoxFit.cover),
                  ),
                  width: MediaQuery.of(context).size.width - 20,
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AlbumPlayer(
                                              socialfeed.docs[i]
                                                  .get('albumname'))));
                                },
                                child: Text(
                                  socialfeed.docs[i].get('albumname'),
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Episode : ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              socialfeed.docs[i].get('name'),
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
                        ExpandablePanel(
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    height: 60,
                                    child: Image.asset(
                                        'assets/wallpaperPodcast2.jpg')),
                                Text(
                                  socialfeed.docs[i]
                                      .get('duration')
                                      .toString()
                                      .substring(0, 7),
                                  //.substring(0, 7),
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                InkWell(
                                    child: Icon(
                                  Icons.play_circle_fill,
                                ))
                              ],
                            ),
                            expanded: _mediaPlayer(i)),
                      ],
                    ),
                  )),
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
                                    countData
                                        .child(socialfeed.docs[i].id)
                                        .child("likecount")
                                        .value
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
                                        .value
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
                                      .value
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
                                        "likescount": countData
                                            .child(socialfeed.docs[i].id)
                                            .child("likecount")
                                            .value
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
          ));
    }
  }

  AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();
  List<bool> _mediaPlayerFlags = [];
  String podcastName = "";
  bool playflagMP = false;

  _mediaPlayer(int index) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          audioPlayer1.builderRealtimePlayingInfos(builder: (context, infos) {
            print(audioPlayer1.playerState.valueWrapper.value);
            if (audioPlayer1.playerState.valueWrapper.value ==
                PlayerState.stop) {
              _mediaPlayerFlags[0] = false;
            }
            //print("infos: $infos");
            /*if (infos != null) {
              if (infos.currentPosition == infos.duration) {
                setState(() {
                  _mediaPlayerFlags[0] = false;
                });
              }
            }*/
            return Column(children: [
              PositionSeekWidget(
                id: index,
                currentPosition: (_mediaPlayerFlags[0] == true)
                    ? infos.currentPosition
                    : Duration(minutes: 0, seconds: 0),
                duration: (_mediaPlayerFlags[0] == true)
                    ? infos.duration
                    : Duration(minutes: 0, seconds: 0),
                seekTo: (to) {
                  audioPlayer1.seek(to);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: InkWell(
                                onTap: () {
                                  audioPlayer1.seekBy(Duration(seconds: -10));
                                },
                                child: Icon(Icons.replay_10))),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: InkWell(
                                onTap: () async {
                                  if (audioPlayer1
                                      .isPlaying.valueWrapper.value) {
                                    audioPlayer1.pause();

                                    setState(() {
                                      _mediaPlayerFlags[0] = false;
                                    });
                                  } else {
                                    await audioPlayer1.open(Audio.network(
                                        socialfeed.docs[index]
                                            .get('audiourl')));
                                    if (audioPlayer1.realtimePlayingInfos
                                            .valueWrapper.value !=
                                        null) {
                                      setState(() {
                                        _mediaPlayerFlags[0] = true;
                                      });
                                    }
                                  }
                                },
                                child: _mediaPlayerFlags[0] == true
                                    ? Icon(Icons.pause)
                                    : Icon(Icons.play_arrow))),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: InkWell(
                                onTap: () {
                                  audioPlayer1.seekBy(Duration(seconds: 10));
                                },
                                child: Icon(Icons.forward_10))),
                      ),
                    ),
                  ],
                ),
              ),
            ]);
          }),
        ]));
  }

  _projectDiscussed(int i) {
    String userprofilepic = "";
    for (int j = 0; j < allUserpersonaldata.docs.length; j++) {
      if (allUserpersonaldata.docs[j].get("userid") ==
          socialfeed.docs[i].get("userid")) {
        userprofilepic = allUserpersonaldata.docs[j].get("profilepic");
      }
    }

    if ((userprofilepic != "")) {
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
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                child: CachedNetworkImage(
                                  imageUrl: userprofilepic,
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
                            socialfeed.docs[i].get("feedtype"), i, [], []),
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
            Container(
                width: MediaQuery.of(context).size.width - 50,
                child: Text(socialfeed.docs[i].get("content"))),
            SizedBox(
              height: 5,
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.dstATop),
                      image: AssetImage(socialfeed.docs[i].get("theme")),
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
                            socialfeed.docs[i].get('title'),
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
                            socialfeed.docs[i].get('grade'),
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
                            socialfeed.docs[i].get('subject'),
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
                            socialfeed.docs[i].get('topic'),
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
                              (socialfeed.docs[i].get("projectvideourl") != "")
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Video_Player(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                  socialfeed.docs[i]
                                                      .get("projectvideourl"));
                                            },
                                          ),
                                        );
                                      },
                                      child: Material(
                                        elevation: 1,
                                        borderRadius: BorderRadius.circular(5),
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
                              (socialfeed.docs[i].get("reqvideourl") != "")
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Video_Player(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                  socialfeed.docs[i]
                                                      .get("reqvideourl"));
                                            },
                                          ),
                                        );
                                      },
                                      child: Material(
                                        elevation: 1,
                                        borderRadius: BorderRadius.circular(5),
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
                              (socialfeed.docs[i].get("otherdoc") != null)
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Video_Player(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                  socialfeed.docs[i]
                                                      .get("reqvideourl"));
                                            },
                                          ),
                                        );
                                      },
                                      child: Material(
                                        elevation: 1,
                                        borderRadius: BorderRadius.circular(5),
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
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewFile(socialfeed.docs[i].id)));
                              },
                              child: Container(
                                child: Text("....See More",
                                    style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue)),
                              ),
                            )
                          ])
                    ],
                  ),
                )),
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
                                      .value
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
                                      .value
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
                                    .value
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
                                      }
                                    }
                                  } else {
                                    if (_reactionIndex[0] == -1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 0) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 2) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    }
                                    socialFeed.updateReactionCount(
                                        socialfeed.docs[i].id, {
                                      "likescount": countData
                                          .child(socialfeed.docs[i].id)
                                          .child("likecount")
                                          .value
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
                                    builder: (context) =>
                                        ShareFeedPost(socialfeed.docs[i].id)));
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
  }

  Widget buildGridView(List imagesFile, int i) {
    return imagesFile.length == 1
        ? InkWell(
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             MultipleImagesPostInDetails(socialfeed.docs[i].id)));
            },
            child: Container(
              height: 300,
              width: 300,
              child: Image.network(
                imagesFile[0],
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Image.asset(
                    "assets/loadingimg.gif",
                  );
                },
              ),
            ),
          )
        : InkWell(
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             MultipleImagesPostInDetails(socialfeed.docs[i].id)));
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
                              Image.network(
                                imagesFile[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Image.asset(
                                    "assets/loadingimg.gif",
                                  );
                                },
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
                      : Image.network(
                          imagesFile[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Image.asset(
                              "assets/loadingimg.gif",
                            );
                          },
                        );
                }),
              ),
            ),
          );
  }

  _chooseHeaderAccordingToMood(
      String mood, int i, List selectedUserName, List selectedUserID) {
    String gender = "";
    String celebrategender = "";
    if ((mood != "projectdiscuss") &&
        (mood != "businessideas") &&
        (mood != "podcast") &&
        (mood != "blog")) {
      gender = socialfeed.docs[i].get("usergender") == "Male" ? "him" : "her";
      celebrategender =
          socialfeed.docs[i].get("usergender") == "Male" ? "his" : "her";
    }
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
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'need people around $gender ',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset("assets/group.png", height: 20, width: 20),
              ],
            ),
            Row(
              children: [
                ((selectedUserName != null) && (selectedUserName.length > 0))
                    ? Icon(FontAwesome5.user_tag,
                        size: 10, color: Color.fromRGBO(0, 0, 0, 0.8))
                    : SizedBox(),
                SizedBox(width: 5),
                RichText(
                    text: ((selectedUserName != null) &&
                            (selectedUserName.length > 0))
                        ? TextSpan(
                            text: selectedUserName[0],
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
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
                                        text:
                                            '${selectedUserName.length - 1} others',
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
                                        text:
                                            '${selectedUserName.length - 1} other',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 12,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : TextSpan(),
                              ])
                        : TextSpan()),
              ],
            )
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
    } else if (mood == "projectdiscuss") {
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
                      text: ' has Discussed a Project on',
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
              socialfeed.docs[i].get("title"),
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
    } else if (mood == "businessideas") {
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
                      text: ' has Discussed a Business Idea',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "podcast") {
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
                      text: ' hosted a Podcast.',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
          ],
        ),
      );
    } else if (mood == "blog") {
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
                      text: ' has created a Blog.',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
          ],
        ),
      );
    }
  }

  _businessIdeas(int i, String id) {
    String userprofilepic = "";
    for (int j = 0; j < allUserpersonaldata.docs.length; j++) {
      if (allUserpersonaldata.docs[j].get("userid") ==
          socialfeed.docs[i].get("userid")) {
        userprofilepic = allUserpersonaldata.docs[j].get("profilepic");
      }
    }
    int totalDoc = socialfeed.docs[i].get("totaldocuments");
    List<dynamic> files = socialfeed.docs[i].get("documents");
    List<dynamic> fileformat = socialfeed.docs[i].get("formats");
    print(fileformat);

    if ((userprofilepic != "")) {
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
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                child: CachedNetworkImage(
                                  imageUrl: userprofilepic,
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
                            socialfeed.docs[i].get("feedtype"), i, [], []),
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
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.dstATop),
                      image: AssetImage(socialfeed.docs[i].get("theme")),
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
                            socialfeed.docs[i].get('title'),
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
                                          // PdftronFlutter.openDocument(files[0]);
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
                                                  child: (fileformat[0] ==
                                                          "pdf")
                                                      ? Icon(
                                                          Icons.picture_as_pdf,
                                                          color: Colors.red,
                                                          size: 22)
                                                      : (fileformat[0] ==
                                                              "excel")
                                                          ? Image.asset(
                                                              "assets/excel_icon.png",
                                                              height: 22,
                                                              width: 22,
                                                            )
                                                          : (fileformat[0] ==
                                                                  "ppt")
                                                              ? Image.asset(
                                                                  "assets/ppt_icon1.png",
                                                                  height: 22,
                                                                  width: 22)
                                                              : (fileformat[
                                                                          0] ==
                                                                      "word")
                                                                  ? Image.asset(
                                                                      "assets/word_icon.png",
                                                                      height:
                                                                          22,
                                                                      width: 22)
                                                                  : SizedBox())),
                                        ),
                                      )
                                    : (totalDoc > 1)
                                        ? Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // PdftronFlutter.openDocument(
                                                  //     files[0]);
                                                },
                                                child: Material(
                                                  elevation: 1,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        // color: Color(0xFFE9A81D)
                                                      ),
                                                      child: Center(
                                                          child: (fileformat[
                                                                      0] ==
                                                                  "pdf")
                                                              ? Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 22)
                                                              : (fileformat[
                                                                          0] ==
                                                                      "excel")
                                                                  ? Image.asset(
                                                                      "assets/excel_icon.png",
                                                                      height:
                                                                          22,
                                                                      width: 22,
                                                                    )
                                                                  : (fileformat[
                                                                              0] ==
                                                                          "ppt")
                                                                      ? Image.asset(
                                                                          "assets/ppt_icon1.png",
                                                                          height:
                                                                              22,
                                                                          width:
                                                                              22)
                                                                      : (fileformat[0] ==
                                                                              "word")
                                                                          ? Image.asset(
                                                                              "assets/word_icon.png",
                                                                              height: 22,
                                                                              width: 22)
                                                                          : SizedBox())),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              InkWell(
                                                onTap: () {
                                                  // PdftronFlutter.openDocument(
                                                  //     files[1]);
                                                },
                                                child: Material(
                                                  elevation: 1,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        // color: Color(0xFFE9A81D)
                                                      ),
                                                      child: Center(
                                                          child: (fileformat[
                                                                      1] ==
                                                                  "pdf")
                                                              ? Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 22)
                                                              : (fileformat[
                                                                          1] ==
                                                                      "excel")
                                                                  ? Image.asset(
                                                                      "assets/excel_icon.png",
                                                                      height:
                                                                          22,
                                                                      width: 22,
                                                                    )
                                                                  : (fileformat[
                                                                              1] ==
                                                                          "ppt")
                                                                      ? Image.asset(
                                                                          "assets/ppt_icon1.png",
                                                                          height:
                                                                              22,
                                                                          width:
                                                                              22)
                                                                      : (fileformat[1] ==
                                                                              "word")
                                                                          ? Image.asset(
                                                                              "assets/word_icon.png",
                                                                              height: 22,
                                                                              width: 22)
                                                                          : SizedBox())),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              (totalDoc == 3)
                                                  ? InkWell(
                                                      onTap: () {
                                                        // PdftronFlutter
                                                        //     .openDocument(
                                                        //     files[2]);
                                                      },
                                                      child: Material(
                                                        elevation: 1,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              // color: Color(0xFFE9A81D)
                                                            ),
                                                            child: Center(
                                                                child: (fileformat[
                                                                            0] ==
                                                                        "pdf")
                                                                    ? Icon(
                                                                        Icons
                                                                            .picture_as_pdf,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            22)
                                                                    : (fileformat[2] ==
                                                                            "excel")
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/excel_icon.png",
                                                                            height:
                                                                                22,
                                                                            width:
                                                                                22,
                                                                          )
                                                                        : (fileformat[2] ==
                                                                                "ppt")
                                                                            ? Image.asset("assets/ppt_icon1.png",
                                                                                height: 22,
                                                                                width: 22)
                                                                            : (fileformat[2] == "word")
                                                                                ? Image.asset("assets/word_icon.png", height: 22, width: 22)
                                                                                : SizedBox())),
                                                      ),
                                                    )
                                                  : SizedBox()
                                            ],
                                          )
                                        : SizedBox()),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewBusinessFile(
                                            socialfeed.docs[i].id)));
                              },
                              child: Container(
                                child: Text("....See Full Plan",
                                    style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue)),
                              ),
                            )
                          ])
                    ],
                  ),
                )),
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
                                      .value
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
                                      .value
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
                                    .value
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
                                      }
                                    }
                                  } else {
                                    if (_reactionIndex[0] == -1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 0) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 1) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    } else if (_reactionIndex[0] == 2) {
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
                                                .value
                                                .toString()) +
                                            1
                                      });
                                    }
                                    socialFeed.updateReactionCount(
                                        socialfeed.docs[i].id, {
                                      "likescount": countData
                                          .child(socialfeed.docs[i].id)
                                          .child("likecount")
                                          .value
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
                                    builder: (context) =>
                                        ShareFeedPost(socialfeed.docs[i].id)));
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
  }

  _shareSocialFeed(int i) {
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
                              child: Image.network(
                                socialfeed.docs[i].get("userprofilepic"),
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
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            FlutterReactionButtonCheck(
                              onReactionChanged: (reaction, index, ischecked) {
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
                                        _currentUserId + socialfeed.docs[i].id);
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
                                    } else if (_reactionIndex[0] == 1) {
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
                                    } else if (_reactionIndex[0] == 2) {
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
                                    } else if (_reactionIndex[0] == 3) {
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
                                    } else if (_reactionIndex[0] == 4) {
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " liked your post.",
                                            "You got a like!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Like",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " loved your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Love",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted haha on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Haha",
                                            comparedate);

                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted yay on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Yay",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                personaldata.docs[0]
                                                    .get("lastname"),
                                            personaldata.docs[0]
                                                .get("profilepic"),
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted wow on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Wow",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                            socialfeed.docs[i].get("username"),
                                            socialfeed.docs[i].get("userid"),
                                            personaldata.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata.docs[0]
                                                    .get("lastname") +
                                                " reacted angry on your post.",
                                            "You got a reaction!",
                                            current_date,
                                            usertokendataLocalDB.get(socialfeed
                                                .docs[i]
                                                .get("userid")),
                                            socialfeed.docs[i].id,
                                            i,
                                            "Angry",
                                            comparedate);
                                    socialFeedPostReactionsDB.put(
                                        _currentUserId + socialfeed.docs[i].id,
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
                                    "likescount": countData
                                        .child(socialfeed.docs[i].id)
                                        .child("likecount")
                                        .value
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
                                                    fontWeight: FontWeight.w700,
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.comment,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
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
                Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    color: Colors.white54,
                    height: 1,
                    width: MediaQuery.of(context).size.width),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/reactions/like.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/laugh.png",
                                  height: 15, width: 15),
                              Image.asset("assets/reactions/wow.png",
                                  height: 15, width: 15),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                countData
                                    .child(socialfeed.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color.fromRGBO(205, 61, 61, 1)),
                              ),
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
                                      child: Image.network(
                                        socialfeed.docs[i]
                                            .get("shareuserprofilepic"),
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
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

  _comment(int i) {
    String date =
        getTimeDifferenceFromNow(smComments.docs[i].get("createdate"));
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 35,
                width: 35,
                margin: EdgeInsets.all(10),
                child: CircleAvatar(
                  child: ClipOval(
                    child: Container(
                      child: Image.network(
                        smComments.docs[i].get("userprofilepic"),
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            personaldata.docs[0].get("gender") == "Male"
                                ? "assets/maleicon.jpg"
                                : "assets/femaleicon.png",
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Bubble(
                    color: Color.fromRGBO(242, 246, 248, 1),
                    nip: BubbleNip.leftTop,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.45,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(242, 246, 248, 1),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                smComments.docs[i].get("username"),
                                style: TextStyle(
                                    color: Color(0xFF4D4D4D),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${smComments.docs[i].get("userschoolname")} | Grade ${smComments.docs[i].get("usergrade")}",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: ReadMoreText(
                                smComments.docs[i].get("comment"),
                                trimLines: 4,
                                colorClickableText: Color(0xff0962ff),
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'read more',
                                trimExpandedText: 'Show less',
                                style: TextStyle(
                                    color: Color(0xFF4D4D4D),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                                lessStyle: TextStyle(
                                    color: Color(0xFF4D4D4D),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                                moreStyle: TextStyle(
                                    color: Color(0xFF4D4D4D),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          smComments.docs[i].get("imagelist") != ""
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (smComments.docs[i]
                                                  .get("imagelist") !=
                                              "") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SingleImageView(
                                                            smComments.docs[i]
                                                                .get(
                                                                    "imagelist"),
                                                            "NetworkImage")));
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        height: 300,
                                        child: Image.network(
                                          smComments.docs[i].get("imagelist"),
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Image.asset(
                                              "assets/loadingimg.gif",
                                              width: 200,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () {
                            if (socialFeedCommentsReactionsDB
                                    .get(smComments.docs[i].id) !=
                                null) {
                              socialFeedCommentsReactionsDB
                                  .delete(smComments.docs[i].id);
                              socialFeedComment.deleteCommentLikeDetails(
                                  _currentUserId + smComments.docs[i].id);
                              databaseReference
                                  .child("sm_feeds_comments")
                                  .child("reactions")
                                  .child(smComments.docs[i].id)
                                  .update({
                                'likecount': int.parse(countData2
                                        .child(smComments.docs[i].id)
                                        .child("likecount")
                                        .value
                                        .toString()) -
                                    1
                              });
                              _notificationdb
                                  .deleteSocialFeedReactionsNotification(
                                      _currentUserId +
                                          smComments.docs[i].id +
                                          "Like");
                            } else {
                              socialFeedCommentsReactionsDB.put(
                                  smComments.docs[i].id, "Like");

                              databaseReference
                                  .child("sm_feeds_comments")
                                  .child("reactions")
                                  .child(smComments.docs[i].id)
                                  .update({
                                'likecount': int.parse(countData2
                                        .child(smComments.docs[i].id)
                                        .child("likecount")
                                        .value
                                        .toString()) +
                                    1
                              });
                              _notificationdb
                                  .socialFeedcommentsReactionsNotifications(
                                      personaldata.docs[0].get("firstname") +
                                          personaldata.docs[0].get("lastname"),
                                      personaldata.docs[0].get("profilepic"),
                                      socialfeed.docs[i].get("username"),
                                      socialfeed.docs[i].get("userid"),
                                      personaldata.docs[0].get("firstname") +
                                          " " +
                                          personaldata.docs[0].get("lastname") +
                                          " liked your post.",
                                      "You got a like!",
                                      current_date,
                                      usertokendataLocalDB.get(
                                          socialfeed.docs[i].get("userid")),
                                      socialfeed.docs[i].id,
                                      i,
                                      smComments.docs[i].id,
                                      "Like",
                                      comparedate);
                              socialFeedComment.addFeedCommentLikesDetails(
                                  this.feedID,
                                  smComments.docs[i].id,
                                  smComments.docs[i].get("userid"),
                                  smComments.docs[i].get("username"),
                                  smComments.docs[i].get("userschoolname"),
                                  smComments.docs[i].get("userprofilepic"),
                                  "Delhi",
                                  smComments.docs[i].get("usergrade"),
                                  personaldata.docs[0].get("firstname") +
                                      personaldata.docs[0].get("lastname"),
                                  schooldata.docs[0].get("schoolname"),
                                  personaldata.docs[0].get("profilepic"),
                                  "Delhi",
                                  schooldata.docs[0].get("grade"),
                                  current_date,
                                  comparedate);
                            }
                          },
                          child: Text(
                            "Like",
                            style: TextStyle(
                                color: socialFeedCommentsReactionsDB
                                            .get(smComments.docs[i].id) !=
                                        null
                                    ? Color(0xff0962ff)
                                    : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString()) >
                                0
                            ? SizedBox(width: 4)
                            : SizedBox(),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("likecount")
                                    .value) >
                                0
                            ? Text(
                                " " +
                                    (countData2
                                            .child(smComments.docs[i].id)
                                            .child("likecount")
                                            .value)
                                        .toString() +
                                    " ",
                                style: TextStyle(
                                    color: socialFeedCommentsReactionsDB
                                                .get(smComments.docs[i].id) !=
                                            null
                                        ? Color(0xff0962ff)
                                        : Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString()) >
                                0
                            ? Image.asset("assets/reactions/like.gif",
                                height: 25, width: 25)
                            : SizedBox(),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          " | ",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () {
                            print(i);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => SocialFeedSubComments(
                            //             this.feedID,
                            //             feedindex,
                            //             smComments.docs[i].id,
                            //             i)));
                          },
                          child: Text(
                            "Reply",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("commentcount")
                                    .value
                                    .toString()) >
                                0
                            ? SizedBox(
                                width: 4,
                              )
                            : SizedBox(),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("commentcount")
                                    .value
                                    .toString()) >
                                0
                            ? Text(
                                " " +
                                    (countData2
                                            .child(smComments.docs[i].id)
                                            .child("commentcount")
                                            .value)
                                        .toString() +
                                    " ",
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        int.parse(countData2
                                    .child(smComments.docs[i].id)
                                    .child("commentcount")
                                    .value
                                    .toString()) >
                                0
                            ? Icon(Icons.chat,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14)
                            : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _subComment(smComments.docs[i].id, i),
        i == smComments.docs.length - 1
            ? SizedBox(
                height: 100,
              )
            : SizedBox()
      ],
    );
  }

  _subComment(String commentid, int commentIndex) {
    int count = 0;
    bool check = false;
    int subcommentIndex = 0;
    for (int k = 0; k < smReplies.docs.length; k++) {
      if (smReplies.docs[k].get("commentid") == commentid) {
        check = true;
        count++;

        if (count == 1) {
          subcommentIndex = k;
        }
      }
    }
    if (check == true) {
      if (count == 1) {
        String date = getTimeDifferenceFromNow(
            smReplies.docs[subcommentIndex].get("createdate"));
        return Container(
          margin: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  child: ClipOval(
                    child: Container(
                      child: Image.network(
                        smReplies.docs[subcommentIndex].get("userprofilepic"),
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            personaldata.docs[0].get("usergender") == "Male"
                                ? "assets/maleicon.jpg"
                                : "assets/femaleicon.png",
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bubble(
                      color: Color.fromRGBO(242, 246, 248, 1),
                      nip: BubbleNip.leftTop,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.60,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(242, 246, 248, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  smReplies.docs[subcommentIndex]
                                      .get("username"),
                                  style: TextStyle(
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${smReplies.docs[subcommentIndex].get("userschoolname")} | Grade ${smReplies.docs[subcommentIndex].get("usergrade")}",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                child: ReadMoreText(
                                  smReplies.docs[subcommentIndex]
                                      .get("comment"),
                                  trimLines: 4,
                                  colorClickableText: Color(0xff0962ff),
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'read more',
                                  trimExpandedText: 'Show less',
                                  style: TextStyle(
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500),
                                  lessStyle: TextStyle(
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500),
                                  moreStyle: TextStyle(
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            smReplies.docs[subcommentIndex].get("imagelist") !=
                                    ""
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (smReplies.docs[subcommentIndex]
                                                    .get("imagelist") !=
                                                "") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SingleImageView(
                                                              smReplies.docs[
                                                                      subcommentIndex]
                                                                  .get(
                                                                      "imagelist"),
                                                              "NetworkImage")));
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          height: 300,
                                          child: Image.network(
                                            smReplies.docs[subcommentIndex]
                                                .get("imagelist"),
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Image.asset(
                                                "assets/loadingimg.gif",
                                                width: 200,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              if (socialFeedSubCommentsReactionsDB.get(
                                      smReplies.docs[subcommentIndex].id) !=
                                  null) {
                                socialFeedSubCommentsReactionsDB
                                    .delete(smReplies.docs[subcommentIndex].id);
                                socialFeedSubComment
                                    .deleteSubCommentLikeDetails(
                                        _currentUserId +
                                            smReplies.docs[subcommentIndex].id);
                                databaseReference
                                    .child("sm_feeds_reply")
                                    .child("reactions")
                                    .child(smReplies.docs[subcommentIndex].id)
                                    .update({
                                  'likecount': int.parse(countData3
                                          .child(smReplies
                                              .docs[subcommentIndex].id)
                                          .child("likecount")
                                          .value
                                          .toString()) -
                                      1
                                });
                                _notificationdb
                                    .deleteSocialFeedReactionsNotification(
                                        _currentUserId +
                                            smReplies.docs[subcommentIndex].id +
                                            "Like");
                              } else {
                                socialFeedSubCommentsReactionsDB.put(
                                    smReplies.docs[subcommentIndex].id, "Like");

                                databaseReference
                                    .child("sm_feeds_reply")
                                    .child("reactions")
                                    .child(smReplies.docs[subcommentIndex].id)
                                    .update({
                                  'likecount': int.parse(countData3
                                          .child(smReplies
                                              .docs[subcommentIndex].id)
                                          .child("likecount")
                                          .value
                                          .toString()) +
                                      1
                                });
                                _notificationdb
                                    .socialFeedreplyReactionNotifications(
                                        personaldata.docs[0].get("firstname") +
                                            personaldata.docs[0]
                                                .get("lastname"),
                                        personaldata.docs[0].get("profilepic"),
                                        smReplies.docs[subcommentIndex]
                                            .get("username"),
                                        smReplies.docs[subcommentIndex]
                                            .get("userid"),
                                        personaldata.docs[0].get("firstname") +
                                            " " +
                                            personaldata.docs[0]
                                                .get("lastname") +
                                            " liked your post.",
                                        "You got a like!",
                                        current_date,
                                        usertokendataLocalDB.get(smReplies
                                            .docs[subcommentIndex]
                                            .get("userid")),
                                        feedID,
                                        feedindex,
                                        commentid,
                                        commentIndex,
                                        smReplies.docs[subcommentIndex].id,
                                        subcommentIndex,
                                        "Like",
                                        comparedate);
                                socialFeedSubComment
                                    .addFeedSubCommentLikesDetails(
                                        feedindex,
                                        commentid,
                                        smReplies.docs[subcommentIndex].id,
                                        smReplies.docs[subcommentIndex]
                                            .get("userid"),
                                        smReplies.docs[subcommentIndex]
                                            .get("username"),
                                        smReplies.docs[subcommentIndex]
                                            .get("userschoolname"),
                                        smReplies.docs[subcommentIndex]
                                            .get("userprofilepic"),
                                        "Delhi",
                                        smReplies.docs[subcommentIndex]
                                            .get("usergrade"),
                                        personaldata.docs[0].get("firstname") +
                                            personaldata.docs[0]
                                                .get("lastname"),
                                        schooldata.docs[0].get("schoolname"),
                                        personaldata.docs[0].get("profilepic"),
                                        "Delhi",
                                        schooldata.docs[0].get("grade"),
                                        current_date,
                                        comparedate);
                              }
                            },
                            child: Text(
                              "Like",
                              style: TextStyle(
                                  color: socialFeedSubCommentsReactionsDB.get(
                                              smReplies
                                                  .docs[subcommentIndex].id) !=
                                          null
                                      ? Color(0xff0962ff)
                                      : Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          int.parse(countData3
                                      .child(smReplies.docs[subcommentIndex].id)
                                      .child("likecount")
                                      .value
                                      .toString()) >
                                  0
                              ? SizedBox(
                                  width: 4,
                                )
                              : SizedBox(),
                          int.parse(countData3
                                      .child(smReplies.docs[subcommentIndex].id)
                                      .child("likecount")
                                      .value
                                      .toString()) >
                                  0
                              ? Text(
                                  " " +
                                      (countData3
                                              .child(smReplies
                                                  .docs[subcommentIndex].id)
                                              .child("likecount")
                                              .value)
                                          .toString() +
                                      " ",
                                  style: TextStyle(
                                      color: socialFeedSubCommentsReactionsDB
                                                  .get(smReplies
                                                      .docs[subcommentIndex]
                                                      .id) !=
                                              null
                                          ? Color(0xff0962ff)
                                          : Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                )
                              : SizedBox(),
                          int.parse(countData3
                                      .child(smReplies.docs[subcommentIndex].id)
                                      .child("likecount")
                                      .value
                                      .toString()) >
                                  0
                              ? Image.asset("assets/reactions/like.gif",
                                  height: 25, width: 25)
                              : SizedBox(),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            " | ",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            onTap: () async {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             SocialFeedSubComments(
                              //                 this.feedID,
                              //                 feedindex,
                              //                 commentid,
                              //                 commentIndex)));
                            },
                            child: Text(
                              "Reply",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          int.parse(countData3
                                      .child(smReplies.docs[subcommentIndex].id)
                                      .child("commentcount")
                                      .value
                                      .toString()) >
                                  0
                              ? SizedBox(
                                  width: 4,
                                )
                              : SizedBox(),
                          int.parse(countData3
                                      .child(smReplies.docs[subcommentIndex].id)
                                      .child("commentcount")
                                      .value
                                      .toString()) >
                                  0
                              ? Text(
                                  " " +
                                      countData3
                                          .child(smReplies
                                              .docs[subcommentIndex].id)
                                          .child("commentcount")
                                          .value
                                          .toString() +
                                      " replies",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
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
        );
      } else if (count > 1) {
        if (subcommarrayshow[commentIndex] == false) {
          String date = getTimeDifferenceFromNow(
              smReplies.docs[subcommentIndex].get("createdate"));
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      subcommarrayshow[commentIndex] =
                          !subcommarrayshow[commentIndex];
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Show ${count - 1} more replies",
                          style: TextStyle(
                              color: Color.fromRGBO(0, 17, 255, 1),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      margin: EdgeInsets.only(right: 10),
                      child: CircleAvatar(
                        child: ClipOval(
                          child: Container(
                            child: Image.network(
                              smReplies.docs[subcommentIndex]
                                  .get("userprofilepic"),
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Image.asset(
                                  personaldata.docs[0].get("usergender") ==
                                          "Male"
                                      ? "assets/maleicon.jpg"
                                      : "assets/femaleicon.png",
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bubble(
                            color: Color.fromRGBO(242, 246, 248, 1),
                            nip: BubbleNip.leftTop,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.60,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(242, 246, 248, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        smReplies.docs[subcommentIndex]
                                            .get("username"),
                                        style: TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${smReplies.docs[subcommentIndex].get("userschoolname")} | Grade ${smReplies.docs[subcommentIndex].get("usergrade")}",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      child: ReadMoreText(
                                        smReplies.docs[subcommentIndex]
                                            .get("comment"),
                                        trimLines: 4,
                                        colorClickableText: Color(0xff0962ff),
                                        trimMode: TrimMode.Line,
                                        trimCollapsedText: 'read more',
                                        trimExpandedText: 'Show less',
                                        style: TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500),
                                        lessStyle: TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500),
                                        moreStyle: TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  smReplies.docs[subcommentIndex]
                                              .get("imagelist") !=
                                          ""
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (smReplies
                                                          .docs[subcommentIndex]
                                                          .get("imagelist") !=
                                                      "") {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SingleImageView(
                                                                    smReplies
                                                                        .docs[
                                                                            subcommentIndex]
                                                                        .get(
                                                                            "imagelist"),
                                                                    "NetworkImage")));
                                                  }
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(5),
                                                height: 300,
                                                child: Image.network(
                                                  smReplies
                                                      .docs[subcommentIndex]
                                                      .get("imagelist"),
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Image.asset(
                                                      "assets/loadingimg.gif",
                                                      width: 200,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                  SizedBox(
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (socialFeedSubCommentsReactionsDB.get(
                                            smReplies
                                                .docs[subcommentIndex].id) !=
                                        null) {
                                      socialFeedSubCommentsReactionsDB.delete(
                                          smReplies.docs[subcommentIndex].id);
                                      socialFeedSubComment
                                          .deleteSubCommentLikeDetails(
                                              _currentUserId +
                                                  smReplies
                                                      .docs[subcommentIndex]
                                                      .id);
                                      databaseReference
                                          .child("sm_feeds_reply")
                                          .child("reactions")
                                          .child(smReplies
                                              .docs[subcommentIndex].id)
                                          .update({
                                        'likecount': int.parse(countData3
                                                .child(smReplies
                                                    .docs[subcommentIndex].id)
                                                .child("likecount")
                                                .value
                                                .toString()) -
                                            1
                                      });
                                    } else {
                                      socialFeedSubCommentsReactionsDB.put(
                                          smReplies.docs[subcommentIndex].id,
                                          "Like");

                                      databaseReference
                                          .child("sm_feeds_reply")
                                          .child("reactions")
                                          .child(smReplies
                                              .docs[subcommentIndex].id)
                                          .update({
                                        'likecount': int.parse(countData3
                                                .child(smReplies
                                                    .docs[subcommentIndex].id)
                                                .child("likecount")
                                                .value
                                                .toString()) +
                                            1
                                      });
                                      socialFeedSubComment
                                          .addFeedSubCommentLikesDetails(
                                              feedindex,
                                              commentid,
                                              smReplies
                                                  .docs[subcommentIndex].id,
                                              smReplies.docs[subcommentIndex]
                                                  .get("userid"),
                                              smReplies.docs[subcommentIndex]
                                                  .get("username"),
                                              smReplies.docs[subcommentIndex]
                                                  .get("userschoolname"),
                                              smReplies.docs[subcommentIndex]
                                                  .get("userprofilepic"),
                                              "Delhi",
                                              smReplies.docs[subcommentIndex]
                                                  .get("usergrade"),
                                              personaldata.docs[0]
                                                      .get("firstname") +
                                                  personaldata.docs[0]
                                                      .get("lastname"),
                                              schooldata.docs[0]
                                                  .get("schoolname"),
                                              personaldata.docs[0]
                                                  .get("profilepic"),
                                              "Delhi",
                                              schooldata.docs[0].get("grade"),
                                              current_date,
                                              comparedate);
                                    }
                                  },
                                  child: Text(
                                    "Like",
                                    style: TextStyle(
                                        color: socialFeedSubCommentsReactionsDB
                                                    .get(smReplies
                                                        .docs[subcommentIndex]
                                                        .id) !=
                                                null
                                            ? Color(0xff0962ff)
                                            : Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                int.parse(countData3
                                            .child(smReplies
                                                .docs[subcommentIndex].id)
                                            .child("likecount")
                                            .value
                                            .toString()) >
                                        0
                                    ? SizedBox(
                                        width: 4,
                                      )
                                    : SizedBox(),
                                int.parse(countData3
                                            .child(smReplies
                                                .docs[subcommentIndex].id)
                                            .child("likecount")
                                            .value
                                            .toString()) >
                                        0
                                    ? Text(
                                        " " +
                                            (countData3
                                                    .child(smReplies
                                                        .docs[subcommentIndex]
                                                        .id)
                                                    .child("likecount")
                                                    .value)
                                                .toString() +
                                            " ",
                                        style: TextStyle(
                                            color: socialFeedSubCommentsReactionsDB
                                                        .get(smReplies
                                                            .docs[
                                                                subcommentIndex]
                                                            .id) !=
                                                    null
                                                ? Color(0xff0962ff)
                                                : Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      )
                                    : SizedBox(),
                                int.parse(countData3
                                            .child(smReplies
                                                .docs[subcommentIndex].id)
                                            .child("likecount")
                                            .value
                                            .toString()) >
                                        0
                                    ? Image.asset("assets/reactions/like.gif",
                                        height: 25, width: 25)
                                    : SizedBox(),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  " | ",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                InkWell(
                                  onTap: () async {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             SocialFeedSubComments(
                                    //                 this.feedID,
                                    //                 feedindex,
                                    //                 commentid,
                                    //                 commentIndex)));
                                  },
                                  child: Text(
                                    "Reply",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                int.parse(countData3
                                            .child(smReplies
                                                .docs[subcommentIndex].id)
                                            .child("commentcount")
                                            .value
                                            .toString()) >
                                        0
                                    ? SizedBox(
                                        width: 4,
                                      )
                                    : SizedBox(),
                                int.parse(countData3
                                            .child(smReplies
                                                .docs[subcommentIndex].id)
                                            .child("commentcount")
                                            .value
                                            .toString()) >
                                        0
                                    ? Text(
                                        " " +
                                            countData3
                                                .child(smReplies
                                                    .docs[subcommentIndex].id)
                                                .child("commentcount")
                                                .value
                                                .toString() +
                                            " replies",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
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
              ],
            ),
          );
        } else {
          return Container(
            height: (subcommarray[commentIndex].length * 140).toDouble(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: subcommarray[commentIndex].length,
              itemBuilder: (context, i) {
                String date = getTimeDifferenceFromNow(smReplies
                    .docs[subcommarray[commentIndex][i]]
                    .get("createdate"));
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            margin: EdgeInsets.only(right: 10),
                            child: CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                  child: Image.network(
                                    smReplies
                                        .docs[subcommarray[commentIndex][i]]
                                        .get("userprofilepic"),
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Image.asset(
                                        personaldata.docs[0]
                                                    .get("usergender") ==
                                                "Male"
                                            ? "assets/maleicon.jpg"
                                            : "assets/femaleicon.png",
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Bubble(
                                  color: Color.fromRGBO(242, 246, 248, 1),
                                  nip: BubbleNip.leftTop,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.60,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(242, 246, 248, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              smReplies.docs[
                                                      subcommarray[commentIndex]
                                                          [i]]
                                                  .get("username"),
                                              style: TextStyle(
                                                  color: Color(0xFF4D4D4D),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${smReplies.docs[subcommarray[commentIndex][i]].get("userschoolname")} | Grade ${smReplies.docs[subcommarray[commentIndex][i]].get("usergrade")}",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            child: ReadMoreText(
                                              smReplies.docs[
                                                      subcommarray[commentIndex]
                                                          [i]]
                                                  .get("comment"),
                                              trimLines: 4,
                                              colorClickableText:
                                                  Color(0xff0962ff),
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: 'read more',
                                              trimExpandedText: 'Show less',
                                              style: TextStyle(
                                                  color: Color(0xFF4D4D4D),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w500),
                                              lessStyle: TextStyle(
                                                  color: Color(0xFF4D4D4D),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w500),
                                              moreStyle: TextStyle(
                                                  color: Color(0xFF4D4D4D),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        smReplies.docs[subcommarray[
                                                        commentIndex][i]]
                                                    .get("imagelist") !=
                                                ""
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (smReplies
                                                                .docs[subcommarray[
                                                                        commentIndex]
                                                                    [i]]
                                                                .get(
                                                                    "imagelist") !=
                                                            "") {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => SingleImageView(
                                                                      smReplies
                                                                          .docs[subcommarray[commentIndex]
                                                                              [
                                                                              i]]
                                                                          .get(
                                                                              "imagelist"),
                                                                      "NetworkImage")));
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(5),
                                                      height: 300,
                                                      child: Image.network(
                                                        smReplies
                                                            .docs[subcommarray[
                                                                commentIndex][i]]
                                                            .get("imagelist"),
                                                        fit: BoxFit.cover,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Image.asset(
                                                            "assets/loadingimg.gif",
                                                            width: 200,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        date,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (socialFeedSubCommentsReactionsDB
                                                  .get(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id) !=
                                              null) {
                                            socialFeedSubCommentsReactionsDB
                                                .delete(smReplies
                                                    .docs[subcommarray[
                                                        commentIndex][i]]
                                                    .id);
                                            socialFeedSubComment
                                                .deleteSubCommentLikeDetails(
                                                    _currentUserId +
                                                        smReplies
                                                            .docs[subcommarray[
                                                                commentIndex][i]]
                                                            .id);
                                            databaseReference
                                                .child("sm_feeds_reply")
                                                .child("reactions")
                                                .child(smReplies
                                                    .docs[subcommarray[
                                                        commentIndex][i]]
                                                    .id)
                                                .update({
                                              'likecount': int.parse(countData3
                                                      .child(smReplies
                                                          .docs[subcommarray[
                                                              commentIndex][i]]
                                                          .id)
                                                      .child("likecount")
                                                      .value
                                                      .toString()) -
                                                  1
                                            });
                                          } else {
                                            socialFeedSubCommentsReactionsDB
                                                .put(
                                                    smReplies
                                                        .docs[subcommarray[
                                                            commentIndex][i]]
                                                        .id,
                                                    "Like");

                                            databaseReference
                                                .child("sm_feeds_reply")
                                                .child("reactions")
                                                .child(smReplies
                                                    .docs[subcommarray[
                                                        commentIndex][i]]
                                                    .id)
                                                .update({
                                              'likecount': int.parse(countData3
                                                      .child(smReplies
                                                          .docs[subcommarray[
                                                              commentIndex][i]]
                                                          .id)
                                                      .child("likecount")
                                                      .value
                                                      .toString()) +
                                                  1
                                            });
                                            socialFeedSubComment.addFeedSubCommentLikesDetails(
                                                feedindex,
                                                commentid,
                                                smReplies
                                                    .docs[
                                                        subcommarray[commentIndex]
                                                            [i]]
                                                    .id,
                                                smReplies.docs[subcommarray[commentIndex][i]]
                                                    .get("userid"),
                                                smReplies.docs[subcommarray[commentIndex][i]]
                                                    .get("username"),
                                                smReplies.docs[subcommarray[commentIndex][i]]
                                                    .get("userschoolname"),
                                                smReplies.docs[subcommarray[commentIndex][i]]
                                                    .get("userprofilepic"),
                                                "Delhi",
                                                smReplies.docs[
                                                        subcommarray[commentIndex]
                                                            [i]]
                                                    .get("usergrade"),
                                                personaldata.docs[0].get("firstname") +
                                                    personaldata.docs[0]
                                                        .get("lastname"),
                                                schooldata.docs[0]
                                                    .get("schoolname"),
                                                personaldata.docs[0]
                                                    .get("profilepic"),
                                                "Delhi",
                                                schooldata.docs[0].get("grade"),
                                                current_date,
                                                comparedate);
                                          }
                                        },
                                        child: Text(
                                          "Like",
                                          style: TextStyle(
                                              color: socialFeedSubCommentsReactionsDB
                                                          .get(smReplies
                                                              .docs[subcommarray[
                                                                  commentIndex][i]]
                                                              .id) !=
                                                      null
                                                  ? Color(0xff0962ff)
                                                  : Colors.black54,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      int.parse(countData3
                                                  .child(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) >
                                              0
                                          ? SizedBox(
                                              width: 4,
                                            )
                                          : SizedBox(),
                                      int.parse(countData3
                                                  .child(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) >
                                              0
                                          ? Text(
                                              " " +
                                                  (countData3
                                                          .child(smReplies
                                                              .docs[subcommarray[
                                                                  commentIndex][i]]
                                                              .id)
                                                          .child("likecount")
                                                          .value)
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: socialFeedSubCommentsReactionsDB
                                                              .get(smReplies
                                                                  .docs[subcommarray[
                                                                      commentIndex][i]]
                                                                  .id) !=
                                                          null
                                                      ? Color(0xff0962ff)
                                                      : Colors.black54,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          : SizedBox(),
                                      int.parse(countData3
                                                  .child(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id)
                                                  .child("likecount")
                                                  .value
                                                  .toString()) >
                                              0
                                          ? Image.asset(
                                              "assets/reactions/like.gif",
                                              height: 25,
                                              width: 25)
                                          : SizedBox(),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        " | ",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             SocialFeedSubComments(
                                          //                 this.feedID,
                                          //                 feedindex,
                                          //                 commentid,
                                          //                 commentIndex)));
                                        },
                                        child: Text(
                                          "Reply",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      int.parse(countData3
                                                  .child(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id)
                                                  .child("commentcount")
                                                  .value
                                                  .toString()) >
                                              0
                                          ? SizedBox(
                                              width: 4,
                                            )
                                          : SizedBox(),
                                      int.parse(countData3
                                                  .child(smReplies
                                                      .docs[subcommarray[
                                                          commentIndex][i]]
                                                      .id)
                                                  .child("commentcount")
                                                  .value
                                                  .toString()) >
                                              0
                                          ? Text(
                                              " " +
                                                  countData3
                                                      .child(smReplies
                                                          .docs[subcommarray[
                                                              commentIndex][i]]
                                                          .id)
                                                      .child("commentcount")
                                                      .value
                                                      .toString() +
                                                  " replies",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
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
                      i == subcommarray[commentIndex].length - 1
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  subcommarrayshow[commentIndex] =
                                      !subcommarrayshow[commentIndex];
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.45,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Show less",
                                      style: TextStyle(
                                          color: Color.fromRGBO(0, 17, 255, 1),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                );
              },
            ),
          );
        }
      }
    } else
      return SizedBox();
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

  Widget showSelectedVideos(int i) {
    // _onControllerChange(socialfeed.docs[i].get("videolist"), i);
    return Container(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              socialfeed.docs[i].get("videothumbnail"),
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Image.asset(
                  "assets/loadingimg.gif",
                );
              },
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
                            'Save post',
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
                            'Add this to your saved items.',
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
}

class PositionSeekWidget extends StatefulWidget {
  int id;
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  PositionSeekWidget({
    this.id,
    this.currentPosition,
    this.duration,
    this.seekTo,
  });

  @override
  _PositionSeekWidgetState createState() => _PositionSeekWidgetState(this.id);
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  Duration _visibleValue;
  bool listenOnlyUserInterraction = false;
  int id;

  _PositionSeekWidgetState(this.id);

  double get percent => widget.duration.inMilliseconds == 0
      ? 0
      : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(durationToString(widget.currentPosition)),
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: percent * widget.duration.inMilliseconds.toDouble(),
              onChangeEnd: (newValue) {
                setState(() {
                  listenOnlyUserInterraction = false;

                  widget.seekTo(_visibleValue);
                });
              },
              onChangeStart: (_) {
                setState(() {
                  listenOnlyUserInterraction = true;
                });
              },
              onChanged: (newValue) {
                setState(() {
                  final to = Duration(milliseconds: newValue.floor());
                  _visibleValue = to;
                });
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(durationToString(widget.duration)),
          ),
        ],
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds =
      twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
