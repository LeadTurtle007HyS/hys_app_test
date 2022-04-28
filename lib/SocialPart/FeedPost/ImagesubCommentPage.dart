import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
import 'package:hys/SocialPart/database/SocialMSubCommentsDB.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:readmore/readmore.dart';
import 'package:hys/SocialPart/ImageView/SingleImageView.dart';
import 'package:story_designer/story_designer.dart';
import 'package:video_compress/video_compress.dart';

class SocialFeedImageSubComment extends StatefulWidget {
  String feedid;
  int feedIndex;
  int imgIndex;
  String commId;
  int commIndex;
  SocialFeedImageSubComment(
      this.feedid, this.feedIndex, this.imgIndex, this.commId, this.commIndex);
  @override
  _SocialFeedImageSubCommentState createState() =>
      _SocialFeedImageSubCommentState(this.feedid, this.feedIndex,
          this.imgIndex, this.commId, this.commIndex);
}

class _SocialFeedImageSubCommentState extends State<SocialFeedImageSubComment> {
  String feedid;
  int feedIndex;
  int imgIndex;
  String commId;
  int commIndex;
  _SocialFeedImageSubCommentState(
      this.feedid, this.feedIndex, this.imgIndex, this.commId, this.commIndex);
  String current_date = DateTime.now().toString();
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  CrudMethods crudobj = CrudMethods();
  SocialFeedPost socialFeed = SocialFeedPost();
  QuerySnapshot socialfeed;
  SocialMCommentsDB socialFeedComment = SocialMCommentsDB();

  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  SocialMSubCommentsDB socialFeedSubComment = SocialMSubCommentsDB();
  QuerySnapshot smReplies;
  VideoPlayerController _controller;
  List<bool> _videControllerStatus = [];
  ScrollController _scrollController;
  DataSnapshot countData;
  DataSnapshot countData2;
  DataSnapshot feedCountData;
  final databaseReference = FirebaseDatabase.instance.reference();
  Box<dynamic> socialFeedPostReactionsDB;
  Box<dynamic> socialFeedCommentsReactionsDB;
  Box<dynamic> socialFeedSubCommentsReactionsDB;
  Box<dynamic> usertokendataLocalDB;
  List<int> _reactionIndex = [];
  SocialFeedNotification _notificationdb = SocialFeedNotification();
  QuerySnapshot notificationToken;
  QuerySnapshot smComments;
  //QuerySnapshot commentsData;
  QuerySnapshot allUserschooldata;
  QuerySnapshot allUserpersonaldata;
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

