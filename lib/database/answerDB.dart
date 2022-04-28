import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:hys/database/notificationdb.dart';
import 'package:hys/database/questionDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'package:video_compress/video_compress.dart';

final databaseReference = FirebaseDatabase.instance.reference();
QuerySnapshot tokenNotify;
QuerySnapshot allusers;
QuerySnapshot service;
CrudMethods crudobj = CrudMethods();
PushNotificationDB notify = PushNotificationDB();
QuestionDB qDB = QuestionDB();
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

class AnswerDB {
  String datavalue;
  Future<void> postAnswer(
      questionid,
      askerid,
      answererid,
      answerername,
      answererpic,
      schoolname,
      grade,
      subject,
      topic,
      answertype,
      ocrimage,
      additionalText,
      answer,
      File noter,
      audior,
      videor,
      textreference,
      createdate,
      updatedate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String audioUrl = "";
    String videoUrl = "";
    String notesUrl = "";
    databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
      "isquestionposting": false,
      "questionpostingpercentage": 0,
      "isfeedpostposting": false,
      "feedpostpercentage": 0,
      "isanswerposting": true,
      "answerpercentage": 10,
      "showquestionfeedbackdialogbox": true
    });
    if (noter != null) {
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 15,
        "showquestionfeedbackdialogbox": false
      });
      await uploadReferenceNotes(noter).then((value) {
        print(value);
        if (value[0] == true) {
          notesUrl = value[1];
        }
      });
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 20,
        "showquestionfeedbackdialogbox": false
      });
    }
    if (videor != "") {
      await VideoCompress.setLogLevel(0);
      final info = await VideoCompress.compressVideo(
        videor,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 30,
        "showquestionfeedbackdialogbox": false
      });
      if (info != null) {
        await uploadReferenceVideo(info.path).then((value) {
          print(value);
          if (value[0] == true) {
            print(value[1]);
            videoUrl = value[1];
          }
        });
        databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
          "isquestionposting": false,
          "questionpostingpercentage": 0,
          "isfeedpostposting": false,
          "feedpostpercentage": 0,
          "isanswerposting": true,
          "answerpercentage": 50,
          "showquestionfeedbackdialogbox": false
        });
      }
    }
    if (audior != "") {
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 60,
        "showquestionfeedbackdialogbox": false
      });
      await uploadReferenceAudio(audior).then((value) {
        print(value);
        if (value[0] == true) {
          print(value[1]);
          audioUrl = value[1];
        }
      });
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 80,
        "showquestionfeedbackdialogbox": false
      });
    }
    databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
      "isquestionposting": false,
      "questionpostingpercentage": 0,
      "isfeedpostposting": false,
      "feedpostpercentage": 0,
      "isanswerposting": true,
      "answerpercentage": 90,
      "showquestionfeedbackdialogbox": false
    });
    String image = "";
    if (answertype == "image") {
      await uploadAnswerImage(ocrimage).then((value) {
        print(value);
        if (value[0] == true) {
          image = value[1];
        }
      });
    }
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('useranswerposted');
    await reference.add({
      "questionid": questionid,
      "askerid": askerid,
      "answererid": firebaseUser,
      "answerername": answerername,
      "answererpic": answererpic,
      "schoolname": schoolname,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "answertype": answertype,
      "answer": answer,
      "ocrimage": answertype == "image" ? image : ocrimage,
      "additionaltext": additionalText,
      "notesreference": notesUrl,
      "videoreference": videoUrl,
      "audioreference": audioUrl,
      "textreference": textreference,
      "createdate": createdate,
      "updatedate": updatedate,
      "comparedate": comparedate,
      "likecount": 0,
      "commentcount": 0,
      "upvote": 0,
      "downvote": 0
    }).then((value) async {
      id = value.id;
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": true,
        "answerpercentage": 99,
        "showquestionfeedbackdialogbox": false
      });
      await databaseReference
          .child("answers")
          .child(value.id)
          .set({"likecount": 0, "commentcount": 0, "upvote": 0, "downvote": 0});
      await addDataToUserEnvolvedInAnswer(
          id, answerername, "Answerer", current_date, comparedate);
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
        "showquestionfeedbackdialogbox": true
      });
    });
  }

  Future getAnswerPosted(String qid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('useranswerposted')
        .where("questionid", isEqualTo: qid)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future deleteAnswer(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("useranswerposted")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

//username who like the question
  Future<void> addAnswerLiked(answerid, answererid, username, profilepic,
      schoolname, grade, likedtype, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("answerliked")
        .doc(firebaseUser + answerid + likedtype);
    await reference.set({
      "answerid": answerid,
      "userid": firebaseUser,
      "username": username,
      "answererid": answererid,
      "liketype": likedtype,
      "profilepic": profilepic,
      "schoolname": schoolname,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future<void> addAnswerVote(answerid, answererid, username, profilepic,
      schoolname, grade, voteType, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("answervote")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "userid": firebaseUser,
      "username": username,
      "answererid": answererid,
      "votetype": voteType,
      "profilepic": profilepic,
      "schoolname": schoolname,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future deleteAnswervote(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answervote")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future getAnswerAllRreactions(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answerliked')
        .orderBy("comparedate", descending: true)
        .where("answerid", isEqualTo: id)
        .get();
  }

  Future getAnswerLiked(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answerliked')
        .orderBy("comparedate", descending: true)
        .where("answerid", isEqualTo: id)
        .where("likedtype", isEqualTo: "like")
        .get();
  }

  Future getAnswerHelpful(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answerliked')
        .orderBy("comparedate", descending: true)
        .where("answerid", isEqualTo: id)
        .where("likedtype", isEqualTo: "helpful")
        .get();
  }

  Future getAnswerImp(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answerliked')
        .orderBy("comparedate", descending: true)
        .where("answerid", isEqualTo: id)
        .where("likedtype", isEqualTo: "markasimp")
        .get();
  }

  Future<void> notificationAnswer(
      answerid,
      answererid,
      answerername,
      answerertoken,
      message,
      tittle,
      username,
      function,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("answernotification")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "answererid": answererid,
      "answerername": answerername,
      "token": answerertoken,
      "message": message,
      "tittle": tittle,
      "userid": firebaseUser,
      "username": username,
      "createdate": createdate,
      "function": function,
      "notificationtype": "answernotification",
      "comparedate": comparedate
    });
  }

  Future<void> addDataToUserEnvolvedInAnswer(
      answerid, username, function, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("userenvolvedinanswer")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "userid": firebaseUser,
      "username": username,
      "createdate": createdate,
      "function": function,
      "comparedate": comparedate
    });
  }

  Future getDataToUserEnvolvedInAnswer(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userenvolvedinanswer')
        .where("answerid", isEqualTo: id)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future deleteAnswerLiked(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answerliked")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addAnswerSaved(
      answerid,
      question,
      questiontype,
      questionid,
      questionIndex,
      subject,
      topic,
      answer,
      answertype,
      answererid,
      username,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("answersaved")
        .doc(firebaseUser + answerid);
    ;
    await reference.set({
      "answerid": answerid,
      "answer": answer,
      "questionid": questionid,
      "question": question,
      "questiontype": questiontype,
      "questionIndex": questionIndex,
      "subject": subject,
      "topic": topic,
      "answertpe": answertype,
      "username": username,
      "userid": firebaseUser,
      "answererid": answererid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getAnswersaved() async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answersaved')
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .orderBy("topic", descending: true)
        .get();
  }

  Future deleteAnswerSaved(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answersaved")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addAnswerBookmarked(
      answerid,
      question,
      questiontype,
      questionid,
      questionIndex,
      subject,
      topic,
      answer,
      answertype,
      answererid,
      username,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("answerbookmarked")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "answer": answer,
      "questionid": questionid,
      "question": question,
      "questiontype": questiontype,
      "questionIndex": questionIndex,
      "subject": subject,
      "topic": topic,
      "answertype": answertype,
      "username": username,
      "userid": firebaseUser,
      "answererid": answererid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getAnswerBookmarked() async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answerbookmarked')
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .orderBy("topic", descending: true)
        .get();
  }

  Future deleteAnswerBookMarked(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answerbookmarked")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addAnswerReportData(answerid, reportername, reporttype, message,
      receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("answerreport")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "reportername": reportername,
      "message": message,
      "reporttype": reporttype,
      "reporterid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future<void> addAnswerAskReference(answerid, referencername, message,
      receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("answeraskreference")
        .doc(firebaseUser + answerid);
    await reference.set({
      "answerid": answerid,
      "referencername": referencername,
      "message": message,
      "referencerid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future deleteAnswerAskReference(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answeraskreference")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future updateLikeCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('useranswerposted');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateCommentCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('useranswerposted');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<dynamic> uploadAnswerImage(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userAnswermage/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('userAnswermage/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceNotes(File notes) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userNotesReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(notes.path)}')
        .putFile(notes);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('userNotesReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(notes.path)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceAudio(String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userAudioReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .putFile(File(filePath));

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('userAudioReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceVideo(String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userVideoReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .putFile(File(filePath));

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('userVideoReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
