import 'dart:typed_data';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hys/SocialPart/database/SocialDiscussDB.dart';
import 'package:hys/SocialPart/network_crud.dart';
import 'package:hys/utils/cropper.dart';
import 'package:hys/utils/options.dart';
import 'package:intl/intl.dart';
import 'package:hys/navBar.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:hive/hive.dart';

int index = 0;

class DiscussProject extends StatefulWidget {
  @override
  _DiscussProjectState createState() => _DiscussProjectState();
}

GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
List<String> tagids = [];
bool _showList = false;
var _users = [
  {
    'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
    'display': 'Vivek Sharma',
    'full_name': 'DPS | Grade 7',
    'photo':
        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
  },
];
String markuptext = "";
QuerySnapshot userData;
CrudMethods crudobj = CrudMethods();
SocialDiscuss socialobj = SocialDiscuss();
final _formKey = GlobalKey<FormState>();
FocusNode focusNode1 = FocusNode();
FocusNode focusNode2 = FocusNode();
FocusNode focusNode3 = FocusNode();
FocusNode focusNode4 = FocusNode();

FocusNode focusNode5 = FocusNode();
FocusNode focusNode6 = FocusNode();
FocusNode focusNode7 = FocusNode();
FocusNode focusNode8 = FocusNode();
FocusNode focusNode9 = FocusNode();
String themepath = "assets/projectbackg1.png";
bool themeflag = false;
FocusNode focusNode10 = FocusNode();
FocusNode focusNode = FocusNode();
FocusNode focusNode11 = FocusNode();
QuerySnapshot allUserschooldata;
QuerySnapshot allUserpersonaldata;

class _DiscussProjectState extends State<DiscussProject> {
  List<dynamic> userDatainit = [];
  Map<dynamic, dynamic> userData = {};
  Box<dynamic> userDataDB;
  Box<dynamic> allSocialPostLocalDB;

