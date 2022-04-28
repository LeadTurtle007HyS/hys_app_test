// import 'dart:io';
// import 'package:bubble/bubble.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
// import 'package:flutter_mentions/flutter_mentions.dart';
// import 'package:flutter_reaction_button/flutter_reaction_button.dart';
// import 'package:fluttericon/font_awesome5_icons.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hive/hive.dart';
// import 'package:hys/SocialPart/FeedPost/AddCommentPage.dart';
// import 'package:hys/SocialPart/FeedPost/CommentImagePage.dart';
// import 'package:hys/SocialPart/FeedPost/CommentPage.dart';
// import 'package:hys/SocialPart/ImageView/SingleImageView.dart';
// import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
// import 'package:hys/SocialPart/database/SocialMNotificationDB.dart';
// import 'package:hys/SocialPart/database/SocialMSubCommentsDB.dart';
// import 'package:hys/SocialPart/database/feedpostDB.dart';
// import 'package:hys/SocialPart/database/SocialMCommentsDB.dart';
// import 'package:hys/database/questionSection/crud.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:readmore/readmore.dart';
// import 'package:story_designer/story_designer.dart';
// import 'package:video_compress/video_compress.dart';
// import 'package:video_player/video_player.dart';
// import 'package:intl/intl.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:hys/SocialPart/FeedPost/subCommentPage.dart';

// class MultipleImagesPostInDetails extends StatefulWidget {
//   String feedID;
//   MultipleImagesPostInDetails(this.feedID);
//   @override
//   _MultipleImagesPostInDetailsState createState() =>
//       _MultipleImagesPostInDetailsState(this.feedID);
// }

// class _MultipleImagesPostInDetailsState
//     extends State<MultipleImagesPostInDetails> {
//   String feedID;
//   _MultipleImagesPostInDetailsState(this.feedID);

//   String current_date = DateTime.now().toString();
//   String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
//   QuerySnapshot personaldata;
//   QuerySnapshot schooldata;
//   CrudMethods crudobj = CrudMethods();
//   SocialFeedPost socialFeed = SocialFeedPost();
//   QuerySnapshot socialfeed;
//   SocialMCommentsDB socialFeedComment = SocialMCommentsDB();
//   String _currentUserId = FirebaseAuth.instance.currentUser.uid;
//   int feedindex = 0;
//   VideoPlayerController _controller;
//   List<bool> _videControllerStatus = [];
//   ScrollController _scrollController;
//   DataSnapshot countData;
//   DataSnapshot imageReactionCountData;
//   final databaseReference = FirebaseDatabase.instance.reference();
//   Box<dynamic> socialFeedPostReactionsDB;
//   Box<dynamic> socialFeedCommentsReactionsDB;
//   Box<dynamic> socialFeedSubCommentsReactionsDB;
//   Box<dynamic> usertokendataLocalDB;
//   List<int> _reactionIndex = [];
//   List<int> _imagereactionIndex = [];
//   SocialFeedNotification _notificationdb = SocialFeedNotification();
//   SocialMSubCommentsDB socialFeedSubComment = SocialMSubCommentsDB();
//   QuerySnapshot smReplies;
//   QuerySnapshot notificationToken;
//   QuerySnapshot smComments;
//   //QuerySnapshot commentsData;
//   QuerySnapshot allUserschooldata;
//   QuerySnapshot allUserpersonaldata;
//   String textshow = "";
//   int tagcount = 0;
//   List<String> tagids = [];
//   List<String> tagedUsersName = [];
//   String sharesubcomment = "";
//   bool imageupload = false;
//   bool showimgcontainer = false;
//   bool showvdocontainer = false;
//   FocusNode focusNode;
//   String markupptext = '';
//   String sharecomment = "";
//   String markuppcommenttext = '';
//   String comment = "";
//   List<List<int>> subcommarray = [];
//   List<bool> subcommarrayshow = [];
//   File _image;
//   File imageFile;
//   final picker = ImagePicker();
//   GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
//   GlobalKey<FlutterMentionsState> key2 = GlobalKey<FlutterMentionsState>();
//   GlobalKey<FlutterMentionsState> key3 = GlobalKey<FlutterMentionsState>();
//   bool _showList = false;
//   String imgUrl = "";
//   var _users = [
//     {
//       'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
//       'display': 'Vivek Sharma',
//       'full_name': 'DPS | Grade 7',
//       'photo':
//           'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
//     },
//   ];
//   String finalVideos = "";
//   String finalVideosUrl = "";
//   bool videoUploaded = false;
//   String _error = 'No Error Dectected';
//   String thumbURL = "";
//   File commentImageFile;
//   bool commentImg = false;
//   int calculatedfeedindex = 0;

