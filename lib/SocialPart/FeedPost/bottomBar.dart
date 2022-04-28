import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/fontelico_icons.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/SocialPart/FeedPost/MoodPost.dart';
import 'package:hys/SocialPart/FeedPost/SocialFeeds.dart';

class BottomNav extends StatefulWidget {
  int index;
  BottomNav({Key key, this.index}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final _bottomNavigationBarColor = Colors.white;
  List<Widget> _dynamicPageList;
  int _index = 0;
  QuerySnapshot personaldata;
  QuerySnapshot schooldata;
  QuerySnapshot socialfeed;
  QuerySnapshot notificationToken;
  String post = "";

  CrudMethods crudobj = CrudMethods();

  @override
  void initState() {
    crudobj.getUserSchoolData().then((value) {
      setState(() {
        schooldata = value;
      });
    });
    _dynamicPageList = List();
    _dynamicPageList
      ..add(SOcialFeedPosts())
      ..add(SOcialFeedPosts())
      ..add(SOcialFeedPosts())
      ..add(SOcialFeedPosts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index != null) {
      setState(() {
        _index = widget.index;
      });
    }
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: SafeArea(
        child: Scaffold(
            body: schooldata != null ? _dynamicPageList[_index] : _loading(),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Color.fromRGBO(88, 165, 196, 1),
                onPressed: () {
                  moreButtonForViewer(context);
                },
                tooltip: '',
                child: Icon(
                  Icons.add,
                  color: _bottomNavigationBarColor,
                )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
                color: Color.fromRGBO(88, 165, 196, 1),
                shape: CircularNotchedRectangle(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(FontAwesome5.home, size: 20),
                          color: _index == 0 ? Colors.white : Colors.black,
                          onPressed: () {
                            setState(() {
                              _index = 0;
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: IconButton(
                            icon: Icon(Icons.people, size: 20),
                            color: _index == 1 ? Colors.white : Colors.black,
                            onPressed: () {
                              setState(() {
                                _index = 1;
                              });
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: IconButton(
                            icon: Icon(FontAwesome5.bell, size: 17),
                            color: _index == 2 ? Colors.white : Colors.black,
                            onPressed: () {
                              setState(() {
                                _index = 2;
                              });
                            }),
                      ),
                      IconButton(
                          icon: Icon(FontAwesome5.book, size: 17),
                          color: _index == 3 ? Colors.white : Colors.black,
                          onPressed: () {
                            setState(() {
                              _index = 3;
                            });
                          })
                    ]))),
      ),
    );
  }

  YYDialog moreButtonForViewer(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: MediaQuery.of(context).size.height / 2,
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
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MakePostOfMyMood()));
                },
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_wink,
                        color: Color.fromRGBO(88, 165, 196, 1),
                        size: 25,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mood',
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
                            'Tell others about your mood!',
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
              ExpandablePanel(
                header: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_saint,
                        color: Color.fromRGBO(88, 165, 196, 1),
                        size: 25,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create',
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
                            'Make a difference in someone\'s life!',
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
                expanded: Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Cause',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Rebel',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Help Group',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Podcast',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Blog',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ExpandablePanel(
                header: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_coffee,
                        color: Color.fromRGBO(88, 165, 196, 1),
                        size: 25,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discuss',
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
                            'Share your interesting ideas with others',
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
                expanded: Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: [
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Bussiness Ideas',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Projects',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Exam Questions',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(88, 165, 196, 1)),
                              borderRadius: BorderRadius.circular(3)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              'Books',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_sunglasses,
                        color: Color.fromRGBO(88, 165, 196, 1),
                        size: 25,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Showcase your talent',
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
                            'Let all knows about your hidden talent',
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
                child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Fontelico.emo_thumbsup,
                        color: Color.fromRGBO(88, 165, 196, 1),
                        size: 25,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Predict Questions',
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
                            'Guess the questions having high priority in exam',
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

  _loading() {
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
}
