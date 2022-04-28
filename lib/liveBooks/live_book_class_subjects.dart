import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hys/liveBooks/subject_publication_list.dart';
import 'package:hys/models/book_model.dart';

import '../database/crud.dart';
import '../models/grade_details_model.dart';

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  CrudMethods crudobj = CrudMethods();
  bool loading = false;
  Dio dio = new Dio();

  Box<dynamic> userDataDB;

  List lessons = [];

  List subjectsList = [
    'Mathematics',
    'Science',
    'Social Sciences',
    'Computer Science',
    'Economics',
    'Agricultural Science'
  ];

  @override
  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    lessons = getAllBook();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


  var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;


    ListTile makeListTile(final BookModel lesson) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            lesson.bookName.toString(),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right,
              color: Colors.black, size: 30.0),
          onTap: () {},
        );
    Card makeCard(BookModel lesson) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(199, 234, 246, 1)),
            child: makeListTile(lesson),
          ),
        );

    makeBody(bookList) => ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: bookList.length,
          itemBuilder: (BuildContext context, int index) {
            return makeCard(bookList[index]);
          },
        );

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(88, 165, 196, 1),
      centerTitle: true,
      title:  Text("Class  "+userDataDB.get('grade').toString()+"th",
          style: const TextStyle(
            fontFamily:'Nunito Sans' ,
            fontSize: 20.0,
              color: Colors.white, fontWeight: FontWeight.bold)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: topAppBar,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(8.0),
        child: FutureBuilder<GradeDetailsModel>(
          future: crudobj.fetchGradeDetails(userDataDB.get('grade').toString()),
          builder: (
            BuildContext context,
            AsyncSnapshot<GradeDetailsModel> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: (itemWidth / 200),
                  ),
                 
              controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.distinct_subjects.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                    elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) =>
                                SubjectPublicationListPage(subjectDetailsModel:snapshot.data.distinct_subjects[index])));
                      },
                      child: Stack(
                        children: <Widget>[
                        CachedNetworkImage(
                          width: itemWidth,
                          height: 200,
                          fit: BoxFit.cover,
                          imageUrl: snapshot
                              .data
                              .distinct_subjects[index]
                              .subjectImageURL,
                          progressIndicatorBuilder: (context, url,
                                  downloadProgress) =>
                              Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            size: 100,
                            color: Colors.red,
                          ),
                        ),
                        Center(
                          child: Text(
                              snapshot
                                  .data.distinct_subjects[index].subject_.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ),
                  ),
                );
              } else {
                return Center(child: const Text('Empty data'));
              }
            } else {
              return Center(child: Text('State: ${snapshot.connectionState}'));
            }
          },
        ),
      ),
    );
  }
}

List getAllBook() {
  return [
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 Electrostatics- NCERT")
  ];
}
