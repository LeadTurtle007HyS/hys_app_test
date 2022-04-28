
// Future<void> _get_all_cause_post_details() async {
//     setState(() {
      
//       allCausePostData = allSocialPostLocalDB.get("causepost");
//       for (int i = 0; i < allCausePostData.length; i++) {
//         for (int j = 0; j < allPostData.length; j++) {
//           if (allPostData[j]["post_id"] == allCausePostData[i]["post_id"]) {
//             setState(() {
//               allPostLikeCount[j] = allCausePostData[i]["like_count"];
//               allPostCommentCount[j] = allCausePostData[i]["comment_count"];
//               allPostViewCount[j] = allCausePostData[i]["view_count"];
//               allPostImpressionCount[j] =
//                   allCausePostData[i]["impression_count"];
//             });
//           }
//         }
//       }
//     });
//   }

//   Future<void> _get_all_cause_post_details_api() async {
     
//     final http.Response response = await http.get(
//       Uri.parse('https://hys-api.herokuapp.com/get_all_sm_cause_posts'),
//     );

//     print("get_all_sm_cause_posts: ${response.statusCode}");
//     if ((response.statusCode == 200) || (response.statusCode == 201)) {
//       setState(() {
        
//         allSocialPostLocalDB.put("causepost", json.decode(response.body));
//       });
//     }
//   }


//    List<dynamic> userDatainit = [];
//   Map<dynamic, dynamic> userData = {};
//   Future<void> _get_userData() async {
    
  
//     final http.Response response = await http.get(
//       Uri.parse('https://hys-api.herokuapp.com/get_user_data/$_currentUserId'),
//     );

