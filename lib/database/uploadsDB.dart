import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:hys/database/questionDB.dart';
import 'package:intl/intl.dart';

final databaseReference = FirebaseDatabase.instance.reference();
var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
QuerySnapshot tokenNotify;
QuerySnapshot allusers;
QuerySnapshot service;
CrudMethods crudobj = CrudMethods();
SocialFeedPost socialobj = SocialFeedPost();
QuestionDB qDB = QuestionDB();
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

class UploadsDB {
  String datavalue;
  Future<void> uploadSchoolExams(
      _schoolname,
      _class,
      _subject,
      _chapter,
      _examName,
      _term,
      _year,
      _tags,
      _desc,
      _file,
      _filetype,
      _uploadtype) async {
    String imgUrl = "";
    List<String> finalImagesUrl = [];
    if (_filetype == "singlefile") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    } else if (_filetype == "images") {
      for (int j = 0; j < _file.length; j++) {
        await socialobj.uploadEventPic(_file[j]).then((value) {
          if (value[0] == true) {
            finalImagesUrl.add(value[1]);
          } else
            print("error");
        });
      }
    } else if (_filetype == "image") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    }
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('useruploads');
    await reference.add({
      "userid": firebaseUser,
      "schoolname": _schoolname,
      "class": _class,
      "subject": _subject,
      "chapter": _chapter,
      "examname": _examName,
      "term": _term,
      "year": _year,
      "tags": _tags,
      "description": _desc,
      "file": _filetype == "image"
          ? imgUrl
          : _filetype == "images"
              ? finalImagesUrl
              : _filetype == "singlefile"
                  ? imgUrl
                  : "",
      "filetype": _filetype,
      "uploadtype": _uploadtype,
      "createdate": current_date,
      "comparedate": comparedate
    }).then((value) async {
      print("Upload Done");
    });
  }

  Future<void> uploadClassNotes(_schoolname, _class, _subject, _chapter, _topic,
      _year, _tags, _desc, _file, _filetype, _uploadtype) async {
    String imgUrl = "";
    List<String> finalImagesUrl = [];
    if (_filetype == "singlefile") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    } else if (_filetype == "images") {
      for (int j = 0; j < _file.length; j++) {
        await socialobj.uploadEventPic(_file[j]).then((value) {
          if (value[0] == true) {
            finalImagesUrl.add(value[1]);
          } else
            print("error");
        });
      }
    } else if (_filetype == "image") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    }
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('useruploads');
    await reference.add({
      "userid": firebaseUser,
      "schoolname": _schoolname,
      "class": _class,
      "subject": _subject,
      "chapter": _chapter,
      "topic": _topic,
      "year": _year,
      "tags": _tags,
      "description": _desc,
      "file": _filetype == "image"
          ? imgUrl
          : _filetype == "images"
              ? finalImagesUrl
              : _filetype == "singlefile"
                  ? imgUrl
                  : "",
      "filetype": _filetype,
      "uploadtype": _uploadtype,
      "createdate": current_date,
      "comparedate": comparedate
    }).then((value) async {});
  }

  Future<void> uploadCompetitiveExams(_exam, _class, _subject, _topic, _year,
      _tags, _desc, _file, _filetype, _uploadtype) async {
    String imgUrl = "";
    List<String> finalImagesUrl = [];
    if (_filetype == "singlefile") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    } else if (_filetype == "images") {
      for (int j = 0; j < _file.length; j++) {
        await socialobj.uploadEventPic(_file[j]).then((value) {
          if (value[0] == true) {
            finalImagesUrl.add(value[1]);
          } else
            print("error");
        });
      }
    } else if (_filetype == "image") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    }
    CollectionReference reference =
        FirebaseFirestore.instance.collection('useruploads');
    await reference.add({
      "userid": firebaseUser,
      "exam": _exam,
      "class": _class,
      "subject": _subject,
      "topic": _topic,
      "year": _year,
      "tags": _tags,
      "description": _desc,
      "file": _filetype == "image"
          ? imgUrl
          : _filetype == "images"
              ? finalImagesUrl
              : _filetype == "singlefile"
                  ? imgUrl
                  : "",
      "filetype": _filetype,
      "uploadtype": _uploadtype,
      "createdate": current_date,
      "comparedate": comparedate
    }).then((value) async {});
  }

  Future<void> uploadOthers(_schoolname, _class, _subject, _topic, _desc, _file,
      _filetype, _uploadtype) async {
    String imgUrl = "";
    List<String> finalImagesUrl = [];
    if (_filetype == "singlefile") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    } else if (_filetype == "images") {
      for (int j = 0; j < _file.length; j++) {
        await socialobj.uploadEventPic(_file[j]).then((value) {
          if (value[0] == true) {
            finalImagesUrl.add(value[1]);
          } else
            print("error");
        });
      }
    } else if (_filetype == "image") {
      await socialobj.uploadEventPic(_file).then((value) {
        if (value[0] == true) {
          imgUrl = value[1];
        }
      });
    }
    CollectionReference reference =
        FirebaseFirestore.instance.collection('useruploads');
    await reference.add({
      "userid": firebaseUser,
      "schoolname": _schoolname,
      "class": _class,
      "subject": _subject,
      "topic": _topic,
      "description": _desc,
      "file": _filetype == "image"
          ? imgUrl
          : _filetype == "images"
              ? finalImagesUrl
              : _filetype == "singlefile"
                  ? imgUrl
                  : "",
      "filetype": _filetype,
      "uploadtype": _uploadtype,
      "createdate": current_date,
      "comparedate": comparedate
    }).then((value) async {});
  }

  Future getUserUploads(String userid, String type) async {
    return await FirebaseFirestore.instance
        .collection('useruploads')
        .orderBy("comparedate", descending: true)
        .where('userid', isEqualTo: userid)
        .where('uploadtype', isEqualTo: type)
        .get();
  }

  Future getAllUploads() async {
    return await FirebaseFirestore.instance
        .collection('useruploads')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getSubjectAndTopicList() async {
    return await FirebaseFirestore.instance
        .collection('classgradesubjectdata')
        .get();
  }
}
