import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/database/SocialDiscussDB.dart';
import 'package:hys/SocialPart/network_crud.dart';
import 'package:hys/navBar.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:elegant_notification/elegant_notification.dart';

int index = 0;

class NEWCreateBusiness extends StatefulWidget {
  @override
  _NEWCreateBusinessState createState() => _NEWCreateBusinessState();
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
NetworkCRUD networkCRUD = NetworkCRUD();

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
String themepath = "";
bool themeflag = false;
FocusNode focusNode10 = FocusNode();
FocusNode focusNode = FocusNode();
FocusNode focusNode11 = FocusNode();
QuerySnapshot allUserschooldata;
QuerySnapshot allUserpersonaldata;
List<String> tagedUsersName = [];

String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

class _NEWCreateBusinessState extends State<NEWCreateBusiness> {
  bool themekeyboard = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
          child: Scaffold(body: _body()),
          onTap: () {
            setState(() {
              focusNode.unfocus();
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
              themekeyboard = false;
              ocrkeyboard = false;
              filekeyboard = false;
            });
          }),
    );
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

  // Future _imgFromCamera(ImageSource source) async {
  //   final pickedFile = await picker.getImage(source: source);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //       if (_image != null) {
  //         getEventImgURL(_image);
  //       }
  //     });
  //   }
  // }

  FilePickerResult fileresult;
  List<String> fileformat = [];
  List<String> fileNames = [];
  Future _fileFromGallery(ImageSource source) async {
    fileresult = await FilePicker.platform.pickFiles(allowMultiple: true);
    print(fileresult.count);
    print(fileresult);
    if (fileresult != null) {
      uploaded = true;
      for (int i = 0; i < fileresult.count; i++) {
        PlatformFile file1 = fileresult.files[i];
        File file1_format = File(file1.path);
        String filename = file1.path.split('/').last;
        fileNames.add(filename);
        String format = filename.split('.').last;
        print(format);
        if (format == "pdf") {
          fileformat.add("pdf");
        } else if (format == "ppt" || format == "pptx") {
          fileformat.add("ppt");
        } else if (format == "xlsx" || format == "xml" || format == "xls") {
          fileformat.add("excel");
        } else if (format == "doc" || format == "docx") {
          fileformat.add("word");
        }
        await getFileURL(file1_format, i);
      }
      print(fileformat);
    }
  }

  List<dynamic> fileUrl = [];
  Future getFileURL(File _image, int i) async {
    setState(() {
      print(_image);
      socialobj.uploadEventPic(_image).then((value) {
        setState(() {
          if (value[0] == true) {
            fileUrl.add(value[1]);

            print(fileUrl);
          } else
            _showAlertDialog(value[1]);
        });
      });
    });
  }

  //dynamic imgUrl;
  // Future getEventImgURL(File _image) async {
  //   setState(() {
  //     print(_image);
  //     socialobj.uploadEventPic(_image).then((value) {
  //       setState(() {
  //         print(value);
  //         if (value[0] == true) {
  //           imgUrl = value[1];

  //           imgFlag = false;
  //           print(imgUrl);
  //         } else
  //           _showAlertDialog(value[1]);
  //       });
  //     });
  //   });
  // }
// Future uploadSocialFeedVideo(ImageSource source, int i) async {
//     String path = "";
//     final file = await picker.getVideo(
//         source: source, maxDuration: Duration(minutes: 15));
//     if (file == null) {
//       return;
//     }
//     finalVideos = file.path;
//     // _onControllerChange(file.path);
//     await VideoCompress.setLogLevel(0);
//     final info = await VideoCompress.compressVideo(
//       file.path,
//       quality: VideoQuality.LowQuality,
//       deleteOrigin: false,
//       includeAudio: true,
//     );
//     print(info.path);
//     if (info != null) {
//       setState(() {
//         path = info.path;
//         Fluttertoast.showToast(
//             msg: "Video compressed successfully",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 10,
//             backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//             textColor: Colors.white,
//             fontSize: 12.0);
//       });
//     }

