import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:easy_gradient_text/easy_gradient_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import 'package:hys/SocialPart/network_crud.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:hys/utils/cropper.dart';
import 'package:hys/utils/options.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hys/navBar.dart';

class BlogInfo extends StatefulWidget {
  @override
  _BlogInfoState createState() => _BlogInfoState();
}

/// Zefyr editor like any other input field requires a focus node.
FocusNode zef_focusNode;

NetworkCRUD network_crud = NetworkCRUD();

String imgUrl = "";
final _formKey = new GlobalKey<FormState>();
String createdate = DateTime.now().toString();
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
CrudMethods crudobj = CrudMethods();
SocialFeedPost socialobj = SocialFeedPost();
FocusNode focusnode1 = FocusNode();
FocusNode focusnode2 = FocusNode();
FocusNode focusnode3 = FocusNode();
FocusNode focusnode4 = FocusNode();
var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
bool flag = false;
bool otherflag = false;
PanelController _pc1 = new PanelController();
List<String> choosedTopics = List();
ScrollController _scrollController = ScrollController();
bool showimgcontainer = false;

List<String> blogTopics = [
  "Management",
  "Strategy",
  "Anxiety",
  "Stress",
  "friendship",
  "Relationships",
  "Exam and Results",
  "Careers",
  "Environment",
  "Depression",
  "Eating Disorder",
  "Stay Fit",
  "Finding Supoort",
  "Looking after yourself",
  "Love to write",
  "Business Ideas",
  "Wierd Experience",
  "Most Funny Person",
  "Best Friends",
  "Science",
  "Supproting Loved Ones",
  "Study Abroad",
  "Healthy LifeStyle",
  "Other"
];
String choosenPrint = "";
String contentValue = '';
String name = "";
String intro = "";
String content = "";
String bio = "";
String title = "";
QuerySnapshot userData;
double wid;
double wd;
ModalRoute _mountRoute;
final converter = NotusHtmlCodec();
TextEditingController _textcontroller = TextEditingController();
final HtmlEditorController controller = HtmlEditorController();

class _BlogInfoState extends State<BlogInfo> {
  @override
  void initState() {
    jsonString = "";

    crudobj.getUserData().then((value) {
      setState(() {
        userData = value;
      });
    });

    zef_focusNode = FocusNode();
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _mountRoute ??= ModalRoute.of(context);
    super.didChangeDependencies();
  }

