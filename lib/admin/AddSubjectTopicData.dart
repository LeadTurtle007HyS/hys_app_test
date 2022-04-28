// import 'dart:io';
// import 'dart:async';
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:hys/database/questionSection/crud.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// //this file is used to stored the data from excel to firebase firestore
// //It is used to stored the grade wise subject and there topics for each board

// class AddSubjectTopicData extends StatefulWidget {
//   @override
//   _AddSubjectTopicDataState createState() => _AddSubjectTopicDataState();
// }

// class Item {
//   const Item(this.name);
//   final String name;
// }

// class _AddSubjectTopicDataState extends State<AddSubjectTopicData> {
//   QuerySnapshot service;
//   CrudMethods crudobj = CrudMethods();
//   Item selectedUser;
//   File _excel;
//   File _image;
//   final picker = ImagePicker();
//   List<String> attachments = [];
//   List<Item> users = <Item>[];
//   List<int> maxrows = [];
//   bool upload = false;
//   bool sheetDropdown = false;
//   bool fileupload = false;
//   bool imageupload = false;
//   int row = 1;

//   int dataRows = 0;

//   //used to get excel file
//   Future getEXCEL() async {
//     var file = await FilePicker.platform
//         .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

//     setState(() {
//       _excel = file as File;
//       attachments.add(_excel.path);
//       print(_excel.path);
//       fileupload = true;
//       _readEXCEL();
//     });
//   }

//   //used to read excel file
//   void _readEXCEL() {
//     var file = _excel.path;
//     var bytes = File(file).readAsBytesSync();
//     var excel = Excel.decodeBytes(bytes);
//     for (var table in excel.tables.keys) {
//       users.add(Item(table));
//       maxrows.add(excel.tables[table].maxRows);
//     }
//     setState(() {
//       sheetDropdown = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _body(),
//     );
//   }

