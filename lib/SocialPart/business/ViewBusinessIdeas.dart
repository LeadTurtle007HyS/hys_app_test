import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:hys/SocialPart/business/ViewBusinessFile.dart';
import 'package:hys/SocialPart/database/SocialDiscussDB.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;

class ViewBusinessIdeas extends StatefulWidget {
  @override
  _ViewBusinessIdeasState createState() => _ViewBusinessIdeasState();
}

SocialDiscuss socialobj = SocialDiscuss();
QuerySnapshot projectData;
int length = 0;
List<bool> ratedFlag = List(length);
QuerySnapshot projectRatings;
Map<String, double> avgRatingMap = Map();
Map<String, bool> ratingflags = Map();
int totalDoc = 0;

class _ViewBusinessIdeasState extends State<ViewBusinessIdeas> {
  @override
  void initState() {
    socialobj.getDiscussedBusinessIdeas().then((value) {
      setState(() {
        projectData = value;

        socialobj.getBusinessIdeaRating().then((value) {
          setState(() {
            projectRatings = value;

            if (projectData != null && projectRatings != null) {
              length = projectData.docs.length;
              for (int i = 0; i < length; i++) {
                double sum = 0;
                int l = 0;
                String projectid = projectData.docs[i].id;
                double avg = 0;
                ratingflags[projectid] = false;
                for (int j = 0; j < projectRatings.docs.length; j++) {
                  if (projectRatings.docs[j].get("projectid") == projectid) {
                    double rating = projectRatings.docs[j].get("rating");
                    sum = sum + rating;
                    l = l + 1;
                    if (projectRatings.docs[j].get("userid") == firebaseUser) {
                      ratingflags[projectid] = true;
                    }
                  }
                }
                if (sum > 0) {
                  avg = sum / l;
                }
                avgRatingMap[projectid] = avg;
                print(avgRatingMap);
              }
            }
          });
        });
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
    if ((projectData != null) && (projectRatings != null)) {
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
    totalDoc = projectData.docs[i].get("totaldocuments");
    List<dynamic> files = projectData.docs[i].get("documents");
    List<dynamic> fileformat = projectData.docs[i].get("formats");
    print(fileformat);
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
                              Text(' has Discussed a Business Idea.'),
                              // Text(projectData.docs[i].get("title"),
                              //     style: TextStyle(fontWeight: FontWeight.w500))
                            ]),
                            // Row(
                            //   children: [
                            //     Text(projectData.docs[i].get('title'),
                            //         style: TextStyle(
                            //             color: Colors.black87,
                            //             fontWeight: FontWeight.w500))
                            //   ],
                            // ),
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
                              child: (totalDoc == 1)
                                  ? InkWell(
                                      onTap: () {
                                        //   PdftronFlutter.openDocument(files[0]);
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
                                                child: (fileformat[0] == "pdf")
                                                    ? Icon(Icons.picture_as_pdf,
                                                        color: Colors.red,
                                                        size: 22)
                                                    : (fileformat[0] == "excel")
                                                        ? Image.asset(
                                                            "assets/excel_icon.png",
                                                            height: 22,
                                                            width: 22,
                                                          )
                                                        : (fileformat[0] ==
                                                                "ppt")
                                                            ? Image.asset(
                                                                "assets/ppt_icon1.png",
                                                                height: 22,
                                                                width: 22)
                                                            : (fileformat[0] ==
                                                                    "word")
                                                                ? Image.asset(
                                                                    "assets/word_icon.png",
                                                                    height: 22,
                                                                    width: 22)
                                                                : SizedBox())),
                                      ),
                                    )
                                  : (totalDoc > 1)
                                      ? Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // PdftronFlutter.openDocument(
                                                //     files[0]);
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
                                                        child: (fileformat[0] ==
                                                                "pdf")
                                                            ? Icon(
                                                                Icons
                                                                    .picture_as_pdf,
                                                                color:
                                                                    Colors.red,
                                                                size: 22)
                                                            : (fileformat[0] ==
                                                                    "excel")
                                                                ? Image.asset(
                                                                    "assets/excel_icon.png",
                                                                    height: 22,
                                                                    width: 22,
                                                                  )
                                                                : (fileformat[
                                                                            0] ==
                                                                        "ppt")
                                                                    ? Image.asset(
                                                                        "assets/ppt_icon1.png",
                                                                        height:
                                                                            22,
                                                                        width:
                                                                            22)
                                                                    : (fileformat[0] ==
                                                                            "word")
                                                                        ? Image.asset(
                                                                            "assets/word_icon.png",
                                                                            height:
                                                                                22,
                                                                            width:
                                                                                22)
                                                                        : SizedBox())),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            InkWell(
                                              onTap: () {
                                                // PdftronFlutter.openDocument(
                                                //     files[1]);
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
                                                        child: (fileformat[1] ==
                                                                "pdf")
                                                            ? Icon(
                                                                Icons
                                                                    .picture_as_pdf,
                                                                color:
                                                                    Colors.red,
                                                                size: 22)
                                                            : (fileformat[1] ==
                                                                    "excel")
                                                                ? Image.asset(
                                                                    "assets/excel_icon.png",
                                                                    height: 22,
                                                                    width: 22,
                                                                  )
                                                                : (fileformat[
                                                                            1] ==
                                                                        "ppt")
                                                                    ? Image.asset(
                                                                        "assets/ppt_icon1.png",
                                                                        height:
                                                                            22,
                                                                        width:
                                                                            22)
                                                                    : (fileformat[1] ==
                                                                            "word")
                                                                        ? Image.asset(
                                                                            "assets/word_icon.png",
                                                                            height:
                                                                                22,
                                                                            width:
                                                                                22)
                                                                        : SizedBox())),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            (totalDoc == 3)
                                                ? InkWell(
                                                    onTap: () {
                                                      // PdftronFlutter
                                                      //     .openDocument(
                                                      //         files[2]);
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
                                                              child: (fileformat[
                                                                          0] ==
                                                                      "pdf")
                                                                  ? Icon(
                                                                      Icons
                                                                          .picture_as_pdf,
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                      size: 22)
                                                                  : (fileformat[
                                                                              2] ==
                                                                          "excel")
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/excel_icon.png",
                                                                          height:
                                                                              22,
                                                                          width:
                                                                              22,
                                                                        )
                                                                      : (fileformat[2] ==
                                                                              "ppt")
                                                                          ? Image.asset(
                                                                              "assets/ppt_icon1.png",
                                                                              height: 22,
                                                                              width: 22)
                                                                          : (fileformat[2] == "word")
                                                                              ? Image.asset("assets/word_icon.png", height: 22, width: 22)
                                                                              : SizedBox())),
                                                    ),
                                                  )
                                                : SizedBox()
                                          ],
                                        )
                                      : SizedBox()),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewBusinessFile(id)));
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
                                      avgRatingMap[projectData.docs[i].id]
                                          .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          color:
                                              Color.fromRGBO(205, 61, 61, 1)),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Icon(FontAwesome5.star,
                                        color: Colors.orangeAccent, size: 12),
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
                            ))
                      ]),
                    )),
                    Container(
                        child: IconButton(
                      onPressed: () {},
                      icon: Icon(FontAwesome5.share,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                    )),
                    Container(
                        child: IconButton(
                      icon: Icon(FontAwesome5.edit,
                          color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                      onPressed: () {},
                    )),
                    (ratingflags[projectData.docs[i].id] == false)
                        ? Container(
                            child: IconButton(
                            icon: Icon(FontAwesome5.star,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              _showRatingDialog(i);
                            },
                          ))
                        : Container(
                            child: IconButton(
                            icon: Icon(FontAwesome5.star,
                                color: Colors.orangeAccent, size: 14),
                            onPressed: () {
                              ratingflags[projectData.docs[i].id] = false;
                            },
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

  double feedbackRating = 5;

  void _showRatingDialog(int i) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: 160,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            RichText(
                text: TextSpan(
                    text: "Rate this Project On ",
                    style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w300),
                    children: [
                  TextSpan(
                      text: projectData.docs[i].get('title'),
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500))
                ])),
            SizedBox(
              height: 15,
            ),
            VxRating(
              onRatingUpdate: (value) {
                // ratedFlag[i] = true;
                // feedbackRating = double.parse(value) / 2;
                // print(feedbackRating);
                setState(() {
                  feedbackRating = double.parse(value);
                  ratingflags[projectData.docs[i].id] = true;
                  print(feedbackRating);
                });
              },
              count: 5,
              normalColor: Colors.grey[300],
              selectionColor: Colors.orangeAccent,
              size: 35,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      await socialobj.addBusinessIdeaRating(
                          projectData.docs[i].id,
                          firebaseUser,
                          feedbackRating,
                          "",
                          "");

                      Navigator.pop(context);
                    })
              ],
            )
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