  var progress;
  Future<void> _get_userData() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_user_data/$_currentUserId'),
    );

    print("get_user_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userDatainit = json.decode(response.body);
        print(userDatainit);
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
      });
    }
  }

  List selectedUserflag = [];
  List selectedUserID = [];
  List<dynamic> taggingData = [];

  Future<void> _get_all_users_data_for_tagging() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_users_data_for_tagging'),
    );

    print("get_all_users_data_for_taggigng: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        taggingData = json.decode(response.body);
        for (int i = 0; i < taggingData.length; i++) {
          if (taggingData[i]["user_id"].toString() !=
              userDataDB.get("user_id")) {
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
          }
          selectedUserflag.add(false);
        }
      });
    }
  }

  List<dynamic> allPostData = [];

  String _currentUserId = "";

  void initState() {
    _currentUserId = FirebaseAuth.instance.currentUser.uid;
    userDataDB = Hive.box<dynamic>('userdata');
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    allPostData = allSocialPostLocalDB.get("allpost");

    _get_userData();
    _get_all_users_data_for_tagging();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(body: _body()),
        onTap: () {
          setState(() {
            focusNode1.unfocus();
            focusNode2.unfocus();
            focusNode3.unfocus();
            focusNode4.unfocus();
            focusNode5.unfocus();
            focusNode6.unfocus();
            focusNode7.unfocus();
            focusNode8.unfocus();
            focusNode9.unfocus();
            focusNode10.unfocus();
            focusNode11.unfocus();
            dismissKeyboard();
            ocrkeyboard = false;
          });
        });
  }

  final picker = ImagePicker();
  bool imgFlag = false;
  bool uploaded = false;
  File _image;
  bool showimgcontainer = false;
  bool showvdocontainer = false;
  String dropdownValueClass = '5';
  String dropdownValueSubject = 'Mathematics';
  String dropdownValueTopic = 'None';

  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

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
                          getProfilePic(ImageSource.camera, 0);
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
                          getProfilePic(ImageSource.gallery, 0);
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

  dynamic imgUrl;
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
          } else
            _showAlertDialog(value[1]);
        });
      });
    });
  }

  void _showDialog(int index) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: 100,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          getProfilePic(ImageSource.camera, index);
                        });
                        Navigator.pop(context);
                      },
                      icon: Tab(
                          child: Icon(Icons.camera_enhance_sharp,
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
                          getProfilePic(ImageSource.gallery, index);
                        });
                        Navigator.pop(context);
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
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _showVideoDialog(int i) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: 100,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          uploadSocialFeedVideo(ImageSource.camera, i);
                        });
                        Navigator.pop(context);
                      },
                      icon: Tab(
                          child: Icon(Icons.camera_enhance_sharp,
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
                          uploadSocialFeedVideo(ImageSource.gallery, i);
                        });
                        Navigator.pop(context);
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
    showDialog(context: context, builder: (_) => alertDialog);
  }

  File firstcrop;
  String base64Image = "";
  bool ocruploaded1 = false;
  bool ocruploaded2 = false;
  bool ocruploaded3 = false;
  bool ocruploaded4 = false;
  bool ocruploaded5 = false;
  bool ocruploaded6 = false;
  bool ocruploaded7 = false;
  bool ocruploaded8 = false;

  Future getProfilePic(ImageSource source, int index) async {
    final pickedfile = await picker.getImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _image = File(pickedfile.path);
        print(_image);
      });
    }

    if (_image != null) {
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

      /* if (firstcrop != null) {
        croppedFile = await ImageCropper.cropImage(
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
      }*/
      if (firstcrop != null) {
        getEventImgURL(firstcrop);
        if (firstcrop != null) {
          setState(() {
            base64Image = base64Encode(firstcrop.readAsBytesSync());
            print(base64Image);
            // imagereading = true;
            uploadImage(base64Image, firstcrop, index);
          });
        }
        /*setState(() {
          imageFile = croppedFile;
          print(imageFile);
          base64Image = base64Encode(imageFile.readAsBytesSync());
          print(base64Image);
          imagereading = true;
          uploadImage(base64Image, imageFile);
        });*/
      }
    }
  }

  Map totaldata;
  String latex1 = "";
  String latex2 = "";
  String latex3 = "";
  String latex4 = "";
  String latex5 = "";
  String latex6 = "";
  String latex7 = "";
  String latex8 = "";
  List tex = [''];

  List<dynamic> allProjectsPostData = [];
  int latexStep = 0;
  NetworkCRUD networkCRUD = NetworkCRUD();

  Future<void> uploadImage(String x, File y, int index) async {
    final http.Response response = await http.post(
      Uri.parse('https://api.mathpix.com/v3/text'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'app_id': 'shubham_sparrowrms_in_f5ee1d_512d15',
        'app_key': 'a95e398dbb1b1faf2af3',
      },
      body: jsonEncode(<String, dynamic>{
        "src": "data:image/jpeg;base64," + x,
        "formats": ["text", "data"],
        "data_options": {"include_asciimath": false, "include_latex": true}
      }),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        //print(response.body);
        ocrkeyboard = false;
        totaldata = json.decode(response.body);
        //print(totaldata);
        //  print(totaldata["data"]);
        if (index == 1) {
          latex1 = totaldata["text"];
          ocruploaded1 = true;
        } else if (index == 2) {
          latex2 = totaldata["text"];
          ocruploaded2 = true;
        } else if (index == 3) {
          latex3 = totaldata["text"];
          ocruploaded3 = true;
        } else if (index == 4) {
          latex4 = totaldata["text"];
          ocruploaded4 = true;
        } else if (index == 5) {
          latex5 = totaldata["text"];
          ocruploaded5 = true;
        } else if (index == 6) {
          latex6 = totaldata["text"];
          ocruploaded6 = true;
        } else if (index == 7) {
          latex7 = totaldata["text"];
          ocruploaded7 = true;
        } else if (index == 8) {
          latex8 = totaldata["text"];
          ocruploaded8 = true;
        }
        //print(latex);
        print(totaldata["data"]);
        for (int i = 0; i < totaldata["data"].length; i++) {
          tex.add(totaldata["data"][i]['value']);
        }

        print(latex1);

        // imagereading = false;

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => QuestionInputPreviewOCR(
        //             this.selectedGrade,
        //             selectedSubject,
        //             selectedTopic,
        //             latex,
        //             y)));
      });
    } else {
      // loading = false;

    }
  }

  void _initController(String link) {
    _controller = VideoPlayerController.file(File(link))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(false);
        _controller.play();
      });
  }

  Future<void> _onControllerChange(String link) async {
    if (_controller == null) {
      // If there was no controller, just create a new one
      _initController(link);
    } else {
      // If there was a controller, we need to dispose of the old one first
      final oldController = _controller;

      // Registering a callback for the end of next frame
      // to dispose of an old controller
      // (which won't be used anymore after calling setState)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        oldController.pause();
        await oldController.dispose();

        // Initing new controller
        _initController(link);
      });

      // Making sure that controller is not used by setting it to null
      setState(() {
        _controller = null;
      });
    }
  }

  String _error = 'No Error Dectected';
  VideoPlayerController _controller;
  String thumbURL1 = "";
  String thumbURL2 = "";

  String finalVideos = "";
  String finalVideosUrl1 = "";
  String finalVideosUrl2 = "";
  bool videoUploaded1 = false;
  bool videoUploaded2 = false;
  String video1URL = "";
  String video2URL = "";

  Future uploadSocialFeedVideo(ImageSource source, int i) async {
    String path = "";
    final file = await picker.getVideo(
        source: source, maxDuration: Duration(minutes: 15));
    if (file == null) {
      return;
    }
    finalVideos = file.path;
    // _onControllerChange(file.path);
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
      if (i == 1) {
        socialobj.uploadProjectVideo(path).then((value) {
          setState(() {
            print(value);
            if (value[0] == true) {
              print(value[1]);
              finalVideosUrl1 = value[1];

              getThumbnail(finalVideosUrl1, i);
              //Navigator.pop(context);
              dismissKeyboard();
            } else
              _showAlertDialog(value[1]);
          });
        });
      } else if (i == 2) {
        socialobj.uploadProjectVideo(path).then((value) {
          setState(() {
            print(value);
            if (value[0] == true) {
              print(value[1]);
              finalVideosUrl2 = value[1];

              getThumbnail(finalVideosUrl2, i);
              //Navigator.pop(context);
              dismissKeyboard();
            } else
              _showAlertDialog(value[1]);
          });
        });
      }
    }
  }

  getThumbnail(String videURL, int i) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videURL,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 30,
    );
    print(fileName);
    if (i == 1) {
      socialobj.uploadSocialMediaFeedImages(File(fileName)).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            thumbURL1 = value[1];
            videoUploaded1 = true;
          } else
            _showAlertDialog(value[1]);
        });
      });
    } else if (i == 2) {
      socialobj.uploadSocialMediaFeedImages(File(fileName)).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            thumbURL2 = value[1];
            videoUploaded2 = true;
          } else
            _showAlertDialog(value[1]);
        });
      });
    }
  }

  bool flag1 = false;
  Future<void> dismissKeyboard() async {
    flag1 = false;
    focusNode.unfocus();
  }

  Future<void> showKeyboard() async {
    flag1 = true;
    focusNode.requestFocus();
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

  String procedure = "";
  String content = "";
  String title = "";
  String taggedString = "";
  String requirement = "";
  bool ocrkeyboard = false;
  String purchasedfrom = "";
  String theory = "";
  String findings = "";
  String similartheory = "";
  dynamic videourl;
  dynamic reqvideourl;
  File summary;
  String summary_string = "";
  String otherdocs_string = "";
  File otherdocs;
  String topic = "";
  bool topicflag = false;

  _body() {
    if ((userDataDB != null)) {
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
                      if ((content != "") && (title != "")) {
                        Dialogs.showLoadingDialog(context, _formKey);
                        tagids.clear();
                        print(markuptext);
                        for (int l = 0; l < markuptext.length - 4; l++) {
                          int k = l;
                          if (markuptext.substring(k, k + 1) == "@") {
                            String test1 = markuptext.substring(k);
                            print(
                                "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                            tagids
                                .add(test1.substring(4, test1.indexOf("__]")));
                          }
                        }
                        comparedate =
                            DateFormat('yyyyMMddkkmm').format(DateTime.now());
                        String postID = "sm${_currentUserId}${comparedate}";
                        String userTagID =
                            "usrtgsm${_currentUserId}${comparedate}";
                        bool isImagesPosted = false;
                        bool isVideosPosted = false;
                        bool isUserTaggedPosted = false;
                        bool isFinalPostDone = false;
                        bool ispostIDCreated = await networkCRUD
                            .addsmPostDetails([
                          postID,
                          _currentUserId,
                          "projectdiscuss",
                          content,
                          comparedate
                        ]);
                        // allPostData.insert(0, {
                        //   "first_name": userDataDB.get("first_name"),
                        //   "last_name": userDataDB.get("last_name"),
                        //   "profilepic": userDataDB.get("profilepic"),
                        //   "school_name": userDataDB.get("school_name"),
                        //   "post_id": postID,
                        //   "user_id": _currentUserId,
                        //   "post_type": "projectdiscuss",
                        //   "comment": content,
                        //   "compare_date": comparedate
                        // });
                        //allSocialPostLocalDB.put("allpost", allPostData);
                        if (ispostIDCreated == true) {
                          if (tagids.isNotEmpty) {
                            for (int i = 0; i < tagids.length; i++) {
                              isUserTaggedPosted = await networkCRUD
                                  .addsmPostUserTaggedDetails(
                                      [userTagID, tagids[i]]);
                            }
                          }
                          List<dynamic> data = [
                            postID,
                            _currentUserId,
                            content,
                            themepath,
                            title,
                            dropdownValueClass,
                            dropdownValueSubject,
                            (topicflag == true) ? topic : dropdownValueTopic,
                            (ocruploaded1 == false) ? requirement : latex1,
                            (ocruploaded2 == false) ? purchasedfrom : latex2,
                            (ocruploaded3 == false) ? procedure : latex3,
                            (ocruploaded4 == false) ? theory : latex4,
                            (ocruploaded5 == false) ? findings : latex5,
                            (ocruploaded6 == false) ? similartheory : latex6,
                            finalVideosUrl1,
                            finalVideosUrl2,
                            (ocruploaded7 == true) ? latex7 : summary_string,
                            (ocruploaded8 == false) ? otherdocs_string : latex8,
                            tagids.isNotEmpty ? userTagID : "",
                            "hyspostprivacy01",
                            0,
                            0,
                            0,
                            0,
                            comparedate
                          ];
                          isFinalPostDone = await networkCRUD
                              .addsmProjectDiscussPostDetails(data);
                          print(isFinalPostDone);
                          // allProjectsPostData.insert(0, {
                          //   "first_name": userDataDB.get("first_name"),
                          //   "last_name": userDataDB.get("last_name"),
                          //   "profilepic": userDataDB.get("profilepic"),
                          //   "school_name": userDataDB.get("school_name"),
                          //   "post_id": data[0],
                          //   "user_id": data[1],
                          //   "content": data[2],
                          //   "theme": data[3],
                          //   "title": data[4],
                          //   "grade": data[5],
                          //   "subject": data[6],
                          //   "topic": data[7],
                          //   "requirements": data[8],
                          //   "purchasedfrom": data[9],
                          //   "procedure_": data[10],
                          //   "theory": data[11],
                          //   "findings": data[12],
                          //   "similartheory": data[13],
                          //   "projectvideourl": data[14],
                          //   "reqvideourl": data[15],
                          //   "summarydoc": data[16],
                          //   "otherdoc": data[17],
                          //   "memberlist_id": data[18],
                          //   "privacy": data[19],
                          //   "like_count": data[20],
                          //   "comment_count": data[21],
                          //   "view_count": data[22],
                          //   "impression_count": data[23],
                          //   "compare_date": data[24]
                          //});
                          if (isFinalPostDone == true) {
                            //allSocialPostLocalDB.put("projectpost", allProjectsPostData);
                            for (int k = 0; k < selectedUserflag.length; k++) {
                              setState(() {
                                selectedUserflag[k] = false;
                              });
                            }

                            ElegantNotification.success(
                              title: Text("Congrats,"),
                              description:
                                  Text("Your post created successfully."),
                            );
                          } else {
                            ElegantNotification.success(
                              title: Text("Error..."),
                              description: Text("Something wrong."),
                            );
                          }
                        }
                      }
                      setState(() {
                        ocruploaded1 = false;
                        ocruploaded2 = false;
                        ocruploaded3 = false;
                        ocruploaded4 = false;
                        ocruploaded5 = false;
                        ocruploaded6 = false;
                        ocruploaded7 = false;
                        ocruploaded8 = false;
                        latex1 = "";
                        latex2 = "";
                        latex3 = "";
                        latex4 = "";
                        latex5 = "";
                        latex6 = "";
                        latex7 = "";
                        latex8 = "";
                        latexStep = 0;

                        procedure = "";
                        taggedString = "";
                        requirement = "";
                        purchasedfrom = "";
                        theory = "";
                        findings = "";
                        similartheory = "";
                        videoUploaded1 = false;
                        videoUploaded2 = false;
                        finalVideosUrl1 = "";
                        finalVideosUrl2 = "";
                        selectedUserID = [];
                      });
                      Navigator.of(_formKey.currentContext, rootNavigator: true)
                          .pop();

                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(88, 165, 196, 1),
                          borderRadius: BorderRadius.circular(3)),
                      child: Text(
                        'Post',
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
                                      child: Image.network(
                                          userDataDB.get("profilepic"))),
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
                                        userDataDB.get('first_name') +
                                            ' ' +
                                            userDataDB.get('last_name'),
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text(' has Discussed a Project '),
                                  ]),
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
                              content = val;
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
                              hintText: 'Write about your project...',
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
                      // (showimgcontainer == true) ? _imgContainer() : SizedBox(),
                      // (uploaded == true)
                      //     ? Container(
                      //         color: Colors.black12,
                      //         padding: EdgeInsets.all(10),
                      //         height: 300,
                      //         width: MediaQuery.of(context).size.width,
                      //         child: ListView(
                      //           children: [
                      //             Padding(
                      //               padding: const EdgeInsets.all(0.0),
                      //               child: Row(
                      //                 mainAxisAlignment: MainAxisAlignment.end,
                      //                 children: [
                      //                   IconButton(
                      //                     icon: Icon(Icons.cancel,
                      //                         color: Colors.black),
                      //                     onPressed: () {
                      //                       setState(() {
                      //                         imgFlag = false;
                      //                         uploaded = false;
                      //                         _image.delete();
                      //                       });
                      //                     },
                      //                   )
                      //                 ],
                      //               ),
                      //             ),
                      //             Image.file(firstcrop, fit: BoxFit.contain),
                      //           ],
                      //         ),
                      //       )
                      //     : SizedBox(),
                    ],
                  )
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text('Fill Project Details.',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 15,
                        color: Color.fromRGBO(78, 160, 193, 2),
                        fontWeight: FontWeight.w500,
                      ))),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
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
                                                image: AssetImage(themepath)))),
                                    IconButton(
                                      icon: Icon(Icons.cancel,
                                          color: Colors.black),
                                      onPressed: () {
                                        setState(() {
                                          themeflag = false;
                                          themepath = "";
                                        });
                                      },
                                    )
                                  ])
                                ])
                          : SizedBox(
                              height: 1,
                            ),
                    ])),
              ),
              SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25, bottom: 10),
                child: Column(children: [
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Project Title',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                      width: MediaQuery.of(context).size.width - 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: "Enter Your Project title",
                                hintStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
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
                                title = value;
                              });
                            },
                          ))),
                  SizedBox(
                    height: 30,
                  ),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                        Container(
                          child: Text('Class',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        SizedBox(width: 20),
                        Container(
                            width: 60,
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

                  // ]),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                        Container(
                            child: Text('Subject',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ))),
                        SizedBox(width: 20),
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
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [

                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                        Container(
                            child: Text('Topic',
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
                              value: dropdownValueTopic,
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
                                  dropdownValueTopic = value;
                                  if (dropdownValueTopic == "Others") {
                                    topicflag = true;
                                  } else
                                    topicflag = false;
                                });
                              },
                              items: <String>[
                                "None",
                                "Others"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  (topicflag == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width - 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: "Enter topic here",
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54)),
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please Enter Name.';
                            //   } else
                            //     return null;
                            // },
                            onTap: () async {
                              focusNode2.requestFocus();
                            },
                            focusNode: focusNode2,
                            onChanged: (value) {
                              setState(() {
                                topic = value;
                              });
                            },
                          ))
                      : SizedBox(),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('Team Members',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ))),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        padding: EdgeInsets.all(2),
                        child: FlutterMentions(
                          focusNode: focusNode3,
                          keyboardType: TextInputType.text,
                          cursorColor: Color.fromRGBO(88, 165, 196, 1),
                          decoration: InputDecoration(
                            fillColor: Color.fromRGBO(245, 245, 245, 1),
                            filled: true,
                            counterText: '',
                            hintText: '@Tag someone here',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600),
                            alignLabelWithHint: false,
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            errorStyle: TextStyle(
                                color: Color.fromRGBO(240, 20, 41, 1)),
                            focusColor: Color.fromRGBO(88, 165, 196, 1),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(245, 245, 245, 1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(245, 245, 245, 1),
                              ),
                            ),
                          ),
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(88, 165, 196, 1),
                              fontWeight: FontWeight.w500),
                          suggestionPosition: SuggestionPosition.Bottom,
                          onMarkupChanged: (val) {
                            setState(() {
                              markuptext = val;
                            });
                          },
                          onTap: () {
                            focusNode3.requestFocus();
                          },
                          onEditingComplete: () {
                            setState(() {
                              tagids.clear();
                              for (int l = 0; l < markuptext.length; l++) {
                                int k = l;
                                if (markuptext.substring(k, k + 1) == "@") {
                                  String test1 = markuptext.substring(k);
                                  tagids.add(
                                      test1.substring(4, test1.indexOf("__]")));
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
                          onChanged: (val) {
                            setState(() {
                              taggedString = val;
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
                                  color: Color.fromRGBO(88, 165, 196, 1),
                                ),
                                matchAll: false,
                                data: _users,
                                suggestionBuilder: (data) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            top: BorderSide(
                                                color: Color(0xFFE0E1E4)))),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(data['display']),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                    ],
                  ),

                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text("Material's Required",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded1 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: TextFormField(
                                    maxLines: 7,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: "Enter text or scan",
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    keyboardType: TextInputType.multiline,
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please Enter Name.';
                                    //   } else
                                    //     return null;
                                    // },
                                    onTap: () async {
                                      setState(() {
                                        ocrkeyboard = true;
                                        index = 1;
                                        filekeyboard = false;
                                        focusNode4.requestFocus();
                                      });

                                      // focusNode1.requestFocus();
                                    },
                                    focusNode: focusNode4,
                                    onChanged: (value) {
                                      setState(() {
                                        requirement = value;
                                      });
                                    },
                                  ),
                                )),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 120,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex1,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),

                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Can be purchased from',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded2 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 7,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      keyboardType: TextInputType.multiline,
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        setState(() {
                                          ocrkeyboard = true;
                                          index = 2;
                                          filekeyboard = false;
                                          focusNode5.requestFocus();
                                        });
                                      },
                                      focusNode: focusNode5,
                                      onChanged: (value) {
                                        setState(() {
                                          purchasedfrom = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 100,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex2,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),

                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Procedure',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded3 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 10,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        setState(() {
                                          ocrkeyboard = true;
                                          index = 3;
                                          filekeyboard = false;
                                          focusNode6.requestFocus();
                                        });

                                        // focusNode1.requestFocus();
                                      },
                                      focusNode: focusNode6,
                                      onChanged: (value) {
                                        setState(() {
                                          procedure = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 120,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex3,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),

                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Theory',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded4 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 10,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      keyboardType: TextInputType.multiline,
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        index = 4;
                                        ocrkeyboard = true;
                                        filekeyboard = false;
                                        focusNode7.requestFocus();
                                      },
                                      focusNode: focusNode7,
                                      onChanged: (value) {
                                        setState(() {
                                          theory = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 150,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex4,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),

                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Findings',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded5 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 7,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      keyboardType: TextInputType.multiline,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Enter Name.';
                                        } else
                                          return null;
                                      },
                                      onTap: () async {
                                        index = 5;
                                        ocrkeyboard = true;
                                        filekeyboard = false;
                                        focusNode8.requestFocus();
                                      },
                                      focusNode: focusNode8,
                                      onChanged: (value) {
                                        setState(() {
                                          findings = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex5,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),
                  SizedBox(height: 30),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Similar Projects',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded6 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 7,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      keyboardType: TextInputType.multiline,
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        setState(() {
                                          index = 6;
                                          ocrkeyboard = true;
                                          filekeyboard = false;
                                        });
                                        focusNode9.requestFocus();
                                      },
                                      focusNode: focusNode9,
                                      onChanged: (value) {
                                        setState(() {
                                          similartheory = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex6,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Upload Video of the project',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      videoUploaded1 == false
                          ? Container(
                              width: MediaQuery.of(context).size.width - 50,
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: "Click here to upload",
                                    hintStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                readOnly: true,
                                // validator: (value) {
                                //   if (value.isEmpty) {
                                //     return 'Please Enter Name.';
                                //   } else
                                //     return null;
                                // },
                                onTap: () async {
                                  _showVideoDialog(1);
                                  // focusNode1.requestFocus();
                                },
                                // focusNode: focusNode1,
                                // onChanged: (value) {
                                //   setState(() {
                                //      = value;
                                //   });
                                // },
                              ))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    height: 200,
                                    width:
                                        MediaQuery.of(context).size.width - 50,
                                    child: Stack(children: [
                                      Container(
                                        child: Image.network(thumbURL1),
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                      ),
                                      Center(
                                        child: Icon(Icons.play_circle_outline,
                                            color: Colors.white),
                                      )
                                    ])),
                              ],
                            )
                    ],
                  ),
                  SizedBox(height: 30),

                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Video of assembly of parts',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  videoUploaded2 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Click here to upload",
                                      hintStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  readOnly: true,
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please Enter Name.';
                                  //   } else
                                  //     return null;
                                  // },
                                  onTap: () async {
                                    _showVideoDialog(2);
                                  },
                                  // focusNode: focusNode1,
                                  // onChanged: (value) {
                                  //   setState(() {
                                  //     title = value;
                                  //   });
                                  // },
                                ))
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width - 50,
                                child: Stack(children: [
                                  Container(
                                    child: Image.network(thumbURL2),
                                    height: 200,
                                    width:
                                        MediaQuery.of(context).size.width - 50,
                                  ),
                                  Center(
                                    child: Icon(Icons.play_circle_outline,
                                        color: Colors.white),
                                  )
                                ])),
                          ],
                        ),
                  SizedBox(height: 30),

                  /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Briefs and insights',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ocruploaded7 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      maxLines: 5,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      keyboardType: TextInputType.multiline,
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        setState(() {
                                          filekeyboard = true;
                                          ocrkeyboard = false;

                                          index = 7;
                                          focusNode10.requestFocus();
                                        });

                                        focusNode10.requestFocus();
                                      },
                                      // focusNode: focusNode1,
                                      onChanged: (value) {
                                        setState(() {
                                          summary_string = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex7,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text("References",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ))),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ocruploaded8 == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter text or scan",
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please Enter Name.';
                                      //   } else
                                      //     return null;
                                      // },
                                      onTap: () async {
                                        setState(() {
                                          ocrkeyboard = true;
                                          filekeyboard = false;
                                          index = 8;
                                        });
                                        focusNode11.requestFocus();
                                      },
                                      focusNode: focusNode11,
                                      onChanged: (value) {
                                        setState(() {
                                          otherdocs_string = value;
                                        });
                                      },
                                    ))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 110,
                                child: ListView(children: [
                                  TeXView(
                                    child: TeXViewColumn(children: [
                                      TeXViewDocument(latex8,
                                          style: TeXViewStyle(
                                            fontStyle: TeXViewFontStyle(
                                                fontSize: 6,
                                                sizeUnit: TeXViewSizeUnit.Pt),
                                            padding: TeXViewPadding.all(10),
                                          )),
                                    ]),
                                    style: TeXViewStyle(
                                      elevation: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ])),
                          ],
                        ),
                  SizedBox(height: 30),
                ]),
              ),
            ])),
            (ocrkeyboard == true)
                ? Container(
                    height: 74,
                    width: MediaQuery.of(context).size.width,
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
                                          setState(() {
                                            _showDialog(index);
                                          });
                                          // themeflag = true;
                                          // setState(() {
                                          //   themeindex = 0;
                                          // });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                                height: 50,
                                                width: 50,
                                                child: Image(
                                                    image: AssetImage(
                                                        "assets/ocr1.gif"))),
                                            SizedBox(height: 0.5),
                                            Text("Upload OCR",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.w500))
                                          ],
                                        )),
                                    SizedBox(width: 10),
                                    Text("Themes : ",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(width: 5),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            themeflag = true;
                                            themepath =
                                                "assets/projectbackg1.png";
                                          });
                                        },
                                        child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/projectbackg1.png"))),
                                    SizedBox(width: 8),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            themeflag = true;
                                            themepath =
                                                "assets/projectbackg2.png";
                                          });
                                        },
                                        child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/projectbackg2.png"))),
                                    SizedBox(width: 8),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            themeflag = true;
                                            themepath =
                                                "assets/projectbackg3.png";
                                          });
                                        },
                                        child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/projectbackg3.png"))),
                                    SizedBox(width: 8),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            themeflag = true;
                                            themepath =
                                                "assets/projectbackg4.png";
                                          });
                                        },
                                        child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/projectbackg4.png")))
                                  ]))
                        ]))
                // Container(
                //   color: Colors.white,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         padding: EdgeInsets.only(bottom: 10),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: [
                //             InkWell(
                //               onTap: () {},
                //               child: Container(
                //                 padding: EdgeInsets.only(
                //                     top: 10, left: 15, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/keyboard.png",
                //                       color: Colors.blue,
                //                       height: 22,
                //                       width: 21),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () async {
                //                 setState(() {});
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/videorecord.jpg",
                //                       height: 25, width: 25),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   dismissKeyboard();
                //                   showvdocontainer = false;
                //                   showimgcontainer = !showimgcontainer;
                //                   print(showimgcontainer);
                //                 });
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/gallery.png",
                //                       height: 22, width: 21),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () async {
                //                 setState(() {});
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Icon(FontAwesome5.user_tag,
                //                       size: 18, color: Colors.deepPurple),
                //                 ),
                //               ),
                //             ),

                //             //   InkWell(
                //             //     onTap: () {},
                //             //     child: Container(
                //             //       padding: EdgeInsets.only(top: 10, left: 20),
                //             //       child: Center(
                //             //         child: Text(
                //             //           "@",
                //             //           style: TextStyle(
                //             //               fontWeight: FontWeight.w700,
                //             //               fontSize: 22,
                //             //               color: Colors.black54),
                //             //         ),
                //             //       ),
                //             //     ),
                //             //   ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // )

                : SizedBox(),
            (filekeyboard == true)
                ? Container(
                    height: 74,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child:
                        ListView(scrollDirection: Axis.horizontal, children: [
                      Row(
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
                                            setState(() {
                                              _showDialog(index);
                                            });
                                            // themeflag = true;
                                            // setState(() {
                                            //   themeindex = 0;
                                            // });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image(
                                                      image: AssetImage(
                                                          "assets/ocr1.gif"))),
                                              SizedBox(height: 0.5),
                                              Text("Upload OCR",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500))
                                            ],
                                          )),
                                      SizedBox(width: 10),
                                      Column(children: [
                                        InkWell(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) {
                                            //       return Video_Player(
                                            //           "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                            //           projectData.docs[i].get("reqvideourl"));
                                            //     },
                                            //   ),
                                            // );
                                          },
                                          child: Material(
                                            elevation: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                height: 40,
                                                width: 40,
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
                                                        size: 20))),
                                          ),
                                        )
                                      ]),
                                      SizedBox(width: 10),
                                      Text("Themes : ",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 5),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              themeflag = true;
                                              themepath =
                                                  "assets/projectbackg1.png";
                                            });
                                          },
                                          child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/projectbackg1.png"))),
                                      SizedBox(width: 8),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              themeflag = true;
                                              themepath =
                                                  "assets/projectbackg2.png";
                                            });
                                          },
                                          child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/projectbackg2.png"))),
                                      SizedBox(width: 8),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              themeflag = true;
                                              themepath =
                                                  "assets/projectbackg3.png";
                                            });
                                          },
                                          child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/projectbackg3.png"))),
                                      SizedBox(width: 8),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              themeflag = true;
                                              themepath =
                                                  "assets/projectbackg4.png";
                                            });
                                          },
                                          child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/projectbackg4.png")))
                                    ]))
                          ])
                    ]))
                // Container(
                //   color: Colors.white,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         padding: EdgeInsets.only(bottom: 10),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: [
                //             InkWell(
                //               onTap: () {},
                //               child: Container(
                //                 padding: EdgeInsets.only(
                //                     top: 10, left: 15, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/keyboard.png",
                //                       color: Colors.blue,
                //                       height: 22,
                //                       width: 21),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () async {
                //                 setState(() {});
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/videorecord.jpg",
                //                       height: 25, width: 25),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   dismissKeyboard();
                //                   showvdocontainer = false;
                //                   showimgcontainer = !showimgcontainer;
                //                   print(showimgcontainer);
                //                 });
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Image.asset("assets/gallery.png",
                //                       height: 22, width: 21),
                //                 ),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () async {
                //                 setState(() {});
                //               },
                //               child: Container(
                //                 padding: EdgeInsets.only(top: 10, right: 15),
                //                 child: Center(
                //                   child: Icon(FontAwesome5.user_tag,
                //                       size: 18, color: Colors.deepPurple),
                //                 ),
                //               ),
                //             ),

                //             //   InkWell(
                //             //     onTap: () {},
                //             //     child: Container(
                //             //       padding: EdgeInsets.only(top: 10, left: 20),
                //             //       child: Center(
                //             //         child: Text(
                //             //           "@",
                //             //           style: TextStyle(
                //             //               fontWeight: FontWeight.w700,
                //             //               fontSize: 22,
                //             //               color: Colors.black54),
                //             //         ),
                //             //       ),
                //             //     ),
                //             //   ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // )

                : SizedBox(),
          ]));
    }
  }

  bool filekeyboard = false;
}

Future<void> _launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
    );
  } else {
    throw 'Could not launch $url';
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
