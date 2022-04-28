import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:hys/database/adminDB.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';

class DeleteQuestionsPosted extends StatefulWidget {
  @override
  _DeleteQuestionsPostedState createState() => _DeleteQuestionsPostedState();
}

class _DeleteQuestionsPostedState extends State<DeleteQuestionsPosted> {
  QuerySnapshot questionDetails;
  AdminDB adminDB = AdminDB();
  void initState() {
    adminDB.getQuestionAdded().then((val) {
      setState(() {
        questionDetails = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    if (questionDetails != null) {
      print(questionDetails.docs.length);
      return ListView.builder(
        itemCount: questionDetails.docs.length,
        itemBuilder: (BuildContext context, int index) {
          return questionDetails.docs[index].get("questiontype") == "ocr"
              ? _questionFeedOCR(index)
              : _questionFeedText(index);
        },
      );
    } else
      _loading();
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

  _questionFeedText(int i) {
    return InkWell(
      onLongPress: () {
        adminDB.deleteQuestions(questionDetails.docs[i].id);
        adminDB.getQuestionAdded().then((val) {
          setState(() {
            questionDetails = val;
          });
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width / 19.65,
                bottom: MediaQuery.of(context).size.width / 19.65),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: (20.0), right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // CircleAvatar(
                      //   child: ClipOval(
                      //      child: Container(
                      //        width: MediaQuery.of(context).size.width / 10.34,
                      //       height: MediaQuery.of(context).size.width / 10.34,
                      //       child: Image.network(
                      //         questionDetails.docs[i].get("profilepic"),
                      //         loadingBuilder: (BuildContext context, Widget child,
                      //             ImageChunkEvent loadingProgress) {
                      //           if (loadingProgress == null) return child;
                      //           return Image.asset(
                      //             "assets/maleicon.jpg",
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      //),
                      InkWell(
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 10.34,
                              height: MediaQuery.of(context).size.width / 10.34,
                              child: Image.asset(
                                "assets/femaleicon.png",
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.71,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionDetails.docs[i].get("username"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 23.12,
                                color: Color(0xff0C2551),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              questionDetails.docs[i].get("schoolname") +
                                  ", " +
                                  "Grade " +
                                  questionDetails.docs[i].get("grade"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 32.75,
                                color: Color(0xff0C2551),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Posted on " +
                                  questionDetails.docs[i].get("createdate"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 39.3,
                                color: Color.fromRGBO(167, 169, 175, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(
                        top: 15, bottom: 5, left: 10, right: 10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Color.fromRGBO(245, 245, 245, 1)),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Color.fromRGBO(245, 245, 245, 1)),
                    child: ReadMoreText(
                      questionDetails.docs[i].get("question"),
                      trimLines: 4,
                      colorClickableText: Color(0xff0962ff),
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'read more',
                      trimExpandedText: 'Show less',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      lessStyle: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 13,
                        color: Color(0xff0962ff),
                        fontWeight: FontWeight.w700,
                      ),
                      moreStyle: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 13,
                        color: Color(0xff0962ff),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _questionFeedOCR(int i) {
    return InkWell(
      onLongPress: () {
        adminDB.deleteQuestions(questionDetails.docs[i].id);
        adminDB.getQuestionAdded().then((val) {
          setState(() {
            questionDetails = val;
          });
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 10.34,
                              height: MediaQuery.of(context).size.width / 10.34,
                              child: Image.asset(
                                "assets/femaleicon.png",
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.71,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionDetails.docs[i].get("username"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 23.12,
                                color: Color(0xff0C2551),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              questionDetails.docs[i].get("schoolname") +
                                  ", " +
                                  "Grade " +
                                  questionDetails.docs[i].get("grade"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 32.75,
                                color: Color(0xff0C2551),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Posted on " +
                                  questionDetails.docs[i].get("createdate"),
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize:
                                    MediaQuery.of(context).size.width / 39.3,
                                color: Color.fromRGBO(167, 169, 175, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  margin:
                      EdgeInsets.only(top: 15, bottom: 5, left: 10, right: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromRGBO(245, 245, 245, 1)),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Color.fromRGBO(245, 245, 245, 1)),
                  child: SizedBox(
                    child: TeXView(
                      loadingWidgetBuilder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 1.31,
                          child: PlaceholderLines(
                            count: 4,
                            animate: true,
                            color: Colors.white,
                          ),
                        );
                      },
                      child: TeXViewColumn(children: [
                        TeXViewInkWell(
                          id: "$i",
                          child: TeXViewDocument(
                              questionDetails.docs[i].get("question"),
                              style: TeXViewStyle(
                                fontStyle: TeXViewFontStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: TeXViewFontWeight.w400,
                                    fontSize: 9,
                                    sizeUnit: TeXViewSizeUnit.Pt),
                                padding: TeXViewPadding.all(5),
                              )),
                        ),
                      ]),
                      style: TeXViewStyle(
                        elevation: 10,
                        backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                      ),
                    ),
                  ),
                ),
                Container(
                    color: Colors.grey[350],
                    height: 1,
                    width: MediaQuery.of(context).size.width),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
