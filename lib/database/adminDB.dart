import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;

class AdminDB {
  String datavalue;
  Future<String> addQuestion(
      prifilepic,
      name,
      schoolname,
      grade,
      subject,
      topic,
      questiontype,
      question,
      ocrimage,
      noter,
      videor,
      audior,
      textr,
      answerpreference,
      credittoans,
      credittoque,
      callnow,
      date,
      timestart,
      timeend,
      createdate,
      posteddate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('userquestionadded');
    await reference.add({
      "profilepic": prifilepic,
      "userid": firebaseUser,
      "username": name,
      "schoolname": schoolname,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "questiontype": questiontype,
      "question": question,
      "ocrimage": ocrimage,
      "notereference": noter,
      "videoreference": videor,
      "audioreference": audior,
      "textreference": textr,
      'answerpreference': answerpreference,
      "creditanswer": credittoans,
      "creditquestion": credittoque,
      "callnow": callnow,
      "calldate": date,
      "callstarttime": timestart,
      "callendtime": timeend,
      "createdate": createdate,
      "posteddate": posteddate
    }).then((value) {
      id = value.id;
    });
    return id;
  }

  Future getQuestionAdded() async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .orderBy("posteddate", descending: true)
        .get();
  }

  Future getQuestionByID(String documentid) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .doc(documentid)
        .get();
  }

  Future updateUserData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userpersonaldata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future deleteQuestions(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<dynamic> uploadOCRImage(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userOCRImage/$firebaseUser/$firebaseUser' +
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
        .ref('userOCRImage/$firebaseUser/$firebaseUser' +
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
