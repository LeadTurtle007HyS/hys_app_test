import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:hys/database/notificationdb.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_database/firebase_database.dart';
import 'package:video_compress/video_compress.dart';
import 'package:intl/intl.dart';

//Question Database

final databaseReference = FirebaseDatabase.instance.reference();
QuerySnapshot tokenNotify;
QuerySnapshot allusers;
QuerySnapshot service;
QuerySnapshot allUserStrengths;
QuerySnapshot allUserAnswers;
QuerySnapshot callingFeedback;
CrudMethods crudobj = CrudMethods();
PushNotificationDB notify = PushNotificationDB();
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

class QuestionDB {
  String datavalue;

  //this function is used to stored the question in DB and also stored some data in realtime DB to show the progesws bar on hone page
  // alslo it used to send nktification and get the Bucket B user, so Super user logic is implemented here
  Future<void> addQuestion(
      prifilepic,
      name,
      schoolname,
      grade,
      subject,
      topic,
      questiontype,
      question,
      ocrimage,
      File noter,
      String videor,
      String audior,
      textr,
      answerpreference,
      tagedArray,
      tagids,
      credittoans,
      credittoque,
      callnow,
      date,
      timestart,
      timeend,
      bool showidentity,
      String callpreferedlanguage,
      createdate,
      posteddate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String audioUrl = "";
    String videoUrl = "";
    String notesUrl = "";
    print(noter);
    print(videor);
    print(audior);
    databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
      "isquestionposting": true,
      "questionpostingpercentage": 10,
      "isfeedpostposting": false,
      "feedpostpercentage": 0,
      "isanswerposting": false,
      "answerpercentage": 0,
      "showquestionfeedbackdialogbox": false
    });
    if (noter != null) {
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": true,
        "questionpostingpercentage": 15,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
        "showquestionfeedbackdialogbox": false
      });
      await uploadReferenceNotes(noter).then((value) {
        print(value);
        if (value[0] == true) {
          notesUrl = value[1];
        }
      });
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": true,
        "questionpostingpercentage": 20,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
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
        "isquestionposting": true,
        "questionpostingpercentage": 30,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
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
          "isquestionposting": true,
          "questionpostingpercentage": 50,
          "isfeedpostposting": false,
          "feedpostpercentage": 0,
          "isanswerposting": false,
          "answerpercentage": 0,
          "showquestionfeedbackdialogbox": false
        });
      }
    }
    if (audior != "") {
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": true,
        "questionpostingpercentage": 60,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
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
        "isquestionposting": true,
        "questionpostingpercentage": 80,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
        "showquestionfeedbackdialogbox": false
      });
    }
    databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
      "isquestionposting": true,
      "questionpostingpercentage": 90,
      "isfeedpostposting": false,
      "feedpostpercentage": 0,
      "isanswerposting": false,
      "answerpercentage": 0,
      "showquestionfeedbackdialogbox": false
    });
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
      "showidentity": showidentity,
      "question": question,
      "ocrimage": ocrimage,
      "notereference": notesUrl,
      "videoreference": videoUrl,
      "audioreference": audioUrl,
      "textreference": textr,
      'answerpreference': answerpreference,
      "tagedusersname": tagedArray,
      "tagedusersid": tagids,
      "creditanswer": credittoans,
      "creditquestion": credittoque,
      "callpreferedlanguage": callpreferedlanguage,
      "callnow": callnow,
      "calldate": date,
      "callstarttime": timestart,
      "callendtime": timeend,
      "createdate": createdate,
      "posteddate": posteddate,
      "examlikelyhoodcount": 0,
      "likecount": 0,
      "toughnesscount": 0,
      "viewcount": 0,
      "answercount": 0,
      "empressionscount": 0
    }).then((value) async {
      String id = value.id;
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": true,
        "questionpostingpercentage": 99,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
        "showquestionfeedbackdialogbox": false
      });
      await databaseReference.child(value.id).set({
        "examlikelyhoodcount": 0,
        "likecount": 0,
        "toughnesscount": 0,
        "viewcount": 0,
        "answercount": 0,
        "empressionscount": 0,
        "showquestionfeedbackdialogbox": false
      });
      databaseReference.child("PostUploadingStatus").child(firebaseUser).set({
        "isquestionposting": false,
        "questionpostingpercentage": 0,
        "isfeedpostposting": false,
        "feedpostpercentage": 0,
        "isanswerposting": false,
        "answerpercentage": 0,
        "showquestionfeedbackdialogbox": false
      });
      String calltype = "";
      if (answerpreference == "2") {
        calltype = "Video";
      } else if (answerpreference == "3") {
        calltype = "Audio";
      }

      await getUserStrengthData().then((value) async {
        allUserStrengths = value;
        if (allUserStrengths != null) {
          List<String> bucketD = [];
          List<int> atleast10Ans = [];
          List<int> atleast2AnsOnGST = [];
          List<int> bothGST_PLUS_10ANS = [];
          List _finalBucketA = [];
          for (int m = 0; m < allUserStrengths.docs.length; m++) {
            if ((allUserStrengths.docs[m].get("grade") == grade) &&
                (allUserStrengths.docs[m].get("subject") == subject) &&
                (allUserStrengths.docs[m].get("topic") == topic)) {
              bucketD.add(allUserStrengths.docs[m].get("userid"));
            }
          }
          // databaseReference
          //     .child("BucketD")
          //     .child(firebaseUser)
          //     .set({"bucketD": bucketD});
          await getAnswerPosted().then((value) async {
            allUserAnswers = value;
            if (allUserAnswers != null) {
              //Bucket A
              //call feedbackDB

              await getcallingFeedback().then((value) async {
                callingFeedback = value;
                if (callingFeedback != null) {
                  List callingfeedbaclCountList = [];
                  for (int k = 0; k < bucketD.length; k++) {
                    int countfeedBack = 0;
                    for (int l = 0; l < callingFeedback.docs.length; l++) {
                      if (callingFeedback.docs[l].get("feedbackgiventouser") ==
                          bucketD[k]) {
                        countfeedBack++;
                      }
                    }
                    callingfeedbaclCountList.add(countfeedBack);
                  }

                  // sorting according to feedback count Desc
                  for (int z = 0; z < callingfeedbaclCountList.length; ++z) {
                    for (int j = z + 1;
                        j < callingfeedbaclCountList.length;
                        ++j) {
                      if (callingfeedbaclCountList[z] <
                          callingfeedbaclCountList[j]) {
                        int a = callingfeedbaclCountList[z];
                        String b = bucketD[z];
                        callingfeedbaclCountList[z] =
                            callingfeedbaclCountList[j];
                        bucketD[z] = bucketD[j];
                        bucketD[j] = b;
                        callingfeedbaclCountList[j] = a;
                      }
                    }
                  }

                  for (int c = 0; c < bucketD.length; c++) {
                    if (callingfeedbaclCountList[c] >= 1 //5
                        ) {
                      _finalBucketA.add(bucketD[c]);
                    }
                  }
                  databaseReference.child("BucketA").child(firebaseUser).set({
                    "callingfeedbaclCountList": callingfeedbaclCountList,
                    "bucketA": _finalBucketA
                  });

                  await crudobj.getUserData().then((value) async {
                    service = value;
                    if (service != null) {
                      await crudobj.getAllUserData().then((value) async {
                        allusers = value;
                        if (allusers != null) {
                          await notify.getTokenData().then((value) async {
                            tokenNotify = value;
                            if (tokenNotify != null) {
                              for (int q = 0; q < _finalBucketA.length; q++) {
                                for (int i = 0;
                                    i < tokenNotify.docs.length;
                                    i++) {
                                  for (int j = 0;
                                      j < allusers.docs.length;
                                      j++) {
                                    if (tokenNotify.docs[i].get("userid") ==
                                            allusers.docs[j].get("userid") &&
                                        (tokenNotify.docs[i].get("userid") !=
                                            firebaseUser) &&
                                        allusers.docs[j].get("userid") ==
                                            _finalBucketA[q]) {
                                      print(tokenNotify.docs[i].get("userid"));
                                      var message = callnow == false
                                          ? "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution "
                                          : "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution on $calltype Call";
                                      notify.addCallingMessages(
                                          service.docs[0].get("firstname"),
                                          allusers.docs[j].get("firstname"),
                                          allusers.docs[j].get("userid"),
                                          message,
                                          current_date,
                                          tokenNotify.docs[i].get("token"),
                                          id,
                                          comparedate);
                                      notify.questionPostNotifications(
                                          service.docs[0].get("firstname"),
                                          allusers.docs[j].get("firstname"),
                                          allusers.docs[j].get("userid"),
                                          message,
                                          current_date,
                                          tokenNotify.docs[i].get("token"),
                                          id,
                                          answerpreference.toString(),
                                          callnow,
                                          "no",
                                          "questionaddedrequestsent",
                                          comparedate);
                                    }
                                  }
                                }
                              }
                            }
                          });
                        }
                      });
                    }
                  });
                }
              });

              //Bucket A users should not be part of bucket B
              for (int r = 0; r < _finalBucketA.length; r++) {
                for (int d = 0; d < bucketD.length; d++) {
                  if (bucketD[d] == _finalBucketA[r]) {
                    bucketD.removeAt(d);
                  }
                }
              }
              databaseReference
                  .child("BucketD-A")
                  .child(firebaseUser)
                  .set({"bucketD-A": bucketD});

              //Bucket D+C
              if (bucketD.length > 25) {
                databaseReference
                    .child("PratikTesting")
                    .child(firebaseUser)
                    .set({"step": ">25"});
                for (int n = 0; n < bucketD.length; n++) {
                  int countOfAny10Correct = 0;
                  int countOfGSTOnly = 0;

                  for (int p = 0; p < allUserAnswers.docs.length; p++) {
                    if (allUserAnswers.docs[p].get("answererid") ==
                        bucketD[n]) {
                      countOfAny10Correct++;
                    }

                    if ((allUserAnswers.docs[p].get("answererid") ==
                            bucketD[n]) &&
                        (allUserAnswers.docs[p].get("grade") == grade) &&
                        (allUserAnswers.docs[p].get("subject") == subject) &&
                        (allUserAnswers.docs[p].get("topic") == topic)) {
                      countOfGSTOnly++;
                    }
                  }

                  if (countOfAny10Correct >= 10) {
                    atleast10Ans.add(1);
                  } else {
                    atleast10Ans.add(0);
                  }
                  if (countOfGSTOnly >= 2) {
                    atleast2AnsOnGST.add(1);
                  } else {
                    atleast2AnsOnGST.add(0);
                  }
                  if ((countOfGSTOnly >= 2) && (countOfAny10Correct >= 10)) {
                    bothGST_PLUS_10ANS.add(1);
                  } else {
                    bothGST_PLUS_10ANS.add(0);
                  }
                }
                int check = 0;
                for (int f = 0; f < bucketD.length; f++) {
                  if (bothGST_PLUS_10ANS[f] == 1) {
                    check++;
                  }
                }
                if (check == 0) {
                  await crudobj.getUserData().then((value) async {
                    service = value;
                    if (service != null) {
                      await crudobj.getAllUserData().then((value) async {
                        allusers = value;
                        if (allusers != null) {
                          await notify.getTokenData().then((value) async {
                            tokenNotify = value;
                            if (tokenNotify != null) {
                              for (int q = 0; q < bucketD.length; q++) {
                                for (int i = 0;
                                    i < tokenNotify.docs.length;
                                    i++) {
                                  for (int j = 0;
                                      j < allusers.docs.length;
                                      j++) {
                                    if (tokenNotify.docs[i].get("userid") ==
                                            allusers.docs[j].get("userid") &&
                                        (tokenNotify.docs[i].get("userid") !=
                                            firebaseUser) &&
                                        allusers.docs[j].get("userid") ==
                                            bucketD[q]) {
                                      print(tokenNotify.docs[i].get("userid"));
                                      var message =
                                          "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution on $calltype Call";
                                      notify.notifyForBucketB(
                                          id,
                                          service.docs[0].get("firstname") +
                                              " " +
                                              service.docs[0].get("lastname"),
                                          allusers.docs[j].get("userid"),
                                          allusers.docs[j].get("firstname") +
                                              " " +
                                              allusers.docs[j].get("lastname"),
                                          tokenNotify.docs[i].get("token"),
                                          message,
                                          current_date,
                                          comparedate);
                                      notify
                                          .notifyForBucketBAllNotificationsTable(
                                              id,
                                              service.docs[0].get("firstname") +
                                                  " " +
                                                  service.docs[0]
                                                      .get("lastname"),
                                              allusers.docs[j].get("userid"),
                                              allusers.docs[j]
                                                      .get("firstname") +
                                                  " " +
                                                  allusers.docs[j]
                                                      .get("lastname"),
                                              tokenNotify.docs[i].get("token"),
                                              message,
                                              current_date,
                                              comparedate);
                                    }
                                  }
                                }
                              }
                            }
                          });
                        }
                      });
                    }
                  });
                } else {
                  await crudobj.getUserData().then((value) async {
                    service = value;
                    if (service != null) {
                      await crudobj.getAllUserData().then((value) async {
                        allusers = value;
                        if (allusers != null) {
                          await notify.getTokenData().then((value) async {
                            tokenNotify = value;
                            if (tokenNotify != null) {
                              for (int q = 0;
                                  q < bothGST_PLUS_10ANS.length;
                                  q++) {
                                for (int i = 0;
                                    i < tokenNotify.docs.length;
                                    i++) {
                                  for (int j = 0;
                                      j < allusers.docs.length;
                                      j++) {
                                    if (bothGST_PLUS_10ANS[q] == 1) {
                                      if (tokenNotify.docs[i].get("userid") ==
                                              allusers.docs[j].get("userid") &&
                                          (tokenNotify.docs[i].get("userid") !=
                                              firebaseUser) &&
                                          allusers.docs[j].get("userid") ==
                                              bucketD[q]) {
                                        print(
                                            tokenNotify.docs[i].get("userid"));
                                        var message =
                                            "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution on $calltype Call";
                                        notify.notifyForBucketB(
                                            id,
                                            service.docs[0].get("firstname") +
                                                " " +
                                                service.docs[0].get("lastname"),
                                            allusers.docs[j].get("userid"),
                                            allusers.docs[j].get("firstname") +
                                                " " +
                                                allusers.docs[j]
                                                    .get("lastname"),
                                            tokenNotify.docs[i].get("token"),
                                            message,
                                            current_date,
                                            comparedate);
                                        notify
                                            .notifyForBucketBAllNotificationsTable(
                                                id,
                                                service.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    service.docs[0]
                                                        .get("lastname"),
                                                allusers.docs[j].get("userid"),
                                                allusers.docs[j]
                                                        .get("firstname") +
                                                    " " +
                                                    allusers.docs[j]
                                                        .get("lastname"),
                                                tokenNotify.docs[i]
                                                    .get("token"),
                                                message,
                                                current_date,
                                                comparedate);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          });
                        }
                      });
                    }
                  });
                }
              } else if ((bucketD.length <= 25) && (bucketD.length != 0)) {
                databaseReference
                    .child("PratikTesting")
                    .child(firebaseUser)
                    .set({"step": "<25"});
                for (int n = 0; n < bucketD.length; n++) {
                  await crudobj.getUserData().then((value) async {
                    service = value;
                    if (service != null) {
                      await crudobj.getAllUserData().then((value) async {
                        allusers = value;
                        if (allusers != null) {
                          await notify.getTokenData().then((value) async {
                            tokenNotify = value;
                            if (tokenNotify != null) {
                              for (int q = 0; q < bucketD.length; q++) {
                                for (int i = 0;
                                    i < tokenNotify.docs.length;
                                    i++) {
                                  for (int j = 0;
                                      j < allusers.docs.length;
                                      j++) {
                                    if (tokenNotify.docs[i].get("userid") ==
                                            allusers.docs[j].get("userid") &&
                                        (tokenNotify.docs[i].get("userid") !=
                                            firebaseUser)) {
                                      if (allusers.docs[j].get("userid") ==
                                          bucketD[q]) {
                                        var message =
                                            "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution on $calltype Call";
                                        notify.notifyForBucketB(
                                            id,
                                            service.docs[0].get("firstname") +
                                                " " +
                                                service.docs[0].get("lastname"),
                                            allusers.docs[j].get("userid"),
                                            allusers.docs[j].get("firstname") +
                                                " " +
                                                allusers.docs[j]
                                                    .get("lastname"),
                                            tokenNotify.docs[i].get("token"),
                                            message,
                                            current_date,
                                            comparedate);

                                        notify
                                            .notifyForBucketBAllNotificationsTable(
                                                id,
                                                service.docs[0]
                                                        .get("firstname") +
                                                    " " +
                                                    service.docs[0]
                                                        .get("lastname"),
                                                allusers.docs[j].get("userid"),
                                                allusers.docs[j]
                                                        .get("firstname") +
                                                    " " +
                                                    allusers.docs[j]
                                                        .get("lastname"),
                                                tokenNotify.docs[i]
                                                    .get("token"),
                                                message,
                                                current_date,
                                                comparedate);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          });
                        }
                      });
                    }
                  });
                }
              } else if (bucketD.length == 0) {
                databaseReference
                    .child("PratikTesting")
                    .child(firebaseUser)
                    .set({"step": "=0"});
                await crudobj.getUserData().then((value) async {
                  service = value;
                  if (service != null) {
                    await crudobj.getAllUserData().then((value) async {
                      allusers = value;
                      if (allusers != null) {
                        await notify.getTokenData().then((value) async {
                          tokenNotify = value;
                          if (tokenNotify != null) {
                            for (int i = 0; i < tokenNotify.docs.length; i++) {
                              for (int j = 0; j < allusers.docs.length; j++) {
                                if (tokenNotify.docs[i].get("userid") ==
                                        allusers.docs[j].get("userid") &&
                                    (tokenNotify.docs[i].get("userid") !=
                                        firebaseUser)) {
                                  print(tokenNotify.docs[i].get("userid"));
                                  var message = callnow == false
                                      ? "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution "
                                      : "Hy's ${allusers.docs[j].get("firstname")}, Question matching your ability! Need Solution on $calltype Call";
                                  notify.addCallingMessages(
                                      service.docs[0].get("firstname"),
                                      allusers.docs[j].get("firstname"),
                                      allusers.docs[j].get("userid"),
                                      message,
                                      current_date,
                                      tokenNotify.docs[i].get("token"),
                                      id,
                                      comparedate);

                                  notify.questionPostNotifications(
                                      service.docs[0].get("firstname"),
                                      allusers.docs[j].get("firstname"),
                                      allusers.docs[j].get("userid"),
                                      message,
                                      current_date,
                                      tokenNotify.docs[i].get("token"),
                                      id,
                                      answerpreference.toString(),
                                      callnow,
                                      "no",
                                      "questionaddedrequestsent",
                                      comparedate);
                                }
                              }
                            }
                          }
                        });
                      }
                    });
                  }
                });
              }
            }
          });
        }
      });
    });
  }

  Future getcallingFeedback() async {
    return await FirebaseFirestore.instance
        .collection('audiovideosolutionfeedback')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future updateAddedQuestion(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future getUserStrengthData() async {
    return await FirebaseFirestore.instance
        .collection('strengthclassgradesubjectdata')
        .get();
  }

  Future getAllQuestionExamlikelihood() async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionexamlikelyhood')
        .get();
  }

  Future getAllQuestiontoughness() async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questiontoughness')
        .get();
  }

  Future getAnswerPosted() async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('useranswerposted')
        .orderBy("upvote", descending: true)
        .get();
  }

  Future<String> shareQuestion(
      sharedprofilepic,
      sharedname,
      sharedschoolname,
      sharedgrade,
      sharedate,
      sharecomment,
      sharedquestionid,
      userid,
      profilepic,
      name,
      schoolname,
      grade,
      subject,
      topic,
      sharequestiontype,
      questiontype,
      question,
      ocrimage,
      noter,
      videor,
      audior,
      textr,
      answerpreference,
      tagedArray,
      tagids,
      credittoans,
      credittoque,
      callnow,
      date,
      timestart,
      timeend,
      bool showidentity,
      String callpreferedlanguage,
      createdate,
      posteddate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    String id;

    CollectionReference reference =
        FirebaseFirestore.instance.collection('userquestionadded');
    await reference.add({
      "sharedprofilepic": sharedprofilepic,
      "sharedname": sharedname,
      "shareduserid": firebaseUser,
      "sharedschoolname": sharedschoolname,
      "sharedgrade": sharedgrade,
      "sharedate": sharedate,
      "showidentity": showidentity,
      "callpreferedlanguage": callpreferedlanguage,
      "sharecomment": sharecomment,
      "sharedquestionid": sharedquestionid,
      "profilepic": profilepic,
      "userid": userid,
      "username": name,
      "schoolname": schoolname,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "sharequestiontype": sharequestiontype,
      "tagedusersname": tagedArray,
      "tagedusersid": tagids,
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
      "posteddate": posteddate,
      "examlikelyhoodcount": 0,
      "likecount": 0,
      "toughnesscount": 0,
      "viewcount": 0,
      "answercount": 0,
      "empressionscount": 0
    }).then((value) {
      databaseReference.child(value.id).set({
        "examlikelyhoodcount": 0,
        "likecount": 0,
        "toughnesscount": 0,
        "viewcount": 0,
        "answercount": 0,
        "empressionscount": 0
      });
    });
    return id;
  }

//username who like the question
  Future<void> addQuestionLiked(questionid, askerid, username, profilepic,
      school, grade, likedtype, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionliked")
        .doc(firebaseUser + questionid + likedtype);
    await reference.set({
      "questionid": questionid,
      "likedtype": likedtype,
      "userid": firebaseUser,
      "username": username,
      "askerid": askerid,
      "profilepic": profilepic,
      "schoolname": school,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestionPostedByMe() async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getSubjectwiseQuestionPostedByMe(String subject) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .where("subject", isEqualTo: subject)
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getQuestionLikedAllTypes(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionliked')
        .where("questionid", isEqualTo: id)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getQuestionLiked(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionliked')
        .where("questionid", isEqualTo: id)
        .orderBy("comparedate", descending: true)
        .where("likedtype", isEqualTo: "like")
        .get();
  }

  Future<void> addQuestionMyDoubtToo(questionid, askerid, username, profilepic,
      school, grade, likedtype, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionliked")
        .doc(firebaseUser + questionid + "mydoubttoo");
    await reference.set({
      "questionid": questionid,
      "likedtype": likedtype,
      "userid": firebaseUser,
      "username": username,
      "askerid": askerid,
      "profilepic": profilepic,
      "schoolname": school,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestionMyDoubtToo(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionliked')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("likedtype", isEqualTo: "mydoubttoo")
        .get();
  }

  Future<void> addQuestionMarkedAsImp(questionid, askerid, username, profilepic,
      school, grade, likedtype, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionliked")
        .doc(firebaseUser + questionid + "markasimp");
    await reference.set({
      "questionid": questionid,
      "likedtype": likedtype,
      "userid": firebaseUser,
      "username": username,
      "askerid": askerid,
      "profilepic": profilepic,
      "schoolname": school,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getUserProfileData(String id) async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .where('userid', isEqualTo: id)
        .get();
  }

  Future getQuestionMarkAsImp(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionliked')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("likedtype", isEqualTo: "markasimp")
        .get();
  }

  Future deleteQuestionLiked(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questionliked")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addDataToUserEnvolvedInQuestion(
      questionid, username, function, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("userenvolvedinquestion")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "userid": firebaseUser,
      "username": username,
      "createdate": createdate,
      "function": function,
      "comparedate": comparedate
    });
  }

  Future getDataToUserEnvolvedInQuestion(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('userenvolvedinquestion')
        .where("questionid", isEqualTo: id)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future<void> addQuestiontoughness(questionid, askerid, username, level,
      profilepic, schoolname, grade, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questiontoughness")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "userid": firebaseUser,
      "askerid": askerid,
      "typelevel": level,
      "username": username,
      "profilepic": profilepic,
      "schoolname": schoolname,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestiontoughnessAll(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questiontoughness')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .get();
  }

  Future getQuestiontoughnessHigh(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questiontoughness')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "high")
        .get();
  }

  Future getQuestiontoughnessModerate(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questiontoughness')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "medium")
        .get();
  }

  Future getQuestiontoughnessLow(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questiontoughness')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "low")
        .get();
  }

  Future deleteQuestionToughness(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questiontoughness")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addQuestionSaved(
      questionid,
      questionIndex,
      subject,
      topic,
      question,
      questiontype,
      askerid,
      username,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionsaved")
        .doc(firebaseUser + questionid);
    ;
    await reference.set({
      "questionid": questionid,
      "questionIndex": questionIndex,
      "subject": subject,
      "topic": topic,
      "username": username,
      "userid": firebaseUser,
      "askerid": askerid,
      "question": question,
      "questiontype": questiontype,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestionSaved() async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionsaved')
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .orderBy("topic", descending: true)
        .get();
  }

  Future deleteQuestionSaved(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questionsaved")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addQuestionBookmarked(
      questionid,
      questionIndex,
      subject,
      topic,
      question,
      questiontype,
      askerid,
      username,
      createdate,
      comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionbookmarked")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "questionIndex": questionIndex,
      "subject": subject,
      "topic": topic,
      "username": username,
      "userid": firebaseUser,
      "askerid": askerid,
      "question": question,
      "questiontype": questiontype,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestionBookmarked() async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionbookmarked')
        .where("userid", isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .orderBy("topic", descending: true)
        .get();
  }

  Future deleteQuestionBookMarked(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questionbookmarked")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addQuestionAnswered(
      questionid, askerid, username, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionanswered")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "username": username,
      "userid": firebaseUser,
      "askerid": askerid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future deleteQuestionAnswered(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questionanswered")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addQuestionExamlikelyhood(questionid, askerid, username, level,
      profilepic, schoolname, grade, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionexamlikelyhood")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "userid": firebaseUser,
      "askerid": askerid,
      "typelevel": level,
      "username": username,
      "profilepic": profilepic,
      "schoolname": schoolname,
      "grade": grade,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getQuestionExamlikelihoodAll(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionexamlikelyhood')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .get();
  }

  Future getQuestionExamlikelihoodHigh(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionexamlikelyhood')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "high")
        .get();
  }

  Future getQuestionExamlikelihoodModerate(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionexamlikelyhood')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "moderate")
        .get();
  }

  Future getQuestionExamlikelihoodLow(String id) async {
    // var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection('questionexamlikelyhood')
        .orderBy("comparedate", descending: true)
        .where("questionid", isEqualTo: id)
        .where("typelevel", isEqualTo: "low")
        .get();
  }

  Future<void> addquestionReportData(questionid, reportername, reporttype,
      message, receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionreport")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "reportername": reportername,
      "message": message,
      "reporttype": reporttype,
      "reporterid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future<void> addquestionAskReference(questionid, referencername, message,
      receivertokenid, createdate, comparedate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection("questionaskreference")
        .doc(firebaseUser + questionid);
    await reference.set({
      "questionid": questionid,
      "referencername": referencername,
      "message": message,
      "referencerid": firebaseUser,
      "receivertokenid": receivertokenid,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future deleteQuestionAskReference(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection("questionaskreference")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteQuestionExamLikelyhood(selectedDoc) async {
    var firebaseUser = FirebaseAuth.instance.currentUser.uid;
    return await FirebaseFirestore.instance
        .collection("questionexamlikelyhood")
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
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

  Future updateLikeCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateImpressionCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateAnswerCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateToughnessCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateExamLikelyhoodCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userquestionadded');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future deleteUserPersonalData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
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
