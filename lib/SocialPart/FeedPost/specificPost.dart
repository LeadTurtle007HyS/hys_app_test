import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:hys/SocialPart/FeedPost/AddCommentPage.dart';
import 'package:hys/SocialPart/network_crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hive/hive.dart';
import 'package:hys/SocialPart/Blogs/viewAllBlogs.dart';
import 'package:hys/SocialPart/ImageView/SingleImageView.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:hys/authanticate/signin.dart';
import 'package:hys/services/auth.dart';
import 'package:hys/utils/permissions.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // showNotification();
  // FlutterRingtonePlayer.play(
  //   android: AndroidSounds.notification,
  //   ios: IosSounds.glass,
  //   looping: true, // Android only - API >= 28
  //   volume: 0.8, // Android only - API >= 28
  //   asAlarm: true, // Android only - all APIs
  // );

  return null;
}

class SpecificSocialPost extends StatefulWidget {
  String post_type;
  SpecificSocialPost(this.post_type);
  @override
  _SpecificSocialPostState createState() =>
      _SpecificSocialPostState(this.post_type);
}

//event

String date1 = "";
String fromtime1 = "";
String totime1 = "";
String from;
String to;
String freq1 = "";
String eventName1 = "";
// MeetingDataSource _dataSource;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
ScrollController _scrollController;
File _image;

class _SpecificSocialPostState extends State<SpecificSocialPost> {
  String post_type;
  _SpecificSocialPostState(this.post_type);
  static const MethodChannel _channel = MethodChannel('epub_viewer');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  String _currentUserId = FirebaseAuth.instance.currentUser.uid;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _auth = AuthService();
  ScrollController _scrollController;
  bool isScrollingDown = false;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<int> indexcount = [];
  bool indexcountbool = false;
  bool flag = false;
  String eventid;
  int count;
  Map<String, int> map = Map();

  NetworkCRUD networkCRUD = NetworkCRUD();

  Future initializetimezone() async {
    tz.initializeTimeZones();
  }

  Future onSelectNotification(String payload) {
    //  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    //    return AllChatScreen(

    //    );
    //  }));
  }
  String current_datetime = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String current_time = DateTime.now().toString().substring(11, 19);
  String current_onlyDate =
      (DateFormat('yyyyMMddkkmm').format(DateTime.now())).substring(0, 8);
  String starttime = DateTime.now().toString();

  void dispose() {
    super.dispose();
  }

  NetworkCRUD networkcrud = NetworkCRUD();
  List<dynamic> allPostData = [];
  Box<dynamic> allSocialPostLocalDB;
  Box<dynamic> userDataDB;

  List<dynamic> allBIdeasPostData = [];
  List<dynamic> isBIdeasPostExpanded = [];
  List<dynamic> isBlogPostExpanded = [];
  List<dynamic> allPDiscussPostDetails = [];
  List<dynamic> allCausePostData = [];
  List<dynamic> allBlogPostData = [];
  List<dynamic> allMoodPostData = [];

  @override
  void initState() {
    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    userDataDB = Hive.box<dynamic>('userdata');
    _fetchData();
    // _scrollController = ScrollController();
    super.initState();
  }

  Future _fetchData() async {
    if (allSocialPostLocalDB.get("allpost") != null) {
      allPostData = allSocialPostLocalDB.get("allpost");
    }
    if (allSocialPostLocalDB.get("moodpost") != null) {
      allMoodPostData = allSocialPostLocalDB.get("moodpost");
    }
    if (allSocialPostLocalDB.get("blogpost") != null) {
      allBlogPostData = allSocialPostLocalDB.get("blogpost");
      for (int i = 0; i < allBlogPostData.length; i++) {
        setState(() {
          isBlogPostExpanded.add(false);
        });
      }
    }
    if (allSocialPostLocalDB.get("causepost") != null) {
      allCausePostData = allSocialPostLocalDB.get("causepost");
    }
    if (allSocialPostLocalDB.get("businesspost") != null) {
      allBIdeasPostData = allSocialPostLocalDB.get("businesspost");
      for (int i = 0; i < allBIdeasPostData.length; i++) {
        setState(() {
          isBIdeasPostExpanded.add(false);
        });
      }
    }
    if (allSocialPostLocalDB.get("projectpost") != null) {
      allPDiscussPostDetails = allSocialPostLocalDB.get("projectpost");
    }
    final List<http.Response> response = await Future.wait([
      http.get(
        Uri.parse('https://hys-api.herokuapp.com/get_all_sm_posts'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_sm_mood_posts/${_currentUserId}'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_sm_blog_posts/${_currentUserId}'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_sm_cause_posts/${_currentUserId}'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_sm_bideas_posts/${_currentUserId}'),
      ),
      http.get(
        Uri.parse(
            'https://hys-api.herokuapp.com/get_all_sm_allPDiscussPostDetails[i]s/${_currentUserId}'),
      )
    ]);
    setState(() {
      print("get_all_sm_posts: ${response[0].statusCode}");
      if ((response[0].statusCode == 200) || (response[0].statusCode == 201)) {
        allPostData = json.decode(response[0].body);
        allSocialPostLocalDB.put("allpost", json.decode(response[0].body));
      }
      print("get_all_sm_mood_posts: ${response[1].statusCode}");
      if ((response[1].statusCode == 200) || (response[1].statusCode == 201)) {
        allMoodPostData = json.decode(response[1].body);
        allSocialPostLocalDB.put("moodpost", json.decode(response[1].body));
      }
      print("get_all_sm_blog_posts: ${response[1].statusCode}");
      if ((response[2].statusCode == 200) || (response[2].statusCode == 201)) {
        allBlogPostData = json.decode(response[2].body);
        allSocialPostLocalDB.put("blogpost", json.decode(response[2].body));
        for (int i = 0; i < allBlogPostData.length; i++) {
          setState(() {
            isBlogPostExpanded.add(false);
          });
        }
      }
      print("get_all_sm_cause_posts: ${response[1].statusCode}");
      if ((response[3].statusCode == 200) || (response[3].statusCode == 201)) {
        allCausePostData = json.decode(response[3].body);
        allSocialPostLocalDB.put("causepost", json.decode(response[3].body));
      }
      print("get_all_sm_BIdeas_posts: ${response[1].statusCode}");
      if ((response[4].statusCode == 200) || (response[4].statusCode == 201)) {
        setState(() {
          allBIdeasPostData = json.decode(response[4].body);
          allSocialPostLocalDB.put(
              "businesspost", json.decode(response[4].body));
        });
        for (int i = 0; i < allBIdeasPostData.length; i++) {
          setState(() {
            isBIdeasPostExpanded.add(false);
          });
        }
      }
      if ((response[5].statusCode == 200) || (response[5].statusCode == 201)) {
        setState(() {
          allPDiscussPostDetails = json.decode(response[5].body);
          allSocialPostLocalDB.put(
              "projectpost", json.decode(response[5].body));
        });
      }
    });
  }

  var rng = new Random();
  List<String> _scrollImg = [
    "assets/shortcuts/mood.png",
    "assets/shortcuts/blog1.png",
    "assets/shortcuts/cause1.png",
    "assets/shortcuts/helpgroup.png",
    "assets/shortcuts/podcast.png",
    "assets/shortcuts/rebel.png",
    "assets/shortcuts/books.png",
    "assets/shortcuts/businessideas.png",
    "assets/shortcuts/examq.png",
    "assets/shortcuts/projects1.png",
    "assets/shortcuts/uploads.png",
    "assets/shortcuts/talents.png",
    "assets/shortcuts/predictq.png",
  ];

  List<String> _scrollName = [
    "Feelings",
    "Blog",
    "Cause",
    "Help Group",
    "Podcast",
    "Rebel",
    "Discuss",
    "Ideas",
    "Discuss",
    "Projects",
    "Uploads",
    "Showcase",
    "Predict",
  ];

