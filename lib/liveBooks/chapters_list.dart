import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hys/models/book_model.dart';
import 'package:hys/models/chapter_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../database/crud.dart';
import '../models/enum/epub_scroll_direction.dart';
import '../models/epub_locator.dart';
import '../models/publication_model.dart';
import '../utils/util.dart';

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({Key key, this.title, this.publicationDetails})
      : super(key: key);

  final String title;
  final PublicationModel publicationDetails;

  @override
  State<ChapterListPage> createState() =>
      _ChapterListPageState(title, publicationDetails);
}

class _ChapterListPageState extends State<ChapterListPage> {
  final String title;
  final PublicationModel publicationDetails;

  ScrollController scrollController;
  bool loading = false;
  Dio dio = new Dio();
  CrudMethods crudobj = CrudMethods();

  Box<dynamic> userDataDB;

  List lessons = [];

  String _currentUserId = FirebaseAuth.instance.currentUser.uid;

  static const MethodChannel _channel = MethodChannel('epub_viewer');
  static const EventChannel _pageChannel = EventChannel('page');

  _ChapterListPageState(this.title, this.publicationDetails);

  @override
  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    lessons = getAllBook();
    super.initState();
    scrollController = new ScrollController();
    // scrollController.addListener(() => setState(() {}));
  }

  static void setConfig(
      {Color themeColor = Colors.blue,
      String identifier = 'book',
      bool nightMode = false,
      EpubScrollDirection scrollDirection = EpubScrollDirection.ALLDIRECTIONS,
      bool allowSharing = false,
      bool enableTts = false}) async {
    Map<String, dynamic> agrs = {
      "identifier": identifier,
      "themeColor": Util.getHexFromColor(themeColor),
      "scrollDirection": Util.getDirection(scrollDirection),
      "allowSharing": allowSharing,
      'enableTts': enableTts,
      'nightMode': nightMode
    };
    await _channel.invokeMethod('setConfig', agrs);
  }

  /// bookPath should be a local file.
  /// Last location is only available for android.
  static void open(
      String bookPath,
      String dictionaryId,
      String grade,
      String subject,
      String publication,
      String publicationEdition,
      String chapter,
      String part,
      String userID,
      String firstname,
      String lastName,
      String profileURL,
      {EpubLocator lastLocation}) async {
    Map<String, dynamic> agrs = {
      "bookPath": bookPath,
      "dictionary_id": dictionaryId,
      "grade": grade,
      "subject": subject,
      "publication": publication,
      "publication_edition": publicationEdition,
      "open_book_type": "1",
      "chapter": chapter,
      "part": part,
      "LOGGED_IN_userName": firstname,
      "LOGGED_IN_profilePic": profileURL,
      "LOGGED_IN_USER_ID": userID,
      "LOGGED_IN_USER_lNAME": lastName,
      'lastLocation':
          lastLocation == null ? '' : jsonEncode(lastLocation.toJson()),
    };
    await _channel.invokeMethod('open', agrs);
  }

  /// bookPath should be an asset file path.
  /// Last location is only available for android.
  static Future openAsset(String bookPath, {EpubLocator lastLocation}) async {
    if (extension(bookPath) == '.epub') {
      Map<String, dynamic> agrs = {
        "bookPath": (await Util.getFileFromAsset(bookPath)).path,
        'lastLocation':
            lastLocation == null ? '' : jsonEncode(lastLocation.toJson()),
      };
      await _channel.invokeMethod('open', agrs);
    } else {
      throw ('${extension(bookPath)} cannot be opened, use an EPUB File');
    }
  }

  /// Stream to get EpubLocator for android and pageNumber for iOS
  static Stream get locatorStream {
    Stream pageStream = _pageChannel
        .receiveBroadcastStream()
        .map((value) => Platform.isAndroid ? value : '{}');

    return pageStream;
  }

  // download(String url) async {
  //   if (Platform.isIOS) {
  //     await downloadFile(url);
  //   } else {
  //     loading = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(
            final MapEntry<String, dynamic> lesson, ChapterModel data) =>
        ListTile(
          leading: CachedNetworkImage(
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            imageUrl: lesson.value['chapterImageURL'],
          ),
          title: Text(
            lesson.key.toString(),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right,
              color: Colors.black, size: 30.0),
          onTap: () {
            setConfig(
                themeColor: Theme.of(context).primaryColor,
                identifier: "iosBook",
                scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                allowSharing: true,
                enableTts: true,
                nightMode: true);

            //    downloadFile(lesson.value['EPUB_link'].toString(),data,lesson.key.toString());
          },
        );
    Card makeCard(MapEntry<String, dynamic> lesson, ChapterModel data) => Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(199, 234, 246, 1)),
            child: makeListTile(lesson, data),
          ),
        );

    return Scaffold(
        body: NestedScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      body: FutureBuilder<ChapterModel>(
        future: crudobj.fetchchapterList(publicationDetails.dictionary_id),
        builder: (
          BuildContext context,
          AsyncSnapshot<ChapterModel> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: List<int>.generate(
                          snapshot.data.dictionary_list.length,
                          (index) => index)
                      .map((index) => makeCard(
                          snapshot.data.dictionary_list.entries
                              .elementAt(index),
                          snapshot.data))
                      .toList(),
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
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          new SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Color.fromRGBO(88, 165, 196, 1),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              background: Container(
                color: Colors.black,
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                  imageUrl: publicationDetails.publicationImageURL,
                ),
              ),
            ),
          )
        ];
      },
    ));
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            headers: {HttpHeaders.acceptEncodingHeader: "*"},
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  openEbookFromAssets() {
    openAsset(
      'assets/Halliday_Resnick_Walker.epub',
      lastLocation: EpubLocator.fromJson({
        "bookId": "2239",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
      }),
    );
  }

  openEbookFile(ChapterModel data, String chapterName) async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir.path + '/sway.epub';
    open(
      path,
      publicationDetails.dictionary_id,
      data.grade,
      data.subject_,
      data.publication,
      data.pub_edition,
      chapterName,
      "1",
      _currentUserId,
      userDataDB.get("first_name"),
      userDataDB.get("last_name"),
      userDataDB.get("profilepic"),
      lastLocation: EpubLocator.fromJson({
        "bookId": "2239",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
      }),
    );
    // get current locator
    locatorStream.listen((locator) {
      print('LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
    });
  }
}

