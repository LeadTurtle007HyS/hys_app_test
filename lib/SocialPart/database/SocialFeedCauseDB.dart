import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialFeedCreateCause {
  Future<String> addEventPost(
      username,
      userprofilepic,
      eventname,
      feedtype,
      grade,
      subject,
      freq,
      _dtdate,
      date,
      timeSlot1,
      timeSlot2,
      from,
      to,
      from24hrs,
      to24hrs,
      loc,
      curr_lat,
      curr_long,
      _image,
      message,
      theme,
      index,
      taglist,
      videolist,
      thumbUrl,
      eventcategory,
      eventsubcategory,
      eventtype,
      meetingid,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds');
    await reference.add({
      "feedtype": feedtype,
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      'eventname': eventname,
      "eventcategory": eventcategory,
      "eventsubcategory": eventsubcategory,
      "eventtype": eventtype,
      "meetingid": meetingid,
      'grade': grade,
      'subject': subject,
      'frequency': freq,
      'DateTime': _dtdate,
      'date': date,
      'fromtime': timeSlot1,
      'totime': timeSlot2,
      'from': from,
      'to': to,
      "from24hrs": from24hrs,
      "to24hrs": to24hrs,
      'address': loc,
      'latitude': curr_lat,
      'longitude': curr_long,
      'poster': _image,
      "message": message,
      "theme": theme,
      "themeindex": index,
      "taglist": taglist,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference.child("sm_feeds").child("reactions").child(id).set({
        "likecount": 0,
        "commentcount": 0,
        "viewscount": 0,
        "joinedcount": 0
      });
    });
    return id;
  }

  Future<String> adduserCalendarEvent(
      feedid, eventname, date, from, to, freq, eventtype, meetingid) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference referrence = FirebaseFirestore.instance
        .collection('events_joined')
        .doc(firebaseUser + feedid);
    await referrence.set({
      "feedid": feedid,
      "userid": firebaseUser,
      "eventname": eventname,
      "date": date,
      "from": from,
      "to": to,
      "eventtype": eventtype,
      "meetingid": meetingid
    });
    return id;
  }

  Future getUserCalendarWhere(String id) async {
    return await FirebaseFirestore.instance
        .collection('events_joined')
        .where('userid', isEqualTo: id)
        .get();
  }

  Future getUserCalendarMeetingidFilter(String id) async {
    return await FirebaseFirestore.instance
        .collection('events_joined')
        .where('meetingid', isEqualTo: id)
        .get();
  }

  Future deleteCalenderDataWhere(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('events_joined')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<String> addEventJoinedDetails(feedid, userid, username, userschoolname,
      userprofilepic, usergrade, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('sm_event_joins_details')
        .doc(firebaseUser + feedid);

    await reference.set({
      "feedid": feedid,
      "userid": firebaseUser,
      "username": username,
      "userschoolname": userschoolname,
      "userprofilepic": userprofilepic,
      "usergrade": usergrade,
      "comparedate": comparedate,
      "updatedate": "",
      "createdate": createdate
    });
    return id;
  }

  Future<String> addEventLikesDetails(feedid, userid, username, userschoolname,
      userprofilepic, usergrade, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('sm_event_likes_details')
        .doc(firebaseUser + feedid);

    await reference.set({
      "feedid": feedid,
      "userid": firebaseUser,
      "username": username,
      "userschoolname": userschoolname,
      "userprofilepic": userprofilepic,
      "usergrade": usergrade,
      "comparedate": comparedate,
      "updatedate": "",
      "createdate": createdate
    });
    return id;
  }

  Future<dynamic> uploadEventPic(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userEventPoster/$firebaseUser/$firebaseUser' +
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
        .ref('userEventPoster/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future getUserEventData() async {
    return await FirebaseFirestore.instance.collection('eventdatatest').get();
  }

  Future getUserEventDataWhere(String id) async {
    return await FirebaseFirestore.instance
        .collection('eventdatatest')
        .where('feedid', isEqualTo: id)
        .get();
  }

  //delete:-
  //sm_events
  //sm_feeds me doc eventdaata ke field honge
  //usereventdatay
  Future getEventLikeData(String id) async {
    return await FirebaseFirestore.instance
        .collection('sm_event_likes_details')
        .where('feedid', isEqualTo: id)
        .get();
  }

  Future getEventJoinedData(String id) async {
    return await FirebaseFirestore.instance
        .collection('sm_event_joins_details')
        .where('feedid', isEqualTo: id)
        .get();
  }

  Future deleteUserLikeData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_event_likes_details')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future updateEventReactionCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addEventPostReactions(
      feedid,
      reactiontype,
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
        .collection('sm_event_reactions_details')
        .doc(firebaseUser + feedid);

    await reference.set({
      "feedid": feedid,
      "reactiontype": reactiontype,
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

  Future<dynamic> uploadSocialMediaEventImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialEventPost/$firebaseUser/Images/$firebaseUser' +
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
        .ref('SocialEventPost/$firebaseUser/Images/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceEventVideo(String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialEventPost/$firebaseUser/$firebaseUser' +
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
        .ref('SocialEventPost/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