//   getThumbnail(String videURL) async {
//     final fileName = await VideoThumbnail.thumbnailFile(
//       video: videURL,
//       thumbnailPath: (await getTemporaryDirectory()).path,
//       imageFormat: ImageFormat.WEBP,
//       maxHeight:
//           200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//       quality: 30,
//     );
//     print(fileName);
//     socialFeed.uploadSocialMediaFeedImages(File(fileName)).then((value) {
//       setState(() {
//         print(value);
//         if (value[0] == true) {
//           thumbURL = value[1];
//           videoUploaded = false;
//           print(thumbURL);
//           Fluttertoast.showToast(
//               msg: "Video thumbnail created successfully",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//               timeInSecForIosWeb: 10,
//               backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//               textColor: Colors.white,
//               fontSize: 12.0);
//         } else
//           _showAlertDialog(value[1]);
//       });
//     });
//   }

//   void _showAlertDialog(String message) {
//     AlertDialog alertDialog = AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       title: Text(
//         'Error',
//         style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Montserrat'),
//       ),
//       content: Text(
//         message,
//         style: TextStyle(
//             color: Colors.red,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Montserrat'),
//       ),
//     );
//     showDialog(context: context, builder: (_) => alertDialog);
//   }

//   @override
//   void initState() {
//     focusNode = FocusNode();
//     socialFeedPostReactionsDB = Hive.box<dynamic>('socialfeedreactions');
//     socialFeedCommentsReactionsDB =
//         Hive.box<dynamic>('socialfeedcommentsreactions');
//     socialFeedSubCommentsReactionsDB =
//         Hive.box<dynamic>('socialfeedsubcommentsreactions');
//     usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
//     _scrollController = ScrollController();
//     crudobj.getUserData().then((value) {
//       setState(() {
//         personaldata = value;
//       });
//     });
//     socialFeed.getSocialFeedPosts().then((value) {
//       setState(() {
//         socialfeed = value;
//         if (socialfeed != null) {
//           for (int i = 0; i < socialfeed.docs.length; i++) {
//             if (socialfeed.docs[i].id == this.feedID) {
//               feedindex = i;
//               print(feedindex);
//               _videControllerStatus.add(false);
//               if (socialFeedPostReactionsDB
//                       .get(_currentUserId + socialfeed.docs[i].id) !=
//                   null) {
//                 if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Like") {
//                   _reactionIndex.add(0);
//                 } else if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Love") {
//                   _reactionIndex.add(1);
//                 } else if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Haha") {
//                   _reactionIndex.add(2);
//                 } else if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Yay") {
//                   _reactionIndex.add(3);
//                 } else if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Wow") {
//                   _reactionIndex.add(4);
//                 } else if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) ==
//                     "Angry") {
//                   _reactionIndex.add(5);
//                 }
//               } else {
//                 _reactionIndex.add(-2);
//               }
//               List imagelist = socialfeed.docs[feedindex].get("imagelist");
//               for (int j = 0; j < imagelist.length; j++) {
//                 if (socialFeedPostReactionsDB
//                         .get(_currentUserId + socialfeed.docs[i].id) !=
//                     null) {
//                   if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Like") {
//                     _imagereactionIndex.add(0);
//                   } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Love") {
//                     _imagereactionIndex.add(1);
//                   } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Haha") {
//                     _imagereactionIndex.add(2);
//                   } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Yay") {
//                     _imagereactionIndex.add(3);
//                   } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Wow") {
//                     _imagereactionIndex.add(4);
//                   } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                           socialfeed.docs[i].id +
//                           j.toString()) ==
//                       "Angry") {
//                     _imagereactionIndex.add(5);
//                   }
//                 } else {
//                   _imagereactionIndex.add(-2);
//                 }
//               }
//             }
//           }
//         }
//       });
//     });
//     crudobj.getAllUserSchoolData().then((value) {
//       setState(() {
//         allUserschooldata = value;
//         crudobj.getAllUserData().then((value) {
//           setState(() {
//             allUserpersonaldata = value;
//             if ((allUserpersonaldata != null) && (allUserschooldata != null)) {
//               for (int i = 0; i < allUserpersonaldata.docs.length; i++) {
//                 for (int j = 0; j < allUserschooldata.docs.length; j++) {
//                   if (allUserpersonaldata.docs[i].get("userid") ==
//                       allUserschooldata.docs[j].get("userid")) {
//                     _users.add({
//                       'id': allUserpersonaldata.docs[i].get("userid"),
//                       'display': allUserpersonaldata.docs[i].get("firstname") +
//                           " " +
//                           allUserpersonaldata.docs[i].get("lastname"),
//                       'full_name': allUserschooldata.docs[j].get("schoolname") +
//                           " | " +
//                           allUserschooldata.docs[j].get("grade"),
//                       'photo': allUserpersonaldata.docs[i].get("profilepic")
//                     });
//                   }
//                 }
//               }
//             }
//           });
//         });
//       });
//     });
//     crudobj.getUserSchoolData().then((value) {
//       setState(() {
//         schooldata = value;
//       });
//     });
//     super.initState();
//   }

