import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialFeedNotification {
  Future<void> socialFeedReactionsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      feedindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + feedid + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareaction",
      "feedid": feedid,
      "feedindex": feedindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + feedid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedcommentsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      feedindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + feedid + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediacomment",
      "feedid": feedid,
      "feedindex": feedindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + feedid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedcommentsReactionsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      feedindex,
      commentid,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + commentid + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediacommentreaction",
      "feedid": feedid,
      "feedindex": feedindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + commentid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedreplyNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      feedindex,
      commentid,
      commentindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + commentid + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareply",
      "feedid": feedid,
      "feedindex": feedindex,
      "commentid": commentid,
      "commentindex": commentindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + commentid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedreplyReactionNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      feedindex,
      commentid,
      commentindex,
      replyid,
      replyindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + replyid + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareplyreaction",
      "feedid": feedid,
      "feedindex": feedindex,
      "commentid": commentid,
      "commentindex": commentindex,
      "replyid": replyid,
      "replyindex": replyindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + replyid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future deleteSocialFeedReactionsNotification(feedid) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("allnotifications")
        .doc(feedid)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> socialFeedReactionsNotificationsImages(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      imageIndex,
      feedindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + feedid + imageIndex + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "imageindex": imageIndex,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareactiononimage",
      "feedid": feedid,
      "feedindex": feedindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + feedid + imageIndex + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedCommentNotificationsImages(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      imageIndex,
      feedindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + feedid + imageIndex.toString());
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "imageindex": imageIndex,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediacommentonimage",
      "feedid": feedid,
      "feedindex": feedindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + feedid + imageIndex.toString())
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedCommentReactionsNotificationsImages(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      imageIndex,
      feedindex,
      commentid,
      commentindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + commentid + imageIndex.toString() + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "imageindex": imageIndex,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareactiononimagecomment",
      "feedid": feedid,
      "feedindex": feedindex,
      "commentid": commentid,
      "commentindex": commentindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(
              firebaseUser + commentid + imageIndex.toString() + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedReplyNotificationsImages(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      imageIndex,
      feedindex,
      commentid,
      commentindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + commentid + imageIndex.toString() + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "imageindex": imageIndex,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareplyonimage",
      "feedid": feedid,
      "feedindex": feedindex,
      "commentid": commentid,
      "commentindex": commentindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(
              firebaseUser + commentid + imageIndex.toString() + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialFeedReplyReactionsNotificationsImages(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      feedid,
      imageIndex,
      feedindex,
      commentid,
      commentindex,
      replyid,
      replyindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + replyid + imageIndex.toString() + reactiontype);
    await reference.set({
      "notificationtype": "socialmedia",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "imageindex": imageIndex,
      "message": message,
      "reactiontype": "sm_feed" + reactiontype,
      "notificationid": "socialmediareactiononimagereply",
      "feedid": feedid,
      "feedindex": feedindex,
      "commentid": commentid,
      "commentindex": commentindex,
      "replyid": replyid,
      "replyindex": replyindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + replyid + imageIndex.toString() + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> allChatNotifications(
      sendername,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      List chatuserdetails,
      chatid,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('allchatnotifications');
    await reference.add({
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "chatuserdetailszero": chatuserdetails[0],
      "chatuserdetailsone": chatuserdetails[1],
      "chatuserdetailstwo": chatuserdetails[2],
      "chatuserdetailsthree": chatuserdetails[3],
      "chatuserdetailsfour": chatuserdetails[4],
      "chatuserdetailsfive": chatuserdetails[5],
      "chatid": chatid,
      "message": message,
      "notificationid": "chatmessage"
    });
  }

  Future getTokenData() async {
    return await FirebaseFirestore.instance
        .collection('notificationtokendata')
        .get();
  }

  Future<void> socialEventReactionsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      eventid,
      eventindex,
      reactiontype,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + eventid + reactiontype);
    await reference.set({
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": reactiontype,
      "notificationid": "eventreactions",
      "questionid": eventid,
      "eventindex": eventindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + eventid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialEventCommentsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      eventid,
      eventindex,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + eventid + "Comment");
    await reference.set({
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "notificationid": "socialeventcomment",
      "questionid": eventid,
      "eventindex": eventindex
    }).then((value) {
      databaseReference
          .child("allnotifications")
          .child(firebaseUser + eventid + "Comment")
          .set({
        "trigger": false,
      });
    });
  }

  Future<void> socialEventJoinNotifications(
      eventname,
      meetingid,
      date,
      fromtime,
      totime,
      username,
      userid,
      message,
      tittle,
      current_date,
      token) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('eventnotifications')
        .doc(userid + "joinevent");
    await reference.set({
      "eventname": eventname,
      "meetingid": meetingid,
      "token": token,
      "createdate": current_date,
      "date": date,
      "fromtime": fromtime,
      "totime": totime,
      "username": username,
      "userid": userid,
      "message": message,
      "notificationid": "joinsocialevent",
      "tittle": tittle
    });
  }

  Future deleteSocialEventReactionsNotification(feedid) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("allnotifications")
        .doc(feedid)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
