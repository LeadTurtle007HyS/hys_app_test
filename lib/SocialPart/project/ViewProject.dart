import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hys/SocialPart/VideoPlayerWidgets/video_player.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:hys/SocialPart/database/SocialDiscussDB.dart';

class ViewProject extends StatefulWidget {
  @override
  _ViewProjectState createState() => _ViewProjectState();
}

SocialDiscuss socialobj = SocialDiscuss();
QuerySnapshot projectData;

class _ViewProjectState extends State<ViewProject> {
  @override
  void initState() {
    socialobj.getDiscussedProjects().then((value) {
      setState(() {
        projectData = value;
        if (projectData != null) {}
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  _body() {
    if ((projectData != null)) {
      return ListView.builder(
        itemCount: projectData.docs.length,
        itemBuilder: (BuildContext context, int i) {
          return _event(i, projectData.docs[i].id);
        },
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

  _event(int i, String id) {
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
                              child: Image.network(
                                projectData.docs[i].get("userprofilepic"),
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
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
                            Row(children: [
                              Text(projectData.docs[i].get('username'),
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(' has Discussed a Project on '),
                              // Text(projectData.docs[i].get("title"),
                              //     style: TextStyle(fontWeight: FontWeight.w500))
                            ]),
                            Row(
                              children: [
                                Text(projectData.docs[i].get('title'),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color.fromRGBO(88, 165, 196, 1)),
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
                                        ' Public ',
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
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Text(projectData.docs[i].get("content"))),
          SizedBox(
            height: 5,
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    image: AssetImage(projectData.docs[i].get("theme")),
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
                          projectData.docs[i].get('title'),
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
                          "Class : ",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          projectData.docs[i].get('grade'),
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
                          projectData.docs[i].get('subject'),
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
                          projectData.docs[i].get('topic'),
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
                            (projectData.docs[i].get("projectvideourl") != null)
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Video_Player(
                                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                projectData.docs[i]
                                                    .get("projectvideourl"));
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
                            (projectData.docs[i].get("reqvideourl") != null)
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Video_Player(
                                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                                projectData.docs[i]
                                                    .get("reqvideourl"));
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
                            (projectData.docs[i].get("otherdoc") != null)
                                ? InkWell(
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
                          Container(
                            child: Text("....See More",
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue)),
                          )
                        ])
                  ],
                ),
              )),
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
                                        '5',
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
                                onTap: () {},
                                child: Container(
                                  child: RichText(
                                    text: TextSpan(
                                        text: "5",
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
                                      "20",
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
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        child: Container(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(FontAwesome5.thumbs_up,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  size: 14),
                            )
                            //     FlutterReactionButtonCheck(
                            //       onReactionChanged:
                            //           (reaction, index, ischecked) {
                            //         setState(() {
                            //           _reactionIndex[i] = index;
                            //         });

                            //         if (eventReactions.get(_currentUserId +
                            //                 eventData.docs[i].id) !=
                            //             null) {
                            //           if (index == -1) {
                            //             setState(() {
                            //               _reactionIndex[i] = -2;
                            //             });
                            //             _notificationdb
                            //                 .deleteSocialEventReactionsNotification(
                            //                     _currentUserId +
                            //                         eventData.docs[i].id +
                            //                         "Like");
                            //             eventReactions.delete(_currentUserId +
                            //                 eventData.docs[i].id);
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] -
                            //                   1
                            //             });
                            //           } else {
                            //             if (_reactionIndex[i] == 0) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0]
                            //                           .get("profilepic"),
                            //                       eventData.docs[i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       userdetails.docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " liked your post.",
                            //                       "You got a like!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Like",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Like");
                            //             } else if (_reactionIndex[i] == 1) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           ' ' +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0]
                            //                           .get("profilepic"),
                            //                       eventData.docs[i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       userdetails.docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " loved your post.",
                            //                       "You got a reaction!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Love",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Love");
                            //             } else if (_reactionIndex[i] == 2) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0].get(
                            //                           "profilepic"),
                            //                       eventData.docs[
                            //                               i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       userdetails
                            //                               .docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " reacted haha on your post.",
                            //                       "You got a reaction!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Haha",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Haha");
                            //             } else if (_reactionIndex[i] == 3) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0]
                            //                           .get("profilepic"),
                            //                       eventData.docs[i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       userdetails.docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " reacted yay on your post.",
                            //                       "You got a reaction!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Yay",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Yay");
                            //             } else if (_reactionIndex[i] == 4) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0]
                            //                           .get("profilepic"),
                            //                       eventData.docs[i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       eventData.docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " reacted wow on your post.",
                            //                       "You got a reaction!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Wow",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Wow");
                            //             } else if (_reactionIndex[i] == 5) {
                            //               _notificationdb
                            //                   .socialEventReactionsNotifications(
                            //                       userdetails.docs[0].get(
                            //                               "firstname") +
                            //                           userdetails.docs[0]
                            //                               .get("lastname"),
                            //                       userdetails.docs[0]
                            //                           .get("profilepic"),
                            //                       eventData.docs[i]
                            //                           .get("username"),
                            //                       eventData.docs[i].get("userid"),
                            //                       userdetails.docs[0]
                            //                               .get("firstname") +
                            //                           " " +
                            //                           userdetails.docs[0]
                            //                               .get("lastname") +
                            //                           " reacted angry on your post.",
                            //                       "You got a reaction!",
                            //                       current_date,
                            //                       usertokendataLocalDB.get(
                            //                           eventData.docs[i]
                            //                               .get("userid")),
                            //                       eventData.docs[i].id,
                            //                       i,
                            //                       "Angry",
                            //                       comparedate);
                            //               eventReactions.put(
                            //                   _currentUserId +
                            //                       eventData.docs[i].id,
                            //                   "Angry");
                            //             }
                            //           }
                            //         } else {
                            //           if (_reactionIndex[i] == -1) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " liked your post.",
                            //                     "You got a like!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Like",
                            //                     comparedate);

                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Like");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 0) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " liked your post.",
                            //                     "You got a like!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Like",
                            //                     comparedate);
                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Like");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 1) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " loved your post.",
                            //                     "You got a reaction!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Love",
                            //                     comparedate);

                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Love");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 2) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " reacted haha on your post.",
                            //                     "You got a reaction!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Haha",
                            //                     comparedate);
                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Haha");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 3) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " reacted yay on your post.",
                            //                     "You got a reaction!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Yay",
                            //                     comparedate);
                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Yay");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 4) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0].get(
                            //                             "firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0].get(
                            //                         "profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails
                            //                             .docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " reacted wow on your post.",
                            //                     "You got a reaction!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Wow",
                            //                     comparedate);
                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Wow");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           } else if (_reactionIndex[i] == 5) {
                            //             _notificationdb
                            //                 .socialEventReactionsNotifications(
                            //                     userdetails.docs[0]
                            //                             .get("firstname") +
                            //                         userdetails.docs[0]
                            //                             .get("lastname"),
                            //                     userdetails.docs[0]
                            //                         .get("profilepic"),
                            //                     eventData.docs[i].get("username"),
                            //                     eventData.docs[i].get("userid"),
                            //                     userdetails.docs[0]
                            //                             .get("firstname") +
                            //                         " " +
                            //                         userdetails.docs[0]
                            //                             .get("lastname") +
                            //                         " reacted angry on your post.",
                            //                     "You got a reaction!",
                            //                     current_date,
                            //                     usertokendataLocalDB.get(eventData
                            //                         .docs[i]
                            //                         .get("userid")),
                            //                     eventData.docs[i].id,
                            //                     i,
                            //                     "Angry",
                            //                     comparedate);
                            //             eventReactions.put(
                            //                 _currentUserId + eventData.docs[i].id,
                            //                 "Angry");
                            //             databaseReference
                            //                 .child("sm_podcast")
                            //                 .child("reactions")
                            //                 .child(eventData.docs[i].id)
                            //                 .update({
                            //               'likecount': countdata1
                            //                           .value[eventData.docs[i].id]
                            //                       ["likecount"] +
                            //                   1
                            //             });
                            //           }
                            //           socialobj.updateEventReactionCount(
                            //               eventData.docs[i].id, {
                            //             "likescount":
                            //                 countdata1.value[eventData.docs[i].id]
                            //                     ["likecount"]
                            //           });
                            //         }
                            //       },
                            //       reactions: reactions,
                            //       initialReaction: _reactionIndex[i] == -1
                            //           ? Reaction(
                            //               icon: Row(
                            //                 children: [
                            //                   Icon(FontAwesome5.thumbs_up,
                            //                       color: Color(0xff0962ff),
                            //                       size: 14),
                            //                   Text(
                            //                     "  Like",
                            //                     style: TextStyle(
                            //                         fontSize: 13,
                            //                         fontWeight: FontWeight.w700,
                            //                         color: Color(0xff0962ff)),
                            //                   )
                            //                 ],
                            //               ),
                            //             )
                            //           : _reactionIndex[i] == -2
                            //               ? Reaction(
                            //                   icon: Row(
                            //                     children: [
                            //                       Icon(FontAwesome5.thumbs_up,
                            //                           color: Color.fromRGBO(
                            //                               0, 0, 0, 0.8),
                            //                           size: 14),
                            //                       Text(
                            //                         "  Like",
                            //                         style: TextStyle(
                            //                             fontSize: 13,
                            //                             fontWeight:
                            //                                 FontWeight.w700,
                            //                             color: Colors.black54),
                            //                       )
                            //                     ],
                            //                   ),
                            //                 )
                            //               : reactions[_reactionIndex[i]],
                            //       selectedReaction: Reaction(
                            //         icon: Row(
                            //           children: [
                            //             Icon(FontAwesome5.thumbs_up,
                            //                 color: Color.fromRGBO(0, 0, 0, 0.8),
                            //                 size: 14),
                            //             Text(
                            //               "  Like",
                            //               style: TextStyle(
                            //                   fontSize: 13,
                            //                   fontWeight: FontWeight.w700,
                            //                   color: Colors.black54),
                            //             )
                            //           ],
                            //         ),
                            //       ),
                            //     ),

                            )
                      ]),
                      /*IconButton(
                            icon: Icon(FontAwesome5.thumbs_up,
                                color: (eventReactions.get(firebaseUser +
                                            this.eventData.docs[i].id) !=
                                        null)
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 14),
                            onPressed: () {
                              setState(() {
                                if (eventReactions.get(
                                        firebaseUser + eventData.docs[i].id) !=
                                    null) {
                                  flag = false;
                                  eventReactions.delete(
                                      firebaseUser + eventData.docs[i].id);
                                  socialobj.deleteUserLikeData(
                                      firebaseUser + eventData.docs[i].id);
                                  print('hellobro,you disliked');
                                  databaseReference
                                      .child("sm_events")
                                      .child("reactions")
                                      .child(eventData.docs[i].id)
                                      .update({
                                    "likecount":
                                        countdata1.value[eventData.docs[i].id]
                                                ["likecount"] -
                                            1
                                  });
                                  socialobj.updateEventReactionCount(
                                      eventData.docs[i].id, {
                                    "likescount":
                                        countdata1.value[eventData.docs[i].id]
                                                ["likecount"] -
                                            1
                                  });
                                } else {
                                  eventReactions.put(
                                      firebaseUser + eventData.docs[i].id,
                                      "Like");
                                  flag = true;
                                  print('hello sis you liked');
                                  socialobj.addEventLikesDetails(
                                      eventData.docs[i].id,
                                      firebaseUser,
                                      userdetails.docs[0].get('firstname') +
                                          ' ' +
                                          userdetails.docs[0].get('lastname'),
                                      "",
                                      userdetails.docs[0].get('profilepic'),
                                      "",
                                      current_date,
                                      comparedate);
                                  databaseReference
                                      .child("sm_events")
                                      .child("reactions")
                                      .child(eventData.docs[i].id)
                                      .update({
                                    "likecount":
                                        countdata1.value[eventData.docs[i].id]
                                                ["likecount"] +
                                            1
                                  });
                                  socialobj.updateEventReactionCount(
                                      eventData.docs[i].id, {
                                    "likescount":
                                        countdata1.value[eventData.docs[i].id]
                                                ["likecount"] +
                                            1
                                  });
                                }
                              });
                            }),*/
                      /*Text('Like',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: (eventReactions.get(firebaseUser +
                                            this.eventData.docs[i].id) !=
                                        null)
                                    ? Color(0xff0962ff)
                                    : Colors.black54))*/
                    )),
                    Container(
                        child: IconButton(
                      onPressed: () {},
                      icon: Icon(FontAwesome5.share,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                    )),

                    /* InkWell(
                      child: Container(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: Icon(FontAwesome5.comment,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SocialEventComments(
                                          eventData.docs[i].id, i)));
                            }),
                        Text('Comment',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54))
                      ])),
                    ),*/
                    /*Text((count > 0) ? '$count'+ 'Comments' : 'Comment',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500))*/
                    Container(
                        child: IconButton(
                      icon: Icon(FontAwesome5.edit,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                      onPressed: () {},
                    )),
                    Container(
                        child: IconButton(
                      icon: Icon(Entypo.gauge,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                      onPressed: () {},
                    )),
                    Container(
                      child: IconButton(
                          icon: Icon(FontAwesome5.ellipsis_v,
                              color: Color.fromRGBO(0, 0, 0, 0.8), size: 10),
                          onPressed: () {
                            // moreOptionsSMPostViewer(context, i);
                          }),
                    ),
                  ])),
        ]));
  }
}
