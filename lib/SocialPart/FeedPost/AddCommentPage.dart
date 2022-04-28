import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hys/SocialPart/FeedPost/subCommentPage.dart';
import 'package:hys/notification/notificationDB.dart';
import 'package:hys/utils/permissions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:story_designer/story_designer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;

import '../network_crud.dart';

String post_type = "";

class SocialFeedAddComments extends StatefulWidget {
  List post_list;
  SocialFeedAddComments(this.post_list);

  @override
  _SocialFeedAddCommentsState createState() =>
      _SocialFeedAddCommentsState(this.post_list);
}

class _SocialFeedAddCommentsState extends State<SocialFeedAddComments> {
  List post_list;
  _SocialFeedAddCommentsState(this.post_list);
  static const MethodChannel _channel = MethodChannel('epub_viewer');

  String current_date = DateTime.now().toString();
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  SocialMCommentsDB socialFeedComment = SocialMCommentsDB();
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  Box<dynamic> userDataDB;
  VideoPlayerController _controller;
  List<bool> _videControllerStatus = [];
  ScrollController _scrollController;
  final databaseReference = FirebaseDatabase.instance.reference();
  String textshow = "";
  int tagcount = 0;
  int feedindex = -1;
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
  ItemScrollController _scrollVController = ItemScrollController();
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
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

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
    post_type = post_list[0]["post_type"];
    _fetchData();
    userDataDB = Hive.box<dynamic>('userdata');
    focusNode = FocusNode();