//   Future<void> showKeyboard() async {
//     FocusScope.of(context).requestFocus();
//   }

//   Future<void> dismissKeyboard() async {
//     FocusScope.of(context).unfocus();
//   }

//   String getTimeDifferenceFromNow(String dateTime) {
//     DateTime todayDate = DateTime.parse(dateTime);
//     Duration difference = DateTime.now().difference(todayDate);
//     if (difference.inSeconds < 5) {
//       return "Just now";
//     } else if (difference.inMinutes < 1) {
//       return "Just now";
//     } else if (difference.inHours < 1) {
//       return "${difference.inMinutes} m";
//     } else if (difference.inHours < 24) {
//       return "${difference.inHours} h";
//     } else {
//       return "${difference.inDays} d";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: _body(),
//       ),
//     );
//   }

//   _body() {
//     if ((socialfeed != null) &&
//         (personaldata != null) &&
//         (allUserpersonaldata != null) &&
//         (schooldata != null) &&
//         (allUserschooldata != null)) {
//       databaseReference
//           .child("sm_feeds")
//           .child("reactions")
//           .once()
//           .then((value) {
//         setState(() {
//           if (mounted) {
//             setState(() {
//               countData = value.snapshot;
//             });
//           }
//         });
//       });
//       databaseReference
//           .child("sm_feeds")
//           .child("images")
//           .once()
//           .then((value) {
//         setState(() {
//           if (mounted) {
//             setState(() {
//               imageReactionCountData = value.snapshot;
//             });
//           }
//         });
//       });
//       if ((countData != null) && (imageReactionCountData != null)) {
//         List imagelist = socialfeed.docs[feedindex].get("imagelist");
//         print(imagelist.length);
//         return Column(
//           children: [
//             Expanded(
//               child: Material(
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   itemCount: imagelist.length,
//                   itemBuilder: (BuildContext context, int j) {
//                     return j == 0
//                         ? when_I_is_Zero()
//                         : Column(
//                             children: [
//                               _socialFeedImageWithoutHeader(feedindex, j),
//                               j == imagelist.length - 1
//                                   ? SizedBox(height: 80)
//                                   : SizedBox()
//                             ],
//                           );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         );
//       } else
//         return _loading();
//     } else
//       return _loading();
//   }

//   when_I_is_Zero() {
//     return Container(
//       child: Column(
//         children: [
//           Container(
//             height: 50,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: Tab(
//                       child: Icon(Icons.arrow_back_ios_outlined,
//                           color: Colors.black45, size: 23)),
//                 )
//               ],
//             ),
//           ),
//           socialfeed.docs[feedindex].get("message") != ""
//               ? _socialFeed(feedindex)
//               : _socialFeedImageWithHeader(feedindex, 0),
//           socialfeed.docs[feedindex].get("message") != ""
//               ? _socialFeedImageWithoutHeader(feedindex, 0)
//               : SizedBox()
//         ],
//       ),
//     );
//   }