  getThumbnail(String videURL) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videURL,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
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
    print(key.currentState?.controller?.markupText);
    key.currentState?.controller?.addListener(() {
      print(key.currentState?.controller?.text);
    });
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
      });
    });

    crudobj.getAllUserSchoolData().then((value) {
      setState(() {
        allUserschooldata = value;
        crudobj.getAllUserData().then((value) {
          setState(() {
            allUserpersonaldata = value;
            if ((allUserpersonaldata != null) && (allUserschooldata != null)) {
              print("case2");
              for (int i = 0; i < allUserpersonaldata.docs.length; i++) {
                for (int j = 0; j < allUserschooldata.docs.length; j++) {
                  if (allUserpersonaldata.docs[i].get("userid") ==
                      allUserschooldata.docs[j].get("userid")) {
                    print(i);
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
    socialFeedComment
        .getSocialFeedImagesComments(this.feedid, this.imgIndex.toString())
        .then((value) {
      setState(() {
        smComments = value;
      });
    });
    socialFeedSubComment
        .getSocialFeedImageSubComments(
            this.feedid, this.imgIndex.toString(), this.commId)
        .then((value) {
      setState(() {
        smReplies = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    databaseReference.child("sm_feeds").child("images").once().then((value) {
      setState(() {
        if (mounted) {
          setState(() {
            feedCountData = value.snapshot;
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
            countData = value.snapshot;
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
            countData2 = value.snapshot;
          });
        }
      });
    });
    if ((smReplies != null) &&
        (socialfeed != null) &&
        (feedCountData != null) &&
        (personaldata != null) &&
        (countData != null) &&
        (countData2 != null) &&
        (allUserpersonaldata != null) &&
        (schooldata != null) &&
        (allUserschooldata != null) &&
        (smComments != null)) {
      return Column(
        children: [
          Expanded(
            child: Material(
              child: smReplies.docs.length == 0
                  ? when_no_comment()
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: smReplies.docs.length,
                      itemBuilder: (BuildContext context, int i) {
                        return i == 0 ? when_I_is_Zero() : _subComment(i);
                      },
                    ),
            ),
          ),
          commentImg == true
              ? Container(
                  color: Colors.black12,
                  padding: EdgeInsets.all(10),
                  height: 300,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  commentImg = false;
                                  commentImageFile.delete();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      Image.file(
                        commentImageFile,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          Container(
            padding: EdgeInsets.only(bottom: 10.0),
            width: MediaQuery.of(context).size.width,
            child: FlutterMentions(
              key: key,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xff0962ff),
              decoration: new InputDecoration(
                  prefixIcon: Container(
                    height: 35,
                    width: 35,
                    margin: EdgeInsets.all(6),
                    child: CircleAvatar(
                      child: ClipOval(
                        child: Container(
                          child: Image.network(
                            personaldata.docs[0].get("profilepic"),
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
                  hintText: "Leave your comment here",
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 12)),
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff0962ff),
                  fontWeight: FontWeight.w500),
              suggestionPosition: SuggestionPosition.Top,
              defaultText: comment,
              onMarkupChanged: (val) {
                setState(() {
                  markupptext = val;
                });
              },
              onEditingComplete: () {
                setState(() {
                  tagids.clear();
                  for (int l = 0; l < markupptext.length; l++) {
                    int k = l;
                    if (markupptext.substring(k, k + 1) == "@") {
                      String test1 = markupptext.substring(k);
                      tagids.add(test1.substring(4, test1.indexOf("__]")));
                    }
                  }
                  print(tagids);
                });
              },
              onSuggestionVisibleChanged: (val) {
                setState(() {
                  _showList = val;
                });
              },
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  comment = val;
                });
              },
              onTap: () {
                setState(() {
                  // ocrbutton = false;
                });
              },
              onSearchChanged: (
                trigger,
                value,
              ) {
                print('again | $trigger | $value ');
              },
              hideSuggestionList: false,
              minLines: 1,
              maxLines: 5,
              mentions: [
                Mention(
                    trigger: r'@',
                    style: TextStyle(
                      color: Color(0xff0C2551),
                    ),
                    matchAll: false,
                    data: _users,
                    suggestionBuilder: (data) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(color: Color(0xFFE0E1E4)))),
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                data['photo'],
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(data['display']),
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data['full_name']}',
                                      style: TextStyle(
                                        color: Color(0xFFAAABAD),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
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
                        onTap: () {
                          showKeyboard();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 10, left: 15),
                          child: Center(
                            child: Image.asset("assets/keyboard.png",
                                height: 25, width: 25),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            showimgcontainer = false;
                            showvdocontainer = !showvdocontainer;
                            print(showvdocontainer);
                            dismissKeyboard();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 10, left: 20),
                          child: Center(
                            child: Image.asset("assets/videorecord.jpg",
                                height: 25, width: 25),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            showvdocontainer = false;
                            showimgcontainer = !showimgcontainer;
                            print(showimgcontainer);
                            dismissKeyboard();
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 10, left: 15, right: 15),
                          child: Center(
                            child: Image.asset("assets/gallery.png",
                                height: 22, width: 21),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            key.currentState.controller.text =
                                key.currentState.controller.text + "@";
                            showKeyboard();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 10, right: 15),
                          child: Center(
                            child: Icon(FontAwesome5.user_tag,
                                size: 18, color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (imageupload == false && videoUploaded == false) {
                        tagids.clear();
                        for (int l = 0; l < markupptext.length; l++) {
                          int k = l;
                          if (markupptext.substring(k, k + 1) == "@") {
                            String test1 = markupptext.substring(k);
                            tagids
                                .add(test1.substring(4, test1.indexOf("__]")));
                          }
                        }
                        print(tagids);
                        socialFeedSubComment.addImageFeedSubComment(
                            this.feedid,
                            this.imgIndex.toString(),
                            this.commId,
                            personaldata.docs[0].get("firstname") +
                                personaldata.docs[0].get("lastname"),
                            personaldata.docs[0].get("profilepic"),
                            personaldata.docs[0].get("gender"),
                            "Delhi",
                            schooldata.docs[0].get("schoolname"),
                            schooldata.docs[0].get("grade"),
                            comment,
                            tagedUsersName,
                            tagids,
                            finalVideosUrl,
                            thumbURL,
                            imgUrl,
                            current_date,
                            comparedate,
                            "");
                        print("s1");
                        dismissKeyboard();
                        databaseReference
                            .child("sm_feeds")
                            .child("images")
                            .child(this.feedid + this.imgIndex.toString())
                            .update({
                          'commentcount': int.parse(feedCountData
                                  .child(this.feedid + this.imgIndex.toString())
                                  .child("commentcount")
                                  .value
                                  .toString()) +
                              1
                        });
                        print("s2");
                        databaseReference
                            .child("sm_feeds_comments")
                            .child("reactions")
                            .child(this.commId)
                            .update({
                          'commentcount': int.parse(countData
                                  .child(this.commId)
                                  .child("commentcount")
                                  .value
                                  .toString()) +
                              1
                        });
                        print("s3");
                        _notificationdb.socialFeedReplyNotificationsImages(
                            personaldata.docs[0].get("firstname") +
                                personaldata.docs[0].get("lastname"),
                            personaldata.docs[0].get("profilepic"),
                            socialfeed.docs[this.feedIndex].get("username"),
                            socialfeed.docs[this.feedIndex].get("userid"),
                            personaldata.docs[0].get("firstname") +
                                " " +
                                personaldata.docs[0].get("lastname") +
                                " replied on your comment.",
                            "You got a Reply!",
                            current_date,
                            usertokendataLocalDB.get(
                                socialfeed.docs[this.feedIndex].get("userid")),
                            socialfeed.docs[this.feedIndex].id,
                            this.imgIndex,
                            this.feedIndex,
                            this.commId,
                            this.commIndex,
                            "SMReply",
                            comparedate);
                        print("s4");
                        smReplies = null;
                        smComments = null;

                        socialFeedSubComment
                            .getSocialFeedImageSubComments(this.feedid,
                                this.imgIndex.toString(), this.commId)
                            .then((value) {
                          setState(() {
                            smReplies = value;
                          });
                        });
                        print("s5");
                        socialFeedComment
                            .getSocialFeedImagesComments(
                                this.feedid, this.imgIndex.toString())
                            .then((value) {
                          setState(() {
                            smComments = value;
                          });
                        });
                        print("s6");
                        countData2 = null;
                        databaseReference
                            .child("sm_feeds_reply")
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
                        print("s7");
                        key.currentState.controller.clear();
                        FocusScope.of(context).requestFocus(new FocusNode());
                        commentImg = false;
                        commentImageFile = null;
                        dismissKeyboard();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Center(
                      child: Text(
                        ((imageupload == false) && (videoUploaded == false))
                            ? "POST"
                            : "WAIT",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ((comment != "") &&
                                    (imageupload == false) &&
                                    (videoUploaded == false))
                                ? Color(0xff0962ff)
                                : Colors.black54),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          showimgcontainer == true
              ? _imgContainer()
              : showvdocontainer == true
                  ? _vdoContainer()
                  : SizedBox()
        ],
      );
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
          _comment(this.commIndex),
          _subComment(0)
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
        _comment(this.commIndex)
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

  _comment(int i) {
    String date =
        getTimeDifferenceFromNow(smComments.docs[i].get("createdate"));
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
                              fontWeight: FontWeight.w400),
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
                              databaseReference
                                  .child("sm_feeds_comments")
                                  .child("reactions")
                                  .child(smComments.docs[i].id)
                                  .update({
                                'likecount': int.parse(countData
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
                                          this.imgIndex.toString() +
                                          "Like");
                            } else {
                              socialFeedCommentsReactionsDB.put(
                                  smComments.docs[i].id, "Like");

                              databaseReference
                                  .child("sm_feeds_comments")
                                  .child("reactions")
                                  .child(smComments.docs[i].id)
                                  .update({
                                'likecount': int.parse(countData
                                        .child(smComments.docs[i].id)
                                        .child("likecount")
                                        .value
                                        .toString()) +
                                    1
                              });
                              _notificationdb
                                  .socialFeedCommentReactionsNotificationsImages(
                                      personaldata.docs[0].get("firstname") +
                                          personaldata.docs[0].get("lastname"),
                                      personaldata.docs[0].get("profilepic"),
                                      smComments.docs[i].get("username"),
                                      smComments.docs[i].get("userid"),
                                      personaldata.docs[0].get("firstname") +
                                          " " +
                                          personaldata.docs[0].get("lastname") +
                                          " liked your post.",
                                      "You got a like!",
                                      current_date,
                                      usertokendataLocalDB.get(
                                          smComments.docs[i].get("userid")),
                                      this.feedid,
                                      this.imgIndex,
                                      this.feedIndex,
                                      this.commId,
                                      this.commIndex,
                                      "Like",
                                      comparedate);
                              socialFeedComment.addFeedCommentLikesDetails(
                                  this.feedid,
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
                        int.parse(countData
                                    .child(smComments.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString()) >
                                0
                            ? SizedBox(
                                width: 4,
                              )
                            : SizedBox(),
                        int.parse(countData
                                    .child(smComments.docs[i].id)
                                    .child("likecount")
                                    .value
                                    .toString()) >
                                0
                            ? Text(
                                " " +
                                    (countData
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
                        int.parse(countData
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
                            showKeyboard();
                          },
                          child: Text(
                            "Reply",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        int.parse(countData
                                    .child(smComments.docs[i].id)
                                    .child("commentcount")
                                    .value
                                    .toString()) >
                                0
                            ? SizedBox(
                                width: 8,
                              )
                            : SizedBox(),
                        int.parse(countData
                                    .child(smComments.docs[i].id)
                                    .child("commentcount")
                                    .value
                                    .toString()) >
                                0
                            ? Text(
                                " " +
                                    (countData
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
                        int.parse(countData
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
      ],
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

  _subComment(i) {
    String date = getTimeDifferenceFromNow(smReplies.docs[i].get("createdate"));
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 10),
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
                    smReplies.docs[i].get("userprofilepic"),
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
                              smReplies.docs[i].get("username"),
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
                              "${smReplies.docs[i].get("userschoolname")} | Grade ${smReplies.docs[i].get("usergrade")}",
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
                              smReplies.docs[i].get("comment"),
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
                        smReplies.docs[i].get("imagelist") != ""
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (smReplies.docs[i]
                                                .get("imagelist") !=
                                            "") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SingleImageView(
                                                          smReplies.docs[i]
                                                              .get("imagelist"),
                                                          "NetworkImage")));
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      height: 300,
                                      child: Image.network(
                                        smReplies.docs[i].get("imagelist"),
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
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          if (socialFeedSubCommentsReactionsDB
                                  .get(smReplies.docs[i].id) !=
                              null) {
                            socialFeedSubCommentsReactionsDB
                                .delete(smReplies.docs[i].id);
                            socialFeedSubComment.deleteSubCommentLikeDetails(
                                _currentUserId + smReplies.docs[i].id);
                            databaseReference
                                .child("sm_feeds_reply")
                                .child("reactions")
                                .child(smReplies.docs[i].id)
                                .update({
                              'likecount': int.parse(countData2
                                      .child(smReplies.docs[i].id)
                                      .child("likecount")
                                      .value
                                      .toString()) -
                                  1
                            });
                            _notificationdb
                                .deleteSocialFeedReactionsNotification(
                                    _currentUserId +
                                        smReplies.docs[i].id +
                                        this.imgIndex.toString() +
                                        "Like");
                          } else {
                            socialFeedSubCommentsReactionsDB.put(
                                smReplies.docs[i].id, "Like");

                            databaseReference
                                .child("sm_feeds_reply")
                                .child("reactions")
                                .child(smReplies.docs[i].id)
                                .update({
                              'likecount': int.parse(countData2
                                      .child(smReplies.docs[i].id)
                                      .child("likecount")
                                      .value
                                      .toString()) +
                                  1
                            });
                            _notificationdb
                                .socialFeedReplyReactionsNotificationsImages(
                                    personaldata.docs[0].get("firstname") +
                                        personaldata.docs[0].get("lastname"),
                                    personaldata.docs[0].get("profilepic"),
                                    smReplies.docs[i].get("username"),
                                    smReplies.docs[i].get("userid"),
                                    personaldata.docs[0].get("firstname") +
                                        " " +
                                        personaldata.docs[0].get("lastname") +
                                        " liked your post.",
                                    "You got a like!",
                                    current_date,
                                    usertokendataLocalDB
                                        .get(smReplies.docs[i].get("userid")),
                                    this.feedid,
                                    this.imgIndex,
                                    this.feedIndex,
                                    this.commId,
                                    this.commIndex,
                                    smReplies.docs[i].id,
                                    i,
                                    "Like",
                                    comparedate);
                            socialFeedSubComment.addFeedSubCommentLikesDetails(
                                this.feedIndex,
                                this.commId,
                                smReplies.docs[i].id,
                                smReplies.docs[i].get("userid"),
                                smReplies.docs[i].get("username"),
                                smReplies.docs[i].get("userschoolname"),
                                smReplies.docs[i].get("userprofilepic"),
                                "Delhi",
                                smReplies.docs[i].get("usergrade"),
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
                              color: socialFeedSubCommentsReactionsDB
                                          .get(smReplies.docs[i].id) !=
                                      null
                                  ? Color(0xff0962ff)
                                  : Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      int.parse(countData2
                                  .child(smReplies.docs[i].id)
                                  .child("likecount")
                                  .value
                                  .toString()) >
                              0
                          ? SizedBox(
                              width: 4,
                            )
                          : SizedBox(),
                      int.parse(countData2
                                  .child(smReplies.docs[i].id)
                                  .child("likecount")
                                  .value
                                  .toString()) >
                              0
                          ? Text(
                              " " +
                                  (countData2
                                          .child(smReplies.docs[i].id)
                                          .child("likecount")
                                          .value)
                                      .toString() +
                                  " ",
                              style: TextStyle(
                                  color: socialFeedSubCommentsReactionsDB
                                              .get(smReplies.docs[i].id) !=
                                          null
                                      ? Color(0xff0962ff)
                                      : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            )
                          : SizedBox(),
                      int.parse(countData2
                                  .child(smReplies.docs[i].id)
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
                          await showKeyboard();
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
                                  .child(smReplies.docs[i].id)
                                  .child("commentcount")
                                  .value
                                  .toString()) >
                              0
                          ? SizedBox(
                              width: 4,
                            )
                          : SizedBox(),
                      int.parse(countData2
                                  .child(smReplies.docs[i].id)
                                  .child("commentcount")
                                  .value
                                  .toString()) >
                              0
                          ? Text(
                              " " +
                                  countData2
                                      .child(smReplies.docs[i].id)
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
  }
}