  final picker = ImagePicker();
  bool imgFlag = false;
  bool uploaded = false;
  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return true; // return true if the route to be popped
  }

  /// Loads the document to be edited in Zefyr.

  /// Loads the document to be edited in Zefyr.

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
            onTap: () {
              showimgcontainer = false;
              focusnode1.unfocus();
              focusnode2.unfocus();
              focusnode3.unfocus();
              focusnode4.unfocus();
            },
            child: Scaffold(
                backgroundColor: Colors.white,
                drawer: _drawer(),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  centerTitle: false,
                  title: InkWell(
                      onTap: () {
                        null;
                      },
                      child: Row(children: [
                        GradientText(
                          text: 'HyS',
                          colors: [
                            Color.fromRGBO(88, 165, 196, 1),
                            Color.fromRGBO(88, 165, 196, 1),
                          ],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GradientText(
                          text: ' Blogs',
                          colors: [
                            Color.fromRGBO(88, 165, 196, 1),
                            Color.fromRGBO(88, 165, 196, 1),
                          ],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ])),
                  leading: InkWell(
                    onTap: () async {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Container(
                      margin: EdgeInsets.all(9),
                      child: CircleAvatar(
                        backgroundColor: Color.fromRGBO(88, 165, 196, 1),
                        child: ClipOval(
                          child: Container(
                            width: 35,
                            height: 35,
                            child: Image.asset(
                              "assets/maleicon.jpg",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    InkWell(
                      onTap: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.NO_HEADER,
                          animType: AnimType.BOTTOMSLIDE,
                          btnOkColor: Color.fromRGBO(88, 165, 196, 1),
                          title: 'Dialog Title',
                          desc: 'Dialog description here.............',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        )..show();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 14, bottom: 14),
                        padding: EdgeInsets.only(right: 17, left: 5),
                        width: 130,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 1.0,
                                spreadRadius: 0.0,
                                offset: Offset(
                                    0.5, 0.5), // shadow direction: bottom right
                              )
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(100.0)),
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("  Search",
                                style: TextStyle(color: Colors.black38)),
                            Icon(MfgLabs.search,
                                color: Colors.black26, size: 15),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(MfgLabs.chat,
                          color: Color.fromRGBO(88, 165, 196, 1), size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
                body:
                    /*SlidingUpPanel(
                      minHeight: 1,
                      controller: _pc1,
                      body: _body(),
                      panel: _handlepressbutton(context))*/
                    _body())));
  }

  _body() {
    if (userData != null) {
      return Form(
          key: _formKey,
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Container(
                      child: Image.asset(
                        "assets/bloglogo.png",
                        height: 100,
                        width: 150,
                      ),
                    )),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: GradientText(
                        text: 'Create Your Own Blog.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: GradientText(
                          text:
                              'Would you like your name to be used on your blog?',
                          colors: [
                            Colors.black87,
                            Colors.black87,
                          ],
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    RadioButtonGroup(
                        activeColor: Color(0xFF6E1B80),
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        labels: [
                          "Full Name",
                          "First Name",
                          "Publish Anonymously",
                          "Nick Name"
                        ],
                        onChange: (String label, int index) {
                          if (index == 3) {
                            setState(() {
                              flag = true;
                            });
                          } else if (index == 0) {
                            setState(() {
                              flag = false;
                              name = userData.docs[0].get('firstname') +
                                  " " +
                                  userData.docs[0].get('lastname');
                            });
                          } else if (index == 1) {
                            setState(() {
                              flag = false;
                              name = userData.docs[0].get('firstname');
                            });
                          } else if (index == 2) {
                            setState(() {
                              flag = false;
                              name = "Unknown";
                            });
                          }
                        },
                        onSelected: (String label) => print(label)),
                    (flag == true)
                        ? Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 73),
                                  child: Container(
                                      height: 20,
                                      width: 150,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please Enter Name.';
                                          } else
                                            return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            name = value;
                                          });
                                        },
                                      )))
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 11),
                      child: RichText(
                          text: TextSpan(
                              text: 'Blog Title',
                              style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                              children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(205, 61, 61, 1))),
                            TextSpan(
                                text: '  (max 10 words)',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ])),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 11, top: 7, bottom: 11),
                      child: GradientText(
                        text: 'Title to encourage viewers to read more.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 11, right: 11, bottom: 11, top: 5),
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter title of blog.';
                          } else
                            return null;
                        },
                        onTap: () {
                          focusnode1.requestFocus();
                        },
                        focusNode: focusnode1,
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      width: MediaQuery.of(context).size.width - 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 11),
                      child: RichText(
                          text: TextSpan(
                              text: 'Blog Introduction',
                              style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                              children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(205, 61, 61, 1))),
                            TextSpan(
                                text: '  (max 25 words)',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ])),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 11, top: 7, bottom: 11),
                      child: GradientText(
                        text:
                            'A third person, brief introduction to explain what the blog is about.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 11, right: 11, bottom: 11, top: 5),
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter a short introduction of your Blog.';
                            } else
                              return null;
                          },
                          onTap: () {
                            focusnode2.requestFocus();
                          },
                          focusNode: focusnode2,
                          onChanged: (value) {
                            setState(() {
                              intro = value;
                            });
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: 2),
                      width: MediaQuery.of(context).size.width - 26,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 11, top: 11),
                        child: Text("Image",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ))),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => _imgContainer());
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 5, bottom: 12, right: 12, top: 12),
                          margin: EdgeInsets.only(
                              left: 11, right: 11, bottom: 11, top: 5),
                          child: (imgFlag == true)
                              ? _loading()
                              : (uploaded == true)
                                  ? Container(
                                      color: Colors.black12,
                                      padding: EdgeInsets.all(10),
                                      height: 300,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.cancel,
                                                      color: Colors.black),
                                                  onPressed: () {
                                                    setState(() {
                                                      imgFlag = false;
                                                      uploaded = false;
                                                      _image.delete();
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                          Image.file(firstcrop,
                                              fit: BoxFit.contain),
                                        ],
                                      ),
                                    )
                                  : Text("Choose any image",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 15)),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black87, width: 1))),
                          width: MediaQuery.of(context).size.width - 50),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 11),
                      child: RichText(
                          text: TextSpan(
                              text: 'Blog Text',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(205, 61, 61, 1))),
                            TextSpan(
                                text: '  (max 800 words)',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ])),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 11, top: 7, bottom: 11),
                      child: GradientText(
                        text: 'Please type or upload your Blog Text here.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    /*InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TextEditor()));
              },
              child: Container(
                  margin:
                      EdgeInsets.only(left: 11, right: 11, bottom: 11, top: 5),
                  padding:
                      EdgeInsets.only(left: 11, right: 11, bottom: 11, top: 5),
                  child: Text(content),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black87, width: 2))),
                  width: MediaQuery.of(context).size.width - 150),
            ),*/

                    Container(
                      padding: EdgeInsets.only(
                          left: 11, right: 11, bottom: 11, top: 5),
                      child: TextFormField(
                        readOnly: true,
                        controller: _textcontroller,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter Content of your Blog.';
                          } else
                            return null;
                        },
                        onTap: () {
                          showBarModalBottomSheet(
                              context: context,
                              builder: (context) => _textEditor(context));

                          //  zef_focusNode.requestFocus();
                        },
                        focusNode: focusnode3,
                        onChanged: (value) {
                          setState(() {
                            content = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                      width: MediaQuery.of(context).size.width - 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 11),
                      child: RichText(
                          text: TextSpan(
                              text: 'Personal Bio',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(205, 61, 61, 1))),
                            TextSpan(
                                text: '  (max 60 words)',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ])),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 11, top: 7, bottom: 11),
                      child: GradientText(
                        text:
                            'Let everyone know who you are and why are you sharing your story.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 11, right: 11, bottom: 11, top: 5),
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter about yourself..';
                          } else
                            return null;
                        },
                        onTap: () {
                          focusnode4.requestFocus();
                        },
                        focusNode: focusnode4,
                        onChanged: (value) {
                          setState(() {
                            bio = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                      ),
                      width: MediaQuery.of(context).size.width - 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 11),
                      child: RichText(
                          text: TextSpan(
                              text: 'What is your Blog about?',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(205, 61, 61, 1))),
                          ])),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 11, top: 7, bottom: 11),
                      child: GradientText(
                        text: 'You can select more than one.',
                        colors: [
                          Colors.black87,
                          Colors.black87,
                        ],
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showBarModalBottomSheet(
                            context: context,
                            builder: (context) => _handlepressbutton(context));
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: 11, right: 11, bottom: 11, top: 5),
                          padding: EdgeInsets.only(
                              left: 11, right: 11, bottom: 11, top: 5),
                          child: _print(),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black87, width: 2))),
                          width: MediaQuery.of(context).size.width - 50),
                    ),
                    SizedBox(height: 15),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      InkWell(
                          onTap: () {
                            if (_formKey.currentState.validate()) {
                              _showBlog(context);
                            } else
                              return null;
                          } /*=> showModalBottomSheet(
                  context: context, builder: (context) => _showBlog(context)),
              /*() {
                _showBlog(context);
                /*socialobj.addBlogPost(
                    name,
                    userData.docs[0].get('profilepic'),
                    userData.docs[0].get('grade'),
                    title,
                    intro,
                    content,
                    bio,
                    choosenPrint,
                    "",
                    createdate,
                    comparedate);*/
              },*/*/
                          ,
                          child: Container(
                              width: 65,
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black87, width: 1)),
                              child: Center(
                                child: Text('Create',
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(88, 165, 196, 1))),
                              ))),
                      SizedBox(width: 10)
                    ]),
                    SizedBox(height: 30)
                  ])));
    }
  }

  _showBlog(BuildContext context) {
    String postID = "sm${firebaseUser}${comparedate}";

    if (userData != null) {
      showBarModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (contex) {
            return StatefulBuilder(builder: (BuildContext context,
                StateSetter setState /*You can rename this!*/) {
              return Container(
                  decoration: BoxDecoration(color: Colors.white),
                  height: MediaQuery.of(context).size.height - 100,
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            List result = [
                                              postID,
                                              firebaseUser,
                                              name,
                                              title,
                                              intro,
                                              content,
                                              "0",
                                              "0",
                                              "0",
                                              "0",
                                              imgUrl,
                                              bio,
                                              comparedate
                                            ];
                                            network_crud
                                                .addsmBlogPostDetails(result);

                                            // socialobj.addBlogPost(
                                            //     name,
                                            //     userData.docs[0]
                                            //         .get('profilepic'),
                                            //     "",
                                            //     title,
                                            //     intro,
                                            //     jsonString,
                                            //     bio,
                                            //     "",
                                            //     imgUrl,
                                            //     createdate,
                                            //     comparedate);
                                            // print('hello');

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BottomNavigationBarWidget()));
                                          });
                                        },
                                        child: Text('Post',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Color.fromRGBO(
                                                    88, 165, 196, 1)))),
                                    SizedBox(
                                      width: 12,
                                    )
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                child: Image.asset(
                                  "assets/bloglogo.png",
                                  height: 100,
                                  width: 150,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(title,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          color: Colors.black,
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 18,
                                          wordSpacing: 2)),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(intro,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          color: Colors.black,
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 15,
                                          wordSpacing: 1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("~ ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontFamily: 'Nunito Sans',
                                                wordSpacing: 1)),
                                    Text(name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontStyle: FontStyle.italic,
                                                wordSpacing: 1)),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            (uploaded == true)
                                ? Center(
                                    child: Container(
                                        child: Image.file(firstcrop,
                                            fit: BoxFit.contain),
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100),
                                  )
                                : SizedBox(),
                            SizedBox(height: 10),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                  data: content,
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.all(8.0),
                                    height: 140,
                                    width: 120,
                                    child: Image.network(
                                        userData.docs[0].get('profilepic'))),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width - 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(bio,
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontFamily: 'Nunito Sans',
                                                    fontStyle: FontStyle.italic,
                                                    wordSpacing: 1)),
                                      ],
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 50,
                            )
                          ])));
            });
          });
      /*return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        color: Colors.white,
      ),
      height: MediaQuery.of(context).size.height - 200,
      child: ListView(physics: BouncingScrollPhysics(), children: [
        SizedBox(
          height: 15,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
              child: Container(
                  width: 50,
                  height: 25,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87, width: 1)),
                  child: Center(
                    child: Text('Post',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(88, 165, 196, 1))),
                  )))
          /*MaterialButton(
              elevation: 5,
              color: Colors.grey,
              onPressed: null,
              child: Text('Post',
                  style: TextStyle(
                      fontSize: 10, color: Color.fromRGBO(88, 165, 196, 1))))*/
        ]),
        SizedBox(
          height: 20,
        ),
        Container(
          child: Image.asset(
            "assets/bloglogo.png",
            height: 100,
            width: 150,
          ),
        )
      ]),
    );*/
    }
  }

  _print() {
    choosenPrint = "";
    if (choosedTopics.length == 0) {
      return;
    } else {
      for (int i = 0; i < choosedTopics.length; i++) {
        if (i == 0) {
          choosenPrint += choosedTopics[i];
        } else
          choosenPrint = choosenPrint + " , " + choosedTopics[i];
      }
      return Text(choosenPrint);
    }
  }

  _handlepressbutton(BuildContext context) {
    if (userData != null) {
      return ListView(physics: BouncingScrollPhysics(), children: [
        Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: CheckboxGroup(
              // orientation: GroupedButtonsOrientation.VERTICAL,
              margin: const EdgeInsets.only(left: 12.0),
              onSelected: (List selected) => setState(() {
                choosedTopics = selected;
                print(choosedTopics);
                if (choosedTopics.contains("Other :") == true) {
                  setState(() {
                    otherflag = true;
                  });
                } else
                  otherflag = false;
              }),
              labels: <String>[
                "Management",
                "Strategy",
                "Anxiety",
                "Stress",
                "friendship",
                "Relationships",
                "Exam and Results",
                "Careers",
                "Environment",
                "Depression",
                "Eating Disorder",
                "Stay Fit",
                "Finding Supoort",
                "Looking after yourself",
                "Love to write",
                "Business Ideas",
                "Wierd Experience",
                "Most Funny Person",
                "Best Friends",
                "Science",
                "Supproting Loved Ones",
                "Study Abroad",
                "Healthy LifeStyle",
                "Other :"
              ],

              /* itemBuilder: (Checkbox cb, Text txt, int i) {
                    return Column(
                      children: <Widget>[
                        Icon(Icons.polymer),
                        cb,
                        txt,
                      ],
                    );
                  },*/
            )),
        (otherflag == true)
            ? Row(children: [
                Padding(
                    padding: EdgeInsets.only(left: 80),
                    child: Container(
                        height: 20, width: 150, child: TextFormField()))
              ])
            : SizedBox(),
        SizedBox(
          height: 15,
        )
      ]);
    } else
      return SizedBox();
  }

  _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: new Text(
              "Pratik Ekghare",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            accountEmail: new Text(
              "ekghare31197@gmail.com",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new AssetImage("assets/maleicon.jpg"),
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
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
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
                  onTap: () async {},
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

  _imgContainer() {
    return Container(
      height: 250,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Upload Image",
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
                          imgFlag = true;
                          Navigator.pop(context);
                          getProfilePic(ImageSource.camera);
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
                          imgFlag = true;
                          Navigator.pop(context);
                          getProfilePic(ImageSource.gallery);
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
                      " Images",
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

  File firstcrop;
  File _image;
  Future getProfilePic(ImageSource source) async {
    final pickedfile = await picker.getImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _image = File(pickedfile.path);
        print(_image);
      });
    }

    if (_image != null) {
      firstcrop = await ImageCropper.cropImage(
          sourcePath: _image.path,
          compressQuality: 90,
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
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

      /* if (firstcrop != null) {
        croppedFile = await ImageCropper.cropImage(
            sourcePath: _image.path,
            compressQuality: 90,
            aspectRatioPresets: Platform.isAndroid
                ? [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio5x3,
                    CropAspectRatioPreset.ratio5x4,
                    CropAspectRatioPreset.ratio7x5,
                    CropAspectRatioPreset.ratio16x9
                  ],
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
      }*/
      if (firstcrop != null) {
        getEventImgURL(firstcrop);
        /*setState(() {
          imageFile = croppedFile;
          print(imageFile);
          base64Image = base64Encode(imageFile.readAsBytesSync());
          print(base64Image);
          imagereading = true;
          uploadImage(base64Image, imageFile);
        });*/
      }
    }
  }

  String saved_html = "";
  _textEditor(context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(children: [
          (controller == null)
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: HtmlEditor(
                      controller: controller,
                      htmlEditorOptions: HtmlEditorOptions(
                        hint: 'Your text here...',
                        initialText: (content != "") ? content.toString() : "",
                      ),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        gridViewVerticalSpacing: 3, toolbarItemHeight: 25,
                        toolbarPosition:
                            ToolbarPosition.aboveEditor, //by default
                        toolbarType: ToolbarType.nativeGrid, //by default
                        // onButtonPressed: (ButtonType type, bool? status,
                        //     Function()? updateStatus) {
                        //   print(
                        //       "button '${describeEnum(type)}' pressed, the current selected status is $status");
                        //   return true;
                        // },
                        // onDropdownChanged: (DropdownType type, dynamic changed,
                        //     Function(dynamic)? updateSelectedItem) {
                        //   print(
                        //       "dropdown '${describeEnum(type)}' changed to $changed");
                        //   return true;
                        // },
                        mediaLinkInsertInterceptor:
                            (String url, InsertFileType type) {
                          print(url);
                          return true;
                        },
                        // mediaUploadInterceptor:
                        //     (PlatformFile file, InsertFileType type) async {
                        //   print(file.name); //filename
                        //   print(file.size); //size in bytes
                        //   print(file.extension); //file extension (eg jpeg or mp4)
                        //   return true;
                        // },
                      ),
                      callbacks: Callbacks(onChangeContent: (String changed) {
                        setState(() {
                          saved_html = changed;
                        });
                      }))
                  // child: ZefyrEditor(
                  //   padding: EdgeInsets.all(16),
                  //   controller: _controller,
                  //   focusNode: zef_focusNode,
                  // ),
                  ),
          MaterialButton(
              onPressed: () => _saveDocument(context), child: Text("Save"))
        ]);

        /*AlertDialog(
          title: Text("Title of Dialog"),
          content:
          actions: <Widget>[
            FlatButton(
              onPressed: () => _saveDocument(context),
              child: Text("Save"),
            ),
            /*FlatButton(
              onPressed: () {
                setState(() {
                  contentText = "Changed Content of Dialog";
                });
              },
              child: Text("Change"),
            ),*/
          ],
        );*/
      },
    );
  }

  String jsonString = '';
  void _saveDocument(BuildContext context) {
    setState(() {
      _textcontroller.text = saved_html;
      content = saved_html;
    });
    Navigator.pop(context);
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    // jsonString = jsonEncode(_controller.document);
    // contentValue = converter.encode(_loadDocument(jsonString).toDelta());
    // _textcontroller.text = Html(data: contentValue).data;
    /*var bytes = utf8.encode(jsonString);
    base64Str = base64.encode(bytes);
    var encoded = base64.decode(base64Str);
    var bytes1 = utf8.decode(encoded);
*/
    // var bytes = utf8.encode(jsonString);
    //var base64String = base64.encode(bytes);
    //print(base64.decode(base64String));
    // For this example we save our document to a temporary file.
    //final file = File(Directory.systemTemp.path + "/quick_start.json");
    // And show a snack bar on success.
    //file.writeAsString(jsonString).then((_) {

    //});
    //getFileURL(file);
  }

  dynamic imgUrl;
  Future getEventImgURL(File _image) async {
    setState(() {
      print(_image);
      socialobj.uploadEventPic(_image).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            imgUrl = value[1];
            uploaded = true;
            imgFlag = false;
            print(imgUrl);
          } else
            print("error");
        });
      });
    });
  }
}
