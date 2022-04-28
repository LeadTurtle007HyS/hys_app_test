import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class AnswerCommentDB {
  String datavalue;
  Future<String> postAnswerComment(
      questionid,
      answerid,
      commentername,
      commenterpic,
      commenterschoolname,
      commentergrade,
      commentercity,
      comment,
      commenttype,
      commentimage,
      likecount,
      replycount,
      createdate,
      updatedate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('answercomments');
    await reference.add({
      "questionid": questionid,
      "answerid": answerid,
      "commenterid": firebaseUser,
      "commentername": commentername,
      "commenterpic": commenterpic,
      "commenterschoolname": commenterschoolname,
      "commentergrade": commentergrade,
      "commentercity": commentercity,
      "comment": comment,
      "commenttype": commenttype,
      "commentimage": commentimage,
      "likecount": 0,
      "replycount": 0,
      "editated": false,
      "createdate": createdate,
      "updatedate": updatedate,
      "comparedate": comparedate
    }).then((value) {
      id = value.id;
      databaseReference
          .child("answercomments")
          .child(value.id)
          .set({"likecount": 0, "replycount": 0});
    });
    return id;
  }

  Future updateAnswercomment(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answercomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> postAnswerSubComment(
      questionid,
      answerid,
      commentid,
      commentername,
      commenterpic,
      commenterschoolname,
      commentergrade,
      commentercity,
      comment,
      commenttype,
      commentimage,
      likecount,
      replycount,
      createdate,
      updatedate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('answersubcomments');
    await reference.add({
      "questionid": questionid,
      "answerid": answerid,
      "commentid": commentid,
      "commenterid": firebaseUser,
      "commentername": commentername,
      "commenterpic": commenterpic,
      "commenterschoolname": commenterschoolname,
      "commentergrade": commentergrade,
      "commentercity": commentercity,
      "comment": comment,
      "commenttype": commenttype,
      "commentimage": commentimage,
      "likecount": 0,
      "replycount": 0,
      "edited": false,
      "createdate": createdate,
      "updatedate": updatedate,
      "comparedate": comparedate
    }).then((value) {
      id = value.id;
      databaseReference
          .child("answersubcomments")
          .child(value.id)
          .set({"likecount": 0, "replycount": 0});
    });
    return id;
  }

  Future updateAnswersubcomment(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answersubcomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> postAnswerCommentsLikeDetails(
      questionid,
      answerid,
      commentid,
      likername,
      likerpic,
      likerschoolname,
      likergrade,
      likercity,
      createdate,
      updatedate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('answercommentslikedetails');
    await reference.add({
      "questionid": questionid,
      "answerid": answerid,
      "commentid": commentid,
      "likerid": firebaseUser,
      "likername": likername,
      "likerpic": likerpic,
      "likerschoolname": likerschoolname,
      "likergrade": likergrade,
      "likercity": likercity,
      "createdate": createdate,
      "updatedate": updatedate,
      "comparedate": comparedate
    }).then((value) {
      id = value.id;
    });
    return id;
  }

  Future<String> postAnswerSubCommentsLikeDetails(
      questionid,
      answerid,
      commentid,
      subcommentid,
      likername,
      likerpic,
      likerschoolname,
      likergrade,
      likercity,
      createdate,
      updatedate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('answersubcommentslikedetails')
        .doc(firebaseUser + answerid);
    await reference.set({
      "questionid": questionid,
      "answerid": answerid,
      "commentid": commentid,
      "subcommentid": subcommentid,
      "likerid": firebaseUser,
      "likername": likername,
      "likerpic": likerpic,
      "likerschoolname": likerschoolname,
      "likergrade": likergrade,
      "likercity": likercity,
      "createdate": createdate,
      "updatedate": updatedate,
      "comparedate": comparedate
    });
  }

  Future<void> notificationComment(
      commentid,
      commenterid,
      commentername,
      commentertoken,
      message,
      tittle,
      username,
      function,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("commentnotification");
    await reference.add({
      "commentid": commentid,
      "commenterid": commenterid,
      "commentername": commentername,
      "token": commentertoken,
      "message": message,
      "tittle": tittle,
      "userid": firebaseUser,
      "username": username,
      "createdate": createdate,
      "function": function,
      "notificationtype": "commentnotification",
      "comparedate": comparedate
    });
  }

  Future<void> addcommentReportData(commentid, reportername, reporttype,
      message, receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("commentreport")
        .doc(firebaseUser + commentid);
    await reference.set({
      "answerid": commentid,
      "reportername": reportername,
      "message": message,
      "reporttype": reporttype,
      "reporterid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future<void> addsubcommentsReportData(subcommentid, reportername, reporttype,
      message, receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("commentreport")
        .doc(firebaseUser + subcommentid);
    await reference.set({
      "answerid": subcommentid,
      "reportername": reportername,
      "message": message,
      "reporttype": reporttype,
      "reporterid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future deleteCommentLiked(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answercommentslikedetails")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteSubCommentLiked(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answersubcommentslikedetails")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteComment(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answercomments")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteSubComment(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("answersubcomments")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future updateLikeCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answercomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateSubCommentLikeCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answersubcomments');
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

  Future updateReplyCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answercomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future getAnswerCommentPosted(String qid, String ansid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answercomments')
        .where("questionid", isEqualTo: qid)
        .where("answerid", isEqualTo: ansid)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getAnswerComment(String qid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answercomments')
        .where("questionid", isEqualTo: qid)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getAnswerSubCommentPosted(
      String qid, String ansid, String commentid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answersubcomments')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: qid)
        .where("answerid", isEqualTo: ansid)
        .where("commentid", isEqualTo: commentid)
        .get();
  }

  Future getAnswerAllSubCommentPosted(String qid, String ansid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('answersubcomments')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: qid)
        .where("answerid", isEqualTo: ansid)
        .get();
  }

  Future updateAnswerCommentData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answercomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateAnswerSubCommentData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('answersubcomments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<dynamic> uploadAnswerCommentImage(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userAnswerCommentImage/$firebaseUser/$firebaseUser' +
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
        .ref('userAnswerCommentImage/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
