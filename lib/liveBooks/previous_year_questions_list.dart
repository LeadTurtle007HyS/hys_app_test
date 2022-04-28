import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hys/models/subject_details_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../database/crud.dart';
import '../models/enum/epub_scroll_direction.dart';
import '../models/epub_locator.dart';
import '../models/previous_year_question_paper_model.dart';
import '../utils/util.dart';

class PreviousYearQuestionPaperPage extends StatefulWidget {
  const PreviousYearQuestionPaperPage(
      {Key key, this.title, this.subjectDetails})
      : super(key: key);

  final String title;
  final SubjectDetailsModel subjectDetails;

  @override
  State<PreviousYearQuestionPaperPage> createState() =>
      _PreviousYearQuestionPaperPageState(title, subjectDetails);
}

class _PreviousYearQuestionPaperPageState
    extends State<PreviousYearQuestionPaperPage> {
  final String title;
  final SubjectDetailsModel subjectDetails;

  ScrollController scrollController;

  Box<dynamic> userDataDB;

  bool loading = false;
  Dio dio = new Dio();
  CrudMethods crudobj = CrudMethods();

  static const MethodChannel _channel = MethodChannel('epub_viewer');
  static const EventChannel _pageChannel = EventChannel('page');

  _PreviousYearQuestionPaperPageState(this.title, this.subjectDetails);

  @override
  void initState() {
    super.initState();
    userDataDB = Hive.box<dynamic>('userdata');
    scrollController = new ScrollController();
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
  static void open(String bookPath, PreQuestionPaperModel paperModel,
      String userID, String firstname, String lastName, String profileURL,
      {EpubLocator lastLocation}) async {
    Map<String, dynamic> agrs = {
      "bookPath": bookPath,
      "dictionary_id": paperModel.dictionary_id,
      "grade": paperModel.grade,
      "subject": paperModel.subject_,
      "open_book_type": "2",
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
    ListTile makeListTile(final MapEntry<String, dynamic> lesson,
            PreQuestionPaperModel paperModel) =>
        ListTile(
          leading: CachedNetworkImage(
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/d9a2mq5-23ceded5-d2e1-48c5-8df5-37bea8337143.png?alt=media&token=b1d83bf7-18f4-4208-8272-b30cffde1bbb",
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

            downloadFile(lesson.value['epub'].toString(), paperModel);
          },
        );
    Card makeCard(MapEntry<String, dynamic> lesson,
            PreQuestionPaperModel paperModel) =>
        Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(199, 234, 246, 1)),
            child: makeListTile(lesson, paperModel),
          ),
        );

    return Scaffold(
        body: NestedScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      body: FutureBuilder<PreQuestionPaperModel>(
        future: crudobj.fetchPreviousYearQuestions(
            userDataDB.get('grade').toString(), subjectDetails.subject_),
        builder: (
          BuildContext context,
          AsyncSnapshot<PreQuestionPaperModel> snapshot,
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
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Color.fromRGBO(88, 165, 196, 1),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              background: Container(
                color: Colors.black,
                child: CachedNetworkImage(
                  width: 100,
                  height: 200,
                  fit: BoxFit.cover,
                  imageUrl: subjectDetails.subjectImageURL,
                ),
              ),
            ),
          )
        ];
      },
    ));
  }

  Future downloadFile(String url, PreQuestionPaperModel paperModel) async {
    // locator<NavigationService>().showProgressDialog();
    await startDownload(url, paperModel);
  }

  startDownload(String url, PreQuestionPaperModel paperModel) async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir.path + '/sway.epub';
    File file = File(path);
//    await file.delete();
    // if (!File(path).existsSync()) {
    await file.create();

    //  download2(dio,url,path);

    await dio.download(
      url,
      path,
      deleteOnError: true,
      onReceiveProgress: (receivedBytes, totalBytes) {
        print((receivedBytes / totalBytes * 100).toStringAsFixed(0));
        if (receivedBytes == totalBytes) {
          //  locator<NavigationService>().hideProgressDialog();
          openEbookFile(paperModel);
          loading = false;
        }
      },
    );
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
      'assets/With_Entities.epub',
      lastLocation: EpubLocator.fromJson({
        "bookId": "2239",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
      }),
    );
  }

  openEbookFile(PreQuestionPaperModel paperModel) async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir.path + '/sway.epub';
    open(
      path,
      paperModel,
      userDataDB.get("user_id"),
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
