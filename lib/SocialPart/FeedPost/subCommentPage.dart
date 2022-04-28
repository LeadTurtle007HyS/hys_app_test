import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hys/SocialPart/network_crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:readmore/readmore.dart';
import 'package:story_designer/story_designer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;

import '../../notification_pages/notificationDB.dart';
import '../Cause/new_CreateCause.dart';

class SocialFeedSubComments extends StatefulWidget {
  List subCommentList;
  SocialFeedSubComments(this.subCommentList);
  @override
  _SocialFeedSubCommentsState createState() =>
      _SocialFeedSubCommentsState(this.subCommentList);
}

class _SocialFeedSubCommentsState extends State<SocialFeedSubComments> {
  List subCommentList;
  _SocialFeedSubCommentsState(this.subCommentList);
  String current_date = DateTime.now().toString();
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  VideoPlayerController _controller;
  List<bool> _videControllerStatus = [];
  ScrollController _scrollController;
  final databaseReference = FirebaseDatabase.instance.reference();
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
  NetworkCRUD networkCRUD = NetworkCRUD();
  NotificationDB notificationDB = NotificationDB();
  DataSnapshot tokenData;

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
  List reply_list = [];
  Box<dynamic> userDataDB;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

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
      maxHeight: 200,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 30,
    );
    print(fileName);
    // socialFeed.uploadSocialMediaFeedImages(File(fileName)).then((value) {
    //   setState(() {
    //     print(value);
    //     if (value[0] == true) {
    //       thumbURL = value[1];
    //       videoUploaded = false;
    //       print(thumbURL);
    //       Fluttertoast.showToast(
    //           msg: "Video thumbnail created successfully",
    //           toastLength: Toast.LENGTH_SHORT,
    //           gravity: ToastGravity.BOTTOM,
    //           timeInSecForIosWeb: 10,
    //           backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
    //           textColor: Colors.white,
    //           fontSize: 12.0);
    //     } else
    //       _showAlertDialog(value[1]);
    //   });
    // });
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
    print(subCommentList);
    reply_list = subCommentList[0]['reply_list'];

    userDataDB = Hive.box<dynamic>('userdata');
    _fetchData();
    focusNode = FocusNode();
    key.currentState?.controller?.addListener(() {
      print(key.currentState?.controller?.text);
    });
    super.initState();
  }

  _fetchData() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/get_comment_details/${subCommentList[0]['comment_id']}/$_currentUserId'),
    );

    print("get_comment_details: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        subCommentList = json.decode(response.body);
        reply_list = subCommentList[0]['reply_list'];
      });
    }
  }

  Future<void> showKeyboard() async {
    FocusScope.of(context).requestFocus();
  }

  Future<void> dismissKeyboard() async {
    FocusScope.of(context).unfocus();
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
      body: _body(),
    );
  }

  _body() {
    return Column(
      children: [
        Expanded(
          child: Material(
            child: reply_list.length == 0
                ? when_no_reply()
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: reply_list.length,
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
                          userDataDB.get("profilepic"),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Image.asset(
                              userDataDB.get("gender") == "Male"
                                  ? "assets/maleicon.jpg"
                                  : "assets/femaleicon.png",
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                hintText: "Leave your reply here",
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
                          showvdocontainer = false;
                          commentImg = false;
                          showimgcontainer = !showimgcontainer;
                          print(showimgcontainer);
                          dismissKeyboard();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
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
                onTap: () async {
                  if ((comment != "")) {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    comparedate =
                        DateFormat('yyyyMMddkkmm').format(DateTime.now());
                    String cmntID = "rply${_currentUserId}${comparedate}";
                    String imgID = "imgrplysm${_currentUserId}${comparedate}";
                    String videoID = "vdorplysm${_currentUserId}${comparedate}";
                    String userTagID =
                        "usrtgrplysm${_currentUserId}${comparedate}";
                    bool isImagesPosted = false;
                    bool isVideosPosted = false;
                    bool isUserTaggedPosted = false;
                    bool isFinalPostDone = false;

                    if (commentImageURL != "") {
                      isImagesPosted = await networkCRUD
                          .addsmPostImageDetails([imgID, commentImageURL]);
                    }
                    if (commentVideoURL != "") {
                      isVideosPosted = await networkCRUD.addsmPostVideoDetails(
                          [videoID, commentVideoURL, ""]);
                    }

                    isFinalPostDone = await networkCRUD.addsmReplyPostDetails([
                      cmntID,
                      subCommentList[0]["comment_id"],
                      subCommentList[0]["post_id"],
                      _currentUserId,
                      comment,
                      commentImageURL != "" ? imgID : "",
                      commentVideoURL != "" ? videoID : "",
                      "",
                      0,
                      comparedate
                    ]);
                    setState(() {
                      subCommentList[0]["reply_count"]++;
                    });

                    if (isFinalPostDone == true) {
                      _fetchData();
                      //////////////////////////////notification//////////////////////////////////////
                      notificationDB.createNotification(
                          subCommentList[0]["comment_id"],
                          subCommentList[0]["user_id"],
                          tokenData
                              .child(
                                  "usertoken/${subCommentList[0]["user_id"]}/tokenid")
                              .value,
                          "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} replied on your comment.",
                          "You got a reaction",
                          "socialcomment",
                          "reply",
                          "+");
                      /////////////////////////////////////////////////////////////////////////////
                      ElegantNotification.success(
                        title: Text("Congrats,"),
                        description: Text("Your comment posted successfully."),
                      ).show(context);
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                    } else {
                      ElegantNotification.error(
                        title: Text("Error..."),
                        description: Text("Sometning wrong."),
                      ).show(context);
                    }
                    setState(() {
                      commentImageURL = "";
                      commentVideoURL = "";
                      comment = "";
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Center(
                    child: Text(
                      ((commentImageURL != "") ||
                              (commentVideoURL != "") ||
                              (comment != ""))
                          ? "POST"
                          : "WAIT",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ((commentImageURL != "") ||
                                  (commentVideoURL != "") ||
                                  (comment != ""))
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
          _comment(),
          _subComment(0)
        ],
      ),
    );
  }

  when_no_reply() {
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
        _comment()
      ],
    );
  }

  double progress = 0.0;
  String commentImageURL = "";
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
      });
    }
    Uint8List file = _image.readAsBytesSync();
    String fileName = _image.path.split('/').last;
    Dialogs.showLoadingDialog(context, _keyLoader);
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child("socialcommentPost/$_currentUserId/$fileName")
        .putData(file);

    task.snapshotEvents.listen((event) async {
      setState(() {
        progress =
            ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                    100)
                .roundToDouble();
      });
      if (progress == 100) {
        print(progress);
        String downloadURL = await FirebaseStorage.instance
            .ref("socialcommentPost/$_currentUserId/$fileName")
            .getDownloadURL();
        if (downloadURL != null) {
          setState(() {
            commentImageURL = downloadURL;
            print(downloadURL);
            showimgcontainer = false;
            showvdocontainer = false;
            Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                .pop(); //close the dialoge
          });
        }
      }
    });
  }

  String commentVideoURL = "";
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

    if (path != "") {
      Uint8List file = info.file.readAsBytesSync();
      String fileName = path.split('/').last;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("socialcommentPost/$_currentUserId/$fileName")
          .putData(file);

      task.snapshotEvents.listen((event) async {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
                      event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
        });
        if (progress == 100) {
          print(progress);
          String downloadURL = await FirebaseStorage.instance
              .ref("socialcommentPost/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            setState(() {
              commentVideoURL = downloadURL;
              print(downloadURL);
              showimgcontainer = false;
              showvdocontainer = false;
              Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                  .pop(); //close the dialoge
            });
          }
        }
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

  _comment() {
    DateTime tempDate = DateTime.parse(
        subCommentList[0]["compare_date"].toString().substring(0, 8));
    String date = DateFormat.yMMMMd('en_US').format(tempDate);
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
                        subCommentList[0]["profilepic"],
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            subCommentList[0]["gender"] == "Male"
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
                                "${subCommentList[0]["first_name"]} ${subCommentList[0]["last_name"]}",
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
                                subCommentList[0]["school_name"]
                                            .toString()
                                            .length >
                                        25
                                    ? subCommentList[0]["school_name"]
                                            .toString()
                                            .substring(0, 25) +
                                        "..., " +
                                        "Grade " +
                                        subCommentList[0]["grade"].toString()
                                    : subCommentList[0]["school_name"]
                                            .toString() +
                                        "..., " +
                                        "Grade " +
                                        subCommentList[0]["grade"].toString(),
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "commented on $date",
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  fontWeight: FontWeight.normal,
                                ),
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
                                subCommentList[0]["comment"],
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
                          subCommentList[0]["image_list"].length > 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // setState(() {
                                        //   if (smComments.docs[i]
                                        //           .get("imagelist") !=
                                        //       "") {
                                        //     Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //             builder: (context) =>
                                        //                 SingleImageView(
                                        //                     smComments.docs[i]
                                        //                         .get(
                                        //                             "imagelist"),
                                        //                     "NetworkImage")));
                                        //   }
                                        // });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        height: 100,
                                        child: Image.network(
                                          subCommentList[0]["image_list"][0]
                                              ["image"],
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
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () {
                            if (subCommentList[0]["like_type"] == "") {
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "TRUE",
                                subCommentList[0]["comment_id"],
                                _currentUserId,
                                "comment",
                                "like",
                                subCommentList[0]["like_count"] + 1,
                                0,
                                0,
                                0,
                                subCommentList[0]["reply_count"]
                              ]);
                              setState(() {
                                subCommentList[0]["like_type"] = "like";
                                subCommentList[0]["like_count"]++;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  subCommentList[0]["comment_id"],
                                  subCommentList[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${subCommentList[0]["user_id"]}/tokenid")
                                      .value,
                                  "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your comment.",
                                  "You got a like",
                                  "socialcomment",
                                  "reaction",
                                  "+");
                              /////////////////////////////////////////////////////////////////////////////
                            } else {
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "FALSE",
                                subCommentList[0]["comment_id"],
                                _currentUserId,
                                "comment",
                                "like",
                                subCommentList[0]["like_count"] - 1,
                                0,
                                0,
                                0,
                                subCommentList[0]["reply_count"]
                              ]);
                              setState(() {
                                subCommentList[0]["like_type"] = "";
                                subCommentList[0]["like_count"]--;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  subCommentList[0]["comment_id"],
                                  subCommentList[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${subCommentList[0]["user_id"]}/tokenid")
                                      .value,
                                  "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your comment.",
                                  "You got a like",
                                  "socialcomment",
                                  "reaction",
                                  "-");
                              ////////////////////////////////////////////////////////////////////////////
                            }
                          },
                          child: Text(
                            "Like",
                            style: TextStyle(
                                color: subCommentList[0]["like_type"] == "like"
                                    ? Color(0xff0962ff)
                                    : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        subCommentList[0]["like_count"] > 0
                            ? SizedBox(width: 4)
                            : SizedBox(),
                        subCommentList[0]["like_count"] > 0
                            ? Text(
                                " " +
                                    subCommentList[0]["like_count"].toString() +
                                    " ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        subCommentList[0]["like_count"] > 0
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
                          onTap: () {},
                          child: Text(
                            "Reply",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        subCommentList[0]["reply_count"] > 0
                            ? SizedBox(
                                width: 4,
                              )
                            : SizedBox(),
                        subCommentList[0]["reply_count"] > 0
                            ? Text(
                                " " +
                                    subCommentList[0]["reply_count"]
                                        .toString() +
                                    " ",
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        subCommentList[0]["reply_count"] > 0
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

  _subComment(i) {
    DateTime tempDate = DateTime.parse(
        reply_list[i]["compare_date"].toString().substring(0, 8));
    String date = DateFormat.yMMMMd('en_US').format(tempDate);
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
                    reply_list[i]["profilepic"],
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Image.asset(
                        reply_list[i]["gender"] == "MALE"
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
                              "${reply_list[i]["first_name"]} ${reply_list[i]["last_name"]}",
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
                              reply_list[i]["school_name"].toString().length >
                                      25
                                  ? reply_list[i]["school_name"]
                                          .toString()
                                          .substring(0, 25) +
                                      "..., " +
                                      "Grade " +
                                      reply_list[i]["grade"].toString()
                                  : reply_list[i]["school_name"].toString() +
                                      "..., " +
                                      "Grade " +
                                      reply_list[i]["grade"].toString(),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 11,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "commented on $date",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 11,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                fontWeight: FontWeight.normal,
                              ),
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
                              reply_list[i]["reply"].toString(),
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
                        reply_list[i]["imagelist_id"].toString() == "zxc"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        // if (smReplies.docs[subcommentIndex]
                                        //         .get("imagelist") !=
                                        //     "") {
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               SingleImageView(
                                        //                   smReplies.docs[
                                        //                           subcommentIndex]
                                        //                       .get(
                                        //                           "imagelist"),
                                        //                   "NetworkImage")));
                                        // }
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      height: 300,
                                      child: Image.network(
                                        "",
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
                      InkWell(
                        onTap: () {
                          if (reply_list[i]["like_type"] == "") {
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              reply_list[i]["reply_id"],
                              _currentUserId,
                              "reply",
                              "like",
                              reply_list[i]["like_count"] + 1,
                              0,
                              0,
                              0,
                              0
                            ]);
                            setState(() {
                              reply_list[i]["like_type"] = "like";
                              reply_list[i]["like_count"]++;
                            });
                            ////////////////////////////notification//////////////////////////////////////
                            notificationDB.createNotification(
                                reply_list[i]["reply_id"],
                                reply_list[i]["user_id"],
                                tokenData
                                    .child(
                                        "usertoken/${reply_list[i]["user_id"]}/tokenid")
                                    .value,
                                "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your reply.",
                                "You got a like",
                                "socialreply",
                                "reaction",
                                "+");
                            /////////////////////////////////////////////////////////////////////////////
                          } else {
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "FALSE",
                              reply_list[i]["reply_id"],
                              _currentUserId,
                              "reply",
                              "like",
                              reply_list[i]["like_count"] - 1,
                              0,
                              0,
                              0,
                              0
                            ]);
                            setState(() {
                              reply_list[i]["like_type"] = "";
                              reply_list[i]["like_count"]--;
                            });
                            ////////////////////////////notification//////////////////////////////////////
                            notificationDB.createNotification(
                                reply_list[i]["reply_id"],
                                reply_list[i]["user_id"],
                                tokenData
                                    .child(
                                        "usertoken/${reply_list[i]["user_id"]}/tokenid")
                                    .value,
                                "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your reply.",
                                "You got a like",
                                "socialreply",
                                "reaction",
                                "-");
                            /////////////////////////////////////////////////////////////////////////////
                          }
                        },
                        child: Text(
                          "Like",
                          style: TextStyle(
                              color: reply_list[i]["like_type"] == "like"
                                  ? Color(0xff0962ff)
                                  : Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      reply_list[i]["like_count"] > 0
                          ? SizedBox(
                              width: 4,
                            )
                          : SizedBox(),
                      reply_list[i]["like_count"] > 0
                          ? Text(
                              " ${reply_list[i]["like_count"].toString()} ",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            )
                          : SizedBox(),
                      reply_list[i]["like_count"] > 0
                          ? Image.asset("assets/reactions/like.gif",
                              height: 25, width: 25)
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
