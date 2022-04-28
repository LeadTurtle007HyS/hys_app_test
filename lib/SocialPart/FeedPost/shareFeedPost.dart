import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:hys/utils/cropper.dart';
import 'package:hys/utils/options.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:readmore/readmore.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:hys/SocialPart/ImageView/SingleImageView.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_designer/story_designer.dart';

import '../../navBar.dart';

class ShareFeedPost extends StatefulWidget {
  String feedid;
  ShareFeedPost(this.feedid);
  @override
  _ShareFeedPostState createState() => _ShareFeedPostState(this.feedid);
}

class _ShareFeedPostState extends State<ShareFeedPost> {
  String feedid;
  _ShareFeedPostState(this.feedid);

  String post = "";
  String mood = "";
  String imgUrl = "";
  bool excited = false;
  bool good = false;
  bool needpeople = false;
  bool certificate = false;
  bool performance = false;
  bool friends = false;
  bool abletopost = false;
  FocusNode focusNode;
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  QuerySnapshot socialfeed;
  CrudMethods crudobj = CrudMethods();
  SocialFeedPost socialFeed = SocialFeedPost();
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  File _image;
  File imageFile;
  final picker = ImagePicker();
  bool imageupload = false;
  bool showimgcontainer = false;
  bool showvdocontainer = false;
  QuerySnapshot allUserschooldata;
  QuerySnapshot allUserpersonaldata;
  List<File> imagesFile = <File>[];
  int feedindex = 0;
  List<String> finalImagesUrl = <String>[];
  String finalVideos = "";
  String finalVideosUrl = "";
  bool videoUploaded = false;
  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';
  VideoPlayerController _controller;
  String thumbURL = "";
  List<bool> selectedUserflag = [];
  List<String> selectedUserName = [];
  List<String> selectedUserID = [];
  var _users = [
    {
      'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
      'display': 'Vivek Sharma',
      'full_name': 'DPS | Grade 7',
      'photo':
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
    },
  ];

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

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#58a5c4",
          actionBarTitle: "Choose uploads",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
      print(images[0].identifier);
    });
  }

  Widget buildGridView() {
    return imagesFile.length == 1
        ? InkWell(
            onLongPress: () {
              setState(() {
                if (imagesFile.length == finalImagesUrl.length) {
                  _showImageEditDialog(0);
                } else {
                  _checkbothImageArraylengthDialog();
                }
              });
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SingleImageView(imagesFile[0].path, "AssetImage")));
            },
            child: Container(
              child: Image.file(
                imagesFile[0],
                // height: 300,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          )
        : Container(
            height:
                imagesFile.length > 3 ? (200 * (imagesFile.length / 3)) : 300,
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(imagesFile.length, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SingleImageView(
                                imagesFile[index].path, "AssetImage")));
                  },
                  onLongPress: () {
                    if (imagesFile.length == finalImagesUrl.length) {
                      _showImageEditDialog(index);
                    } else {
                      _checkbothImageArraylengthDialog();
                    }
                  },
                  child: Container(
                    child: Image.file(
                      imagesFile[index],
                      width: 300,
                      height: 300,
                    ),
                  ),
                );
              }),
            ),
          );
  }

  void _initController(String link) {
    _controller = VideoPlayerController.file(File(link))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(false);
        _controller.play();
      });
  }

  List<PlatformFile> platformFile = <PlatformFile>[];
  Future<void> uploadSocialFeedImagesFile() async {
    var file = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.image, allowCompression: true);
    setState(() {
      if (file != null) {
        platformFile = file.files;
        for (int i = 0; i < platformFile.length; i++) {
          imagesFile[i] = File(platformFile[i].path);
        }
      }
    });
    print("image");

    if (file != null) {
      for (int j = 0; j < imagesFile.length; j++) {
        socialFeed.uploadSocialMediaFeedImages(imagesFile[j]).then((value) {
          setState(() {
            print(value);
            if (value[0] == true) {
              imgUrl = value[1];
              print(imgUrl);
              finalImagesUrl.add(imgUrl);
              print(finalImagesUrl);
              imageupload = false;
              dismissKeyboard();
            } else
              _showAlertDialog(value[1]);
          });
        });
      }
    }
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

  Widget showSelectedVideos() {
    return Container(
      height: 300,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            SimpleGestureDetector(
              child: VideoPlayer(_controller),
              onDoubleTap: () {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              },
              onHorizontalSwipe: (direction) async {
                if (direction == SwipeDirection.left) {
                  await _controller.seekTo(
                      await _controller.position - Duration(seconds: 10));
                  setState(() {});
                } else if (direction == SwipeDirection.right) {
                  await _controller.seekTo(
                      await _controller.position + Duration(seconds: 10));
                  setState(() {});
                }
              },
            ),
            _ControlsOverlay(_controller),
            VideoProgressIndicator(_controller,
                colors: VideoProgressColors(
                    playedColor: Color.fromRGBO(88, 165, 196, 1),
                    bufferedColor: Color.fromRGBO(88, 165, 196, 1)),
                allowScrubbing: true),
          ],
        ),
      ),
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
      imagesFile.add(File(editedFile.path));
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
            finalImagesUrl.add(imgUrl);
            print(finalImagesUrl);
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
    _onControllerChange(file.path);
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

  void _showImageEditDialog(int i) {
    AlertDialog alertDialog = AlertDialog(
        backgroundColor: Color(0xFFFFFFFF),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Container(
          height: 230,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Edit Image',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Once modification of image done, you will not retrieve it.',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  if (imagesFile.length != 0) {
                    File imgFile =
                        await Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) => StoryDesigner(
                                  filePath: imagesFile[i].path,
                                )));
                    setState(() {
                      if (imgFile != null) {
                        Navigator.pop(context);
                        _showUploadDialog("Your image is processing");
                        imagesFile.removeAt(i);
                        imagesFile.insert(i, imgFile);
                        finalImagesUrl.removeAt(i);
                        socialFeed
                            .uploadSocialMediaFeedImages(imgFile)
                            .then((value) {
                          setState(() {
                            print(value);
                            if (value[0] == true) {
                              imgUrl = value[1];
                              print(imgUrl);
                              finalImagesUrl.insert(i, imgUrl);
                              dismissKeyboard();
                              Navigator.pop(context);
                            } else
                              _showAlertDialog(value[1]);
                          });
                        });
                      }
                    });
                  }
                },
                child: Container(
                  child: Text(
                    'Add text',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  if (imagesFile.length != 0) {
                    File croppedFile = await ImageCropper.cropImage(
                        sourcePath: imagesFile[i].path,
                        compressQuality: 50,
                        aspectRatioPresets: Platform.isAndroid
                            ? [CropAspectRatioPreset.square]
                            : [CropAspectRatioPreset.square],
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
                    setState(() {
                      if (croppedFile != null) {
                        Navigator.pop(context);
                        _showUploadDialog("Your image is processing");
                        imagesFile.removeAt(i);
                        imagesFile.insert(i, croppedFile);
                        finalImagesUrl.removeAt(i);
                        socialFeed
                            .uploadSocialMediaFeedImages(croppedFile)
                            .then((value) {
                          setState(() {
                            print(value);
                            if (value[0] == true) {
                              imgUrl = value[1];
                              print(imgUrl);
                              finalImagesUrl.insert(i, imgUrl);
                              dismissKeyboard();
                              Navigator.pop(context);
                            } else
                              _showAlertDialog(value[1]);
                          });
                        });
                      }
                    });
                  }
                },
                child: Container(
                  child: Text(
                    'Crop',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  if (imagesFile.length != 0) {
                    imagesFile.removeAt(i);
                    finalImagesUrl.removeAt(i);
                    print(imagesFile.length);
                    print(finalImagesUrl.length);
                    Navigator.pop(context);
                  }
                  if (imageFile != null) {
                    imageFile = null;
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
            ],
          ),
        ));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
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

  void _showUploadDialog(String message) {
    AlertDialog alertDialog = AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'),
            ),
          ],
        ),
        content: Container(
            height: 60.0,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
            ))));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  void _checkbothImageArraylengthDialog() {
    AlertDialog alertDialog = AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                "Your images are initializing to the server\nPlease try after sometime.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ],
        ),
        content: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff0962ff),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xff0962ff))),
              height: 30.0,
              width: 40,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Center(
                  child: Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)))),
        ));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  @override
  void initState() {
    focusNode = FocusNode();
    showKeyboard();
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
      crudobj.getUserSchoolData().then((value) {
        setState(() {
          schooldata = value;
        });
      });
    });
    socialFeed.getSocialFeedPosts().then((value) {
      setState(() {
        socialfeed = value;
        if (socialfeed != null) {
          for (int j = 0; j < socialfeed.docs.length; j++) {
            if (this.feedid == socialfeed.docs[j].id) {
              feedindex = j;
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
                    selectedUserflag.add(false);
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              showimgcontainer = false;
            });
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            body: _body(),
          ),
        ),
      ),
    );
  }

  _body() {
    if ((personaldata != null) &&
        (socialfeed != null) &&
        (schooldata != null) &&
        (allUserpersonaldata != null) &&
        (allUserschooldata != null)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showDiscardDialog();
                        //loadAssets();
                      },
                      icon: Tab(
                          child: Icon(MfgLabs.cancel,
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
                      onTap: () {
                        setState(() {
                          if ((finalImagesUrl.length == imagesFile.length) &&
                              (videoUploaded == false)) {
                            socialFeed.addSharedFeedPost(
                                "Mood",
                                personaldata.docs[0].get("firstname") +
                                    " " +
                                    personaldata.docs[0].get("lastname"),
                                personaldata.docs[0].get("profilepic"),
                                personaldata.docs[0].get("gender"),
                                "Delhi",
                                schooldata.docs[0].get("schoolname"),
                                schooldata.docs[0].get("grade"),
                                mood,
                                post,
                                selectedUserID,
                                selectedUserName,
                                finalVideosUrl,
                                thumbURL,
                                finalImagesUrl,
                                socialfeed.docs[feedindex].get("userid"),
                                socialfeed.docs[feedindex].get("username"),
                                socialfeed.docs[feedindex].id,
                                feedindex,
                                socialfeed.docs[feedindex]
                                    .get("userprofilepic"),
                                socialfeed.docs[feedindex].get("usergender"),
                                socialfeed.docs[feedindex].get("userarea"),
                                socialfeed.docs[feedindex]
                                    .get("userschoolname"),
                                socialfeed.docs[feedindex].get("usergrade"),
                                socialfeed.docs[feedindex].get("usermood"),
                                socialfeed.docs[feedindex].get("message"),
                                socialfeed.docs[feedindex].get("tageduserid"),
                                socialfeed.docs[feedindex].get("tagedusername"),
                                socialfeed.docs[feedindex].get("videolist"),
                                socialfeed.docs[feedindex]
                                    .get("videothumbnail"),
                                socialfeed.docs[feedindex].get("imagelist"),
                                current_date,
                                comparedate,
                                "");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavigationBarWidget(index: 1)));
                          } else {}
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            color:
                                ((finalImagesUrl.length == imagesFile.length) &&
                                        (videoUploaded == false))
                                    ? Color.fromRGBO(88, 165, 196, 1)
                                    : Colors.black12,
                            borderRadius: BorderRadius.circular(3)),
                        child: Text(
                          ((finalImagesUrl.length == imagesFile.length) &&
                                  (videoUploaded == false))
                              ? 'Post'
                              : "Wait",
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10.34,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10.34,
                                          child: Image.asset(
                                            "assets/maleicon.jpg",
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _chooseHeaderAccordingToMood(mood),
                                        InkWell(
                                          onTap: () {
                                            postshowtowhichusers(context);
                                          },
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Icon(
                                                    WebSymbols.down_micro,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 60,
                              child: TextField(
                                minLines: 2,
                                maxLines: 15,
                                focusNode: focusNode,
                                keyboardType: TextInputType.multiline,
                                cursorColor: Color.fromRGBO(88, 165, 196, 1),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400),
                                onChanged: (val) {
                                  setState(() => post = val);
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: 'How\'s your mood today?',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 17,
                                      color: Colors.black26,
                                      fontWeight: FontWeight.w800,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        ((imagesFile.length > 0))
                            ? buildGridView()
                            : SizedBox(),
                        finalVideos.length > 0
                            ? showSelectedVideos()
                            : SizedBox(),
                        showshareFeedPost(feedindex),
                        showimgcontainer == true
                            ? _imgContainer()
                            : showvdocontainer == true
                                ? _vdoContainer()
                                : SizedBox()
                      ],
                    )),
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
                        onTap: () {},
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
                          _showAllUserNameDialog(context);
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
              ],
            ),
          ),
        ],
      );
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

  Future<void> showKeyboard() async {
    focusNode.requestFocus();
  }

  Future<void> dismissKeyboard() async {
    focusNode.unfocus();
  }

  _chooseHeaderAccordingToMood(String mood) {
    String gender =
        personaldata.docs[0].get("gender") == "Male" ? "him" : "her";
    String celebrategender =
        personaldata.docs[0].get("gender") == "Male" ? "his" : "her";
    if (mood == "") {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                  text: personaldata.docs[0].get("firstname") +
                      " " +
                      personaldata.docs[0].get("lastname"),
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
              schooldata.docs[0].get("schoolname") +
                  ", " +
                  "Grade " +
                  schooldata.docs[0].get("grade"),
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
                          uploadSocialFeedImagesFile();
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

  void _showDiscardDialog() {
    AlertDialog alertDialog = AlertDialog(
        backgroundColor: Color(0xFFFFFFFF),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Container(
          height: 180,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Save this post as a draft?',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'If you discard now, you\'ll lose this post.',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    if (mood != "") {
                      if ((post != "")) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        socialFeed.addFeedPostasDraft(
                            "Mood",
                            personaldata.docs[0].get("firstname") +
                                " " +
                                personaldata.docs[0].get("firstname"),
                            personaldata.docs[0].get("profilepic"),
                            personaldata.docs[0].get("gender"),
                            "Delhi",
                            schooldata.docs[0].get("schoolname"),
                            schooldata.docs[0].get("grade"),
                            mood,
                            post,
                            finalVideosUrl,
                            thumbURL,
                            finalImagesUrl,
                            selectedUserID,
                            selectedUserName,
                            current_date,
                            comparedate,
                            "");
                      } else {}
                    } else {}
                  });
                },
                child: Container(
                  child: Text(
                    'Save Draft',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text(
                    'Discard Post',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text(
                    'Keep Editing',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 14,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
            ],
          ),
        ));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  showshareFeedPost(int i) {
    List imagelist = socialfeed.docs[i].get("imagelist");
    String video = socialfeed.docs[i].get("videolist");
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
                                        socialfeed.docs[feedindex]
                                            .get("userprofilepic"),
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
                                        socialfeed.docs[i].get("usermood"),
                                        feedindex),
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
                    SizedBox(
                      width: 10,
                    ),
                    imagelist.length > 0
                        ? buildGridViewOfSharePost(imagelist, feedindex)
                        : SizedBox(),
                    video.length > 0
                        ? showSelectedVideosOfSharePost(feedindex)
                        : SizedBox()
                  ],
                )),
          ],
        ));
  }

  Widget buildGridViewOfSharePost(List imagesFile, int i) {
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
                // controller: _scrollController,
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

  Widget showSelectedVideosOfSharePost(int i) {
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

  _chooseShareFeedPostHeaderAccordingToMood(String mood, int i) {
    List selectedUserName = socialfeed.docs[i].get("tagedusername");
    List selectedUserID = socialfeed.docs[i].get("tageduserid");
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                  text: socialfeed.docs[i].get("username"),
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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
                      text: ', ${socialfeed.docs[i].get("userarea")}',
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

  YYDialog _showAllUserNameDialog(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.center
      ..decoration = BoxDecoration(borderRadius: BorderRadius.circular(10))
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: 500,
        margin: EdgeInsets.only(left: 2, right: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Tag friends",
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 17,
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(height: 1, color: Colors.black26),
              Container(
                height: 400,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _users.length - 1,
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedUserflag[i] = !selectedUserflag[i];
                              if (selectedUserflag[i] == true) {
                                selectedUserName.add(_users[i]["display"]);
                                selectedUserID.add(_users[i]["id"]);
                              } else {
                                if (selectedUserName.length == 1) {
                                  selectedUserName.clear();
                                  selectedUserID.clear();
                                } else {
                                  for (int j = 0;
                                      j < selectedUserName.length;
                                      j++) {
                                    if (_users[i]["display"] ==
                                        selectedUserName[j]) {
                                      selectedUserName.removeAt(j);
                                      selectedUserID.removeAt(j);
                                    }
                                  }
                                }
                              }
                              print(selectedUserID);
                              print(selectedUserName);
                              Navigator.of(context).pop();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedUserflag[i] == false
                                    ? Colors.white
                                    : Color.fromRGBO(88, 165, 196, 1),
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: CircleAvatar(
                                    child: ClipOval(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                10.34,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                10.34,
                                        child: Image.network(
                                          _users[i]["photo"],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: _users[i]["display"],
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 15,
                                            color: selectedUserflag[i] == true
                                                ? Colors.white
                                                : Color.fromRGBO(0, 0, 0, 0.8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ', Delhi',
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 12,
                                                color:
                                                    selectedUserflag[i] == true
                                                        ? Colors.white
                                                        : Color.fromRGBO(
                                                            0, 0, 0, 0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ]),
                                    ),
                                    Text(
                                      _users[i]["full_name"],
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 12,
                                        color: selectedUserflag[i] == true
                                            ? Colors.white
                                            : Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(height: 1, color: Colors.black26),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ))
      ..show();
  }

  YYDialog postshowtowhichusers(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: MediaQuery.of(context).size.height - 20,
        margin: EdgeInsets.only(left: 2, right: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Tab(
                        child: Icon(MfgLabs.cancel,
                            color: Colors.black45, size: 20)),
                  ),
                  Text(
                    'Edit Audiance',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 17,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    padding:
                        EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(88, 165, 196, 1),
                        borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: Container(
                    padding: EdgeInsets.only(
                        top: 20, right: 10, left: 10, bottom: 20),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 246, 248, 1),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Who can see your post?',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'your post will appear in News Feed, on your profile and in search results',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 1,
                          color: Colors.black26,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(MfgLabs.globe,
                                color: Colors.black38, size: 25),
                            SizedBox(width: 10),
                            Container(
                                width: 312,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Public',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Anyone on or off HyS',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 13,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(FontAwesome.circle_empty,
                                            color: Colors.black45, size: 15)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.group, color: Colors.black38, size: 25),
                            SizedBox(width: 10),
                            Container(
                                width: 312,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Friends',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Your friends on HyS',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 13,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(FontAwesome.circle_empty,
                                            color: Colors.black45, size: 15)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person, color: Colors.black38, size: 25),
                            SizedBox(width: 10),
                            Container(
                                width: 312,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Friends excepts...',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Don\'t show to some friends',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 13,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(FontAwesome.circle_empty,
                                            color: Colors.black45, size: 15)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person_add,
                                color: Colors.black38, size: 25),
                            SizedBox(width: 10),
                            Container(
                                width: 312,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Specific friends',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Vivan Verma',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 13,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(FontAwesome.circle_empty,
                                            color: Colors.black45, size: 15)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ))
      ..show();
  }
}

class _ControlsOverlay extends StatefulWidget {
  VideoPlayerController controller;
  _ControlsOverlay(this.controller);
  @override
  __ControlsOverlayState createState() =>
      __ControlsOverlayState(this.controller);
}

class __ControlsOverlayState extends State<_ControlsOverlay> {
  VideoPlayerController controller;
  __ControlsOverlayState(this.controller);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black87,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
