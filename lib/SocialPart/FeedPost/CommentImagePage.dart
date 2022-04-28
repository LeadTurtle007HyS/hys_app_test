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
// import 'package:hys/SocialPart/FeedPost/ImagesubCommentPage.dart';
// import 'package:hys/SocialPart/ImageView/GalleryImageView.dart';
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

// class ShowSocialFeedImagesComments extends StatefulWidget {
//   String feedID;
//   int imgIndex;
//   ShowSocialFeedImagesComments(this.feedID, this.imgIndex);
//   @override
//   _ShowSocialFeedImagesCommentsState createState() =>
//       _ShowSocialFeedImagesCommentsState(this.feedID, this.imgIndex);
// }

// class _ShowSocialFeedImagesCommentsState
//     extends State<ShowSocialFeedImagesComments> {
//   String feedID;
//   int imgIndex;
//   _ShowSocialFeedImagesCommentsState(this.feedID, this.imgIndex);


//   String current_date = DateTime.now().toString();
//   String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
//   QuerySnapshot personaldata;
//   QuerySnapshot schooldata;
//   CrudMethods crudobj = CrudMethods();
//   SocialFeedPost socialFeed = SocialFeedPost();
//   QuerySnapshot socialfeed;
//   SocialMCommentsDB socialFeedComment = SocialMCommentsDB();
//   String _currentUserId = FirebaseAuth.instance.currentUser.uid;