    super.initState();
  }

  Future _fetchData() async {
    String base_url = post_type == "Mood"
        ? 'get_sm_mood_posts'
        : post_type == "cause|teachunprevilagedKids"
            ? 'get_sm_cause_posts'
            : post_type == "businessideas"
                ? 'get_sm_bideas_posts'
                : post_type == "projectdiscuss"
                    ? 'get_sm_project_posts'
                    : post_type == "blog"
                        ? 'get_sm_blog_posts'
                        : "get_all_sm_mood_posts";
    final List<http.Response> response = await Future.wait([
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/$base_url/${post_list[0]["post_id"]}/${_currentUserId}'),
      )
    ]);
    setState(() {
      if ((response[0].statusCode == 200) || (response[0].statusCode == 201)) {
        post_list = json.decode(response[0].body);
        print(post_list);
      }
    });
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
    databaseReference.child("hysweb").once().then((snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            tokenData = snapshot.snapshot;
          });
        }
      });
    });
    return SafeArea(
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  _body() {
    if (post_list != null) {
      return Column(
        children: [
          Expanded(
            child: Material(
              child: post_list[0]["comment_list"].length > 0
                  ? ScrollablePositionedList.builder(
                      itemScrollController: _scrollVController,
                      itemCount: post_list[0]["comment_list"].length,
                      itemBuilder: (BuildContext context, int i) {
                        return i == 0 ? whenIisZero() : _comment(i);
                      },
                    )
                  : when_no_comment(),
            ),
          ),
          commentImg == true
              ? Container(
                  color: Colors.black12,
                  padding: EdgeInsets.all(10),
                  height: 200,
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
                          child: CachedNetworkImage(
                            imageUrl: post_list[0]["profilepic"],
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
                            commentVideoURL = "";
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
                            commentImg = false;
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
                  onTap: () async {
                    if ((comment != "")) {
                      setState(() {
                        Dialogs.showLoadingDialog(context, _keyLoader);
                      });
                      comparedate =
                          DateFormat('yyyyMMddkkmm').format(DateTime.now());
                      String cmntID = "cmnt${_currentUserId}${comparedate}";
                      String imgID = "imgcmntsm${_currentUserId}${comparedate}";
                      String videoID =
                          "vdocmntsm${_currentUserId}${comparedate}";
                      String userTagID =
                          "usrtgcmntsm${_currentUserId}${comparedate}";
                      bool isImagesPosted = false;
                      bool isVideosPosted = false;
                      bool isUserTaggedPosted = false;
                      bool isFinalPostDone = false;

                      if (commentImageURL != "") {
                        isImagesPosted = await networkCRUD
                            .addsmPostImageDetails([imgID, commentImageURL]);
                      }
                      if (commentVideoURL != "") {
                        isVideosPosted = await networkCRUD
                            .addsmPostVideoDetails(
                                [videoID, commentVideoURL, ""]);
                      }

                      isFinalPostDone =
                          await networkCRUD.addsmCommentPostDetails([
                        cmntID,
                        post_list[0]["post_id"],
                        _currentUserId,
                        comment,
                        commentImageURL != "" ? imgID : "",
                        commentVideoURL != "" ? videoID : "",
                        "",
                        0,
                        0,
                        comparedate
                      ]);
                      setState(() {
                        post_list[0]["comment_count"]++;
                      });

                      if (isFinalPostDone == true) {
                        ////////////////////////////notification//////////////////////////////////////
                        ElegantNotification.success(
                          title: Text("Congrats,"),
                          description:
                              Text("Your comment posted successfully."),
                        ).show(context);
                        await _fetchData();
                      } else {
                        ElegantNotification.error(
                          title: Text("Error..."),
                          description: Text("Sometning wrong."),
                        ).show(context);
                      }
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: false)
                          .pop();
                      setState(() {
                        commentImageURL = "";
                        commentVideoURL = "";
                        comment = "";
                        markupptext = "";
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
    } else {
      return _loading();
    }
  }

  whenIisZero() {
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
          post_type == "cause|teachunprevilagedKids"
              ? _smEventPost(0)
              : post_type == "Mood"
                  ? _smMoodPost(0)
                  : post_type == "projectdiscuss"
                      ? _projectDiscuss(0)
                      : post_type == "businessideas"
                          ? _businessIdeas(0)
                          : post_type == "blog"
                              ? _smBlogPost(0)
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
        post_type == "cause|teachunprevilagedKids"
            ? _smEventPost(0)
            : post_type == "Mood"
                ? _smMoodPost(0)
                : post_type == "projectdiscuss"
                    ? _projectDiscuss(0)
                    : post_type == "businessideas"
                        ? _businessIdeas(0)
                        : post_type == "blog"
                            ? _smBlogPost(0)
                            : SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset("assets/type_loading.gif", height: 20, width: 30),
          ],
        )
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
        _loading();
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

  _comment(int i) {
    DateTime tempDate = DateTime.parse(post_list[0]["comment_list"][i]
            ["compare_date"]
        .toString()
        .substring(0, 8));
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
                        post_list[0]["comment_list"][i]["profilepic"],
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            post_list[0]["comment_list"][i]["gender"] == "Male"
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
                                "${post_list[0]["comment_list"][i]["first_name"]} ${post_list[0]["comment_list"][i]["last_name"]}",
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
                                post_list[0]["comment_list"][i]["school_name"]
                                            .toString()
                                            .length >
                                        25
                                    ? post_list[0]["comment_list"][i]
                                                ["school_name"]
                                            .toString()
                                            .substring(0, 25) +
                                        "..., " +
                                        "Grade " +
                                        post_list[0]["comment_list"][i]["grade"]
                                            .toString()
                                    : post_list[0]["comment_list"][i]
                                                ["school_name"]
                                            .toString() +
                                        "..., " +
                                        "Grade " +
                                        post_list[0]["comment_list"][i]["grade"]
                                            .toString(),
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
                                post_list[0]["comment_list"][i]["comment"],
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
                          post_list[0]["comment_list"][i]["image_list"].length >
                                  0
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
                                          post_list[0]["comment_list"][i]
                                              ["image_list"][0]["image"],
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
                            if (post_list[0]["comment_list"][i]["like_type"] ==
                                "") {
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "TRUE",
                                post_list[0]["comment_list"][i]["comment_id"],
                                _currentUserId,
                                "comment",
                                "like",
                                post_list[0]["comment_list"][i]["like_count"] +
                                    1,
                                0,
                                0,
                                0,
                                post_list[0]["comment_list"][i]["reply_count"]
                              ]);
                              setState(() {
                                post_list[0]["comment_list"][i]["like_type"] =
                                    "like";
                                post_list[0]["comment_list"][i]["like_count"]++;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  post_list[0]["comment_id"],
                                  post_list[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${post_list[0]["user_id"]}/tokenid")
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
                                post_list[0]["comment_list"][i]["comment_id"],
                                _currentUserId,
                                "comment",
                                "like",
                                post_list[0]["comment_list"][i]["like_count"] -
                                    1,
                                0,
                                0,
                                0,
                                post_list[0]["comment_list"][i]["reply_count"]
                              ]);
                              setState(() {
                                post_list[0]["comment_list"][i]["like_type"] =
                                    "";
                                post_list[0]["comment_list"][i]["like_count"]--;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  post_list[0]["comment_id"],
                                  post_list[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${post_list[0]["user_id"]}/tokenid")
                                      .value,
                                  "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your comment.",
                                  "You got a like",
                                  "socialcomment",
                                  "reaction",
                                  "-");
                              /////////////////////////////////////////////////////////////////////////////
                            }
                          },
                          child: Text(
                            "Like",
                            style: TextStyle(
                                color: post_list[0]["comment_list"][i]
                                            ["like_type"] ==
                                        "like"
                                    ? Color(0xff0962ff)
                                    : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        post_list[0]["comment_list"][i]["like_count"] > 0
                            ? SizedBox(width: 4)
                            : SizedBox(),
                        post_list[0]["comment_list"][i]["like_count"] > 0
                            ? Text(
                                " " +
                                    post_list[0]["comment_list"][i]
                                            ["like_count"]
                                        .toString() +
                                    " ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        post_list[0]["comment_list"][i]["like_count"] > 0
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SocialFeedSubComments(
                                        [post_list[0]["comment_list"][i]])));
                          },
                          child: Text(
                            "Reply",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        post_list[0]["comment_list"][i]["reply_count"] > 0
                            ? SizedBox(
                                width: 4,
                              )
                            : SizedBox(),
                        post_list[0]["comment_list"][i]["reply_count"] > 0
                            ? Text(
                                " " +
                                    post_list[0]["comment_list"][i]
                                            ["reply_count"]
                                        .toString() +
                                    " ",
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        post_list[0]["comment_list"][i]["reply_count"] > 0
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
        _subComment(i),
      ],
    );
  }

  _subComment(commentIndex) {
    List reply = post_list[0]["comment_list"][commentIndex]["reply_list"];

    if (reply.length == 1) {
      DateTime tempDate =
          DateTime.parse(reply[0]["compare_date"].toString().substring(0, 8));
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
                      reply[0]["profilepic"],
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Image.asset(
                          reply[0]["gender"] == "MALE"
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
                                "${reply[0]["first_name"]} ${reply[0]["last_name"]}",
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
                                reply[0]["school_name"].toString().length > 25
                                    ? reply[0]["school_name"]
                                            .toString()
                                            .substring(0, 25) +
                                        "..., " +
                                        "Grade " +
                                        reply[0]["grade"].toString()
                                    : reply[0]["school_name"].toString() +
                                        "..., " +
                                        "Grade " +
                                        reply[0]["grade"].toString(),
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
                                reply[0]["reply"].toString(),
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
                          reply[0]["imagelist_id"].toString() == "zxc"
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
                            if (reply[0]["like_type"] == "") {
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "TRUE",
                                reply[0]["reply_id"],
                                _currentUserId,
                                "reply",
                                "like",
                                reply[0]["like_count"] + 1,
                                0,
                                0,
                                0,
                                0
                              ]);
                              setState(() {
                                reply[0]["like_type"] = "like";
                                reply[0]["like_count"]++;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  reply[0]["comment_id"],
                                  reply[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${post_list[0]["user_id"]}/tokenid")
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
                                reply[0]["reply_id"],
                                _currentUserId,
                                "reply",
                                "like",
                                reply[0]["like_count"] - 1,
                                0,
                                0,
                                0,
                                0
                              ]);
                              setState(() {
                                reply[0]["like_type"] = "";
                                reply[0]["like_count"]--;
                              });
                              ////////////////////////////notification//////////////////////////////////////
                              notificationDB.createNotification(
                                  reply[0]["comment_id"],
                                  reply[0]["user_id"],
                                  tokenData
                                      .child(
                                          "usertoken/${post_list[0]["user_id"]}/tokenid")
                                      .value,
                                  "${userDataDB.get('first_name')} ${userDataDB.get('last_name')} liked your reply.",
                                  "You got a like",
                                  "socialreply",
                                  "reaction",
                                  "+");
                              /////////////////////////////////////////////////////////////////////////////
                            }
                          },
                          child: Text(
                            "Like",
                            style: TextStyle(
                                color: reply[0]["like_type"] == "like"
                                    ? Color(0xff0962ff)
                                    : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        reply[0]["like_count"] > 0
                            ? SizedBox(
                                width: 4,
                              )
                            : SizedBox(),
                        reply[0]["like_count"] > 0
                            ? Text(
                                " ${reply[0]["like_count"].toString()} ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        reply[0]["like_count"] > 0
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
    } else if (reply.length > 1) {
      bool show_all_replies = false;
      return Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: show_all_replies ? reply.length : 1,
              itemBuilder: (context, i) {
                DateTime tempDate = DateTime.parse(
                    reply[i]["compare_date"].toString().substring(0, 8));

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
                                reply[i]["profilepic"],
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Image.asset(
                                    reply[i]["gender"] == "MALE"
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
                                          "${reply[i]["first_name"]} ${reply[i]["last_name"]}",
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
                                          reply[i]["school_name"]
                                                      .toString()
                                                      .length >
                                                  25
                                              ? reply[i]["school_name"]
                                                      .toString()
                                                      .substring(0, 25) +
                                                  "..., " +
                                                  "Grade " +
                                                  reply[i]["grade"].toString()
                                              : reply[i]["school_name"]
                                                      .toString() +
                                                  "..., " +
                                                  "Grade " +
                                                  reply[i]["grade"].toString(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                          reply[i]["reply"].toString(),
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
                                    reply[i]["imagelist_id"].toString() == "zxc"
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
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
                                      if (reply[i]["like_type"] == "") {
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          reply[i]["reply_id"],
                                          _currentUserId,
                                          "reply",
                                          "like",
                                          reply[i]["like_count"] + 1,
                                          0,
                                          0,
                                          0,
                                          0
                                        ]);
                                        setState(() {
                                          reply[i]["like_type"] = "like";
                                          reply[i]["like_count"]++;
                                        });
                                      } else {
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "FALSE",
                                          reply[i]["reply_id"],
                                          _currentUserId,
                                          "reply",
                                          "like",
                                          reply[i]["like_count"] - 1,
                                          0,
                                          0,
                                          0,
                                          0
                                        ]);
                                        setState(() {
                                          reply[i]["like_type"] = "";
                                          reply[i]["like_count"]--;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Like",
                                      style: TextStyle(
                                          color: reply[i]["like_type"] == "like"
                                              ? Color(0xff0962ff)
                                              : Colors.black54,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  reply[i]["like_count"] > 0
                                      ? SizedBox(
                                          width: 4,
                                        )
                                      : SizedBox(),
                                  reply[i]["like_count"] > 0
                                      ? Text(
                                          " ${reply[i]["like_count"].toString()} ",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        )
                                      : SizedBox(),
                                  reply[i]["like_count"] > 0
                                      ? Image.asset("assets/reactions/like.gif",
                                          height: 25, width: 25)
                                      : SizedBox(),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          InkWell(
              onTap: () {
                setState(() {
                  show_all_replies = !show_all_replies;
                });
              },
              child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(show_all_replies ? "show less" : "show more",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: show_all_replies
                              ? Colors.black54
                              : Color(0xff0962ff)))))
        ],
      ));
    } else
      return SizedBox();
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

  Future<bool> checkPermission() async {
    if (!await Permissions.cameraAndMicrophonePermissionsGranted()) {
      return false;
    }
    return true;
  }

  Widget buildGridView(List imagesFile, int i) {
    return imagesFile.length == 1
        ? InkWell(
            onTap: () {
              // if (socialfeed.docs[i].get("feedtype") == "shared") {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) =>
              //               SingleImageView(imagesFile[0], "NetworkImage")));
              // } else {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) =>
              //               SingleImageView(imagesFile[0], "NetworkImage")));
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

  Widget viewAllImages(List imagesFile) {
    return imagesFile.length == 1
        ? InkWell(
            child: Container(
                height: 200,
                width: 200,
                child: CachedNetworkImage(
                  imageUrl: imagesFile[0]["image"],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
          )
        : InkWell(
            onTap: () {},
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
                                imageUrl: imagesFile[index]["image"],
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
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
                          imageUrl: imagesFile[index]["image"],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        );
                }),
              ),
            ),
          );
  }

  _smMoodPost(int i) {
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
                                imageUrl: post_list[0]["profilepic"],
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
                      _chooseHeaderToViewSMPost(
                          post_list[0]["user_mood"], i, [], []),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(FontAwesome5.ellipsis_h,
                        color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                    onPressed: () {
                      //    moreOptionsSMPostViewer(context, i);
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
                post_list[0]["message"],
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
          post_list[0]["image_list"].length > 0
              ? viewAllImages(post_list[0]["image_list"])
              : SizedBox(),
          // video.length > 0 ? showSelectedVideos(i) : SizedBox(),
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
                                post_list[0]["like_count"].toString(),
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ShowSocialFeedComments(
                          //             socialfeed.docs[i].id)));
                        },
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                                text: post_list[0]["comment_count"].toString(),
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
                              post_list[0]["view_count"].toString(),
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
                post_list[0]["user_mood"] == "Need people around me"
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
                                      if (index == -1) {
                                        if (post_list[0]["like_type"] != "") {
                                          setState(() {
                                            post_list[0]["like_count"]--;
                                            post_list[0]["like_type"] = "";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "FALSE",
                                            post_list[0]["post_id"],
                                            _currentUserId,
                                            "Mood",
                                            "like",
                                            post_list[0]["like_count"] - 1,
                                            post_list[0]["comment_count"],
                                            post_list[0]["view_count"],
                                            post_list[0]["impression_count"],
                                            post_list[0]["reply_count"]
                                          ]);
                                        } else {
                                          setState(() {
                                            post_list[0]["like_count"]++;
                                            post_list[0]["like_type"] = "like";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            post_list[0]["post_id"],
                                            _currentUserId,
                                            "Mood",
                                            "like",
                                            post_list[0]["like_count"] + 1,
                                            post_list[0]["comment_count"],
                                            post_list[0]["view_count"],
                                            post_list[0]["impression_count"],
                                            post_list[0]["reply_count"]
                                          ]);
                                        }
                                      } else if (index == 0) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "like";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "like",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 1) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "love";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "love",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 2) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "haha";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "haha",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 3) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "yay";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "yay",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 4) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "wow";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "wow",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 5) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "angry";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "angry",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: post_list[0]
                                                ["like_type"] ==
                                            "like"
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
                                        : post_list[0]["like_type"] == ""
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
                                            : post_list[0]["like_type"] ==
                                                    "love"
                                                ? reactions[1]
                                                : post_list[0]["like_type"] ==
                                                        "haha"
                                                    ? reactions[2]
                                                    : post_list[0]
                                                                ["like_type"] ==
                                                            "yay"
                                                        ? reactions[3]
                                                        : post_list[i][
                                                                    "like_type"] ==
                                                                "wow"
                                                            ? reactions[4]
                                                            : reactions[5],
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
                              onTap: () async {
                                _showCallingDialog(i);
                              },
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
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             SocialFeedAddComments(
                                //                 socialfeed.docs[i].id)));
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
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             ShareFeedPost(
                                //                 socialfeed.docs[i].id)));
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
                                      if (index == -1) {
                                        if (post_list[0]["like_type"] != "") {
                                          setState(() {
                                            post_list[0]["like_count"]--;
                                            post_list[0]["like_type"] = "";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "FALSE",
                                            post_list[0]["post_id"],
                                            _currentUserId,
                                            "Mood",
                                            "like",
                                            post_list[0]["like_count"] - 1,
                                            post_list[0]["comment_count"],
                                            post_list[0]["view_count"],
                                            post_list[0]["impression_count"],
                                            post_list[0]["reply_count"]
                                          ]);
                                        } else {
                                          setState(() {
                                            post_list[0]["like_count"]++;
                                            post_list[0]["like_type"] = "like";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            post_list[0]["post_id"],
                                            _currentUserId,
                                            "Mood",
                                            "like",
                                            post_list[0]["like_count"] + 1,
                                            post_list[0]["comment_count"],
                                            post_list[0]["view_count"],
                                            post_list[0]["impression_count"],
                                            post_list[0]["reply_count"]
                                          ]);
                                        }
                                      } else if (index == 0) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "like";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "like",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 1) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "love";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "love",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 2) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "haha";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "haha",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 3) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "yay";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "yay",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 4) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "wow";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "wow",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      } else if (index == 5) {
                                        setState(() {
                                          post_list[0]["like_count"]++;
                                          post_list[0]["like_type"] = "angry";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          post_list[0]["post_id"],
                                          _currentUserId,
                                          "Mood",
                                          "angry",
                                          post_list[0]["like_count"] + 1,
                                          post_list[0]["comment_count"],
                                          post_list[0]["view_count"],
                                          post_list[0]["impression_count"],
                                          post_list[0]["reply_count"]
                                        ]);
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: post_list[0]
                                                ["like_type"] ==
                                            "like"
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
                                        : post_list[0]["like_type"] == ""
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
                                            : post_list[0]["like_type"] ==
                                                    "love"
                                                ? reactions[1]
                                                : post_list[0]["like_type"] ==
                                                        "haha"
                                                    ? reactions[2]
                                                    : post_list[0]
                                                                ["like_type"] ==
                                                            "yay"
                                                        ? reactions[3]
                                                        : post_list[i][
                                                                    "like_type"] ==
                                                                "wow"
                                                            ? reactions[4]
                                                            : reactions[5],
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
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             SocialFeedAddComments(
                                //                 socialfeed.docs[i].id)));
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
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             ShareFeedPost(
                                //                 socialfeed.docs[i].id)));
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

  bool isBlogPostExpanded = true;
  _smBlogPost(int i) {
    String time = DateFormat.yMMMMd('en_US').format(DateTime.parse(
        post_list[0]["compare_date"].toString().substring(0, 8)));
    return InkWell(
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
                                        post_list[0]["profilepic"].toString(),
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.white,
                                        child: Image.network(
                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                        )),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _chooseHeaderToViewSMPost("blog", i, [], []),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: Icon(FontAwesome5.ellipsis_h,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                      onPressed: () {
                        //  moreOptionsSMPostViewer(context, i);
                      }),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             Ideas(blog_post["post_id"])));
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: ReadMoreText(
                  isBlogPostExpanded == false
                      ? post_list[0]["blog_title"].toString().length < 40
                          ? post_list[0]["blog_title"]
                          : "${post_list[0]["blog_title"].toString().substring(0, 40)}..."
                      : post_list[0]["blog_title"],
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
                time,
                post_list[0]['blog_title'],
                "assets/bloglogo.png", //need changes here
                post_list[0]['blog_intro'],
                post_list[0]["post_id"]),
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
                                  post_list[0]["like_count"].toString(),
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => ShowSocialFeedComments(
                            //             socialfeed.docs[i].id)));
                          },
                          child: Container(
                            child: RichText(
                              text: TextSpan(
                                  text:
                                      post_list[0]["comment_count"].toString(),
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
                                post_list[0]["view_count"].toString(),
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
                                  if (index == -1) {
                                    if (post_list[0]["like_type"] != "") {
                                      setState(() {
                                        post_list[0]["like_count"]--;
                                        post_list[0]["like_type"] = "";
                                      });
                                      networkCRUD
                                          .addSmPostLikeDetailsAdvancedLogic([
                                        "FALSE",
                                        post_list[0]["post_id"],
                                        _currentUserId,
                                        "blog",
                                        "like",
                                        post_list[0]["like_count"] - 1,
                                        post_list[0]["comment_count"],
                                        post_list[0]["view_count"],
                                        post_list[0]["impression_count"],
                                        post_list[0]["reply_count"]
                                      ]);
                                    } else {
                                      setState(() {
                                        post_list[0]["like_count"]++;
                                        post_list[0]["like_type"] = "like";
                                      });
                                      networkCRUD
                                          .addSmPostLikeDetailsAdvancedLogic([
                                        "TRUE",
                                        post_list[0]["post_id"],
                                        _currentUserId,
                                        "blog",
                                        "like",
                                        post_list[0]["like_count"] + 1,
                                        post_list[0]["comment_count"],
                                        post_list[0]["view_count"],
                                        post_list[0]["impression_count"],
                                        post_list[0]["reply_count"]
                                      ]);
                                    }
                                  } else if (index == 0) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "like";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "like",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else if (index == 1) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "love";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "love",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else if (index == 2) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "haha";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "haha",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else if (index == 3) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "yay";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "yay",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else if (index == 4) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "wow";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "wow",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else if (index == 5) {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "angry";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "blog",
                                      "angry",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  }
                                },
                                reactions: reactions,
                                initialReaction: post_list[0]["like_type"] ==
                                        "like"
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
                                    : post_list[0]["like_type"] == ""
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
                                        : post_list[0]["like_type"] == "love"
                                            ? reactions[1]
                                            : post_list[0]["like_type"] ==
                                                    "haha"
                                                ? reactions[2]
                                                : post_list[0]["like_type"] ==
                                                        "yay"
                                                    ? reactions[3]
                                                    : post_list[0]
                                                                ["like_type"] ==
                                                            "wow"
                                                        ? reactions[4]
                                                        : reactions[5],
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             SocialFeedAddComments(
                            //                 socialfeed.docs[i].id)));
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             ShareFeedPost(
                            //                 socialfeed.docs[i].id)));
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
      ),
    );
  }

  blogPost(String time, String tittle, String imgurl, String desc, String id) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Ideas(id)));
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
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => Ideas(id)));
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
                                            child: Image.asset(imgurl)
                                            // child: CachedNetworkImage(
                                            //   imageUrl: imgurl,
                                            //   fit: BoxFit.cover,
                                            //   placeholder: (context, url) =>
                                            //       Container(
                                            //           height: 70,
                                            //           width: 70,
                                            //           child: Image.asset(
                                            //             "assets/loadingimg.gif",
                                            //           )),
                                            //   errorWidget:
                                            //       (context, url, error) =>
                                            //           Icon(Icons.error),
                                            // ),
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

  _projectDiscuss(int i) {
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
                                imageUrl: post_list[0]["profilepic"].toString(),
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                    child: Image.network(
                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
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
                      _chooseHeaderToViewSMPost("projectdiscuss", i, [], []),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(FontAwesome5.ellipsis_h,
                        color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                    onPressed: () {
                      // moreOptionsSMPostViewer(context, i);
                    }),
              ],
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Text(post_list[0]["content"].toString())),
          SizedBox(
            height: 5,
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    image: AssetImage(post_list[0]["theme"]),
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
                    Container(
                      child: Row(
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
                          Container(
                            width: 250,
                            child: Text(
                              post_list[0]["title"].toString(),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          post_list[0]["grade"].toString(),
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
                          post_list[0]["subject"].toString(),
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
                          post_list[0]["topic"].toString(),
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
                            (post_list[0]["projectvideourl"] != "")
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Video_Player(
                                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                post_list[0]
                                                    ["projectvideourl"]);
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
                            (post_list[0]["reqvideourl"] != "")
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Video_Player(
                                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                post_list[0]["reqvideourl"]);
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
                            (post_list[0]["otherdoc"] != "")
                                ? InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) {
                                      //       return Video_Player(
                                      //           "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                      //           socialfeed.docs[i]
                                      //               .get("reqvideourl"));
                                      //     },
                                      //   ),
                                      // );
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
                                              child: Icon(Icons.picture_as_pdf,
                                                  color: Colors.red,
                                                  size: 15))),
                                    ),
                                  )
                                : SizedBox()
                          ])),
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ViewFile(
                              //             post_list[0]["post_id"])));
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
                                post_list[0]["like_count"].toString(),
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ShowSocialFeedComments(
                          //             socialfeed.docs[i].id)));
                        },
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                                text: post_list[0]["comment_count"].toString(),
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
                              post_list[0]["view_count"].toString(),
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
                              onReactionChanged: (reaction, index, ischecked) {
                                if (index == -1) {
                                  if (post_list[0]["like_type"] != "") {
                                    setState(() {
                                      post_list[0]["like_count"]--;
                                      post_list[0]["like_type"] = "";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "FALSE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "projectdiscuss",
                                      "like",
                                      post_list[0]["like_count"] - 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "like";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "projectdiscuss",
                                      "like",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  }
                                } else if (index == 0) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "like";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "like",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 1) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "love";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "love",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 2) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "haha";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "haha",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 3) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "yay";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "yay",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 4) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "wow";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "wow",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 5) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "angry";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "projectdiscuss",
                                    "angry",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                }
                              },
                              reactions: reactions,
                              initialReaction: post_list[0]["like_type"] ==
                                      "like"
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
                                  : post_list[0]["like_type"] == ""
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
                                      : post_list[0]["like_type"] == "love"
                                          ? reactions[1]
                                          : post_list[0]["like_type"] == "haha"
                                              ? reactions[2]
                                              : post_list[0]["like_type"] ==
                                                      "yay"
                                                  ? reactions[3]
                                                  : post_list[i]["like_type"] ==
                                                          "wow"
                                                      ? reactions[4]
                                                      : reactions[5],
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             SocialFeedAddComments(
                          //                 socialfeed.docs[i].id)));
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             ShareFeedPost(
                          //                 socialfeed.docs[i].id)));
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

  _businessIdeas(int i) {
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
                                imageUrl: post_list[0]["profilepic"].toString(),
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                    child: Image.network(
                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
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
                      _chooseHeaderToViewSMPost("businessideas", i, [], []),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(FontAwesome5.ellipsis_h,
                        color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                    onPressed: () {
                      //    moreOptionsSMPostViewer(context, i);
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
                    image: AssetImage(post_list[0]["theme"]),
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
                          post_list[0]["title"].toString(),
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
                              child: (post_list[0]["document_list"].length == 1)
                                  ? InkWell(
                                      onTap: () {
                                        // PdftronFlutter.openDocument(
                                        //     fileurl[0]);
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
                                                child: (post_list[0]
                                                                ["document_list"]
                                                            [0]["file_ext"] ==
                                                        "pdf")
                                                    ? Icon(Icons.picture_as_pdf,
                                                        color: Colors.red,
                                                        size: 22)
                                                    : (post_list[0]["document_list"][0]
                                                                ["file_ext"] ==
                                                            "excel")
                                                        ? Icon(FontAwesome5.file_excel,
                                                            color: Colors.red,
                                                            size: 22)
                                                        : (post_list[0]["document_list"][0]["file_ext"] ==
                                                                "ppt")
                                                            ? Icon(FontAwesome5.file_powerpoint,
                                                                color:
                                                                    Colors.red,
                                                                size: 22)
                                                            : (post_list[0]["document_list"][0]
                                                                        ["file_ext"] ==
                                                                    "word")
                                                                ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                : SizedBox())),
                                      ),
                                    )
                                  : (post_list[0]["document_list"].length > 1)
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
                                                    BorderRadius.circular(5),
                                                child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      // color: Color(0xFFE9A81D)
                                                    ),
                                                    child: Center(
                                                        child: (post_list[0]
                                                                        ["document_list"][0]
                                                                    [
                                                                    "file_ext"] ==
                                                                "pdf")
                                                            ? Icon(Icons.picture_as_pdf,
                                                                color:
                                                                    Colors.red,
                                                                size: 22)
                                                            : (post_list[0]["document_list"][0]["file_ext"] ==
                                                                    "excel")
                                                                ? Icon(FontAwesome5.file_excel,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22)
                                                                : (post_list[0]["document_list"][0]["file_ext"] ==
                                                                        "ppt")
                                                                    ? Icon(
                                                                        FontAwesome5.file_powerpoint,
                                                                        color: Colors.red,
                                                                        size: 22)
                                                                    : (post_list[0]["document_list"][0]["file_ext"] == "word")
                                                                        ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                        : SizedBox())),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            InkWell(
                                              onTap: () {
                                                // PdftronFlutter.openDocument(
                                                //     fileurl[1]);
                                              },
                                              child: Material(
                                                elevation: 1,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      // color: Color(0xFFE9A81D)
                                                    ),
                                                    child: Center(
                                                        child: (post_list[0]
                                                                        ["document_list"][1]
                                                                    [
                                                                    "file_ext"] ==
                                                                "pdf")
                                                            ? Icon(Icons.picture_as_pdf,
                                                                color:
                                                                    Colors.red,
                                                                size: 22)
                                                            : (post_list[0]["document_list"][1]["file_ext"] ==
                                                                    "excel")
                                                                ? Icon(FontAwesome5.file_excel,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22)
                                                                : (post_list[0]["document_list"][1]["file_ext"] ==
                                                                        "ppt")
                                                                    ? Icon(
                                                                        FontAwesome5.file_powerpoint,
                                                                        color: Colors.red,
                                                                        size: 22)
                                                                    : (post_list[0]["document_list"][1]["file_ext"] == "word")
                                                                        ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                        : SizedBox())),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            (post_list[0]["document_list"]
                                                        .length ==
                                                    3)
                                                ? InkWell(
                                                    onTap: () {
                                                      // PdftronFlutter
                                                      //     .openDocument(
                                                      //         fileurl[2]);
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
                                                                    .circular(
                                                                        5),
                                                            // color: Color(0xFFE9A81D)
                                                          ),
                                                          child: Center(
                                                              child: (post_list[0]["document_list"]
                                                                              [2]
                                                                          [
                                                                          "file_ext"] ==
                                                                      "pdf")
                                                                  ? Icon(Icons.picture_as_pdf,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 22)
                                                                  : (post_list[0]["document_list"][2]["file_ext"] ==
                                                                          "excel")
                                                                      ? Icon(
                                                                          FontAwesome5
                                                                              .file_excel,
                                                                          color:
                                                                              Colors.red,
                                                                          size: 22)
                                                                      : (post_list[0]["document_list"][2]["file_ext"] == "ppt")
                                                                          ? Icon(FontAwesome5.file_powerpoint, color: Colors.red, size: 22)
                                                                          : (post_list[0]["document_list"][2]["file_ext"] == "word")
                                                                              ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                              : SizedBox())),
                                                    ),
                                                  )
                                                : SizedBox()
                                          ],
                                        )
                                      : SizedBox()),
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ViewBusinessFile(
                              //             post_list[0]["post_id"])));
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
                                post_list[0]["like_count"].toString(),
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ShowSocialFeedComments(
                          //             socialfeed.docs[i].id)));
                        },
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                                text: post_list[0]["comment_count"].toString(),
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
                              post_list[0]["view_count"].toString(),
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
                              onReactionChanged: (reaction, index, ischecked) {
                                if (index == -1) {
                                  if (post_list[0]["like_type"] != "") {
                                    setState(() {
                                      post_list[0]["like_count"]--;
                                      post_list[0]["like_type"] = "";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "FALSE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "businessideas",
                                      "like",
                                      post_list[0]["like_count"] - 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  } else {
                                    setState(() {
                                      post_list[0]["like_count"]++;
                                      post_list[0]["like_type"] = "like";
                                    });
                                    networkCRUD
                                        .addSmPostLikeDetailsAdvancedLogic([
                                      "TRUE",
                                      post_list[0]["post_id"],
                                      _currentUserId,
                                      "businessideas",
                                      "like",
                                      post_list[0]["like_count"] + 1,
                                      post_list[0]["comment_count"],
                                      post_list[0]["view_count"],
                                      post_list[0]["impression_count"],
                                      post_list[0]["reply_count"]
                                    ]);
                                  }
                                } else if (index == 0) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "like";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "like",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 1) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "love";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "love",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 2) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "haha";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "haha",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 3) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "yay";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "yay",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 4) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "wow";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "wow",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                } else if (index == 5) {
                                  setState(() {
                                    post_list[0]["like_count"]++;
                                    post_list[0]["like_type"] = "angry";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    post_list[0]["post_id"],
                                    _currentUserId,
                                    "businessideas",
                                    "angry",
                                    post_list[0]["like_count"] + 1,
                                    post_list[0]["comment_count"],
                                    post_list[0]["view_count"],
                                    post_list[0]["impression_count"],
                                    post_list[0]["reply_count"]
                                  ]);
                                }
                              },
                              reactions: reactions,
                              initialReaction: post_list[0]["like_type"] ==
                                      "like"
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
                                  : post_list[0]["like_type"] == ""
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
                                      : post_list[0]["like_type"] == "love"
                                          ? reactions[1]
                                          : post_list[0]["like_type"] == "haha"
                                              ? reactions[2]
                                              : post_list[0]["like_type"] ==
                                                      "yay"
                                                  ? reactions[3]
                                                  : post_list[0]["like_type"] ==
                                                          "wow"
                                                      ? reactions[4]
                                                      : reactions[5],
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             SocialFeedAddComments(
                          //                 socialfeed.docs[i].id)));
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             ShareFeedPost(
                          //                 socialfeed.docs[i].id)));
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

  _smEventPost(int i) {
    bool whiteflag = false;
    if (post_list[0]["themeindex"] == 0 ||
        post_list[0]["themeindex"] == 2 ||
        post_list[0]["themeindex"] == 4 ||
        post_list[0]["themeindex"] == 5) {
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
                              child: CachedNetworkImage(
                                imageUrl: post_list[0]["profilepic"].toString(),
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                    child: Image.network(
                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
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
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                post_list[0]["first_name"] +
                                    " " +
                                    post_list[0]["last_name"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 15,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' has Created a Cause ',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                              ),
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset('assets/causeEmoji.png')),
                            ]),
                            Row(
                              children: [
                                Text('to Educate UnderPrivileged Childrens.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color.fromRGBO(0, 0, 0, 0.6),
                                        fontWeight: FontWeight.w500))
                              ],
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
                      //  moreOptionsSMPostViewer(context, i);
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
                post_list[0]["message"],
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
          // (poster_url != null && poster_url != "")
          //     ? Container(
          //         height: 250,
          //         width: MediaQuery.of(context).size.width,
          //         child: Image.network(poster_url, fit: BoxFit.contain))
          //     : SizedBox(),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.8), BlendMode.dstATop),
                    image: AssetImage(post_list[0]["theme"]),
                    fit: BoxFit.fill)),
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                            width: 150,
                            height: 20,
                            child: Text(
                              post_list[0]["grade"],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteflag == true
                                      ? Colors.white
                                      : Colors.black87),
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Container(
                            height: 20,
                            width: 150,
                            child: Text(
                              post_list[0]["subject"],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteflag == true
                                      ? Colors.white
                                      : Colors.black87),
                              textAlign: TextAlign.start,
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Container(
                            height: 20,
                            width: 150,
                            child: Text(
                              post_list[0]["frequency"],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteflag == true
                                      ? Colors.white
                                      : Colors.black87),
                              textAlign: TextAlign.start,
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Container(
                            height: 20,
                            width: 150,
                            child: Text(
                              post_list[0]["date"],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteflag == true
                                      ? Colors.white
                                      : Colors.black87),
                              textAlign: TextAlign.start,
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Container(
                            width: 150,
                            child: Text(
                              post_list[0]["from_"] +
                                  ' to ' +
                                  post_list[0]["to_"],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteflag == true
                                      ? Colors.white
                                      : Colors.black87),
                              textAlign: TextAlign.start,
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            height: 20,
                            child: Text('Venue :',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: whiteflag == true
                                        ? Colors.white
                                        : Colors.black87))),
                        Container(
                            child: Column(children: [
                          post_list[0]["eventtype"] == "offline"
                              ? Container(
                                  width: 150,
                                  child: Text(
                                    post_list[0]["address"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: whiteflag == true
                                            ? Colors.white
                                            : Colors.black87),
                                    textAlign: TextAlign.start,
                                  ))
                              : Container(
                                  width: 150,
                                  child: Text(
                                    "HyS Online Meet",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: whiteflag == true
                                            ? Colors.white
                                            : Colors.black87),
                                    textAlign: TextAlign.start,
                                  )),
                          post_list[0]["eventtype"] == "offline"
                              ? InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => MapLocation(
                                    //             double.parse(
                                    //                 post_list[0]["latitude"]
                                    //                     .toString()),
                                    //             double.parse(
                                    //                 post_list[0]["longitude"]
                                    //                     .toString()))));
                                  },
                                  child: Text(
                                    '(Map to Venue)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue),
                                  ))
                              : SizedBox()
                        ]))
                      ]),
                ])),
          ),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(post_list[0]["eventname"],
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color.fromRGBO(88, 165, 196, 1))),
            Container(
                child: Row(children: [
              Text(
                  post_list[0]["date"] +
                      ' ' +
                      post_list[0]["from_"] +
                      ' to ' +
                      post_list[0]["to_"],
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
                                        post_list[0]["like_count"].toString(),
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1)),
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
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             ShowSocialFeedComments(
                                  //                 socialfeed.docs[i].id)));
                                },
                                child: Container(
                                  child: RichText(
                                    text: TextSpan(
                                        text: post_list[0]["comment_count"]
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
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                                      post_list[0]["view_count"].toString(),
                                      style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          color:
                                              Color.fromRGBO(205, 61, 61, 1)),
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
                            ]))
                  ])),
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
                        onReactionChanged: (reaction, index, ischecked) {
                          if (index == -1) {
                            if (post_list[0]["like_type"] != "") {
                              setState(() {
                                post_list[0]["like_count"]--;
                                post_list[0]["like_type"] = "";
                              });
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "FALSE",
                                post_list[0]["post_id"],
                                _currentUserId,
                                "cause|teachunprevilagedKids",
                                "like",
                                post_list[0]["like_count"] - 1,
                                post_list[0]["comment_count"],
                                post_list[0]["view_count"],
                                post_list[0]["impression_count"],
                                post_list[0]["reply_count"]
                              ]);
                            } else {
                              setState(() {
                                post_list[0]["like_count"]++;
                                post_list[0]["like_type"] = "like";
                              });
                              networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                "TRUE",
                                post_list[0]["post_id"],
                                _currentUserId,
                                "cause|teachunprevilagedKids",
                                "like",
                                post_list[0]["like_count"] + 1,
                                post_list[0]["comment_count"],
                                post_list[0]["view_count"],
                                post_list[0]["impression_count"],
                                post_list[0]["reply_count"]
                              ]);
                            }
                          } else if (index == 0) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "like";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "like",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          } else if (index == 1) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "love";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "love",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          } else if (index == 2) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "haha";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "haha",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          } else if (index == 3) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "yay";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "yay",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          } else if (index == 4) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "wow";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "wow",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          } else if (index == 5) {
                            setState(() {
                              post_list[0]["like_count"]++;
                              post_list[0]["like_type"] = "angry";
                            });
                            networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                              "TRUE",
                              post_list[0]["post_id"],
                              _currentUserId,
                              "cause|teachunprevilagedKids",
                              "angry",
                              post_list[0]["like_count"] + 1,
                              post_list[0]["comment_count"],
                              post_list[0]["view_count"],
                              post_list[0]["impression_count"],
                              post_list[0]["reply_count"]
                            ]);
                          }
                        },
                        reactions: reactions,
                        initialReaction: post_list[0]["like_type"] == "like"
                            ? Reaction(
                                icon: Row(
                                  children: [
                                    Icon(FontAwesome5.thumbs_up,
                                        color: Color(0xff0962ff), size: 14),
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
                            : post_list[0]["like_type"] == ""
                                ? Reaction(
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
                                  )
                                : post_list[0]["like_type"] == "love"
                                    ? reactions[1]
                                    : post_list[0]["like_type"] == "haha"
                                        ? reactions[2]
                                        : post_list[0]["like_type"] == "yay"
                                            ? reactions[3]
                                            : post_list[0]["like_type"] == "wow"
                                                ? reactions[4]
                                                : reactions[5],
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             SocialFeedAddComments(
                    //                 socialfeed.docs[i].id)));
                  },
                  child: Container(
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
                ),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             ShareFeedPost(
                    //                 socialfeed.docs[i].id)));
                  },
                  child: Container(
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
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 2, right: 2, top: 5),
              color: Colors.white54,
              height: 1,
              width: MediaQuery.of(context).size.width),

          SizedBox(
            height: 10,
          ),
          InkWell(
              onTap: () {
                handlePressButton(context);
              },
              child: Row(
                children: [
                  Icon(Icons.person_add),
                  Text(' Invite Friends To Join')
                ],
              )),
          SizedBox(
            height: 7,
          ),
        ]));
  }

  _chooseHeaderToViewSMPost(
      String mood, int i, List selectedUserName, List selectedUserID) {
    if (mood == "") {
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    } else if (mood == "Excited") {
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'need people around ${gender} ',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgroup.png?alt=media&token=3d1de769-bf7c-46cb-9b46-0ddbaa49a049",
                    height: 20,
                    width: 20),
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
                                          fontSize: 11,
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating her ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is celebrating her ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 11,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ]),
            ),
            Text(
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 11,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
            RichText(
              text: TextSpan(
                  text: "is feeling ",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
                              fontSize: 11,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
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
      String gender = post_list[0]["gender"] == "MALE" ? "his" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
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
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              "has discussed $gender project.",
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
    } else if (mood == "podcast") {
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: const <TextSpan>[
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
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: const <TextSpan>[
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
    } else if (mood == "businessideas") {
      String gender = post_list[0]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: post_list[0]["first_name"] +
                      " " +
                      post_list[0]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + post_list[0]["city"],
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
              post_list[0]["school_name"].toString().length > 25
                  ? post_list[0]["school_name"].toString().substring(0, 25) +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString()
                  : post_list[0]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      post_list[0]["grade"].toString(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              "has discussed $gender business idea.",
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
    }
  }

  handlePressButton(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Invite Friends'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/tony1.png'),
                  ),
                  Text('   Pratik Ekghare')
                ]),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/tony1.png'),
                    ),
                    Text('   Vivan Verma')
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/tony1.png'),
                  ),
                  Text('   Nitin Verma')
                ])
              ]));
        });
  }

  _handlejoinbutton(BuildContext context, String id, int i) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Join Event'),
            titleTextStyle:
                TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
            content: Text('Add this Event to your Calendar?',
                style: TextStyle(color: Colors.black54)),
            actions: [
              MaterialButton(
                  onPressed: () {
                    // socialobj.adduserCalendarEvent(
                    //     id,
                    //     eventName1,
                    //     date1,
                    //     fromtime1,
                    //     totime1,
                    //     freq1,
                    //     socialfeed.docs[i].get('eventtype'),
                    //     socialfeed.docs[i].get('meetingid'));
                    // socialEventSubCommLike.put(_currentUserId + id, "Like");
                    // databaseReference
                    //     .child('sm_events')
                    //     .child('reactions')
                    //     .child(id)
                    //     .update({
                    //   "joinedcount": int.parse(countData
                    //           .child(id)
                    //           .child("joinedcount")
                    //           .value
                    //           .toString()) +
                    //       1
                    // });
                    // Navigator.pop(context);
                    //
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CalendarEvent(
                    //             eventName1,
                    //             date1,
                    //             fromtime1,
                    //             totime1,
                    //             freq1,
                    //             socialfeed.docs[i].get('meetingid'))));
                  },
                  child: Text('Yes',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w700))),
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w700)))
            ],
          );
        });
  }

  _handleunjoinbutton(BuildContext context, String id) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Remove Event'),
            titleTextStyle:
                TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
            content: Text(
                'Are you sure to delete this Event from your Calendar?',
                style: TextStyle(color: Colors.black54)),
            actions: [
              MaterialButton(
                  onPressed: () {
                    // socialobj.deleteCalenderDataWhere(_currentUserId + id);
                    // socialEventSubCommLike.delete(_currentUserId + id);
                    // databaseReference
                    //     .child('sm_events')
                    //     .child('reactions')
                    //     .child(id)
                    //     .update({
                    //   "joinedcount": int.parse(countData
                    //           .child(id)
                    //           .child("joinedcount")
                    //           .value
                    //           .toString()) -
                    //       1
                    // });
                    Navigator.pop(context);
                  },
                  child: Text('Yes',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w700))),
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w700)))
            ],
          );
        });
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
                  // if (callStatusCheck
                  //         .child(socialfeed.docs[i].get("userid"))
                  //         .child("callstatus")
                  //         .value ==
                  //     false) {
                  //   for (int j = 0; j < notificationToken.docs.length; j++) {
                  //     if (notificationToken.docs[j].get("userid") ==
                  //         socialfeed.docs[i].get("userid")) {
                  //       String channelid = socialfeed.docs[i].id +
                  //           socialfeed.docs[i].get("userid");
                  //       bool hasPermission = await checkPermission();
                  //       String message =
                  //           "${personaldata.docs[0].get("firstname")} ${personaldata.docs[0].get("lastname")} Calling you";
                  //       if (hasPermission) {
                  //         // String notifyId =
                  //         //     await myNotify.incomingCalNotificationToSuperUser(
                  //         //         personaldata.docs[0].get("firstname") +
                  //         //             " " +
                  //         //             personaldata.docs[0].get("lastname"),
                  //         //         socialfeed.docs[i].get("username"),
                  //         //         socialfeed.docs[i].get("userid"),
                  //         //         message,
                  //         //         current_date,
                  //         //         notificationToken.docs[j].get("token"),
                  //         //         socialfeed.docs[i].id,
                  //         //         "2",
                  //         //         channelid,
                  //         //         "SocailFeedCall",
                  //         //         comparedate);
                  //         Navigator.of(context).pop();

                  //         gotoCallingPage(
                  //             true,
                  //             socialfeed.docs[i].get("userid"),
                  //             socialfeed.docs[i].get("username"),
                  //             socialfeed.docs[i].get("userprofilepic"));

                  //         // Navigator.push(
                  //         //     context,
                  //         //     MaterialPageRoute(
                  //         //       builder: (context) => VideoCallingCallerScreen(
                  //         //           channelid,
                  //         //           socialfeed.docs[i].get("username"),
                  //         //           socialfeed.docs[i].get("userid"),
                  //         //           ""),
                  //         //     ));
                  //       }
                  //     }
                  //   }
                  // } else {
                  //   Fluttertoast.showToast(
                  //       msg:
                  //           "${socialfeed.docs[i].get("username")} is on other call.",
                  //       toastLength: Toast.LENGTH_SHORT,
                  //       gravity: ToastGravity.BOTTOM,
                  //       timeInSecForIosWeb: 10,
                  //       backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
                  //       textColor: Colors.white,
                  //       fontSize: 12.0);
                  // }
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
                  // for (int j = 0; j < notificationToken.docs.length; j++) {
                  //   if (notificationToken.docs[j].get("userid") ==
                  //       socialfeed.docs[i].get("userid")) {
                  //     String channelid = socialfeed.docs[i].id +
                  //         socialfeed.docs[i].get("userid");
                  //     bool hasPermission = await checkMicrophonePermission();
                  //     String message =
                  //         "${personaldata.docs[0].get("firstname")} ${personaldata.docs[0].get("lastname")} Calling you";
                  //     if (hasPermission) {
                  //       // myNotify.incomingCalNotificationToSuperUser(
                  //       //     personaldata.docs[0].get("firstname") +
                  //       //         " " +
                  //       //         personaldata.docs[0].get("lastname"),
                  //       //     socialfeed.docs[i].get("username"),
                  //       //     socialfeed.docs[i].get("userid"),
                  //       //     message,
                  //       //     current_date,
                  //       //     notificationToken.docs[j].get("token"),
                  //       //     socialfeed.docs[i].id,
                  //       //     "3",
                  //       //     channelid,
                  //       //     "SocailFeedCall",
                  //       //     comparedate);
                  //       Navigator.of(context).pop();

                  //       gotoCallingPage(
                  //           false,
                  //           socialfeed.docs[i].get("userid"),
                  //           socialfeed.docs[i].get("username"),
                  //           socialfeed.docs[i].get("userprofilepic"));
                  //       // Navigator.push(
                  //       //     context,
                  //       //     MaterialPageRoute(
                  //       //       builder: (context) => AudioCallingCallerScreen(
                  //       //           channelid,
                  //       //           socialfeed.docs[i].get("username"),
                  //       //           socialfeed.docs[i].get("userid"),
                  //       //           ""),
                  //       //     ));
                  //     }
                  //   }
                  // }
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

  gotoCallingPage(
      bool isVideo, String userID, String userName, String profilePic) async {
    //   Map<String, dynamic> agrs = {
    //     "IS_VIDEO": isVideo,
    //     "USER_ID": userID,
    //     "userName": userName,
    //     "profilePic": profilePic,
    //     "LOGGED_IN_userName": personaldata.docs[0].get("firstname"),
    //     "LOGGED_IN_profilePic": personaldata.docs[0].get("profilepic"),
    //     "LOGGED_IN_USER_ID": personaldata.docs[0].get("userid")
    //   };
    //   await _channel.invokeMethod('outgoing_calling', agrs);
    // }
  }

  Future<bool> checkMicrophonePermission() async {
    if (!await Permissions.microphonePermissionsGranted()) {
      return false;
    }
    return true;
  }

  Widget showSelectedVideos(int i) {
    // _onControllerChange(socialfeed.docs[i].get("videolist"), i);
    return Container(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: post_list[i]["videothumbnail"],
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
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) {
                  //       return Video_Player(
                  //           socialfeed.docs[i].get("videothumbnail"),
                  //           socialfeed.docs[i].get("videolist"));
                  //     },
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ));
  }

  YYDialog moreOptionsSMPostViewer(BuildContext context, int i) {
    String gender = post_list[0]["gender"] == "Male" ? "his" : "her";
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
                      InkWell(
                        onTap: () {},
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
                            'Add ${post_list[0]["first_name"]} ${post_list[0]["last_name"]} to favourites',
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
                            'Snooze ${post_list[0]["first_name"]} ${post_list[0]["last_name"]} for 30 days',
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
                            'Unfollow ${post_list[0]["first_name"]} ${post_list[0]["last_name"]}',
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