//   List<Reaction> reactions = <Reaction>[
//     Reaction(
//         id: 1,
//         previewIcon:
//             Image.asset("assets/reactions/like.gif", height: 50, width: 50),
//         icon: Row(
//           children: [
//             Icon(FontAwesome5.thumbs_up, color: Color(0xff0962ff), size: 14),
//             Text(
//               "  Like",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff0962ff)),
//             )
//           ],
//         ),
//         title: Text(
//           "Like",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//     Reaction(
//         id: 2,
//         previewIcon:
//             Image.asset("assets/reactions/love.gif", height: 50, width: 50),
//         icon: Row(
//           children: [
//             Image.asset("assets/reactions/love.png", height: 20, width: 20),
//             Text(
//               "  Love",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromRGBO(244, 8, 82, 1)),
//             )
//           ],
//         ),
//         title: Text(
//           "Love",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//     Reaction(
//         id: 3,
//         previewIcon:
//             Image.asset("assets/reactions/laugh.gif", height: 50, width: 50),
//         icon: Row(
//           children: [
//             Image.asset("assets/reactions/laugh.png", height: 20, width: 20),
//             Text(
//               "  Haha",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromRGBO(242, 177, 76, 1)),
//             )
//           ],
//         ),
//         title: Text(
//           "Haha",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//     Reaction(
//         id: 4,
//         previewIcon: Column(
//           children: [
//             SizedBox(
//               height: 5,
//             ),
//             Image.asset("assets/reactions/yay.gif", height: 40, width: 40),
//           ],
//         ),
//         icon: Row(
//           children: [
//             Image.asset("assets/reactions/yay.png", height: 20, width: 20),
//             Text(
//               "  Yay",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromRGBO(242, 177, 76, 1)),
//             )
//           ],
//         ),
//         title: Text(
//           "Yay",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//     Reaction(
//         id: 5,
//         previewIcon:
//             Image.asset("assets/reactions/wow.gif", height: 50, width: 50),
//         icon: Row(
//           children: [
//             Image.asset("assets/reactions/wow.png", height: 20, width: 20),
//             Text(
//               "  Wow",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromRGBO(242, 177, 76, 1)),
//             )
//           ],
//         ),
//         title: Text(
//           "Wow",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//     Reaction(
//         id: 5,
//         previewIcon:
//             Image.asset("assets/reactions/angry.gif", height: 50, width: 50),
//         icon: Row(
//           children: [
//             Image.asset("assets/reactions/angry.png", height: 20, width: 20),
//             Text(
//               "  Angry",
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromRGBO(222, 37, 35, 1)),
//             )
//           ],
//         ),
//         title: Text(
//           "Angry",
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         )),
//   ];

//   _socialFeed(int feedi) {
//     List tagedusername = socialfeed.docs[feedindex].get("tagedusername");
//     List tageduserid = socialfeed.docs[feedindex].get("tageduserid");

//     return Container(
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
//                               width: MediaQuery.of(context).size.width / 10.34,
//                               height: MediaQuery.of(context).size.width / 10.34,
//                               child: CachedNetworkImage(
//                                 imageUrl: socialfeed.docs[feedindex]
//                                     .get("userprofilepic"),
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
//                       _chooseHeaderAccordingToMood(
//                           socialfeed.docs[feedindex].get("usermood"),
//                           feedindex,
//                           tagedusername,
//                           tageduserid),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                     icon: Icon(FontAwesome5.ellipsis_h,
//                         color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
//                     onPressed: () {
//                       moreOptionsSMPostViewer(context, feedindex);
//                     }),
//               ],
//             ),
//           ),
//           InkWell(
//             onTap: () {},
//             child: Container(
//               width: MediaQuery.of(context).size.width - 30,
//               margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
//               child: ReadMoreText(
//                 socialfeed.docs[feedindex].get("message"),
//                 textAlign: TextAlign.left,
//                 trimLines: 4,
//                 colorClickableText: Color(0xff0962ff),
//                 trimMode: TrimMode.Line,
//                 trimCollapsedText: 'read more',
//                 trimExpandedText: 'Show less',
//                 style: TextStyle(
//                   fontFamily: 'Nunito Sans',
//                   fontSize: 14,
//                   color: Color.fromRGBO(0, 0, 0, 0.8),
//                   fontWeight: FontWeight.w400,
//                 ),
//                 lessStyle: TextStyle(
//                   fontFamily: 'Nunito Sans',
//                   fontSize: 12,
//                   color: Color(0xff0962ff),
//                   fontWeight: FontWeight.w700,
//                 ),
//                 moreStyle: TextStyle(
//                   fontFamily: 'Nunito Sans',
//                   fontSize: 12,
//                   color: Color(0xff0962ff),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
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
//                                 countData.child(socialfeed.docs[feedindex].id).child("likecount").value
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
//                                   builder: (context) => ShowSocialFeedComments(
//                                       socialfeed.docs[feedindex].id)));
//                         },
//                         child: Container(
//                           child: RichText(
//                             text: TextSpan(
//                                 text: countData
//                                     .child(socialfeed.docs[feedindex].id).child("commentcount").value
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
//                               onReactionChanged: (reaction, index, ischecked) {
//                                 setState(() {
//                                   _reactionIndex[0] = index;
//                                 });