//   VideoPlayerController _controller;
//   List<bool> _videControllerStatus = [];
//   ScrollController _scrollController;
//   DataSnapshot countData;
//   DataSnapshot countData2;
//   DataSnapshot countData3;
//   final databaseReference = FirebaseDatabase.instance.reference();
//   Box<dynamic> socialFeedPostReactionsDB;
//   Box<dynamic> socialFeedCommentsReactionsDB;
//   Box<dynamic> socialFeedSubCommentsReactionsDB;
//   Box<dynamic> usertokendataLocalDB;
//   List<int> _imgreactionIndex = [];
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
//   int feedindex = 0;

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
//               _videControllerStatus.add(false);
//               if (socialFeedPostReactionsDB.get(_currentUserId +
//                       socialfeed.docs[i].id +
//                       this.imgIndex.toString()) !=
//                   null) {
//                 if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Like") {
//                   _imgreactionIndex.add(0);
//                 } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Love") {
//                   _imgreactionIndex.add(1);
//                 } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Haha") {
//                   _imgreactionIndex.add(2);
//                 } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Yay") {
//                   _imgreactionIndex.add(3);
//                 } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Wow") {
//                   _imgreactionIndex.add(4);
//                 } else if (socialFeedPostReactionsDB.get(_currentUserId +
//                         socialfeed.docs[i].id +
//                         this.imgIndex.toString()) ==
//                     "Angry") {
//                   _imgreactionIndex.add(5);
//                 }
//               } else {
//                 _imgreactionIndex.add(-2);
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
//     socialFeedComment
//         .getSocialFeedImagesComments(this.feedID, this.imgIndex.toString())
//         .then((value) {
//       setState(() {
//         smComments = value;
//         socialFeedSubComment
//             .getAllSocialFeedImageSubComments(
//                 this.feedID, this.imgIndex.toString())
//             .then((value) {
//           setState(() {
//             smReplies = value;
//             if (smComments != null && smReplies != null) {
//               for (int i = 0; i < smComments.docs.length; i++) {
//                 List<int> subcomm = [];
//                 for (int j = 0; j < smReplies.docs.length; j++) {
//                   if (smComments.docs[i].id ==
//                       smReplies.docs[j].get("commentid")) {
//                     subcomm.add(j);
//                   }
//                 }
//                 subcommarray.add(subcomm);
//                 subcommarrayshow.add(false);
//               }
//               print(subcommarray);
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
//         (allUserschooldata != null) &&
//         (smComments != null) &&
//         (smReplies != null)) {
//       databaseReference
//           .child("sm_feeds")
//           .child("images")
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
//           .child("sm_feeds_comments")
//           .child("reactions")
//           .once()
//           .then((value) {
//         setState(() {
//           if (mounted) {
//             setState(() {
//               countData2 =value.snapshot;
//             });
//           }
//         });
//       });
//       databaseReference
//           .child("sm_feeds_reply")
//           .child("reactions")
//           .once()
//           .then((value) {
//         setState(() {
//           if (mounted) {
//             setState(() {
//               countData3 = value.snapshot;
//             });
//           }
//         });
//       });
//       print(smComments.docs.length);
//       if ((countData != null) && (countData2 != null) && (countData3 != null)) {
//         return Column(
//           children: [
//             Expanded(
//               child: Material(
//                 child: smComments.docs.length == 0
//                     ? when_no_comment()
//                     : ListView.builder(
//                         controller: _scrollController,
//                         itemCount: smComments.docs.length,
//                         itemBuilder: (BuildContext context, int i) {
//                           return i == 0 ? when_I_is_Zero() : _comment(i);
//                         },
//                       ),
//               ),
//             ),
//             commentImg == true
//                 ? Container(
//                     color: Colors.black12,
//                     padding: EdgeInsets.all(10),
//                     height: 300,
//                     child: ListView(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(0.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.cancel, color: Colors.black),
//                                 onPressed: () {
//                                   setState(() {
//                                     commentImg = false;
//                                     commentImageFile.delete();
//                                   });
//                                 },
//                               )
//                             ],
//                           ),
//                         ),
//                         Image.file(
//                           commentImageFile,
//                           fit: BoxFit.fill,
//                         ),
//                       ],
//                     ),
//                   )
//                 : SizedBox(),
//             Container(
//               padding: EdgeInsets.only(bottom: 10.0),
//               width: MediaQuery.of(context).size.width,
//               child: FlutterMentions(
//                 key: key,
//                 keyboardType: TextInputType.text,
//                 cursorColor: Color(0xff0962ff),
//                 decoration: new InputDecoration(
//                     prefixIcon: Container(
//                       height: 35,
//                       width: 35,
//                       margin: EdgeInsets.all(6),
//                       child: CircleAvatar(
//                         child: ClipOval(
//                           child: Container(
//                             child: Image.network(
//                               personaldata.docs[0].get("profilepic"),
//                               loadingBuilder: (BuildContext context,
//                                   Widget child,
//                                   ImageChunkEvent loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Image.asset(
//                                   personaldata.docs[0].get("gender") == "Male"
//                                       ? "assets/maleicon.jpg"
//                                       : "assets/femaleicon.png",
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     hintText: "Leave your comment here",
//                     hintStyle: TextStyle(color: Colors.black45, fontSize: 12)),
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Color(0xff0962ff),
//                     fontWeight: FontWeight.w500),
//                 suggestionPosition: SuggestionPosition.Top,
//                 defaultText: comment,
//                 onMarkupChanged: (val) {
//                   setState(() {
//                     markupptext = val;
//                   });
//                 },
//                 onEditingComplete: () {
//                   setState(() {
//                     tagids.clear();
//                     for (int l = 0; l < markupptext.length; l++) {
//                       int k = l;
//                       if (markupptext.substring(k, k + 1) == "@") {
//                         String test1 = markupptext.substring(k);
//                         tagids.add(test1.substring(4, test1.indexOf("__]")));
//                       }
//                     }
//                     print(tagids);
//                   });
//                 },
//                 onSuggestionVisibleChanged: (val) {
//                   setState(() {
//                     _showList = val;
//                   });
//                 },
//                 autofocus: true,
//                 onChanged: (val) {
//                   setState(() {
//                     comment = val;
//                   });
//                 },
//                 onTap: () {
//                   setState(() {
//                     // ocrbutton = false;
//                   });
//                 },
//                 onSearchChanged: (
//                   trigger,
//                   value,
//                 ) {
//                   print('again | $trigger | $value ');
//                 },
//                 hideSuggestionList: false,
//                 minLines: 1,
//                 maxLines: 5,
//                 mentions: [
//                   Mention(
//                       trigger: r'@',
//                       style: TextStyle(
//                         color: Color(0xff0C2551),
//                       ),
//                       matchAll: false,
//                       data: _users,
//                       suggestionBuilder: (data) {
//                         return Container(
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               border: Border(
//                                   top: BorderSide(color: Color(0xFFE0E1E4)))),
//                           padding: EdgeInsets.all(10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               CircleAvatar(
//                                 backgroundImage: NetworkImage(
//                                   data['photo'],
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 20.0,
//                               ),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(data['display']),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 3,
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${data['full_name']}',
//                                         style: TextStyle(
//                                           color: Color(0xFFAAABAD),
//                                           fontSize: 11,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         );
//                       }),
//                 ],
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             showKeyboard();
//                           },
//                           child: Container(
//                             padding: EdgeInsets.only(top: 10, left: 15),
//                             child: Center(
//                               child: Image.asset("assets/keyboard.png",
//                                   height: 25, width: 25),
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () async {
//                             setState(() {
//                               showimgcontainer = false;
//                               showvdocontainer = !showvdocontainer;
//                               print(showvdocontainer);
//                               dismissKeyboard();
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.only(top: 10, left: 20),
//                             child: Center(
//                               child: Image.asset("assets/videorecord.jpg",
//                                   height: 25, width: 25),
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () async {
//                             setState(() {
//                               showvdocontainer = false;
//                               showimgcontainer = !showimgcontainer;
//                               print(showimgcontainer);
//                               dismissKeyboard();
//                             });
//                           },
//                           child: Container(
//                             padding:
//                                 EdgeInsets.only(top: 10, left: 15, right: 15),
//                             child: Center(
//                               child: Image.asset("assets/gallery.png",
//                                   height: 22, width: 21),
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () async {
//                             setState(() {
//                               key.currentState.controller.text =
//                                   key.currentState.controller.text + "@";
//                               showKeyboard();
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.only(top: 10, right: 15),
//                             child: Center(
//                               child: Icon(FontAwesome5.user_tag,
//                                   size: 18, color: Colors.deepPurple),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       setState(() {
//                         Fluttertoast.showToast(
//                             msg: "Your comment is in process",
//                             toastLength: Toast.LENGTH_SHORT,
//                             gravity: ToastGravity.BOTTOM,
//                             timeInSecForIosWeb: 2,
//                             backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                             textColor: Colors.white,
//                             fontSize: 12.0);
//                         if (imageupload == false && videoUploaded == false) {
//                           tagids.clear();
//                           for (int l = 0; l < markupptext.length; l++) {
//                             int k = l;
//                             if (markupptext.substring(k, k + 1) == "@") {
//                               String test1 = markupptext.substring(k);
//                               tagids.add(
//                                   test1.substring(4, test1.indexOf("__]")));
//                             }
//                           }
//                           print(tagids);
//                           socialFeedComment.addFeedImageComment(
//                               this.feedID,
//                               this.imgIndex.toString(),
//                               personaldata.docs[0].get("firstname") +
//                                   personaldata.docs[0].get("lastname"),
//                               personaldata.docs[0].get("profilepic"),
//                               personaldata.docs[0].get("gender"),
//                               "Delhi",
//                               schooldata.docs[0].get("schoolname"),
//                               schooldata.docs[0].get("grade"),
//                               comment,
//                               tagedUsersName,
//                               tagids,
//                               finalVideosUrl,
//                               thumbURL,
//                               imgUrl,
//                               current_date,
//                               comparedate,
//                               "");

//                           dismissKeyboard();
//                           databaseReference
//                               .child("sm_feeds")
//                               .child("images")
//                               .child(this.feedID + this.imgIndex.toString())
//                               .update({
//                             'commentcount': int.parse(countData.child(this.feedID +
//                                     this.imgIndex.toString()).child("commentcount").value.toString()) +
//                                 1
//                           });
//                           _notificationdb
//                               .socialFeedReactionsNotificationsImages(
//                                   personaldata.docs[0].get("firstname") +
//                                       personaldata.docs[0].get("lastname"),
//                                   personaldata.docs[0].get("profilepic"),
//                                   socialfeed.docs[feedindex].get("username"),
//                                   socialfeed.docs[feedindex].get("userid"),
//                                   personaldata.docs[0].get("firstname") +
//                                       " " +
//                                       personaldata.docs[0].get("lastname") +
//                                       " commented on your post.",
//                                   "You got a Comment!",
//                                   current_date,
//                                   usertokendataLocalDB.get(
//                                       socialfeed.docs[feedindex].get("userid")),
//                                   socialfeed.docs[feedindex].id,
//                                   this.imgIndex.toString(),
//                                   feedindex,
//                                   "Comment",
//                                   comparedate);
//                           socialFeedComment
//                               .getSocialFeedImagesComments(
//                                   this.feedID, this.imgIndex.toString())
//                               .then((value) {
//                             setState(() {
//                               smComments = value;
//                               socialFeedSubComment
//                                   .getAllSocialFeedImageSubComments(
//                                       this.feedID, this.imgIndex.toString())
//                                   .then((value) {
//                                 setState(() {
//                                   smReplies = value;
//                                   if (smComments != null && smReplies != null) {
//                                     for (int i = 0;
//                                         i < smComments.docs.length;
//                                         i++) {
//                                       List<int> subcomm = [];
//                                       for (int j = 0;
//                                           j < smReplies.docs.length;
//                                           j++) {
//                                         if (smComments.docs[i].id ==
//                                             smReplies.docs[j]
//                                                 .get("commentid")) {
//                                           subcomm.add(j);
//                                         }
//                                       }
//                                       subcommarray.add(subcomm);
//                                       subcommarrayshow.add(false);
//                                     }
//                                     print(subcommarray);
//                                   }
//                                 });
//                               });
//                             });
//                           });
//                           key.currentState.controller.clear();
//                           FocusScope.of(context).requestFocus(new FocusNode());
//                           commentImg = false;
//                           commentImageFile = null;
//                         }
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//                       child: Center(
//                         child: Text(
//                           ((imageupload == false) && (videoUploaded == false))
//                               ? "POST"
//                               : "WAIT",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: ((comment != "") &&
//                                       (imageupload == false) &&
//                                       (videoUploaded == false))
//                                   ? Color(0xff0962ff)
//                                   : Colors.black54),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             showimgcontainer == true
//                 ? _imgContainer()
//                 : showvdocontainer == true
//                     ? _vdoContainer()
//                     : SizedBox()
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
//           _socialFeed(feedindex),
//           _comment(0)
//         ],
//       ),
//     );
//   }

//   when_no_comment() {
//     return ListView(
//       children: [
//         Container(
//           height: 50,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               IconButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 icon: Tab(
//                     child: Icon(Icons.arrow_back_ios_outlined,
//                         color: Colors.black45, size: 23)),
//               )
//             ],
//           ),
//         ),
//         _socialFeed(feedindex),
//       ],
//     );
//   }

//   Future uploadSocialFeedImages(ImageSource source) async {
//     imageupload = true;
//     File editedFile;
//     final pickedfile = await picker.getImage(source: source);
//     if (pickedfile != null) {
//       setState(() {
//         _image = File(pickedfile.path);
//         print(_image);
//       });
//       if (_image != null) {
//         editedFile = await Navigator.of(context).push(new MaterialPageRoute(
//             builder: (context) => StoryDesigner(
//                   filePath: _image.path,
//                 )));
//       }
//       commentImageFile = File(editedFile.path);
//       commentImg = true;
//     }
//     if (editedFile != null) {
//       setState(() {
//         imageFile = editedFile;
//         print(imageFile);
//         _loading();
//       });
//       socialFeed.uploadSocialMediaFeedImages(imageFile).then((value) {
//         setState(() {
//           print(value);
//           if (value[0] == true) {
//             imgUrl = value[1];
//             print(imgUrl);

//             imageupload = false;

//             dismissKeyboard();
//           } else
//             _showAlertDialog(value[1]);
//         });
//       });
//     }
//   }

//   Future uploadSocialFeedVideo(ImageSource source) async {
//     videoUploaded = true;
//     String path = "";
//     final file = await picker.getVideo(
//         source: source, maxDuration: Duration(minutes: 15));
//     if (file == null) {
//       return;
//     }
//     finalVideos = file.path;
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
//       socialFeed.uploadReferenceVideo(path).then((value) {
//         setState(() {
//           print(value);
//           if (value[0] == true) {
//             print(value[1]);
//             finalVideosUrl = value[1];
//             print(finalVideosUrl);
//             Fluttertoast.showToast(
//                 msg: "Video uploaded successfully",
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 timeInSecForIosWeb: 10,
//                 backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
//                 textColor: Colors.white,
//                 fontSize: 12.0);
//             getThumbnail(finalVideosUrl);
//             //Navigator.pop(context);
//             dismissKeyboard();
//           } else
//             _showAlertDialog(value[1]);
//         });
//       });
//     }
//   }

//   _imgContainer() {
//     return Container(
//       height: 250,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Click answer pic and upload",
//                 style: TextStyle(fontSize: 12, color: Colors.black54)),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           showimgcontainer = false;
//                           showvdocontainer = false;
//                           uploadSocialFeedImages(ImageSource.camera);
//                         });
//                       },
//                       icon: Tab(
//                           child: Icon(Icons.camera_alt_outlined,
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
//                           showimgcontainer = false;
//                           showvdocontainer = false;
//                           uploadSocialFeedImages(ImageSource.gallery);
//                         });
//                       },
//                       icon: Tab(
//                           child: Icon(Icons.image,
//                               color: Color(0xff0962ff), size: 40)),
//                     ),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       "Images",
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
//   }

//   _vdoContainer() {
//     return Container(
//       height: 250,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Record video and upload",
//                 style: TextStyle(fontSize: 12, color: Colors.black54)),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           showimgcontainer = false;
//                           showvdocontainer = false;
//                           uploadSocialFeedVideo(ImageSource.camera);
//                         });
//                       },
//                       icon: Tab(
//                           child: Icon(Icons.camera_alt_outlined,
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
//                           showimgcontainer = false;
//                           showvdocontainer = false;
//                           uploadSocialFeedVideo(ImageSource.gallery);
//                         });
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

//   _socialFeed(int i) {
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
//             padding: const EdgeInsets.only(left: (15.0), right: 10),
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
//                                 imageUrl:
//                                     socialfeed.docs[i].get("userprofilepic"),
//                                 fit: BoxFit.cover,
//                                 placeholder: (context, url) => Image.asset(
//                                   "assets/loadingimg.gif",
//                                 ),
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
//                           socialfeed.docs[i].get("usermood"),
//                           i,
//                           tagedusername,
//                           tageduserid),
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
//           imageView(imagelist[this.imgIndex]),
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
//                                 countData.child(this.feedID +
//                                         this.imgIndex.toString()).child("likecount").value
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
//                         padding: EdgeInsets.only(top: 8, bottom: 8),
//                         child: Row(
//                           children: [
//                             FlutterReactionButtonCheck(
//                               onReactionChanged: (reaction, index, ischecked) {
//                                 setState(() {
//                                   _imgreactionIndex[i] = index;
//                                 });

//                                 if (socialFeedPostReactionsDB.get(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString()) !=
//                                     null) {
//                                   if (index == -1) {
//                                     setState(() {
//                                       _imgreactionIndex[i] = -2;
//                                     });
//                                     _notificationdb
//                                         .deleteSocialFeedReactionsNotification(
//                                             _currentUserId+socialfeed.docs[feedindex].id +
//                                                 this.imgIndex.toString());
//                                     socialFeedPostReactionsDB.delete(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString());
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) -
//                                           1
//                                     });
//                                   } else {
//                                     if (_imgreactionIndex[i] == 0) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Like",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Like");
//                                     } else if (_imgreactionIndex[i] == 1) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Love",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Love");
//                                     } else if (_imgreactionIndex[i] == 2) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Haha",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Haha");
//                                     } else if (_imgreactionIndex[i] == 3) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Yay",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Yay");
//                                     } else if (_imgreactionIndex[i] == 4) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Wow",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Wow");
//                                     } else if (_imgreactionIndex[i] == 5) {
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
//                                               this.imgIndex.toString(),
//                                               feedindex,
//                                               "Angry",
//                                               comparedate);
//                                       socialFeedPostReactionsDB.put(
//                                           _currentUserId +
//                                               socialfeed.docs[feedindex].id +
//                                               this.imgIndex.toString(),
//                                           "Angry");
//                                     }
//                                   }
//                                 } else {
//                                   if (_imgreactionIndex[i] == -1) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 0) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Like",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Like");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 1) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Love",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Love");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 2) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Haha",
//                                             comparedate);

//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Haha");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 3) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Yay",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Yay");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 4) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Wow",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Wow");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   } else if (_imgreactionIndex[i] == 5) {
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
//                                             this.imgIndex.toString(),
//                                             feedindex,
//                                             "Angry",
//                                             comparedate);
//                                     socialFeedPostReactionsDB.put(
//                                         _currentUserId +
//                                             socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString(),
//                                         "Angry");
//                                     databaseReference
//                                         .child("sm_feeds")
//                                         .child("images")
//                                         .child(socialfeed.docs[feedindex].id +
//                                             this.imgIndex.toString())
//                                         .update({
//                                       'likecount': int.parse(countData.child(socialfeed
//                                                       .docs[feedindex].id +
//                                                   this.imgIndex.toString()).child("likecount").value.toString()) +
//                                           1
//                                     });
//                                   }
//                                   socialFeed.updateReactionCount(
//                                       socialfeed.docs[feedindex].id, {
//                                     "likescount": int.parse(countData.child(socialfeed
//                                             .docs[feedindex].id +
//                                         this.imgIndex.toString()).child("likecount").value.toString())
//                                   });
//                                 }
//                               },
//                               reactions: reactions,
//                               initialReaction: _imgreactionIndex[i] == -1
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
//                                   : _imgreactionIndex[i] == -2
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
//                                       : reactions[_imgreactionIndex[i]],
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
//                         onTap: () {},
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

//   Widget imageView(String imagesFile) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     SingleImageView(imagesFile, "NetworkImage")));
//       },
//       child: Container(
//         height: 300,
//         width: 300,
//         child: Image.network(
//           imagesFile,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Image.asset(
//               "assets/loadingimg.gif",
//             );
//           },
//         ),
//       ),
//     );
//   }

//   _comment(int i) {
//     String date =
//         getTimeDifferenceFromNow(smComments.docs[i].get("createdate"));
//     return Column(
//       children: [
//         Container(
//           margin: EdgeInsets.only(right: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 35,
//                 width: 35,
//                 margin: EdgeInsets.all(10),
//                 child: CircleAvatar(
//                   child: ClipOval(
//                     child: Container(
//                       child: Image.network(
//                         smComments.docs[i].get("userprofilepic"),
//                         loadingBuilder: (BuildContext context, Widget child,
//                             ImageChunkEvent loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Image.asset(
//                             personaldata.docs[0].get("gender") == "Male"
//                                 ? "assets/maleicon.jpg"
//                                 : "assets/femaleicon.png",
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 20),
//                   Bubble(
//                     color: Color.fromRGBO(242, 246, 248, 1),
//                     nip: BubbleNip.leftTop,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width / 1.45,
//                       decoration: BoxDecoration(
//                           color: Color.fromRGBO(242, 246, 248, 1),
//                           borderRadius: BorderRadius.all(Radius.circular(10))),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 smComments.docs[i].get("username"),
//                                 style: TextStyle(
//                                     color: Color(0xFF4D4D4D),
//                                     fontSize: 13.5,
//                                     fontWeight: FontWeight.w700),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "${smComments.docs[i].get("userschoolname")} | Grade ${smComments.docs[i].get("usergrade")}",
//                                 style: TextStyle(
//                                     color: Colors.black54,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           InkWell(
//                             onTap: () {},
//                             child: Container(
//                               child: ReadMoreText(
//                                 smComments.docs[i].get("comment"),
//                                 trimLines: 4,
//                                 colorClickableText: Color(0xff0962ff),
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'read more',
//                                 trimExpandedText: 'Show less',
//                                 style: TextStyle(
//                                     color: Color(0xFF4D4D4D),
//                                     fontSize: 11.5,
//                                     fontWeight: FontWeight.w500),
//                                 lessStyle: TextStyle(
//                                     color: Color(0xFF4D4D4D),
//                                     fontSize: 11.5,
//                                     fontWeight: FontWeight.w500),
//                                 moreStyle: TextStyle(
//                                     color: Color(0xFF4D4D4D),
//                                     fontSize: 11.5,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                           ),
//                           smComments.docs[i].get("imagelist") != ""
//                               ? Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           if (smComments.docs[i]
//                                                   .get("imagelist") !=
//                                               "") {
//                                             Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         SingleImageView(
//                                                             smComments.docs[i]
//                                                                 .get(
//                                                                     "imagelist"),
//                                                             "NetworkImage")));
//                                           }
//                                         });
//                                       },
//                                       child: Container(
//                                         margin: EdgeInsets.all(5),
//                                         height: 300,
//                                         child: Image.network(
//                                           smComments.docs[i].get("imagelist"),
//                                           fit: BoxFit.cover,
//                                           loadingBuilder: (BuildContext context,
//                                               Widget child,
//                                               ImageChunkEvent loadingProgress) {
//                                             if (loadingProgress == null)
//                                               return child;
//                                             return Image.asset(
//                                               "assets/loadingimg.gif",
//                                               width: 200,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : SizedBox(),
//                           SizedBox(
//                             height: 4,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           date,
//                           style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500),
//                         ),
//                         SizedBox(
//                           width: 8,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             if (socialFeedCommentsReactionsDB
//                                     .get(smComments.docs[i].id) !=
//                                 null) {
//                               socialFeedCommentsReactionsDB
//                                   .delete(smComments.docs[i].id);
//                               socialFeedComment.deleteCommentLikeDetails(
//                                   _currentUserId + smComments.docs[i].id);
//                               databaseReference
//                                   .child("sm_feeds_comments")
//                                   .child("reactions")
//                                   .child(smComments.docs[i].id)
//                                   .update({
//                                 'likecount':
//                                     int.parse(countData2.child(smComments.docs[i].id).child("likecount").value.toString()) -
//                                         1
//                               });
//                               _notificationdb
//                                   .deleteSocialFeedReactionsNotification(
//                                       _currentUserId +
//                                           smComments.docs[i].id +
//                                           this.imgIndex.toString() +
//                                           "Like");
//                             } else {
//                               socialFeedCommentsReactionsDB.put(
//                                   smComments.docs[i].id, "Like");

//                               databaseReference
//                                   .child("sm_feeds_comments")
//                                   .child("reactions")
//                                   .child(smComments.docs[i].id)
//                                   .update({
//                                 'likecount':
//                                     int.parse(countData2.child(smComments.docs[i].id).child("likecount").value.toString()) +
//                                         1
//                               });
//                               _notificationdb
//                                   .socialFeedCommentReactionsNotificationsImages(
//                                       personaldata.docs[0].get("firstname") +
//                                           personaldata.docs[0].get("lastname"),
//                                       personaldata.docs[0].get("profilepic"),
//                                       smComments.docs[i].get("username"),
//                                       smComments.docs[i].get("userid"),
//                                       personaldata.docs[0].get("firstname") +
//                                           " " +
//                                           personaldata.docs[0].get("lastname") +
//                                           " liked your post.",
//                                       "You got a like!",
//                                       current_date,
//                                       usertokendataLocalDB.get(
//                                           smComments.docs[i].get("userid")),
//                                       this.feedID,
//                                       this.imgIndex,
//                                       this.feedindex,
//                                       smComments.docs[i].id,
//                                       i,
//                                       "Like",
//                                       comparedate);
//                               socialFeedComment.addFeedCommentLikesDetails(
//                                   this.feedID,
//                                   smComments.docs[i].id,
//                                   smComments.docs[i].get("userid"),
//                                   smComments.docs[i].get("username"),
//                                   smComments.docs[i].get("userschoolname"),
//                                   smComments.docs[i].get("userprofilepic"),
//                                   "Delhi",
//                                   smComments.docs[i].get("usergrade"),
//                                   personaldata.docs[0].get("firstname") +
//                                       personaldata.docs[0].get("lastname"),
//                                   schooldata.docs[0].get("schoolname"),
//                                   personaldata.docs[0].get("profilepic"),
//                                   "Delhi",
//                                   schooldata.docs[0].get("grade"),
//                                   current_date,
//                                   comparedate);
//                               Fluttertoast.showToast(
//                                   msg: "You liked a comment.",
//                                   toastLength: Toast.LENGTH_SHORT,
//                                   gravity: ToastGravity.BOTTOM,
//                                   timeInSecForIosWeb: 2,
//                                   backgroundColor:
//                                       Color.fromRGBO(37, 36, 36, 1.0),
//                                   textColor: Colors.white,
//                                   fontSize: 12.0);
//                             }
//                           },
//                           child: Text(
//                             "Like",
//                             style: TextStyle(
//                                 color: socialFeedCommentsReactionsDB
//                                             .get(smComments.docs[i].id) !=
//                                         null
//                                     ? Color(0xff0962ff)
//                                     : Colors.black54,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                         int.parse(countData2.child(smComments.docs[i].id).child("likecount").value.toString()) > 0
//                             ? SizedBox(
//                                 width: 4,
//                               )
//                             : SizedBox(),
//                         int.parse(countData2.child(smComments.docs[i].id).child("likecount").value.toString()) > 0
//                             ? Text(
//                                 " " +
//                                     (countData2.child(smComments.docs[i].id).child("likecount")).value
//                                         .toString() +
//                                     " ",
//                                 style: TextStyle(
//                                     color: socialFeedCommentsReactionsDB
//                                                 .get(smComments.docs[i].id) !=
//                                             null
//                                         ? Color(0xff0962ff)
//                                         : Colors.black54,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w400),
//                               )
//                             : SizedBox(),
//                         int.parse(countData2.child(smComments.docs[i].id).child("likecount").value.toString()) > 0
//                             ? Image.asset("assets/reactions/like.gif",
//                                 height: 25, width: 25)
//                             : SizedBox(),
//                         SizedBox(
//                           width: 4,
//                         ),
//                         Text(
//                           " | ",
//                           style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w700),
//                         ),
//                         SizedBox(
//                           width: 4,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             print(i);
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         SocialFeedImageSubComment(
//                                             this.feedID,
//                                             feedindex,
//                                             this.imgIndex,
//                                             smComments.docs[i].id,
//                                             i)));
//                           },
//                           child: Text(
//                             "Reply",
//                             style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                         int.parse(countData2.child(smComments.docs[i].id).child("commentcount").value.toString()) >
//                                 0
//                             ? SizedBox(
//                                 width: 4,
//                               )
//                             : SizedBox(),
//                         int.parse(countData2.child(smComments.docs[i].id).child("commentcount").value.toString()) >
//                                 0
//                             ? Text(
//                                 " " +
//                                     (countData2.child(smComments.docs[i].id).child("commentcount")).value
//                                         .toString() +
//                                     " ",
//                                 style: TextStyle(
//                                     color: Color.fromRGBO(0, 0, 0, 0.8),
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w400),
//                               )
//                             : SizedBox(),
//                         int.parse(countData2.child(smComments.docs[i].id).child("commentcount").value.toString()) >
//                                 0
//                             ? Icon(Icons.chat,
//                                 color: Color.fromRGBO(0, 0, 0, 0.8), size: 14)
//                             : SizedBox(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         _subComment(smComments.docs[i].id, i),
//         i == smComments.docs.length - 1
//             ? SizedBox(
//                 height: 100,
//               )
//             : SizedBox()
//       ],
//     );
//   }

//   _subComment(String commentid, int commentIndex) {
//     int count = 0;
//     bool check = false;
//     int subcommentIndex = 0;
//     for (int k = 0; k < smReplies.docs.length; k++) {
//       if (smReplies.docs[k].get("commentid") == commentid) {
//         check = true;
//         count++;

//         if (count == 1) {
//           subcommentIndex = k;
//         }
//       }
//     }
//     if (check == true) {
//       if (count == 1) {
//         String date = getTimeDifferenceFromNow(
//             smReplies.docs[subcommentIndex].get("createdate"));
//         return Container(
//           margin: EdgeInsets.only(right: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 25,
//                 width: 25,
//                 margin: EdgeInsets.only(right: 10),
//                 child: CircleAvatar(
//                   child: ClipOval(
//                     child: Container(
//                       child: Image.network(
//                         smReplies.docs[subcommentIndex].get("userprofilepic"),
//                         loadingBuilder: (BuildContext context, Widget child,
//                             ImageChunkEvent loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Image.asset(
//                             personaldata.docs[0].get("usergender") == "Male"
//                                 ? "assets/maleicon.jpg"
//                                 : "assets/femaleicon.png",
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.only(top: 10),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Bubble(
//                       color: Color.fromRGBO(242, 246, 248, 1),
//                       nip: BubbleNip.leftTop,
//                       child: Container(
//                         width: MediaQuery.of(context).size.width / 1.60,
//                         decoration: BoxDecoration(
//                             color: Color.fromRGBO(242, 246, 248, 1),
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(10))),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   smReplies.docs[subcommentIndex]
//                                       .get("username"),
//                                   style: TextStyle(
//                                       color: Color(0xFF4D4D4D),
//                                       fontSize: 13.5,
//                                       fontWeight: FontWeight.w700),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "${smReplies.docs[subcommentIndex].get("userschoolname")} | Grade ${smReplies.docs[subcommentIndex].get("usergrade")}",
//                                   style: TextStyle(
//                                       color: Colors.black54,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 8,
//                             ),
//                             InkWell(
//                               onTap: () {},
//                               child: Container(
//                                 child: ReadMoreText(
//                                   smReplies.docs[subcommentIndex]
//                                       .get("comment"),
//                                   trimLines: 4,
//                                   colorClickableText: Color(0xff0962ff),
//                                   trimMode: TrimMode.Line,
//                                   trimCollapsedText: 'read more',
//                                   trimExpandedText: 'Show less',
//                                   style: TextStyle(
//                                       color: Color(0xFF4D4D4D),
//                                       fontSize: 11.5,
//                                       fontWeight: FontWeight.w500),
//                                   lessStyle: TextStyle(
//                                       color: Color(0xFF4D4D4D),
//                                       fontSize: 11.5,
//                                       fontWeight: FontWeight.w500),
//                                   moreStyle: TextStyle(
//                                       color: Color(0xFF4D4D4D),
//                                       fontSize: 11.5,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                             ),
//                             smReplies.docs[subcommentIndex].get("imagelist") !=
//                                     ""
//                                 ? Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             if (smReplies.docs[subcommentIndex]
//                                                     .get("imagelist") !=
//                                                 "") {
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           SingleImageView(
//                                                               smReplies.docs[
//                                                                       subcommentIndex]
//                                                                   .get(
//                                                                       "imagelist"),
//                                                               "NetworkImage")));
//                                             }
//                                           });
//                                         },
//                                         child: Container(
//                                           margin: EdgeInsets.all(5),
//                                           height: 300,
//                                           child: Image.network(
//                                             smReplies.docs[subcommentIndex]
//                                                 .get("imagelist"),
//                                             fit: BoxFit.cover,
//                                             loadingBuilder:
//                                                 (BuildContext context,
//                                                     Widget child,
//                                                     ImageChunkEvent
//                                                         loadingProgress) {
//                                               if (loadingProgress == null)
//                                                 return child;
//                                               return Image.asset(
//                                                 "assets/loadingimg.gif",
//                                                 width: 200,
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 4,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text(
//                             date,
//                             style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w400),
//                           ),
//                           SizedBox(
//                             width: 8,
//                           ),
//                           InkWell(
//                             onTap: () {
//                               if (socialFeedSubCommentsReactionsDB.get(
//                                       smReplies.docs[subcommentIndex].id) !=
//                                   null) {
//                                 socialFeedSubCommentsReactionsDB
//                                     .delete(smReplies.docs[subcommentIndex].id);
//                                 socialFeedSubComment
//                                     .deleteSubCommentLikeDetails(
//                                         _currentUserId +
//                                             smReplies.docs[subcommentIndex].id);
//                                 databaseReference
//                                     .child("sm_feeds_reply")
//                                     .child("reactions")
//                                     .child(smReplies.docs[subcommentIndex].id)
//                                     .update({
//                                   'likecount': int.parse(countData3.child(smReplies
//                                           .docs[subcommentIndex]
//                                           .id).child("likecount").value.toString()) -
//                                       1
//                                 });
//                               } else {
//                                 socialFeedSubCommentsReactionsDB.put(
//                                     smReplies.docs[subcommentIndex].id, "Like");

//                                 databaseReference
//                                     .child("sm_feeds_reply")
//                                     .child("reactions")
//                                     .child(smReplies.docs[subcommentIndex].id)
//                                     .update({
//                                   'likecount': int.parse(countData3.child(smReplies
//                                           .docs[subcommentIndex]
//                                           .id).child("likecount").value.toString()) +
//                                       1
//                                 });
//                                 socialFeedSubComment
//                                     .addFeedSubCommentLikesDetails(
//                                         feedindex,
//                                         commentid,
//                                         smReplies.docs[subcommentIndex].id,
//                                         smReplies.docs[subcommentIndex]
//                                             .get("userid"),
//                                         smReplies.docs[subcommentIndex]
//                                             .get("username"),
//                                         smReplies.docs[subcommentIndex]
//                                             .get("userschoolname"),
//                                         smReplies.docs[subcommentIndex]
//                                             .get("userprofilepic"),
//                                         "Delhi",
//                                         smReplies.docs[subcommentIndex]
//                                             .get("usergrade"),
//                                         personaldata.docs[0].get("firstname") +
//                                             personaldata.docs[0]
//                                                 .get("lastname"),
//                                         schooldata.docs[0].get("schoolname"),
//                                         personaldata.docs[0].get("profilepic"),
//                                         "Delhi",
//                                         schooldata.docs[0].get("grade"),
//                                         current_date,
//                                         comparedate);
//                                 Fluttertoast.showToast(
//                                     msg: "You liked on a reply.",
//                                     toastLength: Toast.LENGTH_SHORT,
//                                     gravity: ToastGravity.BOTTOM,
//                                     timeInSecForIosWeb: 2,
//                                     backgroundColor:
//                                         Color.fromRGBO(37, 36, 36, 1.0),
//                                     textColor: Colors.white,
//                                     fontSize: 12.0);
//                               }
//                             },
//                             child: Text(
//                               "Like",
//                               style: TextStyle(
//                                   color: socialFeedSubCommentsReactionsDB.get(
//                                               smReplies
//                                                   .docs[subcommentIndex].id) !=
//                                           null
//                                       ? Color(0xff0962ff)
//                                       : Colors.black54,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           ),
//                           int.parse(countData3.child(smReplies.docs[subcommentIndex].id).child("likecount").value.toString()) >
//                                   0
//                               ? SizedBox(
//                                   width: 4,
//                                 )
//                               : SizedBox(),
//                           int.parse(countData3.child(smReplies.docs[subcommentIndex].id).child("likecount").value.toString()) >
//                                   0
//                               ? Text(
//                                   " " +
//                                       (countData3.child(smReplies
//                                               .docs[subcommentIndex]
//                                               .id).child("likecount")).value
//                                           .toString() +
//                                       " ",
//                                   style: TextStyle(
//                                       color: socialFeedSubCommentsReactionsDB
//                                                   .get(smReplies
//                                                       .docs[subcommentIndex]
//                                                       .id) !=
//                                               null
//                                           ? Color(0xff0962ff)
//                                           : Colors.black54,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400),
//                                 )
//                               : SizedBox(),
//                           int.parse(countData3.child(smReplies.docs[subcommentIndex].id).child("likecount").value.toString()) >
//                                   0
//                               ? Image.asset("assets/reactions/like.gif",
//                                   height: 25, width: 25)
//                               : SizedBox(),
//                           SizedBox(
//                             width: 4,
//                           ),
//                           Text(
//                             " | ",
//                             style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           SizedBox(
//                             width: 4,
//                           ),
//                           InkWell(
//                             onTap: () async {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           SocialFeedSubComments(
//                                               this.feedID,
//                                               feedindex,
//                                               commentid,
//                                               commentIndex)));
//                             },
//                             child: Text(
//                               "Reply",
//                               style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           ),
//                           int.parse(countData3.child(smReplies.docs[subcommentIndex].id).child("commentcount").value.toString()) >
//                                   0
//                               ? SizedBox(
//                                   width: 4,
//                                 )
//                               : SizedBox(),
//                           int.parse(countData3.child(smReplies.docs[subcommentIndex].id).child("commentcount").value.toString()) >
//                                   0
//                               ? Text(
//                                   " " +
//                                       countData3.child(smReplies
//                                               .docs[subcommentIndex]
//                                               .id).child("commentcount").value
//                                           .toString() +
//                                       " replies",
//                                   style: TextStyle(
//                                       color: Colors.black54,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400),
//                                 )
//                               : SizedBox(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       } else if (count > 1) {
//         if (subcommarrayshow[commentIndex] == false) {
//           String date = getTimeDifferenceFromNow(
//               smReplies.docs[subcommentIndex].get("createdate"));
//           return Container(
//             margin: EdgeInsets.only(right: 10),
//             child: Column(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     setState(() {
//                       subcommarrayshow[commentIndex] =
//                           !subcommarrayshow[commentIndex];
//                     });
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 1.45,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Show ${count - 1} more replies",
//                           style: TextStyle(
//                               color: Color.fromRGBO(0, 17, 255, 1),
//                               fontSize: 13.5,
//                               fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 25,
//                       width: 25,
//                       margin: EdgeInsets.only(right: 10),
//                       child: CircleAvatar(
//                         child: ClipOval(
//                           child: Container(
//                             child: Image.network(
//                               smReplies.docs[subcommentIndex]
//                                   .get("userprofilepic"),
//                               loadingBuilder: (BuildContext context,
//                                   Widget child,
//                                   ImageChunkEvent loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Image.asset(
//                                   personaldata.docs[0].get("usergender") ==
//                                           "Male"
//                                       ? "assets/maleicon.jpg"
//                                       : "assets/femaleicon.png",
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Bubble(
//                             color: Color.fromRGBO(242, 246, 248, 1),
//                             nip: BubbleNip.leftTop,
//                             child: Container(
//                               width: MediaQuery.of(context).size.width / 1.60,
//                               decoration: BoxDecoration(
//                                   color: Color.fromRGBO(242, 246, 248, 1),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         smReplies.docs[subcommentIndex]
//                                             .get("username"),
//                                         style: TextStyle(
//                                             color: Color(0xFF4D4D4D),
//                                             fontSize: 13.5,
//                                             fontWeight: FontWeight.w700),
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "${smReplies.docs[subcommentIndex].get("userschoolname")} | Grade ${smReplies.docs[subcommentIndex].get("usergrade")}",
//                                         style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 8,
//                                   ),
//                                   InkWell(
//                                     onTap: () {},
//                                     child: Container(
//                                       child: ReadMoreText(
//                                         smReplies.docs[subcommentIndex]
//                                             .get("comment"),
//                                         trimLines: 4,
//                                         colorClickableText: Color(0xff0962ff),
//                                         trimMode: TrimMode.Line,
//                                         trimCollapsedText: 'read more',
//                                         trimExpandedText: 'Show less',
//                                         style: TextStyle(
//                                             color: Color(0xFF4D4D4D),
//                                             fontSize: 11.5,
//                                             fontWeight: FontWeight.w500),
//                                         lessStyle: TextStyle(
//                                             color: Color(0xFF4D4D4D),
//                                             fontSize: 11.5,
//                                             fontWeight: FontWeight.w500),
//                                         moreStyle: TextStyle(
//                                             color: Color(0xFF4D4D4D),
//                                             fontSize: 11.5,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   ),
//                                   smReplies.docs[subcommentIndex]
//                                               .get("imagelist") !=
//                                           ""
//                                       ? Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             InkWell(
//                                               onTap: () {
//                                                 setState(() {
//                                                   if (smReplies
//                                                           .docs[subcommentIndex]
//                                                           .get("imagelist") !=
//                                                       "") {
//                                                     Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) =>
//                                                                 SingleImageView(
//                                                                     smReplies
//                                                                         .docs[
//                                                                             subcommentIndex]
//                                                                         .get(
//                                                                             "imagelist"),
//                                                                     "NetworkImage")));
//                                                   }
//                                                 });
//                                               },
//                                               child: Container(
//                                                 margin: EdgeInsets.all(5),
//                                                 height: 300,
//                                                 child: Image.network(
//                                                   smReplies
//                                                       .docs[subcommentIndex]
//                                                       .get("imagelist"),
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder:
//                                                       (BuildContext context,
//                                                           Widget child,
//                                                           ImageChunkEvent
//                                                               loadingProgress) {
//                                                     if (loadingProgress == null)
//                                                       return child;
//                                                     return Image.asset(
//                                                       "assets/loadingimg.gif",
//                                                       width: 200,
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       : SizedBox(),
//                                   SizedBox(
//                                     height: 4,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   date,
//                                   style: TextStyle(
//                                       color: Colors.black54,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                                 SizedBox(
//                                   width: 8,
//                                 ),
//                                 InkWell(
//                                   onTap: () {
//                                     if (socialFeedSubCommentsReactionsDB.get(
//                                             smReplies
//                                                 .docs[subcommentIndex].id) !=
//                                         null) {
//                                       socialFeedSubCommentsReactionsDB.delete(
//                                           smReplies.docs[subcommentIndex].id);
//                                       socialFeedSubComment
//                                           .deleteSubCommentLikeDetails(
//                                               _currentUserId +
//                                                   smReplies
//                                                       .docs[subcommentIndex]
//                                                       .id);
//                                       databaseReference
//                                           .child("sm_feeds_reply")
//                                           .child("reactions")
//                                           .child(smReplies
//                                               .docs[subcommentIndex].id)
//                                           .update({
//                                         'likecount': int.parse(countData3.child(smReplies
//                                                 .docs[subcommentIndex]
//                                                 .id).child("likecount").value.toString()) -
//                                             1
//                                       });
//                                     } else {
//                                       socialFeedSubCommentsReactionsDB.put(
//                                           smReplies.docs[subcommentIndex].id,
//                                           "Like");

//                                       databaseReference
//                                           .child("sm_feeds_reply")
//                                           .child("reactions")
//                                           .child(smReplies
//                                               .docs[subcommentIndex].id)
//                                           .update({
//                                         'likecount': int.parse(countData3.child(smReplies
//                                                 .docs[subcommentIndex]
//                                                 .id).child("likecount").value.toString()) +
//                                             1
//                                       });
//                                       socialFeedSubComment
//                                           .addFeedSubCommentLikesDetails(
//                                               feedindex,
//                                               commentid,
//                                               smReplies
//                                                   .docs[subcommentIndex].id,
//                                               smReplies.docs[subcommentIndex]
//                                                   .get("userid"),
//                                               smReplies.docs[subcommentIndex]
//                                                   .get("username"),
//                                               smReplies.docs[subcommentIndex]
//                                                   .get("userschoolname"),
//                                               smReplies.docs[subcommentIndex]
//                                                   .get("userprofilepic"),
//                                               "Delhi",
//                                               smReplies.docs[subcommentIndex]
//                                                   .get("usergrade"),
//                                               personaldata.docs[0]
//                                                       .get("firstname") +
//                                                   personaldata.docs[0]
//                                                       .get("lastname"),
//                                               schooldata.docs[0]
//                                                   .get("schoolname"),
//                                               personaldata.docs[0]
//                                                   .get("profilepic"),
//                                               "Delhi",
//                                               schooldata.docs[0].get("grade"),
//                                               current_date,
//                                               comparedate);
//                                       Fluttertoast.showToast(
//                                           msg: "You liked on a reply.",
//                                           toastLength: Toast.LENGTH_SHORT,
//                                           gravity: ToastGravity.BOTTOM,
//                                           timeInSecForIosWeb: 2,
//                                           backgroundColor:
//                                               Color.fromRGBO(37, 36, 36, 1.0),
//                                           textColor: Colors.white,
//                                           fontSize: 12.0);
//                                     }
//                                   },
//                                   child: Text(
//                                     "Like",
//                                     style: TextStyle(
//                                         color: socialFeedSubCommentsReactionsDB
//                                                     .get(smReplies
//                                                         .docs[subcommentIndex]
//                                                         .id) !=
//                                                 null
//                                             ? Color(0xff0962ff)
//                                             : Colors.black54,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w700),
//                                   ),
//                                 ),
//                                 int.parse(countData3.child(smReplies.docs[subcommentIndex]
//                                             .id).child("likecount").value.toString()) >
//                                         0
//                                     ? SizedBox(
//                                         width: 4,
//                                       )
//                                     : SizedBox(),
//                                 int.parse(countData3.child(smReplies.docs[subcommentIndex]
//                                             .id).child("likecount").value.toString()) >
//                                         0
//                                     ? Text(
//                                         " " +
//                                             (countData3.child(smReplies
//                                                     .docs[subcommentIndex]
//                                                     .id).child("likecount")).value
//                                                 .toString() +
//                                             " ",
//                                         style: TextStyle(
//                                             color: socialFeedSubCommentsReactionsDB
//                                                         .get(smReplies
//                                                             .docs[
//                                                                 subcommentIndex]
//                                                             .id) !=
//                                                     null
//                                                 ? Color(0xff0962ff)
//                                                 : Colors.black54,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w400),
//                                       )
//                                     : SizedBox(),
//                                 int.parse(countData3.child(smReplies.docs[subcommentIndex]
//                                             .id).child("likecount").value.toString()) >
//                                         0
//                                     ? Image.asset("assets/reactions/like.gif",
//                                         height: 25, width: 25)
//                                     : SizedBox(),
//                                 SizedBox(
//                                   width: 4,
//                                 ),
//                                 Text(
//                                   " | ",
//                                   style: TextStyle(
//                                       color: Colors.black54,
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.w700),
//                                 ),
//                                 SizedBox(
//                                   width: 4,
//                                 ),
//                                 InkWell(
//                                   onTap: () async {
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 SocialFeedSubComments(
//                                                     this.feedID,
//                                                     feedindex,
//                                                     commentid,
//                                                     commentIndex)));
//                                   },
//                                   child: Text(
//                                     "Reply",
//                                     style: TextStyle(
//                                         color: Colors.black54,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w700),
//                                   ),
//                                 ),
//                                 int.parse(countData3.child(smReplies.docs[subcommentIndex]
//                                             .id).child("commentcount").value.toString()) >
//                                         0
//                                     ? SizedBox(
//                                         width: 4,
//                                       )
//                                     : SizedBox(),
//                                 int.parse(countData3.child(smReplies.docs[subcommentIndex]
//                                             .id).child("commentcount").value.toString()) >
//                                         0
//                                     ? Text(
//                                         " " +
//                                             countData3.child(smReplies
//                                                     .docs[subcommentIndex]
//                                                     .id).child("commentcount").value
//                                                 .toString() +
//                                             " replies",
//                                         style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w400),
//                                       )
//                                     : SizedBox(),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Container(
//             height: (subcommarray[commentIndex].length * 140).toDouble(),
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: subcommarray[commentIndex].length,
//               itemBuilder: (context, i) {
//                 String date = getTimeDifferenceFromNow(smReplies
//                     .docs[subcommarray[commentIndex][i]]
//                     .get("createdate"));
//                 return Container(
//                   margin: EdgeInsets.only(right: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 25,
//                             width: 25,
//                             margin: EdgeInsets.only(right: 10),
//                             child: CircleAvatar(
//                               child: ClipOval(
//                                 child: Container(
//                                   child: Image.network(
//                                     smReplies
//                                         .docs[subcommarray[commentIndex][i]]
//                                         .get("userprofilepic"),
//                                     loadingBuilder: (BuildContext context,
//                                         Widget child,
//                                         ImageChunkEvent loadingProgress) {
//                                       if (loadingProgress == null) return child;
//                                       return Image.asset(
//                                         personaldata.docs[0]
//                                                     .get("usergender") ==
//                                                 "Male"
//                                             ? "assets/maleicon.jpg"
//                                             : "assets/femaleicon.png",
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 10),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Bubble(
//                                   color: Color.fromRGBO(242, 246, 248, 1),
//                                   nip: BubbleNip.leftTop,
//                                   child: Container(
//                                     width: MediaQuery.of(context).size.width /
//                                         1.60,
//                                     decoration: BoxDecoration(
//                                         color: Color.fromRGBO(242, 246, 248, 1),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10))),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               smReplies.docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .get("username"),
//                                               style: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 13.5,
//                                                   fontWeight: FontWeight.w700),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "${smReplies.docs[subcommarray[commentIndex][i]].get("userschoolname")} | Grade ${smReplies.docs[subcommarray[commentIndex][i]].get("usergrade")}",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.w400),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 8,
//                                         ),
//                                         InkWell(
//                                           onTap: () {},
//                                           child: Container(
//                                             child: ReadMoreText(
//                                               smReplies.docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .get("comment"),
//                                               trimLines: 4,
//                                               colorClickableText:
//                                                   Color(0xff0962ff),
//                                               trimMode: TrimMode.Line,
//                                               trimCollapsedText: 'read more',
//                                               trimExpandedText: 'Show less',
//                                               style: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.w500),
//                                               lessStyle: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.w500),
//                                               moreStyle: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.w500),
//                                             ),
//                                           ),
//                                         ),
//                                         smReplies.docs[subcommarray[
//                                                         commentIndex][i]]
//                                                     .get("imagelist") !=
//                                                 ""
//                                             ? Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   InkWell(
//                                                     onTap: () {
//                                                       setState(() {
//                                                         if (smReplies
//                                                                 .docs[subcommarray[
//                                                                         commentIndex]
//                                                                     [i]]
//                                                                 .get(
//                                                                     "imagelist") !=
//                                                             "") {
//                                                           Navigator.push(
//                                                               context,
//                                                               MaterialPageRoute(
//                                                                   builder: (context) => SingleImageView(
//                                                                       smReplies
//                                                                           .docs[subcommarray[commentIndex]
//                                                                               [
//                                                                               i]]
//                                                                           .get(
//                                                                               "imagelist"),
//                                                                       "NetworkImage")));
//                                                         }
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       margin: EdgeInsets.all(5),
//                                                       height: 300,
//                                                       child: Image.network(
//                                                         smReplies
//                                                             .docs[subcommarray[
//                                                                 commentIndex][i]]
//                                                             .get("imagelist"),
//                                                         fit: BoxFit.cover,
//                                                         loadingBuilder:
//                                                             (BuildContext
//                                                                     context,
//                                                                 Widget child,
//                                                                 ImageChunkEvent
//                                                                     loadingProgress) {
//                                                           if (loadingProgress ==
//                                                               null)
//                                                             return child;
//                                                           return Image.asset(
//                                                             "assets/loadingimg.gif",
//                                                             width: 200,
//                                                           );
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               )
//                                             : SizedBox(),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         date,
//                                         style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w400),
//                                       ),
//                                       SizedBox(
//                                         width: 8,
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           if (socialFeedSubCommentsReactionsDB
//                                                   .get(smReplies
//                                                       .docs[subcommarray[
//                                                           commentIndex][i]]
//                                                       .id) !=
//                                               null) {
//                                             socialFeedSubCommentsReactionsDB
//                                                 .delete(smReplies
//                                                     .docs[subcommarray[
//                                                         commentIndex][i]]
//                                                     .id);
//                                             socialFeedSubComment
//                                                 .deleteSubCommentLikeDetails(
//                                                     _currentUserId +
//                                                         smReplies
//                                                             .docs[subcommarray[
//                                                                 commentIndex][i]]
//                                                             .id);
//                                             databaseReference
//                                                 .child("sm_feeds_reply")
//                                                 .child("reactions")
//                                                 .child(smReplies
//                                                     .docs[subcommarray[
//                                                         commentIndex][i]]
//                                                     .id)
//                                                 .update({
//                                               'likecount': int.parse(countData3.child(
//                                                       smReplies
//                                                           .docs[subcommarray[
//                                                               commentIndex][i]]
//                                                           .id).child("likecount").value.toString()) -
//                                                   1
//                                             });
//                                           } else {
//                                             socialFeedSubCommentsReactionsDB
//                                                 .put(
//                                                     smReplies
//                                                         .docs[subcommarray[
//                                                             commentIndex][i]]
//                                                         .id,
//                                                     "Like");

//                                             databaseReference
//                                                 .child("sm_feeds_reply")
//                                                 .child("reactions")
//                                                 .child(smReplies
//                                                     .docs[subcommarray[
//                                                         commentIndex][i]]
//                                                     .id)
//                                                 .update({
//                                               'likecount': int.parse(countData3.child(
//                                                       smReplies
//                                                           .docs[subcommarray[
//                                                               commentIndex][i]]
//                                                           .id).child("likecount").value.toString()) +
//                                                   1
//                                             });
//                                             socialFeedSubComment.addFeedSubCommentLikesDetails(
//                                                 feedindex,
//                                                 commentid,
//                                                 smReplies
//                                                     .docs[
//                                                         subcommarray[commentIndex]
//                                                             [i]]
//                                                     .id,
//                                                 smReplies.docs[subcommarray[commentIndex][i]]
//                                                     .get("userid"),
//                                                 smReplies.docs[subcommarray[commentIndex][i]]
//                                                     .get("username"),
//                                                 smReplies.docs[subcommarray[commentIndex][i]]
//                                                     .get("userschoolname"),
//                                                 smReplies.docs[subcommarray[commentIndex][i]]
//                                                     .get("userprofilepic"),
//                                                 "Delhi",
//                                                 smReplies.docs[
//                                                         subcommarray[commentIndex]
//                                                             [i]]
//                                                     .get("usergrade"),
//                                                 personaldata.docs[0].get("firstname") +
//                                                     personaldata.docs[0]
//                                                         .get("lastname"),
//                                                 schooldata.docs[0]
//                                                     .get("schoolname"),
//                                                 personaldata.docs[0]
//                                                     .get("profilepic"),
//                                                 "Delhi",
//                                                 schooldata.docs[0].get("grade"),
//                                                 current_date,
//                                                 comparedate);
//                                             Fluttertoast.showToast(
//                                                 msg: "You liked on a reply.",
//                                                 toastLength: Toast.LENGTH_SHORT,
//                                                 gravity: ToastGravity.BOTTOM,
//                                                 timeInSecForIosWeb: 2,
//                                                 backgroundColor: Color.fromRGBO(
//                                                     37, 36, 36, 1.0),
//                                                 textColor: Colors.white,
//                                                 fontSize: 12.0);
//                                           }
//                                         },
//                                         child: Text(
//                                           "Like",
//                                           style: TextStyle(
//                                               color: socialFeedSubCommentsReactionsDB
//                                                           .get(smReplies
//                                                               .docs[subcommarray[
//                                                                   commentIndex][i]]
//                                                               .id) !=
//                                                       null
//                                                   ? Color(0xff0962ff)
//                                                   : Colors.black54,
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                       ),
//                                       int.parse(countData3.child(smReplies
//                                                   .docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .id).child("likecount").value.toString()) >
//                                               0
//                                           ? SizedBox(
//                                               width: 4,
//                                             )
//                                           : SizedBox(),
//                                       int.parse(countData3.child(smReplies
//                                                   .docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .id).child("likecount").value.toString()) >
//                                               0
//                                           ? Text(
//                                               " " +
//                                                   (countData3.child(smReplies
//                                                           .docs[subcommarray[
//                                                               commentIndex][i]]
//                                                           .id).child("likecount")).value
//                                                       .toString() +
//                                                   " ",
//                                               style: TextStyle(
//                                                   color: socialFeedSubCommentsReactionsDB
//                                                               .get(smReplies
//                                                                   .docs[subcommarray[
//                                                                       commentIndex][i]]
//                                                                   .id) !=
//                                                           null
//                                                       ? Color(0xff0962ff)
//                                                       : Colors.black54,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w400),
//                                             )
//                                           : SizedBox(),
//                                       int.parse(countData3.child(smReplies
//                                                   .docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .id).child("likecount").value.toString()) >
//                                               0
//                                           ? Image.asset(
//                                               "assets/reactions/like.gif",
//                                               height: 25,
//                                               width: 25)
//                                           : SizedBox(),
//                                       SizedBox(
//                                         width: 4,
//                                       ),
//                                       Text(
//                                         " | ",
//                                         style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 17,
//                                             fontWeight: FontWeight.w700),
//                                       ),
//                                       SizedBox(
//                                         width: 4,
//                                       ),
//                                       InkWell(
//                                         onTap: () async {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       SocialFeedSubComments(
//                                                           this.feedID,
//                                                           feedindex,
//                                                           commentid,
//                                                           commentIndex)));
//                                         },
//                                         child: Text(
//                                           "Reply",
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                       ),
//                                       int.parse(countData3.child(smReplies
//                                                   .docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .id).child("commentcount").value.toString()) >
//                                               0
//                                           ? SizedBox(
//                                               width: 4,
//                                             )
//                                           : SizedBox(),
//                                       int.parse(countData3.child(smReplies
//                                                   .docs[
//                                                       subcommarray[commentIndex]
//                                                           [i]]
//                                                   .id).child("commentcount").value.toString()) >
//                                               0
//                                           ? Text(
//                                               " " +
//                                                   int.parse(countData3.child(smReplies
//                                                           .docs[subcommarray[
//                                                               commentIndex][i]]
//                                                           .id).child("commentcount").value.toString())
//                                                       .toString() +
//                                                   " replies",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w400),
//                                             )
//                                           : SizedBox(),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       i == subcommarray[commentIndex].length - 1
//                           ? InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   subcommarrayshow[commentIndex] =
//                                       !subcommarrayshow[commentIndex];
//                                 });
//                               },
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width / 1.45,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Show less",
//                                       style: TextStyle(
//                                           color: Color.fromRGBO(0, 17, 255, 1),
//                                           fontSize: 13.5,
//                                           fontWeight: FontWeight.w700),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : SizedBox(),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//       }
//     } else
//       return SizedBox();
//   }

//   Widget buildGridView(List imagesFile) {
//     return imagesFile.length == 1
//         ? InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           SingleImageView(imagesFile[0], "NetworkImage")));
//             },
//             child: Container(
//               height: 300,
//               width: 300,
//               child: Image.network(
//                 imagesFile[0],
//                 fit: BoxFit.cover,
//                 loadingBuilder: (BuildContext context, Widget child,
//                     ImageChunkEvent loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Image.asset(
//                     "assets/loadingimg.gif",
//                   );
//                 },
//               ),
//             ),
//           )
//         : InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           GalleryImageView(imagesFile, "NetworkImage")));
//             },
//             child: Container(
//               height: 300,
//               child: GridView.count(
//                 controller: _scrollController,
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.3,
//                 children: List.generate(
//                     imagesFile.length > 4 ? 4 : imagesFile.length, (index) {
//                   return ((index == 3) && (imagesFile.length > 4))
//                       ? Container(
//                           height: 150,
//                           width: 150,
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               Image.network(
//                                 imagesFile[index],
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (BuildContext context,
//                                     Widget child,
//                                     ImageChunkEvent loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Image.asset(
//                                     "assets/loadingimg.gif",
//                                   );
//                                 },
//                               ),
//                               Positioned.fill(
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   color: Colors.black54,
//                                   child: Text(
//                                     '+' + "${imagesFile.length - 4}",
//                                     style: TextStyle(
//                                         fontSize: 32, color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : Image.network(
//                           imagesFile[index],
//                           fit: BoxFit.cover,
//                           loadingBuilder: (BuildContext context, Widget child,
//                               ImageChunkEvent loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Image.asset(
//                               "assets/loadingimg.gif",
//                             );
//                           },
//                         );
//                 }),
//               ),
//             ),
//           );
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

//   Widget showSelectedVideos(int i) {
//     // _onControllerChange(socialfeed.docs[i].get("videolist"), i);
//     return Container(
//         height: 250,
//         child: Stack(
//           fit: StackFit.expand,
//           children: <Widget>[
//             Image.network(
//               socialfeed.docs[i].get("videothumbnail"),
//               fit: BoxFit.cover,
//               loadingBuilder: (BuildContext context, Widget child,
//                   ImageChunkEvent loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Image.asset(
//                   "assets/loadingimg.gif",
//                 );
//               },
//             ),
//             Positioned.fill(
//               child: IconButton(
//                 icon: Icon(
//                   Icons.play_circle_outline,
//                   color: Colors.white,
//                 ),
//                 iconSize: 64,
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return Video_Player(
//                             socialfeed.docs[i].get("videothumbnail"),
//                             socialfeed.docs[i].get("videolist"));
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ));
//   }

//   YYDialog moreOptionsSMPostViewer(BuildContext context, int i) {
//     String gender =
//         socialfeed.docs[i].get("usergender") == "Male" ? "his" : "her";
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
//                             'Add ${socialfeed.docs[i].get("username")} to favourites',
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
//                             'Snooze ${socialfeed.docs[i].get("username")} for 30 days',
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
//                             'Unfollow ${socialfeed.docs[i].get("username")}',
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

//   YYDialog moreOptionsSMPostUser(int i) {
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

//   _chooseHeaderAccordingToMood(
//       String mood, int i, List selectedUserName, List selectedUserID) {
//     String gender =
//         socialfeed.docs[i].get("usergender") == "Male" ? "him" : "her";
//     String celebrategender =
//         socialfeed.docs[i].get("usergender") == "Male" ? "his" : "her";
//     if (mood == "") {
//       return Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
//                   text: socialfeed.docs[i].get("username"),
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
//               socialfeed.docs[i].get("userschoolname") +
//                   ", " +
//                   "Grade " +
//                   socialfeed.docs[i].get("usergrade"),
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
// }
