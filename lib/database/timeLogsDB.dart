import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class TimeLogsDB {
  final firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;

  Future<void> addQALogs(activetime, visitCounts, onlydate, startTime,
      createdate, comparedate) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection("userSectionlogs")
        .doc(firebaseUser)
        .collection("qalogs")
        .doc(onlydate);
    await reference.set({
      "senderid": firebaseUser,
      "activetime": activetime,
      "visitcounts": visitCounts,
      "onlydate": onlydate,
      "starttime": startTime,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQALogs(String date) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userSectionlogs')
        .doc(firebaseUser)
        .collection("qalogs")
        .doc(date)
        .get();
  }

  Future<void> addSocialLogs(activetime, visitCounts, onlydate, startTime,
      createdate, comparedate) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection("userSectionlogs")
        .doc(firebaseUser)
        .collection("sociallogs")
        .doc(onlydate);
    await reference.set({
      "senderid": firebaseUser,
      "activetime": activetime,
      "visitcounts": visitCounts,
      "onlydate": onlydate,
      "starttime": startTime,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getSocialLogs(String date) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userSectionlogs')
        .doc(firebaseUser)
        .collection("sociallogs")
        .doc(date)
        .get();
  }

  Future<void> addSearchFriendLogs(friendID, createdate, comparedate) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection("userSectionlogs")
        .doc(firebaseUser)
        .collection("searchedfriendlogs")
        .doc(firebaseUser + friendID);
    await reference.set({
      "id": "friendSearched",
      "userid": firebaseUser,
      "friendid": friendID,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getSearchFriendLogs() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userSectionlogs')
        .doc(firebaseUser)
        .collection("searchedfriendlogs")
        .get();
  }

  Future updateNotificationData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('allnotifications');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }
}
