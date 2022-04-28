import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialMSubCommentsDB {
  Future<String> addFeedSubComment(
      feedid,
      commentid,
      username,
      userprofilepic,
      gender,
      userarea,
      userschoolname,
      usergrade,
      comment,
      taglist,
      tagidlist,
      videolist,
      thumbUrl,
      imagelist,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds_reply');

    await reference.add({
      "feedid": feedid,
      "commentid": commentid,
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      "usergender": gender,
      "userarea": userarea,
      "userschoolname": userschoolname,
      "usergrade": usergrade,
      "comment": comment,
      "taglist": taglist,
      "tagidlist": tagidlist,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "imagelist": imagelist,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likecount": 0,
      "replycount": 0
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds_reply")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0});
    });
    return id;
  }

  Future updateCountofSubComments(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds_reply');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addFeedSubCommentLikesDetails(
      feedid,
      commentid,
      replyid,
      feeduserid,
      feedusername,
      feeduserschoolname,
      feeduserprofilepic,
      feeduserarea,
      feedusergrade,
      reactusername,
      reactuserschoolname,
      reactuserprofilepic,
      reactuserarea,
      reactusergrade,
      createdate,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('sm_reply_reactions_details')
        .doc(firebaseUser + replyid);
    await reference.set({
      "feedid": feedid,
      "commentid": commentid,
      "replyid": replyid,
      "feeduserid": feeduserid,
      "feedusername": feedusername,
      "feeduserschoolname": feeduserschoolname,
      "feeduserprofilepic": feeduserprofilepic,
      "feeduserarea": feeduserarea,
      "feedusergrade": feedusergrade,
      "reactusername": reactusername,
      "reactuserschoolname": reactuserschoolname,
      "reactuserprofilepic": reactuserprofilepic,
      "reactuserarea": reactuserarea,
      "reactusergrade": reactusergrade,
      "reactuserid": firebaseUser,
      "comparedate": comparedate,
      "updatedate": "",
      "createdate": createdate
    });
    return id;
  }

  Future getSocialFeedSubComments(String feedid, String commentid) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_reply')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: feedid)
        .where("commentid", isEqualTo: commentid)
        .get();
  }

  Future getAllSocialFeedSubComments(String feedid) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_reply')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: feedid)
        .get();
  }

  Future deleteSubCommentLikeDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_reply_reactions_details')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

///////////////////////////////////////////////////////////////////////////////////////////

  Future<String> addImageFeedSubComment(
      feedid,
      String imgIndex,
      commentid,
      username,
      userprofilepic,
      gender,
      userarea,
      userschoolname,
      usergrade,
      comment,
      taglist,
      tagidlist,
      videolist,
      thumbUrl,
      imagelist,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds_reply');

    await reference.add({
      "feedid": feedid + imgIndex,
      "commentid": commentid,
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      "usergender": gender,
      "userarea": userarea,
      "userschoolname": userschoolname,
      "usergrade": usergrade,
      "comment": comment,
      "taglist": taglist,
      "tagidlist": tagidlist,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "imagelist": imagelist,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likecount": 0,
      "replycount": 0
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds_reply")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0});
    });
    return id;
  }

  Future updateCountofImageSubComments(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds_reply');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addFeedSubImageCommentLikesDetails(
      feedid,
      String imgIndex,
      commentid,
      replyid,
      feeduserid,
      feedusername,
      feeduserschoolname,
      feeduserprofilepic,
      feeduserarea,
      feedusergrade,
      reactusername,
      reactuserschoolname,
      reactuserprofilepic,
      reactuserarea,
      reactusergrade,
      createdate,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('sm_reply_reactions_details')
        .doc(firebaseUser + replyid);
    await reference.set({
      "feedid": feedid + imgIndex,
      "commentid": commentid,
      "replyid": replyid,
      "feeduserid": feeduserid,
      "feedusername": feedusername,
      "feeduserschoolname": feeduserschoolname,
      "feeduserprofilepic": feeduserprofilepic,
      "feeduserarea": feeduserarea,
      "feedusergrade": feedusergrade,
      "reactusername": reactusername,
      "reactuserschoolname": reactuserschoolname,
      "reactuserprofilepic": reactuserprofilepic,
      "reactuserarea": reactuserarea,
      "reactusergrade": reactusergrade,
      "reactuserid": firebaseUser,
      "comparedate": comparedate,
      "updatedate": "",
      "createdate": createdate
    });
    return id;
  }

  Future getSocialFeedImageSubComments(
      String feedid, String imgIndex, String commentid) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_reply')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: feedid + imgIndex)
        .where("commentid", isEqualTo: commentid)
        .get();
  }

  Future getAllSocialFeedImageSubComments(
      String feedid, String imgIndex) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_reply')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: feedid + imgIndex)
        .get();
  }

  Future deleteImageSubCommentLikeDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_reply_reactions_details')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<dynamic> uploadSocialMediaFeedSubCommentImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedReply/$firebaseUser/Images/$firebaseUser' +
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
        .ref('SocialFeedReply/$firebaseUser/Images/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceVideo(String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedReply/$firebaseUser/$firebaseUser' +
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
        .ref('SocialFeedReply/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
