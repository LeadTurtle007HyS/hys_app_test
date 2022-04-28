import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hys/liveBooks/chapters_list.dart';
import 'package:hys/liveBooks/previous_year_questions_list.dart';
import 'package:hys/models/book_model.dart';
import 'package:hys/models/subject_details_model.dart';

class SubjectPublicationListPage extends StatefulWidget {
  const SubjectPublicationListPage(
      {Key key, this.title, this.subjectDetailsModel})
      : super(key: key);

  final String title;
  final SubjectDetailsModel subjectDetailsModel;


  @override
  State<SubjectPublicationListPage> createState() =>
      _SubjectPublicationListPageState(this.title, this.subjectDetailsModel);
}

class _SubjectPublicationListPageState
    extends State<SubjectPublicationListPage> {
  bool loading = false;
  Dio dio = new Dio();

  List lessons = [];

  final String title;
  final SubjectDetailsModel subjectDetailsModel;

  _SubjectPublicationListPageState(this.title, this.subjectDetailsModel);

  @override
  void initState() {
    lessons = getAllBook();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(88, 165, 196, 1),
      title: Text(subjectDetailsModel.subject_.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20.0)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: topAppBar,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                childAspectRatio: (itemWidth / 200),
              ),
              shrinkWrap: true,
              itemCount: subjectDetailsModel.distinct_publication.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => ChapterListPage(
                          title: subjectDetailsModel
                              .distinct_publication[index].publication,
                          publicationDetails: subjectDetailsModel
                              .distinct_publication[index])));
                },
                child: Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  child: Stack(children: <Widget>[
                    CachedNetworkImage(
                      width: itemWidth,
                      height: 200,
                      fit: BoxFit.cover,
                      imageUrl: subjectDetailsModel
                          .distinct_publication[index].publicationImageURL,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        size: 100,
                        color: Colors.red,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                          (subjectDetailsModel
                              .distinct_publication[index].publication+ " "+subjectDetailsModel.subject_+ subjectDetailsModel
                              .distinct_publication[index].part) .toUpperCase() ,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                        Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => PreviousYearQuestionPaperPage(
                          title: subjectDetailsModel.subject_,
                         subjectDetails : subjectDetailsModel)));
                    },
                    child: Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(199, 234, 246, 1)),
                        child: ListTile(
                          title: Text(
                            'Past year question paper',
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right,
                              color: Colors.black, size: 30.0),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(199, 234, 246, 1)),
                      child: ListTile(
                        title: Text(
                          "Books/Chapter referred by your friend's recently ",
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right,
                            color: Colors.black, size: 30.0),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(199, 234, 246, 1)),
                      child: ListTile(
                        title: Text(
                          'Most Referred book/chapter',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right,
                            color: Colors.black, size: 30.0),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(199, 234, 246, 1)),
                      child: ListTile(
                        title: Text(
                          'Most rated book',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right,
                            color: Colors.black, size: 30.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
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
