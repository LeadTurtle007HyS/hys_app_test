import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hys/database/uploadsDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class AllUploadsView extends StatefulWidget {
  @override
  _AllUploadsViewState createState() => _AllUploadsViewState();
}

class _AllUploadsViewState extends State<AllUploadsView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(backgroundColor: Colors.white, body: _body()));
  }

  Box<dynamic> usertokendataLocalDB;

  CrudMethods crudobj = CrudMethods();
  UploadsDB uploadsDB = UploadsDB();
  QuerySnapshot subjects;
  QuerySnapshot allUploads;
  QuerySnapshot allUserData;

  bool isSchoolExams = true;
  bool isClassNotes = false;
  bool isCompExams = false;
  bool isothers = false;
  int gradeIndex = 0;
  int subjectIndex = 0;

  List<String> schoolExamGrade = [];
  List<List<String>> schoolExamSubject = [];
  List<List<List<String>>> schoolExamFileIDs = [];

  List<String> classNotesGrade = [];
  List<List<String>> classNotesSubject = [];
  List<List<List<String>>> classNotesFileIDs = [];

  List<String> compExamGrade = [];
  List<List<String>> compExamSubject = [];
  List<List<List<String>>> compExamFileIDs = [];

  List<String> othersGrade = [];
  List<List<String>> othersSubject = [];
  List<List<List<String>>> othersFileIDs = [];

  List<List<String>> subjectListgradeWise = [];
  List<String> gradeList = ["5", "6", "7", "8", "9", "10", "11", "12"];

  void initState() {
    usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    crudobj.getAllUserData().then((value) {
      setState(() {
        allUserData = value;
      });
    });
    uploadsDB.getSubjectAndTopicList().then((value) {
      setState(() {
        subjects = value;
        if (subjects != null) {
          //to get subject list
          for (int q = 0; q < gradeList.length; q++) {
            List<String> subjectList = [];
            subjectList.add("English");
            subjectList.add("Science");
            subjectList.add("General Science");
            subjectList.add("General Knowledge");
            for (int i = 0; i < subjects.docs.length; i++) {
              if (subjects.docs[i].get("grade") == gradeList[q]) {
                if (subjectList.length == 0) {
                  setState(() {
                    subjectList.add(subjects.docs[i].get("subject"));
                  });
                } else {
                  int count = 0;
                  for (int j = 0; j < subjectList.length; j++) {
                    if (subjectList[j] == subjects.docs[i].get("subject")) {
                      setState(() {
                        count++;
                      });
                      break;
                    }
                  }
                  if (count == 0) {
                    setState(() {
                      subjectList.add(subjects.docs[i].get("subject"));
                    });
                  }
                }
              }
            }
            subjectListgradeWise.add(subjectList);
            subjectList = [];
          }
          //  print(subjectListgradeWise);

          uploadsDB.getAllUploads().then((value) {
            setState(() {
              allUploads = value;
              if (value != null) {
                schoolExamGrade = [];
                for (int i = 0; i < allUploads.docs.length; i++) {
                  if (allUploads.docs[i].get("uploadtype") == "School Exams") {
                    //grade
                    if (schoolExamGrade.length != 0) {
                      int count = 0;
                      for (int j = 0; j < schoolExamGrade.length; j++) {
                        if (schoolExamGrade[j] ==
                            allUploads.docs[i].get("class")) {
                          setState(() {
                            count++;
                          });
                        }
                      }
                      if (count == 0) {
                        schoolExamGrade.add(allUploads.docs[i].get("class"));
                      }
                      count = 0;
                    } else {
                      schoolExamGrade.add(allUploads.docs[i].get("class"));
                    }
                  } else if (allUploads.docs[i].get("uploadtype") ==
                      "Class Notes") {
                    //grade
                    if (classNotesGrade.length != 0) {
                      int count = 0;
                      for (int j = 0; j < classNotesGrade.length; j++) {
                        if (classNotesGrade[j] ==
                            allUploads.docs[i].get("class")) {
                          setState(() {
                            count++;
                          });
                        }
                      }
                      if (count == 0) {
                        classNotesGrade.add(allUploads.docs[i].get("class"));
                      }
                      count = 0;
                    } else {
                      classNotesGrade.add(allUploads.docs[i].get("class"));
                    }
                  } else if (allUploads.docs[i].get("uploadtype") ==
                      "Competitive Exams") {
                    //grade
                    if (compExamGrade.length != 0) {
                      int count = 0;
                      for (int j = 0; j < compExamGrade.length; j++) {
                        if (compExamGrade[j] ==
                            allUploads.docs[i].get("class")) {
                          setState(() {
                            count++;
                          });
                        }
                      }
                      if (count == 0) {
                        compExamGrade.add(allUploads.docs[i].get("class"));
                      }
                      count = 0;
                    } else {
                      compExamGrade.add(allUploads.docs[i].get("class"));
                    }
                  } else if (allUploads.docs[i].get("uploadtype") == "Others") {
                    //grade
                    if (othersGrade.length != 0) {
                      int count = 0;
                      for (int j = 0; j < othersGrade.length; j++) {
                        if (othersGrade[j] == allUploads.docs[i].get("class")) {
                          setState(() {
                            count++;
                          });
                        }
                      }
                      if (count == 0) {
                        othersGrade.add(allUploads.docs[i].get("class"));
                      }
                      count = 0;
                    } else {
                      othersGrade.add(allUploads.docs[i].get("class"));
                    }
                  }
                }
                schoolExamGrade.sort();
                classNotesGrade.sort();
                compExamGrade.sort();
                othersGrade.sort();

                for (int i = 0; i < schoolExamGrade.length; i++) {
                  List<String> gradeWiseSubjectList = [];
                  for (int j = 0; j < allUploads.docs.length; j++) {
                    if ((allUploads.docs[j].get("class") ==
                            schoolExamGrade[i]) &&
                        (allUploads.docs[j].get("uploadtype") ==
                            "School Exams")) {
                      if (gradeWiseSubjectList.length != 0) {
                        int count = 0;
                        for (int k = 0; k < gradeWiseSubjectList.length; k++) {
                          if (gradeWiseSubjectList[k] ==
                              allUploads.docs[j].get("subject")) {
                            setState(() {
                              count++;
                            });
                            break;
                          }
                        }
                        if (count == 0) {
                          String subjectUploaded = (subjectListgradeWise[
                                      int.parse(schoolExamGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[j]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                          subjectUploaded = subjectUploaded.substring(
                              0, subjectUploaded.length - 1);
                          gradeWiseSubjectList.add(subjectUploaded);
                        }
                      } else {
                        String subjectUploaded = (subjectListgradeWise[
                                int.parse(schoolExamGrade[i]) - 5]
                            .where((element) => element.toLowerCase().contains(
                                allUploads.docs[j]
                                    .get("subject")
                                    .toLowerCase()
                                    .toString()
                                    .substring(0, 4)))).toString().substring(1);
                        subjectUploaded = subjectUploaded.substring(
                            0, subjectUploaded.length - 1);
                        gradeWiseSubjectList.add(subjectUploaded);
                      }
                    }
                  }
                  schoolExamSubject.add(gradeWiseSubjectList);

                  List<List<String>> uploadFileListSubjectWise = [];
                  for (int m = 0; m < schoolExamSubject[i].length; m++) {
                    List<String> gradeSubjectWiseUploadFileIDs = [];
                    for (int n = 0; n < allUploads.docs.length; n++) {
                      String subjectUploaded = (subjectListgradeWise[
                              int.parse(schoolExamGrade[i]) - 5]
                          .where((element) => element.toLowerCase().contains(
                              allUploads.docs[n]
                                  .get("subject")
                                  .toLowerCase()
                                  .toString()
                                  .substring(0, 4)))).toString().substring(1);
                      subjectUploaded = subjectUploaded.substring(
                          0, subjectUploaded.length - 1);
                      if (((schoolExamSubject[i][m]).toLowerCase() ==
                              (subjectUploaded).toLowerCase()) &&
                          ((allUploads.docs[n].get("class")) ==
                              schoolExamGrade[i]) &&
                          (allUploads.docs[n].get("uploadtype") ==
                              "School Exams")) {
                        print("2");
                        gradeSubjectWiseUploadFileIDs
                            .add(allUploads.docs[n].id);
                      }
                    }
                    uploadFileListSubjectWise
                        .add(gradeSubjectWiseUploadFileIDs);
                  }
                  schoolExamFileIDs.add(uploadFileListSubjectWise);
                }
                print(schoolExamGrade);
                print(schoolExamSubject);
                print(schoolExamFileIDs);
                //-------------------------------------------Class Notes-----------------------------------

                for (int i = 0; i < classNotesGrade.length; i++) {
                  List<String> gradeWiseSubjectList = [];
                  for (int j = 0; j < allUploads.docs.length; j++) {
                    if ((allUploads.docs[j].get("class") ==
                            classNotesGrade[i]) &&
                        (allUploads.docs[j].get("uploadtype") ==
                            "Class Notes")) {
                      if (gradeWiseSubjectList.length != 0) {
                        int count = 0;
                        for (int k = 0; k < gradeWiseSubjectList.length; k++) {
                          if (gradeWiseSubjectList[k] ==
                              allUploads.docs[j].get("subject")) {
                            setState(() {
                              count++;
                            });
                            break;
                          }
                        }
                        if (count == 0) {
                          String subjectUploaded = (subjectListgradeWise[
                                      int.parse(classNotesGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[j]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                          subjectUploaded = subjectUploaded.substring(
                              0, subjectUploaded.length - 1);
                          gradeWiseSubjectList.add(subjectUploaded);
                        }
                      } else {
                        String subjectUploaded = (subjectListgradeWise[
                                int.parse(classNotesGrade[i]) - 5]
                            .where((element) => element.toLowerCase().contains(
                                allUploads.docs[j]
                                    .get("subject")
                                    .toLowerCase()
                                    .toString()
                                    .substring(0, 4)))).toString().substring(1);
                        subjectUploaded = subjectUploaded.substring(
                            0, subjectUploaded.length - 1);
                        gradeWiseSubjectList.add(subjectUploaded);
                      }
                    }
                  }
                  classNotesSubject.add(gradeWiseSubjectList);

                  List<List<String>> uploadFileListSubjectWise = [];
                  for (int m = 0; m < classNotesSubject[i].length; m++) {
                    List<String> gradeSubjectWiseUploadFileIDs = [];
                    for (int n = 0; n < allUploads.docs.length; n++) {
                      String subjectUploaded = (subjectListgradeWise[
                              int.parse(classNotesGrade[i]) - 5]
                          .where((element) => element.toLowerCase().contains(
                              allUploads.docs[n]
                                  .get("subject")
                                  .toLowerCase()
                                  .toString()
                                  .substring(0, 4)))).toString().substring(1);
                      subjectUploaded = subjectUploaded.substring(
                          0, subjectUploaded.length - 1);
                      if (((classNotesSubject[i][m]).toLowerCase() ==
                              (subjectUploaded).toLowerCase()) &&
                          ((allUploads.docs[n].get("class")) ==
                              classNotesGrade[i]) &&
                          (allUploads.docs[n].get("uploadtype") ==
                              "Class Notes")) {
                        gradeSubjectWiseUploadFileIDs
                            .add(allUploads.docs[n].id);
                      }
                    }
                    uploadFileListSubjectWise
                        .add(gradeSubjectWiseUploadFileIDs);
                  }
                  classNotesFileIDs.add(uploadFileListSubjectWise);
                }
                print(classNotesGrade);
                print(classNotesSubject);
                print(classNotesFileIDs);

                //-------------------------------------------Compettitive Exam-----------------------------------

                for (int i = 0; i < compExamGrade.length; i++) {
                  List<String> gradeWiseSubjectList = [];
                  for (int j = 0; j < allUploads.docs.length; j++) {
                    if ((allUploads.docs[j].get("class") == compExamGrade[i]) &&
                        (allUploads.docs[j].get("uploadtype") ==
                            "Competitive Exams")) {
                      if (gradeWiseSubjectList.length != 0) {
                        int count = 0;
                        for (int k = 0; k < gradeWiseSubjectList.length; k++) {
                          if (gradeWiseSubjectList[k] ==
                              allUploads.docs[j].get("subject")) {
                            setState(() {
                              count++;
                            });
                            break;
                          }
                        }
                        if (count == 0) {
                          String subjectUploaded = (subjectListgradeWise[
                                      int.parse(compExamGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[j]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                          subjectUploaded = subjectUploaded.substring(
                              0, subjectUploaded.length - 1);
                          gradeWiseSubjectList.add(subjectUploaded);
                        }
                      } else {
                        String subjectUploaded = (subjectListgradeWise[
                                int.parse(compExamGrade[i]) - 5]
                            .where((element) => element.toLowerCase().contains(
                                allUploads.docs[j]
                                    .get("subject")
                                    .toLowerCase()
                                    .toString()
                                    .substring(0, 4)))).toString().substring(1);
                        subjectUploaded = subjectUploaded.substring(
                            0, subjectUploaded.length - 1);
                        gradeWiseSubjectList.add(subjectUploaded);
                      }
                    }
                  }
                  compExamSubject.add(gradeWiseSubjectList);

                  List<List<String>> uploadFileListSubjectWise = [];
                  for (int m = 0; m < compExamSubject[i].length; m++) {
                    List<String> gradeSubjectWiseUploadFileIDs = [];
                    for (int n = 0; n < allUploads.docs.length; n++) {
                      String subjectUploaded =
                          (subjectListgradeWise[int.parse(compExamGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[n]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                      subjectUploaded = subjectUploaded.substring(
                          0, subjectUploaded.length - 1);
                      if (((compExamSubject[i][m]).toLowerCase() ==
                              (subjectUploaded).toLowerCase()) &&
                          ((allUploads.docs[n].get("class")) ==
                              compExamGrade[i]) &&
                          (allUploads.docs[n].get("uploadtype") ==
                              "Competitive Exams")) {
                        gradeSubjectWiseUploadFileIDs
                            .add(allUploads.docs[n].id);
                      }
                    }
                    uploadFileListSubjectWise
                        .add(gradeSubjectWiseUploadFileIDs);
                  }
                  compExamFileIDs.add(uploadFileListSubjectWise);
                }
                print(compExamGrade);
                print(compExamSubject);
                print(compExamFileIDs);

                //-------------------------------------------Others-----------------------------------

                for (int i = 0; i < othersGrade.length; i++) {
                  List<String> gradeWiseSubjectList = [];
                  for (int j = 0; j < allUploads.docs.length; j++) {
                    if ((allUploads.docs[j].get("class") == othersGrade[i]) &&
                        (allUploads.docs[j].get("uploadtype") == "Others")) {
                      if (gradeWiseSubjectList.length != 0) {
                        int count = 0;
                        for (int k = 0; k < gradeWiseSubjectList.length; k++) {
                          if (gradeWiseSubjectList[k] ==
                              allUploads.docs[j].get("subject")) {
                            setState(() {
                              count++;
                            });
                            break;
                          }
                        }
                        if (count == 0) {
                          String subjectUploaded = (subjectListgradeWise[
                                      int.parse(othersGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[j]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                          subjectUploaded = subjectUploaded.substring(
                              0, subjectUploaded.length - 1);
                          gradeWiseSubjectList.add(subjectUploaded);
                        }
                      } else {
                        String subjectUploaded =
                            (subjectListgradeWise[int.parse(othersGrade[i]) - 5]
                                    .where((element) => element
                                        .toLowerCase()
                                        .contains(allUploads.docs[j]
                                            .get("subject")
                                            .toLowerCase()
                                            .toString()
                                            .substring(0, 4))))
                                .toString()
                                .substring(1);
                        subjectUploaded = subjectUploaded.substring(
                            0, subjectUploaded.length - 1);
                        gradeWiseSubjectList.add(subjectUploaded);
                      }
                    }
                  }
                  othersSubject.add(gradeWiseSubjectList);

                  List<List<String>> uploadFileListSubjectWise = [];
                  for (int m = 0; m < othersSubject[i].length; m++) {
                    List<String> gradeSubjectWiseUploadFileIDs = [];
                    for (int n = 0; n < allUploads.docs.length; n++) {
                      String subjectUploaded =
                          (subjectListgradeWise[int.parse(othersGrade[i]) - 5]
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(allUploads.docs[n]
                                          .get("subject")
                                          .toLowerCase()
                                          .toString()
                                          .substring(0, 4))))
                              .toString()
                              .substring(1);
                      subjectUploaded = subjectUploaded.substring(
                          0, subjectUploaded.length - 1);
                      if (((othersSubject[i][m]).toLowerCase() ==
                              (subjectUploaded).toLowerCase()) &&
                          ((allUploads.docs[n].get("class")) ==
                              othersGrade[i]) &&
                          (allUploads.docs[n].get("uploadtype") == "Others")) {
                        gradeSubjectWiseUploadFileIDs
                            .add(allUploads.docs[n].id);
                      }
                    }
                    uploadFileListSubjectWise
                        .add(gradeSubjectWiseUploadFileIDs);
                  }
                  othersFileIDs.add(uploadFileListSubjectWise);
                }
                print(othersGrade);
                print(othersSubject);
                print(othersFileIDs);
              }
            });
          });
        }
      });
    });
    super.initState();
  }

  _body() {
    if ((subjects != null) && (allUploads != null) && (allUserData != null)) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Tab(
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black54, size: 20)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isClassNotes = false;
                      isCompExams = false;
                      isothers = false;
                      isSchoolExams = true;
                      gradeIndex = 0;
                      subjectIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSchoolExams == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/schoolnotes.png",
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "School Notes",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSchoolExams = false;

                      isCompExams = false;
                      isothers = false;
                      isClassNotes = true;
                      gradeIndex = 0;
                      subjectIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isClassNotes == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/classnotes.jpg",
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Class Notes",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSchoolExams = false;
                      isClassNotes = false;

                      isothers = false;
                      isCompExams = true;
                      gradeIndex = 0;
                      subjectIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isCompExams == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/competitiveexam.jpg",
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Competitive\nExam",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSchoolExams = false;
                      isClassNotes = false;
                      isCompExams = false;
                      isothers = true;
                      gradeIndex = 0;
                      subjectIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isothers == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/othernotes.jpg",
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Others",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ]),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 5,
                color: Colors.grey[200]),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 25,
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Grade: ",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width - 80,
                    height: 25,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: isSchoolExams == true
                          ? schoolExamGrade.length
                          : isClassNotes == true
                              ? classNotesGrade.length
                              : isCompExams == true
                                  ? compExamGrade.length
                                  : isothers == true
                                      ? othersGrade.length
                                      : gradeList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (gradeIndex == index) {
                                gradeIndex = 0;
                              } else {
                                gradeIndex = index;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: index == gradeIndex
                                  ? Color.fromRGBO(88, 165, 196, 1)
                                  : Colors.transparent,
                            ),
                            margin: EdgeInsets.only(left: 15),
                            child: Text(
                              isSchoolExams == true
                                  ? schoolExamGrade[index]
                                  : isClassNotes == true
                                      ? classNotesGrade[index]
                                      : isCompExams == true
                                          ? compExamGrade[index]
                                          : isothers == true
                                              ? othersGrade[index]
                                              : gradeList[index],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 5,
                color: Colors.grey[200]),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Subjects: ",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width - 80,
                    height: 25,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: isSchoolExams == true
                          ? schoolExamSubject[gradeIndex].length
                          : isClassNotes == true
                              ? classNotesSubject[gradeIndex].length
                              : isCompExams == true
                                  ? compExamSubject[gradeIndex].length
                                  : isothers == true
                                      ? othersSubject[gradeIndex].length
                                      : 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (subjectIndex == index) {
                                subjectIndex = 0;
                              } else {
                                subjectIndex = index;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: index == subjectIndex
                                  ? Color.fromRGBO(88, 165, 196, 1)
                                  : Colors.transparent,
                            ),
                            margin: EdgeInsets.only(left: 15),
                            child: Text(
                              isSchoolExams == true
                                  ? schoolExamSubject[gradeIndex][index]
                                  : isClassNotes == true
                                      ? classNotesSubject[gradeIndex][index]
                                      : isCompExams == true
                                          ? compExamSubject[gradeIndex][index]
                                          : isothers == true
                                              ? othersSubject[gradeIndex][index]
                                              : "",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 5,
                color: Colors.grey[200]),
            SizedBox(
              height: 15,
            ),
            Container(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: isSchoolExams == true
                      ? schoolExamFileIDs[gradeIndex][subjectIndex].length
                      : isClassNotes == true
                          ? classNotesFileIDs[gradeIndex][subjectIndex].length
                          : isCompExams == true
                              ? compExamFileIDs[gradeIndex][subjectIndex].length
                              : isothers == true
                                  ? othersFileIDs[gradeIndex][subjectIndex]
                                      .length
                                  : 0,
                  itemBuilder: (context, index) {
                    String fileName = "";
                    String uploadDate = "";
                    int index = 0;
                    String fileID = isSchoolExams == true
                        ? schoolExamFileIDs[gradeIndex][subjectIndex][index]
                        : isClassNotes == true
                            ? classNotesFileIDs[gradeIndex][subjectIndex][index]
                            : isCompExams == true
                                ? compExamFileIDs[gradeIndex][subjectIndex]
                                    [index]
                                : isothers == true
                                    ? othersFileIDs[gradeIndex][subjectIndex]
                                        [index]
                                    : "";
                    for (int g = 0; g < allUploads.docs.length; g++) {
                      if (fileID == allUploads.docs[g].id) {
                        fileName = allUploads.docs[g].get("description");
                        uploadDate = allUploads.docs[g].get("createdate");
                      }
                    }
                    return InkWell(
                      onTap: () {
                        for (int i = 0; i < allUploads.docs.length; i++) {
                          if (fileID == allUploads.docs[i].id) {
                            setState(() {
                              index = i;
                            });
                          }
                        }
                        showBarModalBottomSheet(
                            context: context,
                            builder: (context) => _fileDetails(context, index));
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$fileName $index",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  uploadDate,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 2,
                                color: Colors.grey[200]),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
          ],
        ),
      );
    } else
      return _loading();
  }

  _fileDetails(BuildContext context, int fileIndex) {
    String userName = "";
    for (int i = 0; i < allUserData.docs.length; i++) {
      if (allUploads.docs[fileIndex].get("userid") ==
          allUserData.docs[i].get("userid")) {
        userName = allUserData.docs[i].get("firstname") +
            " " +
            allUserData.docs[i].get("lastname");
      }
    }
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Container(
            height: MediaQuery.of(context).size.height - 100,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: allUploads.docs[fileIndex].get("uploadtype") ==
                        "School Exams"
                    ? _schoolExams(fileIndex)
                    : allUploads.docs[fileIndex].get("uploadtype") ==
                            "Class Notes"
                        ? _classNotes(fileIndex)
                        : allUploads.docs[fileIndex].get("uploadtype") ==
                                "Competitive Exams"
                            ? _compExams(fileIndex)
                            : allUploads.docs[fileIndex].get("uploadtype") ==
                                    "Others"
                                ? _others(fileIndex)
                                : SizedBox())));
  }

  _schoolExams(int fileIndex) {
    String userName = "";
    for (int i = 0; i < allUserData.docs.length; i++) {
      if (allUploads.docs[fileIndex].get("userid") ==
          allUserData.docs[i].get("userid")) {
        userName = allUserData.docs[i].get("firstname") +
            " " +
            allUserData.docs[i].get("lastname");
      }
    }
    return Column(
      children: [
        Text("File Details",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Text(allUploads.docs[fileIndex].get("createdate"),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("File Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Category: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("uploadtype"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Uploaded by: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(userName,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Description: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("School Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("schoolname"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Grade: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("class"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Subject: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("subject"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        allUploads.docs[fileIndex].get("examname") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Exam Name: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("examname"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("examname") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("term") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Term: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("term"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("term") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("year") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Exam year: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("year"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("year") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("tags") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Tags: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("tags"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: 60,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                _launchInWebViewOrVC(allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(88, 165, 196, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  )),
                ),
              ),
            ),
            SizedBox(
              width: 60,
            ),
            InkWell(
              onTap: () async {
                // PdftronFlutter.openDocument(
                //     allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(88, 165, 196, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'View File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  _classNotes(int fileIndex) {
    String userName = "";
    for (int i = 0; i < allUserData.docs.length; i++) {
      if (allUploads.docs[fileIndex].get("userid") ==
          allUserData.docs[i].get("userid")) {
        userName = allUserData.docs[i].get("firstname") +
            " " +
            allUserData.docs[i].get("lastname");
      }
    }
    return Column(
      children: [
        Text("File Details",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Text(allUploads.docs[fileIndex].get("createdate"),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("File Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Category: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("uploadtype"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Uploaded by: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(userName,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Description: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("School Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("schoolname"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Grade: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("class"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Subject: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("subject"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        allUploads.docs[fileIndex].get("chapter") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Chapter: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("chapter"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("chapter") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("topic") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Topic: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("topic"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("topic") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("year") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Year: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("year"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("year") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("tags") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Tags: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("tags"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: 60,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                _launchInWebViewOrVC(allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(88, 165, 196, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  )),
                ),
              ),
            ),
            SizedBox(
              width: 60,
            ),
            InkWell(
              onTap: () async {
                // PdftronFlutter.openDocument(
                //     allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(88, 165, 196, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'View File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  _compExams(int fileIndex) {
    String userName = "";
    for (int i = 0; i < allUserData.docs.length; i++) {
      if (allUploads.docs[fileIndex].get("userid") ==
          allUserData.docs[i].get("userid")) {
        userName = allUserData.docs[i].get("firstname") +
            " " +
            allUserData.docs[i].get("lastname");
      }
    }
    return Column(
      children: [
        Text("File Details",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Text(allUploads.docs[fileIndex].get("createdate"),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("File Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Category: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("uploadtype"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Uploaded by: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(userName,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Description: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        allUploads.docs[fileIndex].get("exam") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Exam name: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("exam"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("exam") != "" ? 20 : 0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Grade: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("class"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Subject: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("subject"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        allUploads.docs[fileIndex].get("topic") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Topic: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("topic"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("topic") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("year") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Year: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("year"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: allUploads.docs[fileIndex].get("year") != "" ? 20 : 0,
        ),
        allUploads.docs[fileIndex].get("tags") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Tags: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("tags"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: 60,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                _launchInWebViewOrVC(allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(88, 165, 196, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  )),
                ),
              ),
            ),
            SizedBox(
              width: 60,
            ),
            InkWell(
              onTap: () async {
                // PdftronFlutter.openDocument(
                //     allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(88, 165, 196, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'View File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  _others(int fileIndex) {
    String userName = "";
    for (int i = 0; i < allUserData.docs.length; i++) {
      if (allUploads.docs[fileIndex].get("userid") ==
          allUserData.docs[i].get("userid")) {
        userName = allUserData.docs[i].get("firstname") +
            " " +
            allUserData.docs[i].get("lastname");
      }
    }
    return Column(
      children: [
        Text("File Details",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Text(allUploads.docs[fileIndex].get("createdate"),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("File Name: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Category: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("uploadtype"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Uploaded by: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(userName,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Description: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("description"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Grade: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("class"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 90,
              child: Text("Subject: ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(allUploads.docs[fileIndex].get("subject"),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        allUploads.docs[fileIndex].get("topic") != ""
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    child: Text("Topic: ",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(allUploads.docs[fileIndex].get("topic"),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: 60,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                _launchInWebViewOrVC(allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(88, 165, 196, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  )),
                ),
              ),
            ),
            SizedBox(
              width: 60,
            ),
            InkWell(
              onTap: () async {
                // PdftronFlutter.openDocument(
                //     allUploads.docs[fileIndex].get("file"));
              },
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(88, 165, 196, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    'View File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url,
          enableJavaScript: true, forceSafariVC: true, forceWebView: false);
    } else {
      throw 'could not launch $url';
    }
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(88, 165, 196, 1)),
          ))),
    );
  }
}
