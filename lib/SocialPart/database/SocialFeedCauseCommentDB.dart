import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialFeedCauseComment {
  Future<String> addEventComment(
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
        FirebaseFirestore.instance.collection('sm_event_comments');

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
          .child("sm_event_comments")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0});
    });
    return id;
  }

  Future updateCountofEventComments(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_event_comments');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addEventCommentLikesDetails(
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
    CollectionReference reference = FirebaseFirestore.instance
        .collection('sm__event_comments_reactions_details');

    await reference.add({
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

  Future getSocialEventComments(String id) async {
    return await FirebaseFirestore.instance
        .collection('sm_event_comments')
        .where("feedid", isEqualTo: id)
        .get();
  }
}