//                                 if (socialFeedPostReactionsDB.get(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id) !=
//                                     null) {
//                                   if (index == -1) {
//                                     setState(() {
//                                       _reactionIndex[0] = -2;
//                                     });
//                                     _notificationdb
//                                         .deleteSocialFeedReactionsNotification(
//                                             socialfeed.docs[feedindex].id);
//                                     socialFeedPostReactionsDB.delete(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id);
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) -
//                                           1
//                                     });
//                                   } else {
//                                     if (_reactionIndex[0] == 0) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("userid"),
//                                               personaldata
//                                                       .docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " liked your post.",
//                                               "You got a like!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Like",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Like");
//                                     } else if (_reactionIndex[0] == 1) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("userid"),
//                                               personaldata
//                                                       .docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " loved your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Love",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Love");
//                                     } else if (_reactionIndex[0] == 2) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("userid"),
//                                               personaldata
//                                                       .docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " reacted haha on your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Haha",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Haha");
//                                     } else if (_reactionIndex[0] == 3) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[
//                                                       feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Yay",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Yay");
//                                     } else if (_reactionIndex[0] == 4) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[
//                                                       feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Wow",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Wow");
//                                     } else if (_reactionIndex[0] == 5) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotifications(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed.docs[
//                                                       feedindex]
//                                                   .get("username"),
//                                               socialfeed
//                                                   .docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               feedindex,
//                                               "Angry",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id,
//                                           "Angry");
//                                     }
//                                   }
//                                 } else {
//                                   if (_reactionIndex[0] == -1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 0) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " loved your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Love",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Love");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString())+
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 2) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted haha on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Haha",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Haha");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 3) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted yay on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Yay",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Yay");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 4) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted wow on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Wow",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Wow");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_reactionIndex[0] == 5) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotifications(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted angry on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             feedindex,
//                                             "Angry",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id,
//                                         "Angry");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("reactions")
//                                         .child(socialfeed.docs[feedindex].id)
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                               .docs[feedindex]
//                                               .id).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   }
//                                   socialFeed.updateReactionCount(
//                                       socialfeed.docs[feedindex].id, {
//                                     "likescount": countData.child(socialfeed
//                                         .docs[feedindex].id).child("likecount").value
//                                   });
//                                 }
//                               },
//                               reactions: reactions,
//                               initialReaction: _reactionIndex[0] == -1
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
//                                   : _reactionIndex[0] == -2
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
//                                                     fontWeight: FontWeight.w700,
//                                                     color: Colors.black45),
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       : reactions[_reactionIndex[0]],
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
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _socialFeedImageWithHeader(int feedi, int imageindex) {
//     List tagedusername = socialfeed.docs[feedindex].get("tagedusername");
//     List tageduserid = socialfeed.docs[feedindex].get("tageduserid");
//     List imagelist = socialfeed.docs[feedindex].get("imagelist");
//     String video = socialfeed.docs[feedindex].get("videolist");

//     return Container(
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
//                               width: MediaQuery.of(context).size.width / 10.34,
//                               height: MediaQuery.of(context).size.width / 10.34,
//                               child: CachedNetworkImage(
//                                 imageUrl: socialfeed.docs[feedindex]
//                                     .get("userprofilepic"),
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
//                       _chooseHeaderAccordingToMood(
//                           socialfeed.docs[feedindex].get("usermood"),
//                           feedindex,
//                           tagedusername,
//                           tageduserid),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                     icon: Icon(FontAwesome5.ellipsis_h,
//                         color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
//                     onPressed: () {
//                       moreOptionsSMPostViewer(context, feedindex);
//                     }),
//               ],
//             ),
//           ),
//           buildGridView(imagelist[imageindex]),
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
//                                 imageReactionCountData.child(
//                                         socialfeed.docs[feedindex].id +
//                                             imageindex.toString()).child("likecount").value
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
//                                   builder: (context) => ShowSocialFeedComments(
//                                       socialfeed.docs[feedindex].id)));
//                         },
//                         child: Container(
//                           child: RichText(
//                             text: TextSpan(
//                                 text: imageReactionCountData
//                                     .child(socialfeed.docs[feedindex].id +
//                                         imageindex.toString()).child("commentcount").value
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
//                               onReactionChanged: (reaction, index, ischecked) {
//                                 setState(() {
//                                   _imagereactionIndex[imageindex] = index;
//                                 });

//                                 if (socialFeedPostReactionsDB.get(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString()) !=
//                                     null) {
//                                   if (index == -1) {
//                                     setState(() {
//                                       _imagereactionIndex[imageindex] = -2;
//                                     });
//                                     _notificationdb
//                                         .deleteSocialFeedReactionsNotification(
//                                             _currentUserId +
//                                                 socialfeed.docs[feedindex].id +
//                                                 imageindex.toString());
//                                     socialFeedPostReactionsDB.delete(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString());
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) -
//                                           1
//                                     });
//                                   } else {
//                                     if (_imagereactionIndex[imageindex] == 0) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Like",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Like");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         1) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Love",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Love");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         2) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Haha",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Haha");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         3) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
//                                                   .get("userid"),
//                                               personaldata.docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " reacted yay on your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Yay",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Yay");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         4) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
//                                                   .get("userid"),
//                                               personaldata.docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " reacted wow on your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Wow",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Wow");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         5) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Angry",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Angry");
//                                     }
//                                   }
//                                 } else {
//                                   if (_imagereactionIndex[imageindex] == -1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       0) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " loved your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Love",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Love");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       2) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted haha on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Haha",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Haha");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       3) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted yay on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Yay",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Yay");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       4) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted wow on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Wow",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Wow");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       5) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted angry on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Angry",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Angry");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   }
//                                 }
//                               },
//                               reactions: reactions,
//                               initialReaction:
//                                   _imagereactionIndex[imageindex] == -1
//                                       ? Reaction(
//                                           icon: Row(
//                                             children: [
//                                               Icon(FontAwesome5.thumbs_up,
//                                                   color: Color(0xff0962ff),
//                                                   size: 14),
//                                               Text(
//                                                 "  Like",
//                                                 style: TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w700,
//                                                     color: Color(0xff0962ff)),
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       : _imagereactionIndex[imageindex] == -2
//                                           ? Reaction(
//                                               icon: Row(
//                                                 children: [
//                                                   Icon(FontAwesome5.thumbs_up,
//                                                       color: Color.fromRGBO(
//                                                           0, 0, 0, 0.8),
//                                                       size: 14),
//                                                   Text(
//                                                     "  Like",
//                                                     style: TextStyle(
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                         color: Colors.black45),
//                                                   )
//                                                 ],
//                                               ),
//                                             )
//                                           : reactions[
//                                               _imagereactionIndex[imageindex]],
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
//                                   builder: (context) =>
//                                       ShowSocialFeedImagesComments(
//                                           socialfeed.docs[feedindex].id,
//                                           imageindex)));
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
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _socialFeedImageWithoutHeader(int feedi, int imageindex) {
//     List imagelist = socialfeed.docs[feedindex].get("imagelist");

//     return Container(
//       padding: EdgeInsets.only(top: 5),
//       margin: EdgeInsets.all(7),
//       decoration: BoxDecoration(
//           color: Color.fromRGBO(242, 246, 248, 1),
//           borderRadius: BorderRadius.all(Radius.circular(20))),
//       child: Column(
//         children: [
//           buildGridView(imagelist[imageindex]),
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
//                                 imageReactionCountData.child(
//                                         socialfeed.docs[feedindex].id +
//                                             imageindex.toString()).child("likecount").value
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
//                                   builder: (context) => ShowSocialFeedComments(
//                                       socialfeed.docs[feedindex].id)));
//                         },
//                         child: Container(
//                           child: RichText(
//                             text: TextSpan(
//                                 text: imageReactionCountData
//                                     .child(socialfeed.docs[feedindex].id +
//                                         imageindex.toString()).child("commentcount").value
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
//                               onReactionChanged: (reaction, index, ischecked) {
//                                 setState(() {
//                                   _imagereactionIndex[imageindex] = index;
//                                 });

//                                 if (socialFeedPostReactionsDB.get(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString()) !=
//                                     null) {
//                                   if (index == -1) {
//                                     setState(() {
//                                       _imagereactionIndex[imageindex] = -2;
//                                     });
//                                     _notificationdb
//                                         .deleteSocialFeedReactionsNotification(
//                                             _currentUserId +
//                                                 socialfeed.docs[feedindex].id +
//                                                 imageindex.toString());
//                                     socialFeedPostReactionsDB.delete(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString());
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) -
//                                           1
//                                     });
//                                   } else {
//                                     if (_imagereactionIndex[imageindex] == 0) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Like",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Like");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         1) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Love",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Love");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         2) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Haha",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Haha");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         3) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
//                                                   .get("userid"),
//                                               personaldata.docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " reacted yay on your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Yay",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Yay");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         4) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
//                                                   .get("userid"),
//                                               personaldata.docs[0]
//                                                       .get("firstname") +
//                                                   " " +
//                                                   personaldata.docs[0]
//                                                       .get("lastname") +
//                                                   " reacted wow on your post.",
//                                               "You got a reaction!",
//                                               current_date,
//                                               usertokendataLocalDB.get(
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Wow",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Wow");
//                                     } else if (_imagereactionIndex[
//                                             imageindex] ==
//                                         5) {
//                                       _notificationdb
//                                           .socialFeedReactionsNotificationsImages(
//                                               personaldata.docs[0].get(
//                                                       "firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               personaldata.docs[0].get(
//                                                   "profilepic"),
//                                               socialfeed
//                                                   .docs[feedindex]
//                                                   .get("username"),
//                                               socialfeed.docs[feedindex]
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
//                                                   socialfeed.docs[feedindex]
//                                                       .get("userid")),
//                                               socialfeed.docs[feedindex].id,
//                                               imageindex.toString(),
//                                               feedindex,
//                                               "Angry",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               imageindex.toString(),
//                                           "Angry");
//                                     }
//                                   }
//                                 } else {
//                                   if (_imagereactionIndex[imageindex] == -1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       0) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " liked your post.",
//                                             "You got a like!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       1) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " loved your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Love",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Love");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       2) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted haha on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Haha",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Haha");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       3) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted yay on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Yay",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Yay");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       4) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted wow on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Wow",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Wow");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imagereactionIndex[imageindex] ==
//                                       5) {
//                                     _notificationdb
//                                         .socialFeedReactionsNotificationsImages(
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 personaldata.docs[0]
//                                                     .get("lastname"),
//                                             personaldata.docs[0]
//                                                 .get("profilepic"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("username"),
//                                             socialfeed.docs[feedindex]
//                                                 .get("userid"),
//                                             personaldata.docs[0]
//                                                     .get("firstname") +
//                                                 " " +
//                                                 personaldata.docs[0]
//                                                     .get("lastname") +
//                                                 " reacted angry on your post.",
//                                             "You got a reaction!",
//                                             current_date,
//                                             usertokendataLocalDB.get(socialfeed
//                                                 .docs[feedindex]
//                                                 .get("userid")),
//                                             socialfeed.docs[feedindex].id,
//                                             imageindex.toString(),
//                                             feedindex,
//                                             "Angry",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             imageindex.toString(),
//                                         "Angry");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             imageindex.toString())
//                                         .update({
//                                       'likecount': int.parse(imageReactionCountData.child(
//                                                   socialfeed
//                                                           .docs[feedindex].id +
//                                                       imageindex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   }
//                                 }
//                               },
//                               reactions: reactions,
//                               initialReaction:
//                                   _imagereactionIndex[imageindex] == -1
//                                       ? Reaction(
//                                           icon: Row(
//                                             children: [
//                                               Icon(FontAwesome5.thumbs_up,
//                                                   color: Color(0xff0962ff),
//                                                   size: 14),
//                                               Text(
//                                                 "  Like",
//                                                 style: TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w700,
//                                                     color: Color(0xff0962ff)),
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       : _imagereactionIndex[imageindex] == -2
//                                           ? Reaction(
//                                               icon: Row(
//                                                 children: [
//                                                   Icon(FontAwesome5.thumbs_up,
//                                                       color: Color.fromRGBO(
//                                                           0, 0, 0, 0.8),
//                                                       size: 14),
//                                                   Text(
//                                                     "  Like",
//                                                     style: TextStyle(
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                         color: Colors.black45),
//                                                   )
//                                                 ],
//                                               ),
//                                             )
//                                           : reactions[
//                                               _imagereactionIndex[imageindex]],
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
//                                   builder: (context) =>
//                                       ShowSocialFeedImagesComments(
//                                           socialfeed.docs[feedindex].id,
//                                           imageindex)));
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
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildGridView(String imagelink) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     SingleImageView(imagelink, "NetworkImage")));
//       },
//       child: Container(
//         height: 300,
//         width: 300,
//         child: CachedNetworkImage(
//           imageUrl: imagelink,
//           fit: BoxFit.cover,
//           placeholder: (context, url) => Container(
//               height: 30,
//               width: 30,
//               child: Image.asset(
//                 "assets/loadingimg.gif",
//               )),
//           errorWidget: (context, url, error) => Icon(Icons.error),
//         ),
//       ),
//     );
//   }