//     print(path);
//     if (path != "") {
//       if (i == 1) {
//         socialobj.uploadProjectVideo(path).then((value) {
//           setState(() {
//             print(value);
//             if (value[0] == true) {
//               print(value[1]);
//               finalVideosUrl1 = value[1];

//               Fluttertoast.showToast(
//                   msg: "Video uploaded successfully",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   timeInSecForIosWeb: 10,
//                   backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                   textColor: Colors.white,
//                   fontSize: 12.0);
//               getThumbnail(finalVideosUrl1, i);
//               //Navigator.pop(context);

//             } else
//               _showAlertDialog(value[1]);
//           });
//         });
//       } else if (i == 2) {
//         socialobj.uploadProjectVideo(path).then((value) {
//           setState(() {
//             print(value);
//             if (value[0] == true) {
//               print(value[1]);
//               finalVideosUrl2 = value[1];

//               Fluttertoast.showToast(
//                   msg: "Video uploaded successfully",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   timeInSecForIosWeb: 10,
//                   backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                   textColor: Colors.white,
//                   fontSize: 12.0);
//               getThumbnail(finalVideosUrl2, i);
//               //Navigator.pop(context);

//             } else
//               _showAlertDialog(value[1]);
//           });
//         });
//       }
//     }
//   }
// getThumbnail(String videURL, int i) async {
//     final fileName = await VideoThumbnail.thumbnailFile(
//       video: videURL,
//       thumbnailPath: (await getTemporaryDirectory()).path,
//       imageFormat: ImageFormat.WEBP,
//       maxHeight:
//           200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//       quality: 30,
//     );
//     print(fileName);
//     if (i == 1) {
//       socialobj.uploadSocialMediaFeedImages(File(fileName)).then((value) {
//         setState(() {
//           print(value);
//           if (value[0] == true) {
//             thumbURL1 = value[1];
//             videoUploaded1 = true;

//             Fluttertoast.showToast(
//                 msg: "Video thumbnail created successfully",
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 timeInSecForIosWeb: 10,
//                 backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                 textColor: Colors.white,
//                 fontSize: 12.0);
//           } else
//             _showAlertDialog(value[1]);
//         });
//       });
//     } else if (i == 2) {
//       socialobj.uploadSocialMediaFeedImages(File(fileName)).then((value) {
//         setState(() {
//           print(value);
//           if (value[0] == true) {
//             thumbURL2 = value[1];
//             videoUploaded2 = true;

//             Fluttertoast.showToast(
//                 msg: "Video thumbnail created successfully",
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 timeInSecForIosWeb: 10,
//                 backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                 textColor: Colors.white,
//                 fontSize: 12.0);
//           } else
//             _showAlertDialog(value[1]);
//         });
//       });
//     }
//   }

//   void _showVideoDialog(int i) {
//     AlertDialog alertDialog = AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       content: Container(
//         height: 100,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 15,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           uploadSocialFeedVideo(ImageSource.camera, i);
//                         });
//                         Navigator.pop(context);
//                       },
//                       icon: Tab(
//                           child: Icon(Icons.camera_enhance_sharp,
//                               color: Color(0xff0962ff), size: 40)),
//                     ),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       "Camera",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color(0xff0C2551),
//                         fontWeight: FontWeight.w700,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           uploadSocialFeedVideo(ImageSource.gallery, i);
//                         });
//                         Navigator.pop(context);
//                       },
//                       icon: Tab(
//                           child: Icon(Icons.image,
//                               color: Color(0xff0962ff), size: 40)),
//                     ),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       "Gallery",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color(0xff0C2551),
//                         fontWeight: FontWeight.w700,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//     showDialog(context: context, builder: (_) => alertDialog);
//   }

//   void _initController(String link) {
//     _controller = VideoPlayerController.file(File(link))
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.setLooping(false);
//         _controller.play();
//       });
//   }