  List<String> _scrollPostType = [
    "Mood",
    "blog",
    "EventUnderprivilegeByTeaching",
    "Helpgroup",
    "podcast",
    "rebel",
    "books",
    "businessideas",
    "examq",
    "projectdiscuss",
    "uploads",
    "talent",
    "predict"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      // drawer: _drawer(),
      appBar: AppBar(
        backgroundColor: Color(0xEFFFFFFF),
        elevation: 0.0,
        centerTitle: false,
        leading: Container(
            margin: EdgeInsets.all(9),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87))),
      ),
      body: _body(),
    );
  }

  Future<void> _pullRefresh() async {
    _fetchData();
  }

  _body() {
    if (allPostData.isNotEmpty) {
      return Container(
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          color: Color(0xff0962ff),
          child: InViewNotifierList(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            isInViewPortCondition:
                (double deltaTop, double deltaBottom, double vpHeight) {
              return deltaTop < (0.5 * vpHeight) &&
                  deltaBottom > (0.5 * vpHeight);
            },
            itemCount: allPostData.length,
            builder: (BuildContext context, int i) {
              return InViewNotifierWidget(
                  id: '$i',
                  builder: (BuildContext context, bool isInView, Widget child) {
                    if (isInView) {}
                    return allPostData[i]["post_type"] == "Mood" &&
                            this.post_type == "Mood"
                        ? _smMoodPost(i)
                        : allPostData[i]["post_type"] == "blog" &&
                                this.post_type == "blog"
                            ? _smBlogPost(i)
                            : allPostData[i]["post_type"] == "projectdiscuss" &&
                                    this.post_type == "projectdiscuss"
                                ? _projectDiscuss(i)
                                : allPostData[i]["post_type"] ==
                                            "businessideas" &&
                                        this.post_type == "businessideas"
                                    ? _businessIdeas(i)
                                    : allPostData[i]["post_type"] ==
                                                "cause|teachunprevilagedKids" &&
                                            this.post_type ==
                                                "cause|teachunprevilagedKids"
                                        ? _smEventPost(i)
                                        : SizedBox();
                  });
            },
          ),
        ),
      );
    } else
      return _loading();
  }

  // ifIisZero() {
  //   return Column(
  //     children: [_socialFeed(0), _blog(0)],
  //   );
  // }

  Widget buildGridView(List imagesFile, int i) {
    return imagesFile.length == 1
        ? InkWell(
            onTap: () {
              if (socialfeed.docs[i].get("feedtype") == "shared") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SingleImageView(imagesFile[0], "NetworkImage")));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SingleImageView(imagesFile[0], "NetworkImage")));
              }
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

  Future<bool> checkPermission() async {
    if (!await Permissions.cameraAndMicrophonePermissionsGranted()) {
      return false;
    }
    return true;
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
                //  controller: _scrollController,
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

  _smMoodPost(int allPostIndex) {
    int i = -1;
    for (int j = 0; j < allMoodPostData.length; j++) {
      if (allMoodPostData[j]["post_id"] ==
          allPostData[allPostIndex]["post_id"]) {
        i = j;
        break;
      }
    }
    return i != -1
        ? Container(
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
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    child: CachedNetworkImage(
                                      imageUrl: allMoodPostData[i]
                                          ["profilepic"],
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
                                allMoodPostData[i]["user_mood"], i, [], []),
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
                      allMoodPostData[i]["message"],
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
                allMoodPostData[i]["image_list"].length > 0
                    ? viewAllImages(allMoodPostData[i]["image_list"])
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
                                      allMoodPostData[i]["like_count"]
                                          .toString(),
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
                                //         builder: (context) => ShowSocialFeedComments(
                                //             socialfeed.docs[i].id)));
                              },
                              child: Container(
                                child: RichText(
                                  text: TextSpan(
                                      text: allMoodPostData[i]["comment_count"]
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
                                    allMoodPostData[i]["view_count"].toString(),
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
                      allMoodPostData[i]["user_mood"] == "Need people around me"
                          ? Padding(
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
                                        FlutterReactionButtonCheck(
                                          onReactionChanged:
                                              (reaction, index, ischecked) {
                                            if (index == -1) {
                                              if (allMoodPostData[i]
                                                      ["like_type"] !=
                                                  "") {
                                                setState(() {
                                                  allMoodPostData[i]
                                                      ["like_count"]--;
                                                  allMoodPostData[i]
                                                      ["like_type"] = "";
                                                });
                                                networkCRUD
                                                    .addSmPostLikeDetailsAdvancedLogic([
                                                  "FALSE",
                                                  allMoodPostData[i]["post_id"],
                                                  _currentUserId,
                                                  "Mood",
                                                  "like",
                                                  allMoodPostData[i]
                                                          ["like_count"] -
                                                      1,
                                                  allMoodPostData[i]
                                                      ["comment_count"],
                                                  allMoodPostData[i]
                                                      ["view_count"],
                                                  allMoodPostData[i]
                                                      ["impression_count"],
                                                  allMoodPostData[i]
                                                      ["reply_count"]
                                                ]);
                                              } else {
                                                setState(() {
                                                  allMoodPostData[i]
                                                      ["like_count"]++;
                                                  allMoodPostData[i]
                                                      ["like_type"] = "like";
                                                });
                                                networkCRUD
                                                    .addSmPostLikeDetailsAdvancedLogic([
                                                  "TRUE",
                                                  allMoodPostData[i]["post_id"],
                                                  _currentUserId,
                                                  "Mood",
                                                  "like",
                                                  allMoodPostData[i]
                                                          ["like_count"] +
                                                      1,
                                                  allMoodPostData[i]
                                                      ["comment_count"],
                                                  allMoodPostData[i]
                                                      ["view_count"],
                                                  allMoodPostData[i]
                                                      ["impression_count"],
                                                  allMoodPostData[i]
                                                      ["reply_count"]
                                                ]);
                                              }
                                            } else if (index == 0) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "like";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "like",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 1) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "love";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "love",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 2) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "haha";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "haha",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 3) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "yay";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "yay",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 4) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "wow";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "wow",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 5) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "angry";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "angry",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            }
                                          },
                                          reactions: reactions,
                                          initialReaction: allMoodPostData[i]
                                                      ["like_type"] ==
                                                  "like"
                                              ? Reaction(
                                                  icon: Row(
                                                    children: [
                                                      Icon(
                                                          FontAwesome5
                                                              .thumbs_up,
                                                          color:
                                                              Color(0xff0962ff),
                                                          size: 14),
                                                      Text(
                                                        "  Like",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xff0962ff)),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : allMoodPostData[i]
                                                          ["like_type"] ==
                                                      ""
                                                  ? Reaction(
                                                      icon: Row(
                                                        children: [
                                                          Icon(
                                                              FontAwesome5
                                                                  .thumbs_up,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              size: 14),
                                                          Text(
                                                            "  Like",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black45),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : allMoodPostData[i]
                                                              ["like_type"] ==
                                                          "love"
                                                      ? reactions[1]
                                                      : allMoodPostData[i][
                                                                  "like_type"] ==
                                                              "haha"
                                                          ? reactions[2]
                                                          : allMoodPostData[i][
                                                                      "like_type"] ==
                                                                  "yay"
                                                              ? reactions[3]
                                                              : allMoodPostData[
                                                                              i]
                                                                          [
                                                                          "like_type"] ==
                                                                      "wow"
                                                                  ? reactions[4]
                                                                  : reactions[
                                                                      5],
                                          selectedReaction: Reaction(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(FontAwesome5.phone_alt,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                                      setState(() {
                                        allMoodPostData[i]["post_type"] =
                                            "Mood";
                                        allMoodPostData[i]["comment_list"] = [];
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SocialFeedAddComments(
                                                      [allMoodPostData[i]])));
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
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             ShareFeedPost(
                                      //                 socialfeed.docs[i].id)));
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
                            )
                          : Padding(
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
                                        FlutterReactionButtonCheck(
                                          onReactionChanged:
                                              (reaction, index, ischecked) {
                                            if (index == -1) {
                                              if (allMoodPostData[i]
                                                      ["like_type"] !=
                                                  "") {
                                                setState(() {
                                                  allMoodPostData[i]
                                                      ["like_count"]--;
                                                  allMoodPostData[i]
                                                      ["like_type"] = "";
                                                });
                                                networkCRUD
                                                    .addSmPostLikeDetailsAdvancedLogic([
                                                  "FALSE",
                                                  allMoodPostData[i]["post_id"],
                                                  _currentUserId,
                                                  "Mood",
                                                  "like",
                                                  allMoodPostData[i]
                                                          ["like_count"] -
                                                      1,
                                                  allMoodPostData[i]
                                                      ["comment_count"],
                                                  allMoodPostData[i]
                                                      ["view_count"],
                                                  allMoodPostData[i]
                                                      ["impression_count"],
                                                  allMoodPostData[i]
                                                      ["reply_count"]
                                                ]);
                                              } else {
                                                setState(() {
                                                  allMoodPostData[i]
                                                      ["like_count"]++;
                                                  allMoodPostData[i]
                                                      ["like_type"] = "like";
                                                });
                                                networkCRUD
                                                    .addSmPostLikeDetailsAdvancedLogic([
                                                  "TRUE",
                                                  allMoodPostData[i]["post_id"],
                                                  _currentUserId,
                                                  "Mood",
                                                  "like",
                                                  allMoodPostData[i]
                                                          ["like_count"] +
                                                      1,
                                                  allMoodPostData[i]
                                                      ["comment_count"],
                                                  allMoodPostData[i]
                                                      ["view_count"],
                                                  allMoodPostData[i]
                                                      ["impression_count"],
                                                  allMoodPostData[i]
                                                      ["reply_count"]
                                                ]);
                                              }
                                            } else if (index == 0) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "like";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "like",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 1) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "love";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "love",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 2) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "haha";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "haha",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 3) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "yay";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "yay",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 4) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "wow";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "wow",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            } else if (index == 5) {
                                              setState(() {
                                                allMoodPostData[i]
                                                    ["like_count"]++;
                                                allMoodPostData[i]
                                                    ["like_type"] = "angry";
                                              });
                                              networkCRUD
                                                  .addSmPostLikeDetailsAdvancedLogic([
                                                "TRUE",
                                                allMoodPostData[i]["post_id"],
                                                _currentUserId,
                                                "Mood",
                                                "angry",
                                                allMoodPostData[i]
                                                        ["like_count"] +
                                                    1,
                                                allMoodPostData[i]
                                                    ["comment_count"],
                                                allMoodPostData[i]
                                                    ["view_count"],
                                                allMoodPostData[i]
                                                    ["impression_count"],
                                                allMoodPostData[i]
                                                    ["reply_count"]
                                              ]);
                                            }
                                          },
                                          reactions: reactions,
                                          initialReaction: allMoodPostData[i]
                                                      ["like_type"] ==
                                                  "like"
                                              ? Reaction(
                                                  icon: Row(
                                                    children: [
                                                      Icon(
                                                          FontAwesome5
                                                              .thumbs_up,
                                                          color:
                                                              Color(0xff0962ff),
                                                          size: 14),
                                                      Text(
                                                        "  Like",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xff0962ff)),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : allMoodPostData[i]
                                                          ["like_type"] ==
                                                      ""
                                                  ? Reaction(
                                                      icon: Row(
                                                        children: [
                                                          Icon(
                                                              FontAwesome5
                                                                  .thumbs_up,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              size: 14),
                                                          Text(
                                                            "  Like",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black45),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : allMoodPostData[i]
                                                              ["like_type"] ==
                                                          "love"
                                                      ? reactions[1]
                                                      : allMoodPostData[i][
                                                                  "like_type"] ==
                                                              "haha"
                                                          ? reactions[2]
                                                          : allMoodPostData[i][
                                                                      "like_type"] ==
                                                                  "yay"
                                                              ? reactions[3]
                                                              : allMoodPostData[
                                                                              i]
                                                                          [
                                                                          "like_type"] ==
                                                                      "wow"
                                                                  ? reactions[4]
                                                                  : reactions[
                                                                      5],
                                          selectedReaction: Reaction(
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        allMoodPostData[i]["post_type"] =
                                            "Mood";
                                        allMoodPostData[i]["comment_list"] = [];
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SocialFeedAddComments(
                                                      [allMoodPostData[i]])));
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
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             ShareFeedPost(
                                      //                 socialfeed.docs[i].id)));
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
              ],
            ),
          )
        : SizedBox();
  }

  _smBlogPost(int allPostIndex) {
    int i = -1;
    for (int j = 0; j < allBlogPostData.length; j++) {
      if (allBlogPostData[j]["post_id"] ==
          allPostData[allPostIndex]["post_id"]) {
        i = j;
        break;
      }
    }
    String time = DateFormat.yMMMMd('en_US').format(DateTime.parse(
        allBlogPostData[i]["compare_date"].toString().substring(0, 8)));
    return i != -1
        ? InkWell(
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
                                            MediaQuery.of(context).size.width /
                                                10.34,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                10.34,
                                        child: CachedNetworkImage(
                                          imageUrl: allBlogPostData[i]
                                                  ["profilepic"]
                                              .toString(),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10.34,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10.34,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
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
                        isBlogPostExpanded[i] == false
                            ? allBlogPostData[i]["blog_title"]
                                        .toString()
                                        .length <
                                    40
                                ? allBlogPostData[i]["blog_title"]
                                : "${allBlogPostData[i]["blog_title"].toString().substring(0, 40)}..."
                            : allBlogPostData[i]["blog_title"],
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
                      allBlogPostData[i]['blog_title'],
                      "assets/bloglogo.png", //need changes here
                      allBlogPostData[i]['blog_intro'],
                      allBlogPostData[i]["post_id"]),
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
                                        allBlogPostData[i]["like_count"]
                                            .toString(),
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
                                  //         builder: (context) => ShowSocialFeedComments(
                                  //             socialfeed.docs[i].id)));
                                },
                                child: Container(
                                  child: RichText(
                                    text: TextSpan(
                                        text: allBlogPostData[i]
                                                ["comment_count"]
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
                                      allBlogPostData[i]["view_count"]
                                          .toString(),
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
                                          if (allBlogPostData[i]["like_type"] !=
                                              "") {
                                            setState(() {
                                              allBlogPostData[i]
                                                  ["like_count"]--;
                                              allBlogPostData[i]["like_type"] =
                                                  "";
                                            });
                                            networkCRUD
                                                .addSmPostLikeDetailsAdvancedLogic([
                                              "FALSE",
                                              allBlogPostData[i]["post_id"],
                                              _currentUserId,
                                              "blog",
                                              "like",
                                              allBlogPostData[i]["like_count"] -
                                                  1,
                                              allBlogPostData[i]
                                                  ["comment_count"],
                                              allBlogPostData[i]["view_count"],
                                              allBlogPostData[i]
                                                  ["impression_count"],
                                              allBlogPostData[i]["reply_count"]
                                            ]);
                                          } else {
                                            setState(() {
                                              allBlogPostData[i]
                                                  ["like_count"]++;
                                              allBlogPostData[i]["like_type"] =
                                                  "like";
                                            });
                                            networkCRUD
                                                .addSmPostLikeDetailsAdvancedLogic([
                                              "TRUE",
                                              allBlogPostData[i]["post_id"],
                                              _currentUserId,
                                              "blog",
                                              "like",
                                              allBlogPostData[i]["like_count"] +
                                                  1,
                                              allBlogPostData[i]
                                                  ["comment_count"],
                                              allBlogPostData[i]["view_count"],
                                              allBlogPostData[i]
                                                  ["impression_count"],
                                              allBlogPostData[i]["reply_count"]
                                            ]);
                                          }
                                        } else if (index == 0) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "like";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "like",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        } else if (index == 1) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "love";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "love",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        } else if (index == 2) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "haha";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "haha",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        } else if (index == 3) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "yay";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "yay",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        } else if (index == 4) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "wow";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "wow",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        } else if (index == 5) {
                                          setState(() {
                                            allBlogPostData[i]["like_count"]++;
                                            allBlogPostData[i]["like_type"] =
                                                "angry";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBlogPostData[i]["post_id"],
                                            _currentUserId,
                                            "blog",
                                            "angry",
                                            allBlogPostData[i]["like_count"] +
                                                1,
                                            allBlogPostData[i]["comment_count"],
                                            allBlogPostData[i]["view_count"],
                                            allBlogPostData[i]
                                                ["impression_count"],
                                            allBlogPostData[i]["reply_count"]
                                          ]);
                                        }
                                      },
                                      reactions: reactions,
                                      initialReaction: allBlogPostData[i]
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
                                                        color:
                                                            Color(0xff0962ff)),
                                                  )
                                                ],
                                              ),
                                            )
                                          : allBlogPostData[i]["like_type"] ==
                                                  ""
                                              ? Reaction(
                                                  icon: Row(
                                                    children: [
                                                      Icon(
                                                          FontAwesome5
                                                              .thumbs_up,
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
                                              : allBlogPostData[i]
                                                          ["like_type"] ==
                                                      "love"
                                                  ? reactions[1]
                                                  : allBlogPostData[i]
                                                              ["like_type"] ==
                                                          "haha"
                                                      ? reactions[2]
                                                      : allBlogPostData[i][
                                                                  "like_type"] ==
                                                              "yay"
                                                          ? reactions[3]
                                                          : allBlogPostData[i][
                                                                      "like_type"] ==
                                                                  "wow"
                                                              ? reactions[4]
                                                              : reactions[5],
                                      selectedReaction: Reaction(
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    allBlogPostData[i]["post_type"] = "blog";
                                    allBlogPostData[i]["comment_list"] = [];
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SocialFeedAddComments(
                                                  [allBlogPostData[i]])));
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
          )
        : SizedBox();
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

  _projectDiscuss(int allPostIndex) {
    int i = -1;
    for (int j = 0; j < allPDiscussPostDetails.length; j++) {
      if (allPDiscussPostDetails[j]["post_id"] ==
          allPostData[allPostIndex]["post_id"]) {
        i = j;
        break;
      }
    }
    return i != -1
        ? Container(
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
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    child: CachedNetworkImage(
                                      imageUrl: allPDiscussPostDetails[i]
                                              ["profilepic"]
                                          .toString(),
                                      width: MediaQuery.of(context).size.width /
                                          10.34,
                                      height:
                                          MediaQuery.of(context).size.width /
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            _chooseHeaderToViewSMPost(
                                "projectdiscuss", i, [], []),
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
                    child:
                        Text(allPDiscussPostDetails[i]["content"].toString())),
                SizedBox(
                  height: 5,
                ),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.3), BlendMode.dstATop),
                          image: AssetImage(allPDiscussPostDetails[i]["theme"]),
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
                                    allPDiscussPostDetails[i]["title"]
                                        .toString(),
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
                                allPDiscussPostDetails[i]["grade"].toString(),
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
                                allPDiscussPostDetails[i]["subject"].toString(),
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
                                allPDiscussPostDetails[i]["topic"].toString(),
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
                                  (allPDiscussPostDetails[i]
                                              ["projectvideourl"] !=
                                          "")
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return Video_Player(
                                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                      allPDiscussPostDetails[i]
                                                          ["projectvideourl"]);
                                                },
                                              ),
                                            );
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
                                                    color: Color(0xFFE9A81D)),
                                                child: Center(
                                                    child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(width: 5),
                                  (allPDiscussPostDetails[i]["reqvideourl"] !=
                                          "")
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return Video_Player(
                                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                      allPDiscussPostDetails[i]
                                                          ["reqvideourl"]);
                                                },
                                              ),
                                            );
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
                                                    color: Color(0xFFE9A81D)),
                                                child: Center(
                                                    child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(width: 5),
                                  (allPDiscussPostDetails[i]["otherdoc"] != "")
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
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ViewFile(
                                    //             allPDiscussPostDetails[i]["post_id"])));
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
                                      allPDiscussPostDetails[i]["like_count"]
                                          .toString(),
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
                                //         builder: (context) => ShowSocialFeedComments(
                                //             socialfeed.docs[i].id)));
                              },
                              child: Container(
                                child: RichText(
                                  text: TextSpan(
                                      text: allPDiscussPostDetails[i]
                                              ["comment_count"]
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
                                    allPDiscussPostDetails[i]["view_count"]
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
                                      if (index == -1) {
                                        if (allPDiscussPostDetails[i]
                                                ["like_type"] !=
                                            "") {
                                          setState(() {
                                            allPDiscussPostDetails[i]
                                                ["like_count"]--;
                                            allPDiscussPostDetails[i]
                                                ["like_type"] = "";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "FALSE",
                                            allPDiscussPostDetails[i]
                                                ["post_id"],
                                            _currentUserId,
                                            "projectdiscuss",
                                            "like",
                                            allPDiscussPostDetails[i]
                                                    ["like_count"] -
                                                1,
                                            allPDiscussPostDetails[i]
                                                ["comment_count"],
                                            allPDiscussPostDetails[i]
                                                ["view_count"],
                                            allPDiscussPostDetails[i]
                                                ["impression_count"],
                                            allPDiscussPostDetails[i]
                                                ["reply_count"]
                                          ]);
                                        } else {
                                          setState(() {
                                            allPDiscussPostDetails[i]
                                                ["like_count"]++;
                                            allPDiscussPostDetails[i]
                                                ["like_type"] = "like";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allPDiscussPostDetails[i]
                                                ["post_id"],
                                            _currentUserId,
                                            "projectdiscuss",
                                            "like",
                                            allPDiscussPostDetails[i]
                                                    ["like_count"] +
                                                1,
                                            allPDiscussPostDetails[i]
                                                ["comment_count"],
                                            allPDiscussPostDetails[i]
                                                ["view_count"],
                                            allPDiscussPostDetails[i]
                                                ["impression_count"],
                                            allPDiscussPostDetails[i]
                                                ["reply_count"]
                                          ]);
                                        }
                                      } else if (index == 0) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "like";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "like",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      } else if (index == 1) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "love";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "love",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      } else if (index == 2) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "haha";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "haha",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      } else if (index == 3) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "yay";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "yay",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      } else if (index == 4) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "wow";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "wow",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      } else if (index == 5) {
                                        setState(() {
                                          allPDiscussPostDetails[i]
                                              ["like_count"]++;
                                          allPDiscussPostDetails[i]
                                              ["like_type"] = "angry";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allPDiscussPostDetails[i]["post_id"],
                                          _currentUserId,
                                          "projectdiscuss",
                                          "angry",
                                          allPDiscussPostDetails[i]
                                                  ["like_count"] +
                                              1,
                                          allPDiscussPostDetails[i]
                                              ["comment_count"],
                                          allPDiscussPostDetails[i]
                                              ["view_count"],
                                          allPDiscussPostDetails[i]
                                              ["impression_count"],
                                          allPDiscussPostDetails[i]
                                              ["reply_count"]
                                        ]);
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: allPDiscussPostDetails[i]
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
                                        : allPDiscussPostDetails[i]
                                                    ["like_type"] ==
                                                ""
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
                                            : allPDiscussPostDetails[i]
                                                        ["like_type"] ==
                                                    "love"
                                                ? reactions[1]
                                                : allPDiscussPostDetails[i]
                                                            ["like_type"] ==
                                                        "haha"
                                                    ? reactions[2]
                                                    : allPDiscussPostDetails[i]
                                                                ["like_type"] ==
                                                            "yay"
                                                        ? reactions[3]
                                                        : allPDiscussPostDetails[
                                                                        i][
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
                                setState(() {
                                  allPDiscussPostDetails[i]["post_type"] =
                                      "projectdiscuss";
                                  allPDiscussPostDetails[i]
                                      ["comment_list"] = [];
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SocialFeedAddComments(
                                                [allPDiscussPostDetails[i]])));
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
          )
        : SizedBox();
  }

  _businessIdeas(int allPostIndex) {
    int i = -1;
    for (int j = 0; j < allPDiscussPostDetails.length; j++) {
      if (allBIdeasPostData[j]["post_id"] ==
          allPostData[allPostIndex]["post_id"]) {
        i = j;
        break;
      }
    }
    return i != -1
        ? Container(
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
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
                                    child: CachedNetworkImage(
                                      imageUrl: allBIdeasPostData[i]
                                              ["profilepic"]
                                          .toString(),
                                      width: MediaQuery.of(context).size.width /
                                          10.34,
                                      height:
                                          MediaQuery.of(context).size.width /
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            _chooseHeaderToViewSMPost(
                                "businessideas", i, [], []),
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
                          image: AssetImage(allBIdeasPostData[i]["theme"]),
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
                                allBIdeasPostData[i]["title"].toString(),
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
                                    child:
                                        (allBIdeasPostData[i]["document_list"]
                                                    .length ==
                                                1)
                                            ? InkWell(
                                                onTap: () {
                                                  // PdftronFlutter.openDocument(
                                                  //     fileurl[0]);
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
                                                          child: (allBIdeasPostData[i]
                                                                          ["document_list"][0][
                                                                      "file_ext"] ==
                                                                  "pdf")
                                                              ? Icon(Icons.picture_as_pdf,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 22)
                                                              : (allBIdeasPostData[i]["document_list"][0]["file_ext"] ==
                                                                      "excel")
                                                                  ? Icon(FontAwesome5.file_excel,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 22)
                                                                  : (allBIdeasPostData[i]["document_list"][0]["file_ext"] ==
                                                                          "ppt")
                                                                      ? Icon(FontAwesome5.file_powerpoint,
                                                                          color: Colors.red,
                                                                          size: 22)
                                                                      : (allBIdeasPostData[i]["document_list"][0]["file_ext"] == "word")
                                                                          ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                          : SizedBox())),
                                                ),
                                              )
                                            : (allBIdeasPostData[i]
                                                            ["document_list"]
                                                        .length >
                                                    1)
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
                                                                  child: (allBIdeasPostData[i]["document_list"][0]["file_ext"] ==
                                                                          "pdf")
                                                                      ? Icon(
                                                                          Icons
                                                                              .picture_as_pdf,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              22)
                                                                      : (allBIdeasPostData[i]["document_list"][0]["file_ext"] ==
                                                                              "excel")
                                                                          ? Icon(
                                                                              FontAwesome5.file_excel,
                                                                              color: Colors.red,
                                                                              size: 22)
                                                                          : (allBIdeasPostData[i]["document_list"][0]["file_ext"] == "ppt")
                                                                              ? Icon(FontAwesome5.file_powerpoint, color: Colors.red, size: 22)
                                                                              : (allBIdeasPostData[i]["document_list"][0]["file_ext"] == "word")
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
                                                                  child: (allBIdeasPostData[i]["document_list"][1]["file_ext"] ==
                                                                          "pdf")
                                                                      ? Icon(
                                                                          Icons
                                                                              .picture_as_pdf,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              22)
                                                                      : (allBIdeasPostData[i]["document_list"][1]["file_ext"] ==
                                                                              "excel")
                                                                          ? Icon(
                                                                              FontAwesome5.file_excel,
                                                                              color: Colors.red,
                                                                              size: 22)
                                                                          : (allBIdeasPostData[i]["document_list"][1]["file_ext"] == "ppt")
                                                                              ? Icon(FontAwesome5.file_powerpoint, color: Colors.red, size: 22)
                                                                              : (allBIdeasPostData[i]["document_list"][1]["file_ext"] == "word")
                                                                                  ? Icon(FontAwesome5.file_word, color: Colors.red, size: 22)
                                                                                  : SizedBox())),
                                                        ),
                                                      ),
                                                      SizedBox(width: 7),
                                                      (allBIdeasPostData[i][
                                                                      "document_list"]
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child: Container(
                                                                    padding: EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      // color: Color(0xFFE9A81D)
                                                                    ),
                                                                    child: Center(
                                                                        child: (allBIdeasPostData[i]["document_list"][2]["file_ext"] == "pdf")
                                                                            ? Icon(Icons.picture_as_pdf, color: Colors.red, size: 22)
                                                                            : (allBIdeasPostData[i]["document_list"][2]["file_ext"] == "excel")
                                                                                ? Icon(FontAwesome5.file_excel, color: Colors.red, size: 22)
                                                                                : (allBIdeasPostData[i]["document_list"][2]["file_ext"] == "ppt")
                                                                                    ? Icon(FontAwesome5.file_powerpoint, color: Colors.red, size: 22)
                                                                                    : (allBIdeasPostData[i]["document_list"][2]["file_ext"] == "word")
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
                                    //             allBIdeasPostData[i]["post_id"])));
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
                                      allBIdeasPostData[i]["like_count"]
                                          .toString(),
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
                                //         builder: (context) => ShowSocialFeedComments(
                                //             socialfeed.docs[i].id)));
                              },
                              child: Container(
                                child: RichText(
                                  text: TextSpan(
                                      text: allBIdeasPostData[i]
                                              ["comment_count"]
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
                                    allBIdeasPostData[i]["view_count"]
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
                                      if (index == -1) {
                                        if (allBIdeasPostData[i]["like_type"] !=
                                            "") {
                                          setState(() {
                                            allBIdeasPostData[i]
                                                ["like_count"]--;
                                            allBIdeasPostData[i]["like_type"] =
                                                "";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "FALSE",
                                            allBIdeasPostData[i]["post_id"],
                                            _currentUserId,
                                            "businessideas",
                                            "like",
                                            allBIdeasPostData[i]["like_count"] -
                                                1,
                                            allBIdeasPostData[i]
                                                ["comment_count"],
                                            allBIdeasPostData[i]["view_count"],
                                            allBIdeasPostData[i]
                                                ["impression_count"],
                                            allBIdeasPostData[i]["reply_count"]
                                          ]);
                                        } else {
                                          setState(() {
                                            allBIdeasPostData[i]
                                                ["like_count"]++;
                                            allBIdeasPostData[i]["like_type"] =
                                                "like";
                                          });
                                          networkCRUD
                                              .addSmPostLikeDetailsAdvancedLogic([
                                            "TRUE",
                                            allBIdeasPostData[i]["post_id"],
                                            _currentUserId,
                                            "businessideas",
                                            "like",
                                            allBIdeasPostData[i]["like_count"] +
                                                1,
                                            allBIdeasPostData[i]
                                                ["comment_count"],
                                            allBIdeasPostData[i]["view_count"],
                                            allBIdeasPostData[i]
                                                ["impression_count"],
                                            allBIdeasPostData[i]["reply_count"]
                                          ]);
                                        }
                                      } else if (index == 0) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "like";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "like",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      } else if (index == 1) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "love";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "love",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      } else if (index == 2) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "haha";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "haha",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      } else if (index == 3) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "yay";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "yay",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      } else if (index == 4) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "wow";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "wow",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      } else if (index == 5) {
                                        setState(() {
                                          allBIdeasPostData[i]["like_count"]++;
                                          allBIdeasPostData[i]["like_type"] =
                                              "angry";
                                        });
                                        networkCRUD
                                            .addSmPostLikeDetailsAdvancedLogic([
                                          "TRUE",
                                          allBIdeasPostData[i]["post_id"],
                                          _currentUserId,
                                          "businessideas",
                                          "angry",
                                          allBIdeasPostData[i]["like_count"] +
                                              1,
                                          allBIdeasPostData[i]["comment_count"],
                                          allBIdeasPostData[i]["view_count"],
                                          allBIdeasPostData[i]
                                              ["impression_count"],
                                          allBIdeasPostData[i]["reply_count"]
                                        ]);
                                      }
                                    },
                                    reactions: reactions,
                                    initialReaction: allBIdeasPostData[i]
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
                                        : allBIdeasPostData[i]["like_type"] ==
                                                ""
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
                                            : allBIdeasPostData[i]
                                                        ["like_type"] ==
                                                    "love"
                                                ? reactions[1]
                                                : allBIdeasPostData[i]
                                                            ["like_type"] ==
                                                        "haha"
                                                    ? reactions[2]
                                                    : allBIdeasPostData[i]
                                                                ["like_type"] ==
                                                            "yay"
                                                        ? reactions[3]
                                                        : allBIdeasPostData[i][
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
                                setState(() {
                                  allBIdeasPostData[i]["post_type"] =
                                      "businessideas";
                                  allBIdeasPostData[i]["comment_list"] = [];
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SocialFeedAddComments(
                                                [allBIdeasPostData[i]])));
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
          )
        : SizedBox();
  }

  _smEventPost(int allPostIndex) {
    int i = -1;
    for (int j = 0; j < allCausePostData.length; j++) {
      if (allCausePostData[j]["post_id"] ==
          allPostData[allPostIndex]["post_id"]) {
        i = j;
        break;
      }
    }
    bool whiteflag = false;
    if (allCausePostData[i]["themeindex"] == 0 ||
        allCausePostData[i]["themeindex"] == 2 ||
        allCausePostData[i]["themeindex"] == 4 ||
        allCausePostData[i]["themeindex"] == 5) {
      whiteflag = true;
    }
    return i != -1
        ? Container(
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
                                  child: CachedNetworkImage(
                                    imageUrl: allCausePostData[i]["profilepic"]
                                        .toString(),
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
                                    allCausePostData[i]["first_name"] +
                                        " " +
                                        allCausePostData[i]["last_name"],
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
                                      child:
                                          Image.asset('assets/causeEmoji.png')),
                                ]),
                                Row(
                                  children: [
                                    Text(
                                        'to Educate UnderPrivileged Childrens.',
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
                    allCausePostData[i]["message"],
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
                        image: AssetImage(allCausePostData[i]["theme"]),
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
                                  allCausePostData[i]["grade"],
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
                                  allCausePostData[i]["subject"],
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
                                  allCausePostData[i]["frequency"],
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
                                  allCausePostData[i]["date"],
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
                                  allCausePostData[i]["from_"] +
                                      ' to ' +
                                      allCausePostData[i]["to_"],
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
                              allCausePostData[i]["eventtype"] == "offline"
                                  ? Container(
                                      width: 150,
                                      child: Text(
                                        allCausePostData[i]["address"],
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
                              allCausePostData[i]["eventtype"] == "offline"
                                  ? InkWell(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => MapLocation(
                                        //             double.parse(
                                        //                 allCausePostData[i]["latitude"]
                                        //                     .toString()),
                                        //             double.parse(
                                        //                 allCausePostData[i]["longitude"]
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
                Text(allCausePostData[i]["eventname"],
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color.fromRGBO(88, 165, 196, 1))),
                Container(
                    child: Row(children: [
                  Text(
                      allCausePostData[i]["date"] +
                          ' ' +
                          allCausePostData[i]["from_"] +
                          ' to ' +
                          allCausePostData[i]["to_"],
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
                                            allCausePostData[i]["like_count"]
                                                .toString(),
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
                                            text: allCausePostData[i]
                                                    ["comment_count"]
                                                .toString(),
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
                                          allCausePostData[i]["view_count"]
                                              .toString(),
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
                                if (allCausePostData[i]["like_type"] != "") {
                                  setState(() {
                                    allCausePostData[i]["like_count"]--;
                                    allCausePostData[i]["like_type"] = "";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "FALSE",
                                    allCausePostData[i]["post_id"],
                                    _currentUserId,
                                    "cause|teachunprevilagedKids",
                                    "like",
                                    allCausePostData[i]["like_count"] - 1,
                                    allCausePostData[i]["comment_count"],
                                    allCausePostData[i]["view_count"],
                                    allCausePostData[i]["impression_count"],
                                    allCausePostData[i]["reply_count"]
                                  ]);
                                } else {
                                  setState(() {
                                    allCausePostData[i]["like_count"]++;
                                    allCausePostData[i]["like_type"] = "like";
                                  });
                                  networkCRUD
                                      .addSmPostLikeDetailsAdvancedLogic([
                                    "TRUE",
                                    allCausePostData[i]["post_id"],
                                    _currentUserId,
                                    "cause|teachunprevilagedKids",
                                    "like",
                                    allCausePostData[i]["like_count"] + 1,
                                    allCausePostData[i]["comment_count"],
                                    allCausePostData[i]["view_count"],
                                    allCausePostData[i]["impression_count"],
                                    allCausePostData[i]["reply_count"]
                                  ]);
                                }
                              } else if (index == 0) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "like";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "like",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              } else if (index == 1) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "love";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "love",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              } else if (index == 2) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "haha";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "haha",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              } else if (index == 3) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "yay";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "yay",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              } else if (index == 4) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "wow";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "wow",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              } else if (index == 5) {
                                setState(() {
                                  allCausePostData[i]["like_count"]++;
                                  allCausePostData[i]["like_type"] = "angry";
                                });
                                networkCRUD.addSmPostLikeDetailsAdvancedLogic([
                                  "TRUE",
                                  allCausePostData[i]["post_id"],
                                  _currentUserId,
                                  "cause|teachunprevilagedKids",
                                  "angry",
                                  allCausePostData[i]["like_count"] + 1,
                                  allCausePostData[i]["comment_count"],
                                  allCausePostData[i]["view_count"],
                                  allCausePostData[i]["impression_count"],
                                  allCausePostData[i]["reply_count"]
                                ]);
                              }
                            },
                            reactions: reactions,
                            initialReaction: allCausePostData[i]["like_type"] ==
                                    "like"
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
                                : allCausePostData[i]["like_type"] == ""
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
                                    : allCausePostData[i]["like_type"] == "love"
                                        ? reactions[1]
                                        : allCausePostData[i]["like_type"] ==
                                                "haha"
                                            ? reactions[2]
                                            : allCausePostData[i]
                                                        ["like_type"] ==
                                                    "yay"
                                                ? reactions[3]
                                                : allCausePostData[i]
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
                        setState(() {
                          allCausePostData[i]["post_type"] =
                              "cause|teachunprevilagedKids";
                          allCausePostData[i]["comment_list"] = [];
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SocialFeedAddComments(
                                    [allCausePostData[i]])));
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
            ]))
        : SizedBox();
  }

  // _podcast(int i) {
  //   String userprofilepic = "";
  //   for (int j = 0; j < allUserpersonaldata.docs.length; j++) {
  //     if (allUserpersonaldata.docs[j].get("userid") ==
  //         socialfeed.docs[i].get("userid")) {
  //       userprofilepic = allUserpersonaldata.docs[j].get("profilepic");
  //     }
  //   }
  //   return Container(
  //       padding: EdgeInsets.only(top: 5),
  //       margin: EdgeInsets.all(7),
  //       decoration: BoxDecoration(
  //           color: Color.fromRGBO(242, 246, 248, 1),
  //           borderRadius: BorderRadius.all(Radius.circular(20))),
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(left: (5.0), right: 5),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Container(
  //                   child: Row(
  //                     children: [
  //                       InkWell(
  //                         onTap: () {},
  //                         child: CircleAvatar(
  //                           child: ClipOval(
  //                             child: Container(
  //                               width:
  //                                   MediaQuery.of(context).size.width / 10.34,
  //                               height:
  //                                   MediaQuery.of(context).size.width / 10.34,
  //                               child: CachedNetworkImage(
  //                                 imageUrl: userprofilepic,
  //                                 fit: BoxFit.cover,
  //                                 placeholder: (context, url) => Container(
  //                                     height: 30,
  //                                     width: 30,
  //                                     child: Image.asset(
  //                                       "assets/loadingimg.gif",
  //                                     )),
  //                                 errorWidget: (context, url, error) =>
  //                                     Icon(Icons.error),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: 10,
  //                       ),
  //                       // _chooseHeaderAccordingToMood(
  //                       //     socialfeed.docs[i].get("feedtype"), i, [], []),
  //                     ],
  //                   ),
  //                 ),
  //                 IconButton(
  //                     icon: Icon(FontAwesome5.ellipsis_h,
  //                         color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
  //                     onPressed: () {
  //                       moreOptionsSMPostViewer(context, i);
  //                     }),
  //               ],
  //             ),
  //           ),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 image: DecorationImage(
  //                     colorFilter: new ColorFilter.mode(
  //                         Colors.black.withOpacity(0.3), BlendMode.dstATop),
  //                     image: AssetImage('assets/podcastBackground1.png'),
  //                     fit: BoxFit.cover),
  //               ),
  //               width: MediaQuery.of(context).size.width - 20,
  //               margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(10.0),
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         InkWell(
  //                             onTap: () {
  //                               Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (context) => AlbumPlayer(
  //                                           socialfeed.docs[i]
  //                                               .get('albumname'))));
  //                             },
  //                             child: Text(
  //                               socialfeed.docs[i].get('albumname'),
  //                               style: TextStyle(
  //                                 color: Colors.indigo,
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w700,
  //                               ),
  //                             )),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 3,
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           "Episode : ",
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w700,
  //                           ),
  //                         ),
  //                         Text(
  //                           socialfeed.docs[i].get('name'),
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 4,
  //                     ),
  //                     ExpandablePanel(
  //                         header: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Container(
  //                                 height: 60,
  //                                 child: Image.asset(
  //                                     'assets/wallpaperPodcast2.jpg')),
  //                             Text(
  //                               socialfeed.docs[i]
  //                                   .get('duration')
  //                                   .toString()
  //                                   .substring(0, 7),
  //                               //.substring(0, 7),
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w700,
  //                               ),
  //                             ),
  //                             InkWell(
  //                                 child: Icon(
  //                               Icons.play_circle_fill,
  //                             ))
  //                           ],
  //                         ),
  //                         expanded: _mediaPlayer(i)),
  //                   ],
  //                 ),
  //               )),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Container(
  //             padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 8.0, right: 8.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       InkWell(
  //                         onTap: () {},
  //                         child: Container(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 int.parse(countData
  //                                         .child(socialfeed.docs[i].id)
  //                                         .child("likecount")
  //                                         .value
  //                                         .toString())
  //                                     .toString(),
  //                                 style: TextStyle(
  //                                     fontFamily: 'Nunito Sans',
  //                                     color: Color.fromRGBO(205, 61, 61, 1)),
  //                               ),
  //                               SizedBox(
  //                                 width: 4,
  //                               ),
  //                               Image.asset("assets/reactions/like.png",
  //                                   height: 15, width: 15),
  //                               Image.asset("assets/reactions/laugh.png",
  //                                   height: 15, width: 15),
  //                               Image.asset("assets/reactions/wow.png",
  //                                   height: 15, width: 15),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       ShowSocialFeedComments(
  //                                           socialfeed.docs[i].id)));
  //                         },
  //                         child: Container(
  //                           child: RichText(
  //                             text: TextSpan(
  //                                 text: int.parse(countData
  //                                         .child(socialfeed.docs[i].id)
  //                                         .child("commentcount")
  //                                         .value
  //                                         .toString())
  //                                     .toString(),
  //                                 style: TextStyle(
  //                                   fontFamily: 'Nunito Sans',
  //                                   color: Color.fromRGBO(205, 61, 61, 1),
  //                                 ),
  //                                 children: <TextSpan>[
  //                                   TextSpan(
  //                                     text: ' Comments',
  //                                     style: TextStyle(
  //                                       fontFamily: 'Nunito Sans',
  //                                       fontSize: 12,
  //                                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                       fontWeight: FontWeight.w500,
  //                                     ),
  //                                   )
  //                                 ]),
  //                           ),
  //                         ),
  //                       ),
  //                       Container(
  //                         child: Row(
  //                           children: [
  //                             SizedBox(
  //                               width: 30,
  //                             ),
  //                             Text(
  //                               int.parse(countData
  //                                       .child(socialfeed.docs[i].id)
  //                                       .child("viewscount")
  //                                       .value
  //                                       .toString())
  //                                   .toString(),
  //                               style: TextStyle(
  //                                   fontFamily: 'Nunito Sans',
  //                                   color: Color.fromRGBO(205, 61, 61, 1)),
  //                             ),
  //                             SizedBox(
  //                               width: 4,
  //                             ),
  //                             Icon(FontAwesome5.eye,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                 size: 12),
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                     margin: EdgeInsets.only(left: 2, right: 2, top: 5),
  //                     color: Colors.white54,
  //                     height: 1,
  //                     width: MediaQuery.of(context).size.width),
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 8.0, right: 8.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.only(top: 15, bottom: 15),
  //                         child: Row(
  //                           children: [
  //                             FlutterReactionButtonCheck(
  //                               onReactionChanged:
  //                                   (reaction, index, ischecked) {
  //                                 setState(() {
  //                                   _reactionIndex[i] = index;
  //                                 });
  //                                 if (socialFeedPostReactionsDB.get(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id) !=
  //                                     null) {
  //                                   if (index == -1) {
  //                                     setState(() {
  //                                       _reactionIndex[i] = -2;
  //                                     });
  //                                     _notificationdb
  //                                         .deleteSocialFeedReactionsNotification(
  //                                             socialfeed.docs[i].id);
  //                                     socialFeedPostReactionsDB.delete(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id);
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) -
  //                                           1
  //                                     });
  //                                   } else {
  //                                     if (_reactionIndex[i] == 0) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0]
  //                                                   .get("profilepic"),
  //                                               socialfeed.docs[i]
  //                                                   .get("username"),
  //                                               socialfeed.docs[i]
  //                                                   .get("userid"),
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " liked your post.",
  //                                               "You got a like!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Like",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Like");
  //                                     } else if (_reactionIndex[i] == 1) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0]
  //                                                   .get("profilepic"),
  //                                               socialfeed.docs[i]
  //                                                   .get("username"),
  //                                               socialfeed.docs[i]
  //                                                   .get("userid"),
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " loved your post.",
  //                                               "You got a reaction!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Love",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Love");
  //                                     } else if (_reactionIndex[i] == 2) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0]
  //                                                   .get("profilepic"),
  //                                               socialfeed.docs[i]
  //                                                   .get("username"),
  //                                               socialfeed.docs[i]
  //                                                   .get("userid"),
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " reacted haha on your post.",
  //                                               "You got a reaction!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Haha",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Haha");
  //                                     } else if (_reactionIndex[i] == 3) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0].get(
  //                                                       "firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0].get(
  //                                                   "profilepic"),
  //                                               socialfeed.docs[i].get(
  //                                                   "username"),
  //                                               socialfeed
  //                                                   .docs[i]
  //                                                   .get("userid"),
  //                                               personaldata
  //                                                       .docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " reacted yay on your post.",
  //                                               "You got a reaction!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Yay",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Yay");
  //                                     } else if (_reactionIndex[i] == 4) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0].get(
  //                                                       "firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0].get(
  //                                                   "profilepic"),
  //                                               socialfeed.docs[i].get(
  //                                                   "username"),
  //                                               socialfeed
  //                                                   .docs[i]
  //                                                   .get("userid"),
  //                                               personaldata
  //                                                       .docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " reacted wow on your post.",
  //                                               "You got a reaction!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Wow",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Wow");
  //                                     } else if (_reactionIndex[i] == 5) {
  //                                       _notificationdb
  //                                           .socialFeedReactionsNotifications(
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname"),
  //                                               personaldata.docs[0]
  //                                                   .get("profilepic"),
  //                                               socialfeed.docs[i]
  //                                                   .get("username"),
  //                                               socialfeed.docs[i]
  //                                                   .get("userid"),
  //                                               personaldata.docs[0]
  //                                                       .get("firstname") +
  //                                                   " " +
  //                                                   personaldata.docs[0]
  //                                                       .get("lastname") +
  //                                                   " reacted angry on your post.",
  //                                               "You got a reaction!",
  //                                               current_date,
  //                                               usertokendataLocalDB.get(
  //                                                   socialfeed.docs[i]
  //                                                       .get("userid")),
  //                                               socialfeed.docs[i].id,
  //                                               i,
  //                                               "Angry",
  //                                               comparedate);
  //                                       socialFeedPostReactionsDB.put(
  //                                           _currentUserId +
  //                                               socialfeed.docs[i].id,
  //                                           "Angry");
  //                                     }
  //                                   }
  //                                 } else {
  //                                   if (_reactionIndex[i] == -1) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " liked your post.",
  //                                             "You got a like!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Like",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Like");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 0) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " liked your post.",
  //                                             "You got a like!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Like",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Like");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 1) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " loved your post.",
  //                                             "You got a reaction!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Love",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Love");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 2) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " reacted haha on your post.",
  //                                             "You got a reaction!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Haha",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Haha");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 3) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " reacted yay on your post.",
  //                                             "You got a reaction!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Yay",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Yay");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 4) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0].get(
  //                                                     "firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata
  //                                                     .docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " reacted wow on your post.",
  //                                             "You got a reaction!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Wow",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Wow");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   } else if (_reactionIndex[i] == 5) {
  //                                     _notificationdb
  //                                         .socialFeedReactionsNotifications(
  //                                             personaldata.docs[0]
  //                                                     .get("firstname") +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname"),
  //                                             personaldata.docs[0]
  //                                                 .get("profilepic"),
  //                                             socialfeed.docs[i]
  //                                                 .get("username"),
  //                                             socialfeed.docs[i].get("userid"),
  //                                             personaldata.docs[0]
  //                                                     .get("firstname") +
  //                                                 " " +
  //                                                 personaldata.docs[0]
  //                                                     .get("lastname") +
  //                                                 " reacted angry on your post.",
  //                                             "You got a reaction!",
  //                                             current_date,
  //                                             usertokendataLocalDB.get(
  //                                                 socialfeed.docs[i]
  //                                                     .get("userid")),
  //                                             socialfeed.docs[i].id,
  //                                             i,
  //                                             "Angry",
  //                                             comparedate);
  //                                     socialFeedPostReactionsDB.put(
  //                                         _currentUserId +
  //                                             socialfeed.docs[i].id,
  //                                         "Angry");
  //                                     databaseReference
  //                                         .child("sm_feeds")
  //                                         .child("reactions")
  //                                         .child(socialfeed.docs[i].id)
  //                                         .update({
  //                                       'likecount': int.parse(countData
  //                                               .child(socialfeed.docs[i].id)
  //                                               .child("likecount")
  //                                               .value
  //                                               .toString()) +
  //                                           1
  //                                     });
  //                                   }
  //                                   socialFeed.updateReactionCount(
  //                                       socialfeed.docs[i].id, {
  //                                     "likescount": int.parse(countData
  //                                         .child(socialfeed.docs[i].id)
  //                                         .child("likecount")
  //                                         .value
  //                                         .toString())
  //                                   });
  //                                 }
  //                               },
  //                               reactions: reactions,
  //                               initialReaction: _reactionIndex[i] == -1
  //                                   ? Reaction(
  //                                       icon: Row(
  //                                         children: [
  //                                           Icon(FontAwesome5.thumbs_up,
  //                                               color: Color(0xff0962ff),
  //                                               size: 14),
  //                                           Text(
  //                                             "  Like",
  //                                             style: TextStyle(
  //                                                 fontSize: 13,
  //                                                 fontWeight: FontWeight.w700,
  //                                                 color: Color(0xff0962ff)),
  //                                           )
  //                                         ],
  //                                       ),
  //                                     )
  //                                   : _reactionIndex[i] == -2
  //                                       ? Reaction(
  //                                           icon: Row(
  //                                             children: [
  //                                               Icon(FontAwesome5.thumbs_up,
  //                                                   color: Color.fromRGBO(
  //                                                       0, 0, 0, 0.8),
  //                                                   size: 14),
  //                                               Text(
  //                                                 "  Like",
  //                                                 style: TextStyle(
  //                                                     fontSize: 13,
  //                                                     fontWeight:
  //                                                         FontWeight.w700,
  //                                                     color: Colors.black45),
  //                                               )
  //                                             ],
  //                                           ),
  //                                         )
  //                                       : reactions[_reactionIndex[i]],
  //                               selectedReaction: Reaction(
  //                                 icon: Row(
  //                                   children: [
  //                                     Icon(FontAwesome5.thumbs_up,
  //                                         color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                         size: 14),
  //                                     Text(
  //                                       "  Like",
  //                                       style: TextStyle(
  //                                           fontSize: 13,
  //                                           fontWeight: FontWeight.w700,
  //                                           color: Colors.black45),
  //                                     )
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => SocialFeedAddComments(
  //                                       socialfeed.docs[i].id)));
  //                         },
  //                         child: Container(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               Icon(FontAwesome5.comment,
  //                                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                   size: 14),
  //                               Text(
  //                                 "  Comment",
  //                                 style: TextStyle(
  //                                     fontSize: 13,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.black45),
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       ShareFeedPost(socialfeed.docs[i].id)));
  //                         },
  //                         child: Container(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               Icon(FontAwesome5.share,
  //                                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                   size: 14),
  //                               Text(
  //                                 "  Share",
  //                                 style: TextStyle(
  //                                     fontSize: 13,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.black45),
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ));
  // }

  AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();
  List<bool> _mediaPlayerFlags = [];
  String podcastName = "";
  bool playflagMP = false;
  // _mediaPlayer(int index) {
  //   return Container(
  //       width: MediaQuery.of(context).size.width,
  //       child: Column(children: [
  //         audioPlayer1.builderRealtimePlayingInfos(builder: (context, infos) {
  //           print(audioPlayer1.playerState);
  //           if (audioPlayer1.playerState.valueWrapper.value ==
  //               PlayerState.stop) {
  //             _mediaPlayerFlags[index] = false;
  //           }
  //           //print("infos: $infos");
  //           /*if (infos != null) {
  //             if (infos.currentPosition == infos.duration) {
  //               setState(() {
  //                 _mediaPlayerFlags[index] = false;
  //               });
  //             }
  //           }*/
  //           return Column(children: [
  //             PositionSeekWidget(
  //               id: index,
  //               currentPosition: (_mediaPlayerFlags[index] == true)
  //                   ? infos.currentPosition
  //                   : Duration(minutes: 0, seconds: 0),
  //               duration: (_mediaPlayerFlags[index] == true)
  //                   ? infos.duration
  //                   : Duration(minutes: 0, seconds: 0),
  //               seekTo: (to) {
  //                 audioPlayer1.seek(to);
  //               },
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 8, right: 8),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   Flexible(
  //                     flex: 2,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(right: 15.0),
  //                       child: SizedBox(
  //                           height: 60,
  //                           width: 60,
  //                           child: InkWell(
  //                               onTap: () {
  //                                 audioPlayer1.seekBy(Duration(seconds: -10));
  //                               },
  //                               child: Icon(Icons.replay_10))),
  //                     ),
  //                   ),
  //                   Flexible(
  //                     flex: 2,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(right: 15.0),
  //                       child: SizedBox(
  //                           height: 60,
  //                           width: 60,
  //                           child: InkWell(
  //                               onTap: () async {
  //                                 if (audioPlayer1.isPlaying != null) {
  //                                   audioPlayer1.pause();
  //                                   setState(() {
  //                                     _mediaPlayerFlags[index] = false;
  //                                   });
  //                                 } else {
  //                                   await audioPlayer1.open(Audio.network(
  //                                       socialfeed.docs[index]
  //                                           .get('audiourl')));
  //                                   if (audioPlayer1.realtimePlayingInfos
  //                                           .valueWrapper.value !=
  //                                       null) {
  //                                     setState(() {
  //                                       _mediaPlayerFlags[index] = true;
  //                                     });
  //                                   }
  //                                 }
  //                               },
  //                               child: _mediaPlayerFlags[index] == true
  //                                   ? Icon(Icons.pause)
  //                                   : Icon(Icons.play_arrow))),
  //                     ),
  //                   ),
  //                   Flexible(
  //                     flex: 2,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(right: 15.0),
  //                       child: SizedBox(
  //                           height: 60,
  //                           width: 60,
  //                           child: InkWell(
  //                               onTap: () {
  //                                 audioPlayer1.seekBy(Duration(seconds: 10));
  //                               },
  //                               child: Icon(Icons.forward_10))),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ]);
  //         }),
  //       ]));
  // }

  // showshareFeedPost(int i) {
  //   List imagelist = socialfeed.docs[i].get("shareimagelist");
  //   String video = socialfeed.docs[i].get("sharevideolist");
  //   return Container(
  //       margin: EdgeInsets.all(5),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           border: Border.all(color: Colors.black38)),
  //       child: Column(
  //         children: [
  //           Container(
  //               padding: const EdgeInsets.only(
  //                   left: (5.0), right: 5, top: 5, bottom: 5),
  //               margin: EdgeInsets.all(5),
  //               decoration: BoxDecoration(
  //                   color: Color.fromRGBO(242, 246, 248, 1),
  //                   borderRadius: BorderRadius.all(Radius.circular(20))),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Container(
  //                         child: Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             InkWell(
  //                               onTap: () {},
  //                               child: CircleAvatar(
  //                                 child: ClipOval(
  //                                   child: Container(
  //                                     width: MediaQuery.of(context).size.width /
  //                                         10.34,
  //                                     height:
  //                                         MediaQuery.of(context).size.width /
  //                                             10.34,
  //                                     child: CachedNetworkImage(
  //                                       imageUrl: socialfeed.docs[i]
  //                                           .get("shareuserprofilepic"),
  //                                       fit: BoxFit.cover,
  //                                       placeholder: (context, url) =>
  //                                           Image.asset(
  //                                         "assets/loadingimg.gif",
  //                                       ),
  //                                       errorWidget: (context, url, error) =>
  //                                           Icon(Icons.error),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               width: 10,
  //                             ),
  //                             Container(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   _chooseShareFeedPostHeaderAccordingToMood(
  //                                       socialfeed.docs[i].get("shareusermood"),
  //                                       i),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                   InkWell(
  //                     onTap: () {},
  //                     child: Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
  //                       child: ReadMoreText(
  //                         socialfeed.docs[i].get("sharemessage"),
  //                         textAlign: TextAlign.left,
  //                         trimLines: 4,
  //                         colorClickableText: Color(0xff0962ff),
  //                         trimMode: TrimMode.Line,
  //                         trimCollapsedText: 'read more',
  //                         trimExpandedText: 'Show less',
  //                         style: TextStyle(
  //                           fontFamily: 'Nunito Sans',
  //                           fontSize: 14,
  //                           color: Color.fromRGBO(0, 0, 0, 0.8),
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                         lessStyle: TextStyle(
  //                           fontFamily: 'Nunito Sans',
  //                           fontSize: 12,
  //                           color: Color(0xff0962ff),
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                         moreStyle: TextStyle(
  //                           fontFamily: 'Nunito Sans',
  //                           fontSize: 12,
  //                           color: Color(0xff0962ff),
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                   // imagelist.length > 0
  //                   //     ? buildGridView(imagelist, i)
  //                   //     : SizedBox(),
  //                   // video.length > 0 ? showSelectedVideos(i) : SizedBox()
  //                 ],
  //               )),
  //         ],
  //       ));
  // }

  // _chooseShareFeedPostHeaderAccordingToMood(String mood, int i) {
  //   List selectedUserName = socialfeed.docs[i].get("sharetagedusername");
  //   List selectedUserID = socialfeed.docs[i].get("sharetageduserid");
  //   String gender =
  //       socialfeed.docs[i].get("sharegender") == "Male" ? "him" : "her";
  //   String celebrategender =
  //       socialfeed.docs[i].get("sharegender") == "Male" ? "his" : "her";
  //   if (mood == "") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Excited") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           RichText(
  //             text: TextSpan(
  //                 text: "is feeling ",
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 12,
  //                   color: Color.fromRGBO(0, 0, 0, 0.7),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: 'excited ',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: 'with ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: selectedUserName[0],
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 1))
  //                       ? TextSpan(
  //                           text: ' and ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} others',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length == 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} other',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                 ]),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Good") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           RichText(
  //             text: TextSpan(
  //                 text: "is feeling ",
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 12,
  //                   color: Color.fromRGBO(0, 0, 0, 0.7),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: 'good ',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: 'with ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: selectedUserName[0],
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 1))
  //                       ? TextSpan(
  //                           text: ' and ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} others',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length == 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} other',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                 ]),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Need people around me") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               RichText(
  //                 text: TextSpan(
  //                     text: "need people around $gender ",
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w400,
  //                     ),
  //                     children: <TextSpan>[
  //                       ((selectedUserName != null) &&
  //                               (selectedUserName.length > 0))
  //                           ? TextSpan(
  //                               text: 'with ',
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 12,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.7),
  //                                 fontWeight: FontWeight.w400,
  //                               ),
  //                             )
  //                           : TextSpan(),
  //                       ((selectedUserName != null) &&
  //                               (selectedUserName.length > 0))
  //                           ? TextSpan(
  //                               text: selectedUserName[0],
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 12,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             )
  //                           : TextSpan(),
  //                       ((selectedUserName != null) &&
  //                               (selectedUserName.length > 1))
  //                           ? TextSpan(
  //                               text: ' and ',
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 12,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.7),
  //                                 fontWeight: FontWeight.w400,
  //                               ),
  //                             )
  //                           : TextSpan(),
  //                       ((selectedUserName != null) &&
  //                               (selectedUserName.length > 2))
  //                           ? TextSpan(
  //                               text: '${selectedUserName.length - 1} others',
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 12,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             )
  //                           : TextSpan(),
  //                       ((selectedUserName != null) &&
  //                               (selectedUserName.length == 2))
  //                           ? TextSpan(
  //                               text: '${selectedUserName.length - 1} other',
  //                               style: TextStyle(
  //                                 fontFamily: 'Nunito Sans',
  //                                 fontSize: 12,
  //                                 color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             )
  //                           : TextSpan(),
  //                     ]),
  //               ),
  //               Image.asset("assets/reactions/sadf.gif", height: 22, width: 22),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Certificate") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           RichText(
  //             text: TextSpan(
  //                 text: "is celebrating $celebrategender ",
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 12,
  //                   color: Color.fromRGBO(0, 0, 0, 0.7),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: 'achievement ',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: 'with ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: selectedUserName[0],
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 1))
  //                       ? TextSpan(
  //                           text: ' and ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} others',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length == 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} other',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                 ]),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Performance") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           RichText(
  //             text: TextSpan(
  //                 text: "is celebrating $celebrategender ",
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 12,
  //                   color: Color.fromRGBO(0, 0, 0, 0.7),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: 'performance ',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: 'with ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: selectedUserName[0],
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 1))
  //                       ? TextSpan(
  //                           text: ' and ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} others',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length == 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} other',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                 ]),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (mood == "Friends") {
  //     return Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           RichText(
  //             text: TextSpan(
  //                 text: socialfeed.docs[i].get("shareusername"),
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 15,
  //                   color: Color.fromRGBO(0, 0, 0, 0.8),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: ', ${socialfeed.docs[i].get("shareuserarea")}',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.7),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   )
  //                 ]),
  //           ),
  //           Text(
  //             socialfeed.docs[i].get("shareuserschoolname") +
  //                 ", " +
  //                 "Grade " +
  //                 socialfeed.docs[i].get("shareusergrade"),
  //             style: TextStyle(
  //               fontFamily: 'Nunito Sans',
  //               fontSize: 12,
  //               color: Color.fromRGBO(0, 0, 0, 0.7),
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //           RichText(
  //             text: TextSpan(
  //                 text: "want to introduce $celebrategender ",
  //                 style: TextStyle(
  //                   fontFamily: 'Nunito Sans',
  //                   fontSize: 12,
  //                   color: Color.fromRGBO(0, 0, 0, 0.7),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                     text: 'friends ',
  //                     style: TextStyle(
  //                       fontFamily: 'Nunito Sans',
  //                       fontSize: 12,
  //                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: 'with ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 0))
  //                       ? TextSpan(
  //                           text: selectedUserName[0],
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 1))
  //                       ? TextSpan(
  //                           text: ' and ',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.7),
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length > 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} others',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                   ((selectedUserName != null) &&
  //                           (selectedUserName.length == 2))
  //                       ? TextSpan(
  //                           text: '${selectedUserName.length - 1} other',
  //                           style: TextStyle(
  //                             fontFamily: 'Nunito Sans',
  //                             fontSize: 12,
  //                             color: Color.fromRGBO(0, 0, 0, 0.8),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )
  //                       : TextSpan(),
  //                 ]),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  _chooseHeaderToViewSMPost(
      String mood, int i, List selectedUserName, List selectedUserID) {
    if (mood == "") {
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender = allMoodPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allMoodPostData[i]["city"],
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
              allMoodPostData[i]["school_name"].toString().length > 25
                  ? allMoodPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString()
                  : allMoodPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allMoodPostData[i]["grade"].toString(),
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
      String gender =
          allPDiscussPostDetails[i]["gender"] == "MALE" ? "his" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allPDiscussPostDetails[i]["first_name"] +
                      " " +
                      allPDiscussPostDetails[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allPDiscussPostDetails[i]["city"],
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
              allPDiscussPostDetails[i]["school_name"].toString().length > 25
                  ? allPDiscussPostDetails[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allPDiscussPostDetails[i]["grade"].toString()
                  : allPDiscussPostDetails[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allPDiscussPostDetails[i]["grade"].toString(),
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
      String gender = allBIdeasPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allMoodPostData[i]["first_name"] +
                      " " +
                      allMoodPostData[i]["last_name"],
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
      String gender = allBlogPostData[i]["gender"] == "MALE" ? "him" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allBlogPostData[i]["first_name"] +
                      " " +
                      allBlogPostData[i]["last_name"],
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
      String gender = allBIdeasPostData[i]["gender"] == "MALE" ? "his" : "her";
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: allBIdeasPostData[i]["first_name"] +
                      " " +
                      allBIdeasPostData[i]["last_name"],
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ', ' + allBIdeasPostData[i]["city"],
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
              allBIdeasPostData[i]["school_name"].toString().length > 25
                  ? allBIdeasPostData[i]["school_name"]
                          .toString()
                          .substring(0, 25) +
                      "..., " +
                      "Grade " +
                      allBIdeasPostData[i]["grade"].toString()
                  : allBIdeasPostData[i]["school_name"].toString() +
                      "..., " +
                      "Grade " +
                      allBIdeasPostData[i]["grade"].toString(),
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
                userDataDB.get("first_name") +
                    " " +
                    userDataDB.get("last_name"),
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              accountEmail: new Text(
                userDataDB.get("email_id"),
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              currentAccountPicture: InkWell(
                onTap: () {},
                child: CircleAvatar(
                  child: ClipOval(
                    child: Container(
                      width: 70,
                      height: 70,
                      child: CachedNetworkImage(
                        imageUrl: userDataDB.get("profilepic"),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                            height: 70,
                            width: 70,
                            child: Image.asset(
                              "assets/loadingimg.gif",
                            )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
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
                // Navigator.pop(context);
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             CalendarEvent('', '', '', '', '', "")));
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
                    onTap: () async {
                      await _auth.signOut();

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()));
                    },
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