//   _chooseHeaderAccordingToMood(
//       String mood, int feedi, List selectedUserName, List selectedUserID) {
//     String gender =
//         socialfeed.docs[feedindex].get("usergender") == "Male" ? "him" : "her";
//     String celebrategender =
//         socialfeed.docs[feedindex].get("usergender") == "Male" ? "his" : "her";
//     if (mood == "") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Excited") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is feeling ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'excited ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Good") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is feeling ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'good ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Need people around me") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: 'need people around $gender ',
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Certificate") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is celebrating $celebrategender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'achievement ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Performance") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is celebrating $celebrategender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'performance ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Friends") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("username"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: ', Delhi',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("usergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is feeling ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'friends ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   _chooseShareFeedPostHeaderAccordingToMood(String mood, int feedi) {
//     List selectedUserName =
//         socialfeed.docs[feedindex].get("sharetagedusername");
//     List selectedUserID = socialfeed.docs[feedindex].get("sharetageduserid");
//     String gender =
//         socialfeed.docs[feedindex].get("sharegender") == "Male" ? "him" : "her";
//     String celebrategender =
//         socialfeed.docs[feedindex].get("sharegender") == "Male" ? "his" : "her";
//     if (mood == "") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Excited") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is feeling ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'excited ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Good") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is feeling ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'good ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Need people around me") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "need people around $gender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Certificate") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is celebrating $celebrategender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'achievement ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Performance") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "is celebrating $celebrategender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'performance ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     } else if (mood == "Friends") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[feedindex].get("shareusername"),
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 15,
//                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           ', ${socialfeed.docs[feedindex].get("shareuserarea")}',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.7),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   ]),
//             ),
//             Text(
//               socialfeed.docs[feedindex].get("shareuserschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[feedindex].get("shareusergrade"),
//               style: TextStyle(
//                 fontFamily: 'Nunito Sans',
//                 fontSize: 12,
//                 color: Color.fromRGBO(0, 0, 0, 0.7),
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                   text: "want to introduce $celebrategender ",
//                   style: TextStyle(
//                     fontFamily: 'Nunito Sans',
//                     fontSize: 12,
//                     color: Color.fromRGBO(0, 0, 0, 0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'friends ',
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: Color.fromRGBO(0, 0, 0, 0.8),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: 'with ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 0))
//                         ? TextSpan(
//                             text: selectedUserName[0],
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 1))
//                         ? TextSpan(
//                             text: ' and ',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.7),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length > 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} others',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                     ((selectedUserName != null) &&
//                             (selectedUserName.length == 2))
//                         ? TextSpan(
//                             text: '${selectedUserName.length - 1} other',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 12,
//                               color: Color.fromRGBO(0, 0, 0, 0.8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         : TextSpan(),
//                   ]),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _loading() {
//     return Center(
//       child: Container(
//           height: 50.0,
//           margin: EdgeInsets.only(left: 10.0, right: 10.0),
//           child: Center(
//               child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
//           ))),
//     );
//   }

