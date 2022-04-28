import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialMCommentsDB {
  Future<String> addFeedComment(
      feedid,
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
        FirebaseFirestore.instance.collection('sm_feeds_comments');

    await reference.add({
      "feedid": feedid,
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
          .child("sm_feeds_comments")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0});
    });
    return id;
  }

  Future updateCountofComments(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds_comments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addFeedCommentLikesDetails(
      feedid,
      commentid,
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
        .collection('sm_comments_reactions_details')
        .doc(firebaseUser + commentid);
    await reference.set({
      "feedid": feedid,
      "commentid": commentid,
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

  Future getSocialFeedComments(String id) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_comments')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: id)
        .get();
  }

  Future<String> addFeedImageComment(
      feedid,
      String imagIndex,
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
        FirebaseFirestore.instance.collection('sm_feeds_comments');

    await reference.add({
      "feedid": feedid + imagIndex,
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
          .child("sm_feeds_comments")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0});
    });
    return id;
  }

  Future updateCountofImageComments(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds_comments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addFeedImageCommentLikesDetails(
      feedid,
      String imagIndex,
      commentid,
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
        .collection('sm_comments_reactions_details')
        .doc(firebaseUser + commentid);
    await reference.set({
      "feedid": feedid + imagIndex,
      "commentid": commentid,
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

  Future getSocialFeedImagesComments(String id, String imagIndex) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_comments')
        .orderBy("comparedate", descending: true)
        .where("feedid", isEqualTo: id + imagIndex)
        .get();
  }

  Future deleteCommentImageLikeDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_comments_reactions_details')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteCommentLikeDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_comments_reactions_details')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<dynamic> uploadSocialMediaFeedCommentImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedComment/$firebaseUser/Images/$firebaseUser' +
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
        .ref('SocialFeedComment/$firebaseUser/Images/$firebaseUser' +
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
        .ref('SocialFeedComment/$firebaseUser/$firebaseUser' +
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
        .ref('SocialFeedComment/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
