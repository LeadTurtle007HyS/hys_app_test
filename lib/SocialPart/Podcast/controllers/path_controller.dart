import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hys/SocialPart/Podcast/services/logger_service.dart';
import 'package:hys/SocialPart/Podcast/services/path_service.dart';
import 'package:rxdart/src/streams/value_stream.dart';


class PathController with ChangeNotifier {
  final PathService _pathService = PathService();
  Directory directory;

  PathController() {
    _pathService.docStateStream.listen((event) {
      logger.d('doc state changed: $event');
      notifyListeners();
    });
  }
  set docState(DocState value) {
    _pathService.docState = value ?? DocState.ready;
    notifyListeners();
  }

  Stream<DocState> get docStateStream => _pathService.docStateStream;
  DocState get docState => _pathService.docStateStream.value;
  // Get temp directory path
  Future<String> getTempPath() async {
    return _pathService.getTempPath();
  }

  // Get application documents directory path
  Future<String> getDocPath() async {
    return _pathService.getDocPath();
  }

  // Get application documents directory
  Future<Directory> getDocs() async {
    directory = await _pathService.getDocs();
    if (directory?.listSync().isEmpty == true) directory = null;
    notifyListeners();
    return directory;
  }
}