//     print("get_user_data: ${response.statusCode}");
//     if ((response.statusCode == 200) || (response.statusCode == 201)) {
//       setState(() {
//         userDatainit = json.decode(response.body);
//         print(userDatainit);
//         userData = userDatainit[0];
//         //  userDataDB!.put("user_id", userData["user_id"]);
//         userDataDB.put("first_name", userData["first_name"]);
//         userDataDB.put("last_name", userData["last_name"]);
//         userDataDB.put("email_id", userData["email_id"]);
//         userDataDB.put("mobile_no", userData["mobile_no"]);
//         userDataDB.put("address", userData["address"]);
//         userDataDB.put("board", userData["board"]);
//         userDataDB.put("city", userData["city"]);
//         userDataDB.put("gender", userData["gender"]);
//         userDataDB.put("grade", userData["grade"]);
//         userDataDB.put("profilepic", userData["profilepic"]);
//         userDataDB.put("school_address", userData["school_address"]);
//         userDataDB.put("school_city", userData["school_city"]);
//         userDataDB.put("school_name", userData["school_name"]);
//         userDataDB.put("school_state", userData["school_state"]);
//         userDataDB.put("school_street", userData["school_street"]);
//         userDataDB.put("state", userData["state"]);
//         userDataDB.put("stream", userData["stream"]);
//         userDataDB.put("street", userData["street"]);
//         userDataDB.put("user_dob", userData["user_dob"]);
//       });
//     }
//   }
//   // _event(int i, String id) {
//   //   bool whiteflag = false;
//   //   String poster = socialfeed.docs[i].get('poster') != null
//   //       ? socialfeed.docs[i].get('poster')
//   //       : "";
//   //   if (socialfeed.docs[i].get('themeindex') == 0 ||
//   //       socialfeed.docs[i].get('themeindex') == 2 ||
//   //       socialfeed.docs[i].get('themeindex') == 4 ||
//   //       socialfeed.docs[i].get('themeindex') == 5) {
//   //     whiteflag = true;
//   //   }
//   //   return Container(
//   //       padding: EdgeInsets.only(top: 5),
//   //       margin: EdgeInsets.all(7),
//   //       decoration: BoxDecoration(
//   //           color: Color.fromRGBO(242, 246, 248, 1),
//   //           borderRadius: BorderRadius.all(Radius.circular(20))),
//   //       child: Column(children: [
//   //         Padding(
//   //           padding: const EdgeInsets.only(left: (5.0), right: 2),
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               Container(
//   //                 child: Row(
//   //                   children: [
//   //                     InkWell(
//   //                       onTap: () {},
//   //                       child: CircleAvatar(
//   //                         child: ClipOval(
//   //                           child: Container(
//   //                             width: MediaQuery.of(context).size.width / 10.34,
//   //                             height: MediaQuery.of(context).size.width / 10.34,
//   //                             child: Image.network(
//   //                               socialfeed.docs[i].get("userprofilepic"),
//   //                               loadingBuilder: (BuildContext context,
//   //                                   Widget child,
//   //                                   ImageChunkEvent loadingProgress) {
//   //                                 if (loadingProgress == null) return child;
//   //                                 return Image.asset(
//   //                                   "assets/maleicon.jpg",
//   //                                 );
//   //                               },
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     SizedBox(
//   //                       width: 10,
//   //                     ),
//   //                     Container(
//   //                       child: Column(
//   //                         crossAxisAlignment: CrossAxisAlignment.start,
//   //                         children: [
//   //                           Row(children: [
//   //                             Text(socialfeed.docs[i].get('username'),
//   //                                 style: TextStyle(
//   //                                   fontFamily: 'Nunito Sans',
//   //                                   fontSize: 15,
//   //                                   color: Colors.black87,
//   //                                   fontWeight: FontWeight.w500,
//   //                                 )),
//   //                             Text(' has Created a Cause '),
//   //                             Container(
//   //                                 height: 20,
//   //                                 width: 20,
//   //                                 child: Image.asset('assets/causeEmoji.png')),
//   //                           ]),
//   //                           Row(
//   //                             children: [
//   //                               Text('to Educate UnderPrivileged Childrens.',
//   //                                   style: TextStyle(
//   //                                       color: Colors.black87,
//   //                                       fontWeight: FontWeight.w500))
//   //                             ],
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //               IconButton(
//   //                   icon: Icon(FontAwesome5.ellipsis_h,
//   //                       color: Color.fromRGBO(0, 0, 0, 0.8), size: 10),
//   //                   onPressed: () {
//   //                     moreOptionsSMPostViewer(context, i);
//   //                   }),
//   //             ],
//   //           ),
//   //         ),
//   //         InkWell(
//   //           onTap: () {},
//   //           child: Container(
//   //             width: MediaQuery.of(context).size.width - 30,
//   //             margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
//   //             child: ReadMoreText(
//   //               socialfeed.docs[i].get("message"),
//   //               textAlign: TextAlign.left,
//   //               trimLines: 4,
//   //               colorClickableText: Color(0xff0962ff),
//   //               trimMode: TrimMode.Line,
//   //               trimCollapsedText: 'read more',
//   //               trimExpandedText: 'Show less',
//   //               style: TextStyle(
//   //                 fontFamily: 'Nunito Sans',
//   //                 fontSize: 14,
//   //                 color: Color.fromRGBO(0, 0, 0, 0.8),
//   //                 fontWeight: FontWeight.w400,
//   //               ),
//   //               lessStyle: TextStyle(
//   //                 fontFamily: 'Nunito Sans',
//   //                 fontSize: 12,
//   //                 color: Color(0xff0962ff),
//   //                 fontWeight: FontWeight.w700,
//   //               ),
//   //               moreStyle: TextStyle(
//   //                 fontFamily: 'Nunito Sans',
//   //                 fontSize: 12,
//   //                 color: Color(0xff0962ff),
//   //                 fontWeight: FontWeight.w700,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         SizedBox(height: 10),
//   //         (socialfeed.docs[i].get('poster') != null)
//   //             ? Container(
//   //                 height: 250,
//   //                 width: MediaQuery.of(context).size.width,
//   //                 child: Image.network(socialfeed.docs[i].get('poster'),
//   //                     fit: BoxFit.contain))
//   //             : SizedBox(),
//   //         Container(
//   //           decoration: BoxDecoration(
//   //               image: DecorationImage(
//   //                   colorFilter: new ColorFilter.mode(
//   //                       Colors.black.withOpacity(0.8), BlendMode.dstATop),
//   //                   image: AssetImage(socialfeed.docs[i].get('theme')),
//   //                   fit: BoxFit.fill)),
//   //           child: Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: Row(children: [
//   //               Column(
//   //                   mainAxisAlignment: MainAxisAlignment.start,
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Class :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Subject :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Frequency :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Date :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Time :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                     Container(
//   //                       height: 20,
//   //                       child: Text('Venue :',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: whiteflag == true
//   //                                   ? Colors.white
//   //                                   : Colors.black87)),
//   //                     ),
//   //                     SizedBox(
//   //                       height: 5,
//   //                     ),
//   //                   ]),
//   //               SizedBox(width: 4),
//   //               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//   //                 SizedBox(height: 5),
//   //                 Container(
//   //                     width: 100,
//   //                     height: 20,
//   //                     child: Text(
//   //                       socialfeed.docs[i].get('grade'),
//   //                       textAlign: TextAlign.start,
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.w600,
//   //                           color: whiteflag == true
//   //                               ? Colors.white
//   //                               : Colors.black87),
//   //                     )),
//   //                 SizedBox(
//   //                   height: 5,
//   //                 ),
//   //                 Container(
//   //                     height: 20,
//   //                     width: 100,
//   //                     child: Text(
//   //                       socialfeed.docs[i].get('subject'),
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.w600,
//   //                           color: whiteflag == true
//   //                               ? Colors.white
//   //                               : Colors.black87),
//   //                       textAlign: TextAlign.start,
//   //                     )),
//   //                 SizedBox(
//   //                   height: 5,
//   //                 ),
//   //                 Container(
//   //                     height: 20,
//   //                     width: 100,
//   //                     child: Text(
//   //                       socialfeed.docs[i].get('frequency'),
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.w600,
//   //                           color: whiteflag == true
//   //                               ? Colors.white
//   //                               : Colors.black87),
//   //                       textAlign: TextAlign.start,
//   //                     )),
//   //                 SizedBox(
//   //                   height: 5,
//   //                 ),
//   //                 Container(
//   //                     height: 20,
//   //                     width: 100,
//   //                     child: Text(
//   //                       socialfeed.docs[i].get('date'),
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.w600,
//   //                           color: whiteflag == true
//   //                               ? Colors.white
//   //                               : Colors.black87),
//   //                       textAlign: TextAlign.start,
//   //                     )),
//   //                 SizedBox(
//   //                   height: 5,
//   //                 ),
//   //                 Container(
//   //                     width: 150,
//   //                     child: Text(
//   //                       socialfeed.docs[i].get('from') +
//   //                           ' to ' +
//   //                           socialfeed.docs[i].get('to'),
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.w600,
//   //                           color: whiteflag == true
//   //                               ? Colors.white
//   //                               : Colors.black87),
//   //                       textAlign: TextAlign.start,
//   //                     )),
//   //                 SizedBox(
//   //                   height: 5,
//   //                 ),
//   //                 Row(children: [
//   //                   socialfeed.docs[i].get('eventtype') == "offline"
//   //                       ? Container(
//   //                           width: 150,
//   //                           child: Text(
//   //                             socialfeed.docs[i].get('address'),
//   //                             style: TextStyle(
//   //                                 fontWeight: FontWeight.w600,
//   //                                 color: whiteflag == true
//   //                                     ? Colors.white
//   //                                     : Colors.black87),
//   //                             textAlign: TextAlign.start,
//   //                           ))
//   //                       : Container(
//   //                           width: 150,
//   //                           child: Text(
//   //                             "HyS Online Meet",
//   //                             style: TextStyle(
//   //                                 fontWeight: FontWeight.w600,
//   //                                 color: whiteflag == true
//   //                                     ? Colors.white
//   //                                     : Colors.black87),
//   //                             textAlign: TextAlign.start,
//   //                           )),
//   //                   socialfeed.docs[i].get('eventtype') == "offline"
//   //                       ? InkWell(
//   //                           onTap: () {
//   //                             Navigator.push(
//   //                                 context,
//   //                                 MaterialPageRoute(
//   //                                     builder: (context) => MapLocation(
//   //                                         socialfeed.docs[i].get('latitude'),
//   //                                         socialfeed.docs[i]
//   //                                             .get('longitude'))));
//   //                           },
//   //                           child: Text(
//   //                             '(Map to Venue)',
//   //                             style: TextStyle(
//   //                                 fontWeight: FontWeight.w600,
//   //                                 color: Colors.blue),
//   //                           ))
//   //                       : SizedBox(),
//   //                 ]),
//   //                 SizedBox(height: 10),
//   //               ]),
//   //             ]),
//   //           ),
//   //         ),
//   //         SizedBox(
//   //           height: 10,
//   //         ),
//   //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//   //           Text(socialfeed.docs[i].get('eventname'),
//   //               style: TextStyle(
//   //                   fontWeight: FontWeight.w700,
//   //                   fontSize: 15,
//   //                   color: Color.fromRGBO(88, 165, 196, 1))),
//   //           Container(
//   //               child: Row(children: [
//   //             Text(
//   //                 socialfeed.docs[i].get('date') +
//   //                     ' ' +
//   //                     socialfeed.docs[i].get('from') +
//   //                     ' to ' +
//   //                     socialfeed.docs[i].get('to'),
//   //                 style: TextStyle(
//   //                     fontWeight: FontWeight.w700,
//   //                     fontSize: 14,
//   //                     color: Color.fromRGBO(88, 165, 196, 1))),
//   //           ]))
//   //         ]),
//   //         SizedBox(
//   //           height: 10,
//   //         ),
//   //         Container(
//   //             padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
//   //             child: Column(
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 children: [
//   //                   Padding(
//   //                       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//   //                       child: Row(
//   //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                           children: [
//   //                             InkWell(
//   //                               onTap: () {},
//   //                               child: Container(
//   //                                 child: Row(
//   //                                   mainAxisAlignment: MainAxisAlignment.start,
//   //                                   children: [
//   //                                     Text(
//   //                                       countData.child(socialfeed.docs[i].id).child("likecount")
//   //                                           .toString(),
//   //                                       style: TextStyle(
//   //                                           fontFamily: 'Nunito Sans',
//   //                                           color:
//   //                                               Color.fromRGBO(205, 61, 61, 1)),
//   //                                     ),
//   //                                     SizedBox(
//   //                                       width: 4,
//   //                                     ),
//   //                                     Image.asset("assets/reactions/like.png",
//   //                                         height: 15, width: 15),
//   //                                     Image.asset("assets/reactions/laugh.png",
//   //                                         height: 15, width: 15),
//   //                                     Image.asset("assets/reactions/wow.png",
//   //                                         height: 15, width: 15),
//   //                                   ],
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                             InkWell(
//   //                               onTap: () {
//   //                                 Navigator.push(
//   //                                     context,
//   //                                     MaterialPageRoute(
//   //                                         builder: (context) =>
//   //                                             ShowSocialFeedComments(
//   //                                                 socialfeed.docs[i].id)));
//   //                               },
//   //                               child: Container(
//   //                                 child: RichText(
//   //                                   text: TextSpan(
//   //                                       text: countData
//   //                                          .child(socialfeed.docs[i].id).child("commentcount")
//   //                                           .toString(),
//   //                                       style: TextStyle(
//   //                                         fontFamily: 'Nunito Sans',
//   //                                         color: Color.fromRGBO(205, 61, 61, 1),
//   //                                       ),
//   //                                       children: <TextSpan>[
//   //                                         TextSpan(
//   //                                           text: ' Comments',
//   //                                           style: TextStyle(
//   //                                             fontFamily: 'Nunito Sans',
//   //                                             fontSize: 12,
//   //                                             color:
//   //                                                 Color.fromRGBO(0, 0, 0, 0.8),
//   //                                             fontWeight: FontWeight.w500,
//   //                                           ),
//   //                                         )
//   //                                       ]),
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                             Container(
//   //                               child: Row(
//   //                                 children: [
//   //                                   SizedBox(
//   //                                     width: 30,
//   //                                   ),
//   //                                   Text(
//   //                                     countData.child(socialfeed.docs[i].id).child("viewscount")
//   //                                         .toString(),
//   //                                     style: TextStyle(
//   //                                         fontFamily: 'Nunito Sans',
//   //                                         color:
//   //                                             Color.fromRGBO(205, 61, 61, 1)),
//   //                                   ),
//   //                                   SizedBox(
//   //                                     width: 4,
//   //                                   ),
//   //                                   Icon(FontAwesome5.eye,
//   //                                       color: Color.fromRGBO(0, 0, 0, 0.8),
//   //                                       size: 12),
//   //                                 ],
//   //                               ),
//   //                             )
//   //                           ]))
//   //                 ])),
//   //         Container(
//   //             margin: EdgeInsets.only(left: 2, right: 2, top: 5),
//   //             color: Colors.white54,
//   //             height: 1,
//   //             width: MediaQuery.of(context).size.width),
//   //         Padding(
//   //             padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//   //             child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   InkWell(
//   //                     child: Container(
//   //                         child: Row(mainAxisSize: MainAxisSize.min, children: [
//   //                       Container(
//   //                         padding: EdgeInsets.only(top: 15, bottom: 15),
//   //                         child: Row(
//   //                           children: [
//   //                             FlutterReactionButtonCheck(
//   //                               onReactionChanged:
//   //                                   (reaction, index, ischecked) {
//   //                                 setState(() {
//   //                                   _reactionIndex[i] = index;
//   //                                 });

//   //                                 if (socialFeedPostReactionsDB.get(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id) !=
//   //                                     null) {
//   //                                   if (index == -1) {
//   //                                     setState(() {
//   //                                       _reactionIndex[i] = -2;
//   //                                     });
//   //                                     _notificationdb
//   //                                         .deleteSocialFeedReactionsNotification(
//   //                                             socialfeed.docs[i].id);
//   //                                     socialFeedPostReactionsDB.delete(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id);
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) -
//   //                                           1
//   //                                     });
//   //                                   } else {
//   //                                     if (_reactionIndex[i] == 0) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0]
//   //                                                   .get("profilepic"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("username"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " liked your post.",
//   //                                               "You got a like!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Like",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Like");
//   //                                     } else if (_reactionIndex[i] == 1) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0]
//   //                                                   .get("profilepic"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("username"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " loved your post.",
//   //                                               "You got a reaction!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Love",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Love");
//   //                                     } else if (_reactionIndex[i] == 2) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0]
//   //                                                   .get("profilepic"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("username"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " reacted haha on your post.",
//   //                                               "You got a reaction!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Haha",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Haha");
//   //                                     } else if (_reactionIndex[i] == 3) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0].get(
//   //                                                       "firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0].get(
//   //                                                   "profilepic"),
//   //                                               socialfeed.docs[i].get(
//   //                                                   "username"),
//   //                                               socialfeed
//   //                                                   .docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata
//   //                                                       .docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " reacted yay on your post.",
//   //                                               "You got a reaction!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Yay",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Yay");
//   //                                     } else if (_reactionIndex[i] == 4) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0].get(
//   //                                                       "firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0].get(
//   //                                                   "profilepic"),
//   //                                               socialfeed.docs[i].get(
//   //                                                   "username"),
//   //                                               socialfeed
//   //                                                   .docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata
//   //                                                       .docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " reacted wow on your post.",
//   //                                               "You got a reaction!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Wow",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Wow");
//   //                                     } else if (_reactionIndex[i] == 5) {
//   //                                       _notificationdb
//   //                                           .socialFeedReactionsNotifications(
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname"),
//   //                                               personaldata.docs[0]
//   //                                                   .get("profilepic"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("username"),
//   //                                               socialfeed.docs[i]
//   //                                                   .get("userid"),
//   //                                               personaldata.docs[0]
//   //                                                       .get("firstname") +
//   //                                                   " " +
//   //                                                   personaldata.docs[0]
//   //                                                       .get("lastname") +
//   //                                                   " reacted angry on your post.",
//   //                                               "You got a reaction!",
//   //                                               current_date,
//   //                                               usertokendataLocalDB.get(
//   //                                                   socialfeed.docs[i]
//   //                                                       .get("userid")),
//   //                                               socialfeed.docs[i].id,
//   //                                               i,
//   //                                               "Angry",
//   //                                               comparedate);
//   //                                       socialFeedPostReactionsDB.put(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id,
//   //                                           "Angry");
//   //                                     }
//   //                                   }
//   //                                 } else {
//   //                                   if (_reactionIndex[i] == -1) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " liked your post.",
//   //                                             "You got a like!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Like",
//   //                                             comparedate);
//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Like");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 0) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " liked your post.",
//   //                                             "You got a like!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Like",
//   //                                             comparedate);
//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Like");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 1) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " loved your post.",
//   //                                             "You got a reaction!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Love",
//   //                                             comparedate);

//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Love");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 2) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " reacted haha on your post.",
//   //                                             "You got a reaction!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Haha",
//   //                                             comparedate);

//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Haha");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 3) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " reacted yay on your post.",
//   //                                             "You got a reaction!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Yay",
//   //                                             comparedate);
//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Yay");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 4) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0].get(
//   //                                                     "firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata
//   //                                                     .docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " reacted wow on your post.",
//   //                                             "You got a reaction!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Wow",
//   //                                             comparedate);
//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Wow");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   } else if (_reactionIndex[i] == 5) {
//   //                                     _notificationdb
//   //                                         .socialFeedReactionsNotifications(
//   //                                             personaldata.docs[0]
//   //                                                     .get("firstname") +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname"),
//   //                                             personaldata.docs[0]
//   //                                                 .get("profilepic"),
//   //                                             socialfeed.docs[i]
//   //                                                 .get("username"),
//   //                                             socialfeed.docs[i].get("userid"),
//   //                                             personaldata.docs[0]
//   //                                                     .get("firstname") +
//   //                                                 " " +
//   //                                                 personaldata.docs[0]
//   //                                                     .get("lastname") +
//   //                                                 " reacted angry on your post.",
//   //                                             "You got a reaction!",
//   //                                             current_date,
//   //                                             usertokendataLocalDB.get(
//   //                                                 socialfeed.docs[i]
//   //                                                     .get("userid")),
//   //                                             socialfeed.docs[i].id,
//   //                                             i,
//   //                                             "Angry",
//   //                                             comparedate);
//   //                                     socialFeedPostReactionsDB.put(
//   //                                         _currentUserId +
//   //                                             socialfeed.docs[i].id,
//   //                                         "Angry");
//   //                                     databaseReference
//   //                                         .child("sm_feeds")
//   //                                         .child("reactions")
//   //                                         .child(socialfeed.docs[i].id)
//   //                                         .update({
//   //                                       'likecount': int.parse(countData.child(socialfeed
//   //                                               .docs[i].id).child("likecount").value) +
//   //                                           1
//   //                                     });
//   //                                   }
//   //                                   socialFeed.updateReactionCount(
//   //                                       socialfeed.docs[i].id, {
//   //                                     "likescount":
//   //                                         countData.child(socialfeed.docs[i].id).child("likecount")
//   //                                   });
//   //                                 }
//   //                               },
//   //                               reactions: reactions,
//   //                               initialReaction: _reactionIndex[i] == -1
//   //                                   ? Reaction(
//   //                                       icon: Row(
//   //                                         children: [
//   //                                           Icon(FontAwesome5.thumbs_up,
//   //                                               color: Color(0xff0962ff),
//   //                                               size: 14),
//   //                                           Text(
//   //                                             "  Like",
//   //                                             style: TextStyle(
//   //                                                 fontSize: 13,
//   //                                                 fontWeight: FontWeight.w700,
//   //                                                 color: Color(0xff0962ff)),
//   //                                           )
//   //                                         ],
//   //                                       ),
//   //                                     )
//   //                                   : _reactionIndex[i] == -2
//   //                                       ? Reaction(
//   //                                           icon: Row(
//   //                                             children: [
//   //                                               Icon(FontAwesome5.thumbs_up,
//   //                                                   color: Color.fromRGBO(
//   //                                                       0, 0, 0, 0.8),
//   //                                                   size: 14),
//   //                                               Text(
//   //                                                 "  Like",
//   //                                                 style: TextStyle(
//   //                                                     fontSize: 13,
//   //                                                     fontWeight:
//   //                                                         FontWeight.w700,
//   //                                                     color: Colors.black45),
//   //                                               )
//   //                                             ],
//   //                                           ),
//   //                                         )
//   //                                       : reactions[_reactionIndex[i]],
//   //                               selectedReaction: Reaction(
//   //                                 icon: Row(
//   //                                   children: [
//   //                                     Icon(FontAwesome5.thumbs_up,
//   //                                         color: Color.fromRGBO(0, 0, 0, 0.8),
//   //                                         size: 14),
//   //                                     Text(
//   //                                       "  Like",
//   //                                       style: TextStyle(
//   //                                           fontSize: 13,
//   //                                           fontWeight: FontWeight.w700,
//   //                                           color: Colors.black45),
//   //                                     )
//   //                                   ],
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ),
//   //                     ])),
//   //                   ),
//   //                   InkWell(
//   //                     onTap: () {
//   //                       if (socialEventSubCommLike
//   //                               .get(_currentUserId + socialfeed.docs[i].id) !=
//   //                           null) {
//   //                         _handleunjoinbutton(context, socialfeed.docs[i].id);
//   //                       } else {
//   //                         _handlejoinbutton(context, socialfeed.docs[i].id, i);

//   //                         date1 = socialfeed.docs[i].get('DateTime');
//   //                         String yr = date1.substring(0, 4);
//   //                         String mnth = date1.substring(5, 7);
//   //                         String day = date1.substring(8, 10);
//   //                         eventName1 = socialfeed.docs[i].get('eventname');

//   //                         fromtime1 = socialfeed.docs[i].get('from24hrs');
//   //                         String hr = fromtime1.substring(0, 2);
//   //                         String min = fromtime1.substring(3, 5);
//   //                         totime1 = socialfeed.docs[i].get('to24hrs');
//   //                         freq1 = socialfeed.docs[i].get('frequency');
//   //                         showNotification(
//   //                             "$eventName1 event ",
//   //                             "$eventName1 is started, join now!",
//   //                             socialfeed.docs[i].get('meetingid'),
//   //                             int.parse(yr),
//   //                             int.parse(mnth),
//   //                             int.parse(day),
//   //                             int.parse(hr),
//   //                             int.parse(min));
//   //                       }
//   //                     },
//   //                     child: Container(
//   //                       child: Row(
//   //                         mainAxisAlignment: MainAxisAlignment.start,
//   //                         children: [
//   //                           Icon(FontAwesome5.user_friends,
//   //                               color: socialEventSubCommLike.get(
//   //                                           _currentUserId +
//   //                                               socialfeed.docs[i].id) !=
//   //                                       null
//   //                                   ? Color(0xff0962ff)
//   //                                   : Color.fromRGBO(0, 0, 0, 0.8),
//   //                               size: 14),
//   //                           Text(
//   //                             "   Join",
//   //                             style: TextStyle(
//   //                                 fontSize: 13,
//   //                                 fontWeight: FontWeight.w700,
//   //                                 color: socialEventSubCommLike.get(
//   //                                             _currentUserId +
//   //                                                 socialfeed.docs[i].id) !=
//   //                                         null
//   //                                     ? Color(0xff0962ff)
//   //                                     : Colors.black45),
//   //                           )
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   InkWell(
//   //                     onTap: () {
//   //                       Navigator.push(
//   //                           context,
//   //                           MaterialPageRoute(
//   //                               builder: (context) => SocialFeedAddComments(
//   //                                   socialfeed.docs[i].id)));
//   //                     },
//   //                     child: Container(
//   //                       child: Row(
//   //                         mainAxisAlignment: MainAxisAlignment.start,
//   //                         children: [
//   //                           Icon(FontAwesome5.comment,
//   //                               color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
//   //                           Text(
//   //                             "  Comment",
//   //                             style: TextStyle(
//   //                                 fontSize: 13,
//   //                                 fontWeight: FontWeight.w700,
//   //                                 color: Colors.black45),
//   //                           )
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   /* InkWell(
//   //                     child: Container(
//   //                         child: Row(mainAxisSize: MainAxisSize.min, children: [
//   //                       IconButton(
//   //                           icon: Icon(FontAwesome5.comment,
//   //                               color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
//   //                           onPressed: () {
//   //                             Navigator.push(
//   //                                 context,
//   //                                 MaterialPageRoute(
//   //                                     builder: (context) => SocialEventComments(
//   //                                         socialfeed.docs[i].id, i)));
//   //                           }),
//   //                       Text('Comment',
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: Colors.black54))
//   //                     ])),
//   //                   ),*/
//   //                   /*Text((count > 0) ? '$count'+ 'Comments' : 'Comment',
//   //                             style: TextStyle(
//   //                                 fontSize: 13, fontWeight: FontWeight.w500))*/
//   //                   Container(
//   //                     child: Row(
//   //                       mainAxisAlignment: MainAxisAlignment.start,
//   //                       children: [
//   //                         Icon(FontAwesome5.share,
//   //                             color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
//   //                         Text(
//   //                           "  Share",
//   //                           style: TextStyle(
//   //                               fontSize: 13,
//   //                               fontWeight: FontWeight.w700,
//   //                               color: Colors.black45),
//   //                         )
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ])),
//   //         Container(
//   //             margin: EdgeInsets.only(left: 2, right: 2, top: 5),
//   //             color: Colors.white54,
//   //             height: 1,
//   //             width: MediaQuery.of(context).size.width),
//   //         SizedBox(
//   //           height: 10,
//   //         ),
//   //         InkWell(
//   //             onTap: () {
//   //               handlePressButton(context);
//   //             },
//   //             child: Row(
//   //               children: [
//   //                 Icon(Icons.person_add),
//   //                 Text(' Invite Friends To Join')
//   //               ],
//   //             )),
//   //         SizedBox(
//   //           height: 7,
//   //         ),
//   //       ]));
//   // }
