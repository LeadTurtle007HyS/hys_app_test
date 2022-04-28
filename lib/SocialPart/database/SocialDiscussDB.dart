import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

final databaseReference = FirebaseDatabase.instance.reference();

class SocialDiscuss {
  Future<String> addProjectDetails(
    username,
    userprofilepic,
    content,
    theme,
    title,
    grade,
    subject,
    topic,
    teamMembers,
    requirements,
    purchasedfrom,
    procedure,
    theory,
    findings,
    similartheory,
    projectvideourl,
    reqvideourl,
    summarydoc,
    otherdoc,
    createdate,
    comparedate,
  ) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("sm_feeds");
    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "feedtype": "projectdiscuss",
      "userprofilepic": userprofilepic,
      "content": content,
      "theme": theme,
      "title": title,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "teamMembers": teamMembers,
      "requirements": requirements,
      "purchasedfrom": purchasedfrom,
      "procedure": procedure,
      "theory": theory,
      "findings": findings,
      "similartheory": similartheory,
      "projectvideourl": projectvideourl,
      "reqvideourl": reqvideourl,
      "summarydoc": summarydoc,
      "otherdoc": otherdoc,
      "createdate": createdate,
      "comparedate": comparedate,
      "updatedate": ""
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
    });
  }

  Future<String> addBusinessIdeaDetails(
    username,
    userprofilepic,
    title,
    theme,
    identification,
    solution,
    target,
    competitors,
    swot,
    strategy,
    funds,
    content,
    membersname,
    membersid,
    taggedstring,
    documents,
    fileformat,
    length,
    createdate,
    comparedate,
  ) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("sm_feeds");
    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      "feedtype": "businessideas",
      "content": content,
      "theme": theme,
      "title": title,
      "identification": identification,
      "solution": solution,
      "target": target,
      "competitors": competitors,
      "swot": swot,
      "strategy": strategy,
      "funds": funds,
      "membersname": membersname,
      "membersid": membersid,
      "taggedstring": taggedstring,
      "documents": documents,
      "formats": fileformat,
      "totaldocuments": length,
      "createdate": createdate,
      "comparedate": comparedate,
      "updatedate": ""
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
    });
  }

  Future deleteRatings() async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("project_ratings");
    await reference.doc().delete().then((value) {
      print("deleted");
    });
  }

  Future addProjectRating(
      projectid, userid, rating, profilepic, username) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("project_ratings");
    await reference.add({
      "projectid": projectid,
      "userid": userid,
      "rating": rating,
      "userprofilepic": profilepic,
      "username": username
    });
  }

  Future addBusinessIdeaRating(
      projectid, userid, rating, profilepic, username) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("businessideas_ratings");
    await reference.add({
      "projectid": projectid,
      "userid": userid,
      "rating": rating,
      "userprofilepic": profilepic,
      "username": username
    });
  }

  Future getProjectRating() async {
    return await FirebaseFirestore.instance.collection('project_ratings').get();
  }

  Future getBusinessIdeaRating() async {
    return await FirebaseFirestore.instance
        .collection('businessideas_ratings')
        .get();
  }

  Future getDiscussedProjects() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance.collection('sm_feeds').get();
  }

  Future getDiscussedBusinessIdeas() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance.collection('sm_feeds').get();
  }

  Future getDiscussedProjectsWhere(id) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('sm_feeds')
        .doc(id)
        .get();
  }

  Future getDiscussedBusinessIdeasWhere(id) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('sm_feeds')
        .doc(id)
        .get();
  }

  Future<dynamic> uploadSocialMediaFeedImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/$firebaseUser/Images/$firebaseUser' +
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
        .ref('SocialFeedPost/$firebaseUser/Images/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadProjectVideo(String filePath) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
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
}
