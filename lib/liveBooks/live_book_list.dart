import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hys/models/book_model.dart';
import 'package:hys/utils/jumping_dots.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/enum/epub_scroll_direction.dart';
import '../models/epub_locator.dart';
import '../utils/util.dart';

class LiveBookPage extends StatefulWidget {
  const LiveBookPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<LiveBookPage> createState() => _LiveBookPageState();
}

class _LiveBookPageState extends State<LiveBookPage> {
  bool loading = false;
  Dio dio = new Dio();

  List lessons = [];

  static const MethodChannel _channel = MethodChannel('epub_viewer');
  static const EventChannel _pageChannel = EventChannel('page');

  @override
  void initState() {
    lessons = getAllBook();
    super.initState();
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
  static void open(String bookPath, {EpubLocator lastLocation}) async {
    Map<String, dynamic> agrs = {
      "bookPath": bookPath,
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

  download(String url) async {
    if (Platform.isIOS) {
      await downloadFile(url);
    } else {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () {
            setConfig(
                themeColor: Theme.of(context).primaryColor,
                identifier: "iosBook",
                scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                allowSharing: true,
                enableTts: true,
                nightMode: true);

            downloadFile(lesson.href.toString());
          },
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
      title: const Text("Live Books"),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: Stack(children: <Widget>[
          makeBody(lessons),
          if (loading)
            Center(child: JumpingDotsProgressIndicator(fontSize: 40.0))
        ]));
  }

  Future downloadFile(String url) async {
    openEbookFromAssets();

    // if (await Permission.storage.isGranted) {
    //   await Permission.storage.request();
    //   await startDownload(url);
    // } else {
    //   await startDownload(url);
    // }
  }

  startDownload(String url) async {
    setState(() {
      loading = true;
    });
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
          openEbookFile();
          loading = false;
          setState(() {});
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

  openEbookFile() async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir.path + '/sway.epub';
    open(
      path,
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
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 "),
    BookModel(
        bookId: null,
        href:
            "https://contentserver.adobe.com/store/books/GeographyofBliss_oneChapter.epub",
        bookName: "Chapter 1 ")
  ];
}