//   Future<void> _onControllerChange(String link) async {
//     if (_controller == null) {
//       // If there was no controller, just create a new one
//       _initController(link);
//     } else {
//       // If there was a controller, we need to dispose of the old one first
//       final oldController = _controller;

//       // Registering a callback for the end of next frame
//       // to dispose of an old controller
//       // (which won't be used anymore after calling setState)
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         oldController.pause();
//         await oldController.dispose();

//         // Initing new controller
//         _initController(link);
//       });

//       // Making sure that controller is not used by setting it to null
//       setState(() {
//         _controller = null;
//       });
//     }
//   }

  String title = "";
  String identification = "";

  String solution = "";

  String target = "";

  String competitors = "";

  String swot = "";
  String strategy = "";
  String funds = "";
  String content = "";
  String members = "";
  bool ocrkeyboard = false;

  dynamic videourl;
  dynamic reqvideourl;
  File summary;
  File otherdocs;
  String topic = "";
  bool topicflag = false;
  int totalDoc = 0;
  List<String> finalTagedString = [];
  bool filekeyboard = false;

  String _error = 'No Error Dectected';
  // VideoPlayerController _controller;
  // String thumbURL1 = "";
  // String thumbURL2 = "";

  // String finalVideos = "";
  // String finalVideosUrl1 = "";
  // String finalVideosUrl2 = "";
  // bool videoUploaded1 = false;
  // bool videoUploaded2 = false;

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

  List<dynamic> userDatainit = [];
  Map<dynamic, dynamic> userData = {};
  Box<dynamic> userDataDB;
  Box<dynamic> allSocialPostLocalDB;
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
  List<dynamic> allBIdeasPostData = [];
  String _currentUserId = "";
  @override
  void initState() {
    _currentUserId = FirebaseAuth.instance.currentUser.uid;
    userDataDB = Hive.box<dynamic>('userdata');
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    allPostData = allSocialPostLocalDB.get("allpost");
    allBIdeasPostData = allSocialPostLocalDB.get("businesspost");
    _get_userData();
    _get_all_users_data_for_tagging();

    super.initState();
  }

  void _call_apis() {
    _get_all_users_data_for_tagging();
    // _get_all_attached_images();
    // _get_all_attached_videos();
    // _get_all_tagged_users();
    // _get_all_post_details();
    // _get_all_blog_post_details();
    // _get_all_mood_post_details();
    // _get_all_comment_post_details();
    // _get_all_reply_post_details();
    // _get_all_cause_post_details();
    // _get_all_bideas_post_details();
    // _get_all_project_post_details();
  }

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

  _body() {
    if ((userDataDB != null)) {
      return Column(children: [
        Expanded(
            child: SingleChildScrollView(
          child: Column(children: [
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
                            builder: (context) => BottomNavigationBarWidget()));
                  },
                  icon: Tab(
                      child:
                          Icon(Icons.cancel, color: Colors.black45, size: 20)),
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
                          tagids.add(test1.substring(4, test1.indexOf("__]")));
                        }
                      }
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
                      bool ispostIDCreated = await networkCRUD
                          .addsmPostDetails([
                        postID,
                        _currentUserId,
                        "businessideas",
                        content,
                        comparedate
                      ]);
                      // allPostData
                      //     .insert(
                      //         0,
                      //         {
                      //       "first_name": userDataDB.get("first_name"),
                      //       "last_name": userDataDB.get("last_name"),
                      //       "profilepic": userDataDB.get("profilepic"),
                      //       "school_name": userDataDB.get("school_name"),
                      //       "post_id": postID,
                      //       "user_id": _currentUserId,
                      //       "post_type": "businessideas",
                      //       "comment": content,
                      //       "compare_date": comparedate
                      //     });
                      allSocialPostLocalDB.put("allpost", allPostData);
                      if (ispostIDCreated == true) {
                        if (fileUrl.isNotEmpty) {
                          for (int i = 0; i < fileUrl.length; i++) {
                            print("files uploaded in the DB of FILE");
                            isImagesPosted = await networkCRUD
                                .addsmUploadFilesDetails([
                              imgID,
                              fileUrl[i],
                              fileformat[i],
                              fileNames[i]
                            ]);
                          }
                        }
                        // if (videoList
                        //     .isNotEmpty) {
                        //   for (int i = 0;
                        //       i < videoList.length;
                        //       i++) {
                        //     isVideosPosted = await networkCRUD.addsmPostVideoDetails([
                        //       videoID,
                        //       videoList[i],
                        //       ""
                        //     ]);
                        //   }
                        // }
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
                          identification,
                          solution,
                          target,
                          competitors,
                          swot,
                          strategy,
                          funds, fileUrl.isNotEmpty ? imgID : "", "",
                          // imageList.isNotEmpty
                          //     ? imgID
                          //     : "",
                          // videoList.isNotEmpty
                          //     ? videoID
                          //     : "",
                          tagids.isNotEmpty ? userTagID : "",
                          "hyspostprivacy01",
                          0,
                          0,
                          0,
                          0,
                          comparedate
                        ];
                        isFinalPostDone = await networkCRUD
                            .addsmBusinessIdeasPostDetails(data);
                        if (isFinalPostDone == true) {
                          print("added table of business ideas");
                          // allBIdeasPostData.insert(0, {
                          //   "first_name": userDataDB.get("first_name"),
                          //   "last_name": userDataDB.get("last_name"),
                          //   "profilepic": userDataDB.get("profilepic"),
                          //   "school_name": userDataDB.get("school_name"),
                          //   "post_id": data[0],
                          //   "user_id": data[1],
                          //   "content": data[2],
                          //   "theme": data[3],
                          //   "title": data[4],
                          //   "identification": data[5],
                          //   "solution": data[6],
                          //   "target": data[7],
                          //   "competitors": data[8],
                          //   "swot": data[9],
                          //   "strategy": data[10],
                          //   "funds": data[11],
                          //   "documentlist_id": data[12],
                          //   "videolist_id": data[13],
                          //   "memberlist_id": data[14],
                          //   "privacy": data[15],
                          //   "like_count": data[16],
                          //   "comment_count": data[17],
                          //   "view_count": data[18],
                          //   "impression_count": data[19],
                          //   "compare_date": data[20]
                          // });
                          allSocialPostLocalDB.put(
                              "businesspost", allBIdeasPostData);
                          for (int k = 0; k < selectedUserflag.length; k++) {
                            setState(() {
                              selectedUserflag[k] = false;
                            });
                          }
                          _call_apis();
                          ElegantNotification.success(
                            title: Text("Congrats,"),
                            description:
                                Text("Your post created successfully."),
                          );
                        } else {
                          ElegantNotification.error(
                            title: Text("Error..."),
                            description: Text("Something wrong."),
                          );
                        }
                      }
                    }
                    setState(() {
                      processStepSM = "";

                      mood = "";
                      excited = false;
                      abletopost = false;
                      good = false;
                      needpeople = false;
                      certificate = false;
                      performance = false;
                      friends = false;
                      // imageList =
                      //     [];
                      // videoList =
                      //     [];
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
                                    height: MediaQuery.of(context).size.width /
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
                                      userDataDB.get("first_name") +
                                          ' ' +
                                          userDataDB.get("last_name"),
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(' has a Business Idea '),
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
                          setState(() {
                            focusNode.requestFocus();
                            themekeyboard = true;
                          });
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
                            hintText: 'Write about your Business Idea/Plan...',
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
                  ],
                )
              ]),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25, bottom: 10),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Fill Business Idea Details.',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 15,
                          color: Color.fromRGBO(78, 160, 193, 2),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text('Title of the idea',
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
                              hintText: "Write in not more than 50 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        child: Text('Identification of Problem',
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
                              hintText: "Write in not more than 50 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode2.requestFocus();
                          },
                          focusNode: focusNode2,
                          onChanged: (value) {
                            setState(() {
                              identification = value;
                            });
                          },
                        ))),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Your Solution to the identified problem",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 100 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode3.requestFocus();
                          },
                          focusNode: focusNode3,
                          onChanged: (value) {
                            setState(() {
                              solution = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Target Market",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 100 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode4.requestFocus();
                          },
                          focusNode: focusNode4,
                          onChanged: (value) {
                            setState(() {
                              target = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Your Competitors",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 100 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode5.requestFocus();
                          },
                          focusNode: focusNode5,
                          onChanged: (value) {
                            setState(() {
                              competitors = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("SWOT Analysis",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 100 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode6.requestFocus();
                          },
                          focusNode: focusNode6,
                          onChanged: (value) {
                            setState(() {
                              swot = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Marketing Strategy",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 100 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode7.requestFocus();
                          },
                          focusNode: focusNode7,
                          onChanged: (value) {
                            setState(() {
                              strategy = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Funds Required",
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
                          maxLines: 5,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Write in not more than 50 words.",
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Title.';
                            } else
                              return null;
                          },
                          onTap: () async {
                            focusNode8.requestFocus();
                          },
                          focusNode: focusNode8,
                          onChanged: (value) {
                            setState(() {
                              funds = value;
                            });
                          },
                        ))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Team Members",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      height: 60,
                      padding: EdgeInsets.all(2),
                      child: FlutterMentions(
                        focusNode: focusNode9,
                        key: key,
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
                          errorStyle:
                              TextStyle(color: Color.fromRGBO(240, 20, 41, 1)),
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
                          print(markuptext);
                        },
                        onTap: () {
                          focusNode9.requestFocus();
                        },
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onSuggestionVisibleChanged: (val) {
                          setState(() {
                            _showList = val;
                          });
                        },
                        onChanged: (val) {
                          setState(() {
                            members = val;
                          });
                          print(members);
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
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Upload Documents Related to plan",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                uploaded == false
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
                                        hintText:
                                            "Upload Multiple Document Here",
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    keyboardType: TextInputType.multiline,
                                    onTap: () async {
                                      setState(() {
                                        _fileFromGallery(ImageSource.gallery);
                                      });
                                    },
                                  ))),
                        ],
                      )
                    : Container(
                        child: Stack(children: [
                          Center(
                              child: Text((fileresult.count - 1).toString())),
                          Column(children: [
                            Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/fileuploadicon.png')))),
                            Text(fileresult.files[0].path.split('/').last,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))
                          ]),
                        ]),
                      ),
                SizedBox(height: 30),
              ]),
            )
          ]),
        )),
        (themekeyboard == true)
            ? Container(
                height: 74,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: ListView(scrollDirection: Axis.horizontal, children: [
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
                                          themepath = "assets/ideas1.png";
                                        });
                                      },
                                      child: CircleAvatar(
                                          backgroundImage:
                                              AssetImage("assets/ideas1.png"))),
                                  SizedBox(width: 8),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          themeflag = true;
                                          themepath = "assets/ideas2.jpg";
                                        });
                                      },
                                      child: CircleAvatar(
                                          backgroundImage:
                                              AssetImage("assets/ideas2.jpg"))),
                                  SizedBox(width: 8),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          themeflag = true;
                                          themepath = "assets/ideas3.png";
                                        });
                                      },
                                      child: CircleAvatar(
                                          backgroundImage:
                                              AssetImage("assets/ideas3.png"))),
                                  SizedBox(width: 8),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          themeflag = true;
                                          themepath = "assets/ideas4.png";
                                        });
                                      },
                                      child: CircleAvatar(
                                          backgroundImage:
                                              AssetImage("assets/ideas4.png")))
                                ]))
                      ])
                ]))
            : SizedBox(),
      ]);
    }
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