//   _body() {
//     return ListView(
//       physics: BouncingScrollPhysics(),
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.width / 21.83,
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 13.0),
//                 child: Material(
//                   elevation: 6.0,
//                   shape: CircleBorder(),
//                   clipBehavior: Clip.antiAlias,
//                   shadowColor: Color(0xFF083663),
//                   child: CircleAvatar(
//                     radius: MediaQuery.of(context).size.width / 21.83,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.arrow_back, color: Color(0xFF083663)),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               width: 40,
//             ),
//             Text(
//               'FILL GRADEWISE SUBJECT TOPICS',
//               style: TextStyle(
//                   color: Color(0xFF083663),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'Montserrat'),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 30,
//         ),
//         Container(
//           height: 90,
//           margin: EdgeInsets.only(
//               left: MediaQuery.of(context).size.width / 3.93,
//               right: MediaQuery.of(context).size.width / 3.93),
//           child: Column(
//             children: [
//               RaisedButton(
//                   padding: EdgeInsets.fromLTRB(12, 18, 12, 18),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(7.0)),
//                   elevation: 7.0,
//                   color: Colors.white,
//                   child: Center(
//                     child: Text(
//                       'UPLOAD FILE',
//                       style: TextStyle(
//                           color: Color(0xFF083663),
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Montserrat'),
//                     ),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       getEXCEL();
//                     });
//                   }),
//               SizedBox(
//                 height: 3,
//               ),
//               Text(
//                 fileupload == true ? 'File uploaded successfully' : "",
//                 style: TextStyle(color: Colors.green),
//               ),
//             ],
//           ),
//         ),
//         dropdown(),
//         SizedBox(
//           height: 30,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 12.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'Total Rows: ' + dataRows.toString(),
//                 style: TextStyle(
//                     color: Colors.redAccent, fontWeight: FontWeight.w800),
//               )
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         Divider(
//             height: 5.0, thickness: 0.5, color: Colors.black.withOpacity(0.1)),
//         SizedBox(
//           height: 20,
//         ),
//         selectedUser != null
//             ? Container(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Container(
//                       height: 40,
//                       width: 40,
//                       child: Center(
//                         child: RaisedButton(
//                             padding: EdgeInsets.all(5),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(7.0)),
//                             elevation: 7.0,
//                             color: Colors.white,
//                             child: Center(
//                               child: Icon(
//                                 Icons.keyboard_arrow_left,
//                                 color: Color(0xFF083663),
//                               ),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 if (row > 1) {
//                                   row--;
//                                 }
//                               });
//                             }),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 15,
//                     ),
//                     Container(
//                       child: Text(
//                         row.toString(),
//                         style: TextStyle(
//                             color: Colors.redAccent,
//                             fontWeight: FontWeight.w800),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 15,
//                     ),
//                     Container(
//                       height: 40,
//                       width: 40,
//                       child: RaisedButton(
//                           padding: EdgeInsets.all(5),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(7.0)),
//                           elevation: 7.0,
//                           color: Colors.white,
//                           child: Center(
//                             child: Icon(
//                               Icons.keyboard_arrow_right,
//                               color: Color(0xFF083663),
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               if (dataRows > row) {
//                                 row++;
//                               }
//                             });
//                           }),
//                     ),
//                     SizedBox(
//                       width: 25,
//                     ),
//                   ],
//                 ),
//               )
//             : Container(),
//         SizedBox(
//           height: 30,
//         ),
//         selectedUser != null ? _data(row) : Container(),
//         SizedBox(
//           height: 50,
//         ),
//         selectedUser != null
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   RaisedButton(
//                       padding: EdgeInsets.fromLTRB(12, 18, 12, 18),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(7.0)),
//                       elevation: 7.0,
//                       color: Colors.red,
//                       child: Center(
//                         child: upload == false
//                             ? Text(
//                                 'SAVE',
//                                 style: TextStyle(
//                                   fontFamily: 'ProductSans',
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white70,
//                                 ),
//                               )
//                             : Container(
//                                 height: 12,
//                                 width: 12,
//                                 child: CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               ),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           var file = _excel.path;
//                           print(file);
//                           var bytes = File(file).readAsBytesSync();
//                           var excel = Excel.decodeBytes(bytes);
//                           print(excel);
//                           print(selectedUser.name);
//                           dataRows = excel.tables[selectedUser.name].maxRows;
//                           print(dataRows);
//                           if (upload == false) {
//                             setState(() {
//                               upload = true;
//                               for (int i = 1; i < dataRows; i++) {
//                                 var rowId =
//                                     excel.tables[selectedUser.name].rows;
//                                 print(rowId);
//                                 //crudobj.addGradeSubjectData(
//                                 //    rowId[i][1].toString(),
//                                 //    rowId[i][2].toString(),
//                                 //    rowId[i][3].toString());

//                                 crudobj.addSubjectTopicData(
//                                     rowId[i][0].toString(),
//                                     rowId[i][1].toString(),
//                                     rowId[i][2].toString(),
//                                     rowId[i][3].toString(),
//                                     rowId[i][4].toString(),
//                                     rowId[i][5].toString());
//                               }
//                             });
//                           }
//                         });
//                       }),
//                 ],
//               )
//             : Container(),
//         SizedBox(
//           height: 50,
//         ),
//       ],
//     );
//   }

//   Widget dropdown() {
//     return Container(
//       margin: EdgeInsets.only(
//           left: MediaQuery.of(context).size.width / 3.93,
//           right: MediaQuery.of(context).size.width / 3.93),
//       child: Card(
//         elevation: 7.0,
//         child: Container(
//           decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(
//                 color: Colors.white,
//               ),
//               borderRadius: BorderRadius.circular(7.0)),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
//             child: DropdownButton<Item>(
//               elevation: 6,
//               underline: Container(
//                 color: Colors.transparent,
//               ),
//               icon: Icon(
//                 Icons.arrow_drop_down_circle,
//                 color: Color(0xFF083663),
//               ),
//               isExpanded: true,
//               hint: Text(
//                 "Choose Sheet",
//                 style: TextStyle(
//                     color: Color(0xFF083663),
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Montserrat'),
//               ),
//               value: selectedUser,
//               onChanged: (Item value) {
//                 setState(() {
//                   if (sheetDropdown == true) {
//                     selectedUser = value;
//                     var file = _excel.path;
//                     print(file);
//                     var bytes = File(file).readAsBytesSync();
//                     var excel = Excel.decodeBytes(bytes);
//                     print(excel);
//                     print(selectedUser.name);
//                     dataRows = excel.tables[selectedUser.name].maxRows - 1;
//                   } else {
//                     _showAlertDialog();
//                   }
//                   //Navigator.push(
//                   //    context,
//                   //    MaterialPageRoute(
//                   //        builder: (context) => AuditReportIDS(selectedUser.name)));
//                 });
//               },
//               items: users.map((Item user_) {
//                 return DropdownMenuItem<Item>(
//                     value: user_,
//                     onTap: () {
//                       setState(() {
//                         //  tapcolor = true;
//                       });
//                     },
//                     child: Container(
//                       margin: EdgeInsets.only(left: 4, right: 4),
//                       child: Text(
//                         user_.name,
//                         style: TextStyle(
//                             color: Color(0xFF083663),
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Montserrat'),
//                       ),
//                     ));
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAlertDialog() {
//     AlertDialog alertDialog1 = AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       content: Container(
//         height: 100,
//         child: Column(
//           children: <Widget>[
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               'Please upload Excel file first.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Montserrat'),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Container(
//               margin: EdgeInsets.only(left: 30, right: 30),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Container(
//                     height: 40,
//                     child: RaisedButton(
//                         padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(7.0)),
//                         elevation: 7.0,
//                         color: Colors.white,
//                         child: Center(
//                           child: Text(
//                             'OK',
//                             style: TextStyle(
//                                 color: Color(0xFF083663),
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Montserrat'),
//                           ),
//                         ),
//                         onPressed: () {
//                           setState(() {});
//                         }),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//     showDialog(context: context, builder: (_) => alertDialog1);
//   }

//   String grade = '';
//   String board = "";
//   String subject = '';
//   String topic = '';

//   _data(int i) {
//     var file = _excel.path;
//     print(file);
//     var bytes = File(file).readAsBytesSync();
//     var excel = Excel.decodeBytes(bytes);
//     print(excel);
//     print(selectedUser.name);
//     dataRows = excel.tables[selectedUser.name].maxRows - 1;
//     while (i <= dataRows) {
//       var rowId = excel.tables[selectedUser.name].rows;

//       var _grade = TextEditingController(
//         text: rowId[i][1].toString(),
//       );
//       var _subject = TextEditingController(
//         text: rowId[i][2].toString(),
//       );
//       //    var _topic = TextEditingController(
//       //     text: rowId[i][3].toString(),
//       //   );
//       //   var _board = TextEditingController(
//       //     text: rowId[i][3].toString(),
//       //   );
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Container(
//               child: Row(
//                 children: [
//                   Container(
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(right: 5),
//                           width: 160,
//                           child: Text(
//                             'Board:    ',
//                             style: TextStyle(
//                               fontSize:
//                                   MediaQuery.of(context).size.width / 24.5625,
//                               fontWeight: FontWeight.w400,
//                               color: Color(0xFF083663),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.only(right: 5),
//                     width: 160,
//                     child: Text(
//                       'Grade:    ',
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width / 24.5625,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xFF083663),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       margin: EdgeInsets.only(right: 5),
//                       width: 50,
//                       child: TextField(
//                         controller: _grade,
//                         onChanged: (val) {
//                           setState(() => grade = val);
//                         },
//                         decoration: InputDecoration(
//                             labelStyle: TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey),
//                             focusedBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xFF083663)))),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               child: Row(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.only(right: 5),
//                     width: 160,
//                     child: Text(
//                       'Subject:    ',
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width / 24.5625,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xFF083663),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       margin: EdgeInsets.only(right: 5),
//                       width: 50,
//                       child: TextField(
//                         controller: _subject,
//                         onChanged: (val) {
//                           setState(() => subject = val);
//                         },
//                         decoration: InputDecoration(
//                             labelStyle: TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey),
//                             focusedBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xFF083663)))),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               child: Row(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.only(right: 5),
//                     width: 160,
//                     child: Text(
//                       'Topic:    ',
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width / 24.5625,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xFF083663),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       margin: EdgeInsets.only(right: 5),
//                       width: 50,
//                       child: TextField(
//                         //  controller: _topic,
//                         onChanged: (val) {
//                           setState(() => topic = val);
//                         },
//                         decoration: InputDecoration(
//                             labelStyle: TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey),
//                             focusedBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xFF083663)))),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