List getAllBook() {
  return [
    BookModel(
        bookId: null,
        href:
            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/all%20grade%20subjects%20pickles%2Fclass%2010th%2Feconomics%2Fchapter%201%2Fclass%2010%20economics%20chapter%201.epub?alt=media&token=8394a6e8-8060-47d0-bfb9-ed1354693563",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/all%20grade%20subjects%20pickles%2Fclass%2010th%2Feconomics%2Fchapter%202%2Fclass%2010%20economics%20chapter%202.epub?alt=media&token=9d5f2de2-f765-4c4c-b785-b10accd461a1",
        bookName: "Chapter 2 "),
    BookModel(
        bookId: null,
        href:
            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/all%20grade%20subjects%20pickles%2Fclass%2010th%2Feconomics%2Fchapter%203%2Fclass%2010%20economics%20chapter%203.epub?alt=media&token=cf502005-51b6-4b22-bf12-199b9561eabf",
        bookName: "Chapter 3 "),
    BookModel(
        bookId: null,
        href:
            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/all%20grade%20subjects%20pickles%2Fclass%2010th%2Feconomics%2Fchapter%204%2Fclass%2010%20economics%20chapter%204.epub?alt=media&token=5659e8f6-87c1-4511-86f8-5feb7ee7807e",
        bookName: "Chapter 4 "),
    BookModel(
        bookId: null,
        href:
            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/all%20grade%20subjects%20pickles%2Fclass%2010th%2Feconomics%2Fchapter%205%2Fclass%2010%20economics%20chapter%205.epub?alt=media&token=696b9cb6-8eff-4642-bb00-15ec661418fd",
        bookName: "Chapter 5 "),
  ];
}