//   YYDialog moreOptionsSMPostViewer(BuildContext context, int feedi) {
//     String gender =
//         socialfeed.docs[feedindex].get("usergender") == "Male" ? "his" : "her";
//     return YYDialog().build(context)
//       ..gravity = Gravity.bottom
//       ..gravityAnimationEnable = true
//       ..backgroundColor = Colors.transparent
//       ..widget(Container(
//         height: 470,
//         margin: EdgeInsets.only(left: 2, right: 2),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//           color: Colors.white,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: ListView(
//             physics: BouncingScrollPhysics(),
//             children: [
//               InkWell(
//                 onTap: () async {},
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.bookmark_border,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Save post',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'Add this to your saved items.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   Fluttertoast.showToast(
//                       msg: "Removed from bookmark list.",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.BOTTOM,
//                       timeInSecForIosWeb: 2,
//                       backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                       textColor: Colors.white,
//                       fontSize: 12.0);
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.star_border,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Add ${socialfeed.docs[feedindex].get("username")} to favourites',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'Prioritise $gender post in News Feed.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.cancel_presentation_outlined,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Hide post',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'See fewer posts like this.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.timelapse_outlined,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Snooze ${socialfeed.docs[feedindex].get("username")} for 30 days',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'Temporarily stop seeing posts.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.undo_outlined,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Unfollow ${socialfeed.docs[feedindex].get("username")}',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'Stop seeing posts but stay friend.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 55,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.report_outlined,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Find suppost or repost post',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'I\'m concerned about this post.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               /*  InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 45,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.info_outline,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Why am i seeing this post?',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),*/
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 45,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.notifications_on_outlined,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Turn on notifications for this post',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ))
//       ..show();
//   }

//   YYDialog moreOptionsSMPostUser(int feedi) {
//     return YYDialog().build()
//       ..gravity = Gravity.bottom
//       ..gravityAnimationEnable = true
//       ..backgroundColor = Colors.transparent
//       ..widget(Container(
//         height: 100,
//         margin: EdgeInsets.only(left: 2, right: 2),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//           color: Colors.white,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: ListView(
//             physics: BouncingScrollPhysics(),
//             children: [
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 65,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.edit,
//                         color: Colors.black87,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Edit',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             'Edit the question or add more relative reference.',
//                             style: TextStyle(
//                               fontFamily: 'Nunito Sans',
//                               fontSize: 11,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ))
//       ..show();
//   }
// }
