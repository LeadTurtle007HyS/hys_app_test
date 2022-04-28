import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:hys/SocialPart/Podcast/backgorund_music_list.dart';
import 'package:hys/SocialPart/Podcast/services/locator_service.dart';
import 'package:hys/SocialPart/Podcast/services/path_service.dart';
import 'package:hys/SocialPart/Podcast/utils/jumping_dots.dart';
import 'package:hys/SocialPart/Podcast/widgets/amplitude_widget.dart';
import 'package:hys/SocialPart/Podcast/widgets/directory_button.dart';
import 'package:hys/SocialPart/Podcast/widgets/format_settings.dart';
import 'package:hys/SocialPart/Podcast/widgets/last_recording_bubble.dart';
import 'package:hys/SocialPart/Podcast/widgets/pause_button.dart';
import 'package:hys/SocialPart/Podcast/widgets/record_button.dart';
import 'package:hys/SocialPart/Podcast/widgets/record_duration.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:hys/database/crud.dart';
import 'package:hys/models/podcast_album_model.dart';
import 'package:hys/models/podcast_bg_file_model.dart';

class RecordPage extends StatefulWidget {
  final PodcastAlbumModel podcastAlbumModel;
  const RecordPage({Key key, this.podcastAlbumModel}) : super(key: key);
  @override
  State<RecordPage> createState() => _RecordPageState(podcastAlbumModel);
}

class _RecordPageState extends State<RecordPage> {
  final PodcastAlbumModel podcastAlbumModel;

  _RecordPageState(this.podcastAlbumModel);
  SocialFeedPost socialFeedDB = SocialFeedPost();
  CrudMethods crudObj = CrudMethods();
  bool lastRecording = false;
  bool isBackgroundMusicAdding = false;
  bool isBackgroundMusicAdded = false;
  bool isLoading = false;
  String backgroundMusicPath = "";
  int time = 0;
  String recordedPath = "";
  String fileFormat = "wav";
  PodcastBgFile podcastBgFile;
  double mediaVolume = 0.9;
  double backgroundMediaVol = 0.6;

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final PathService _pathService = locator<PathService>();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    String valueText;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Episode'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter episode name"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    valueText = "";
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  if (isBackgroundMusicAdded) {
                    _playMashup(backgroundMusicPath, valueText);
                  } else {
                    createEpisode(valueText, recordedPath);
                  }

                  valueText = "";
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  createEpisode(String episodeName, String outPutPath) async {
    setState(() {
      isLoading = true;
    });
    var value = await socialFeedDB.uploadPodcastAudioFile(outPutPath);
    // if (value[0]) {
    //   String episodeID = podcastAlbumModel.albumID + episodeName;
    //   crudObj
    //       .addAlbumEpisode(episodeName, podcastAlbumModel.albumID, episodeID,
    //           value[1], fileFormat)
    //       .then((value) {
    //     Navigator.of(context).pop();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 50,
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.save,
                    color: lastRecording && recordedPath != ""
                        ? Colors.white
                        : Colors.white24,
                  ),
                  onPressed: () {
                    if (lastRecording && recordedPath != "" && !isLoading) {
                      _displayTextInputDialog(context);
                    }
                  })
            ],
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
            title: Text(
              lastRecording && recordedPath != ""
                  ? "Preview your Audio"
                  : "Record",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : AmplitudeWidget(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const RecordDuration(),
                      const FormatSettings(),
                      lastRecording &&
                              recordedPath != "" &&
                              !isBackgroundMusicAdding
                          ? LastRecordingBubble(
                              time: time,
                              path: recordedPath,
                              backgroundMusicPath: backgroundMusicPath,
                              updateMediaVolume: (volume) {
                                mediaVolume = volume;
                              },
                              updateBackgroundMediaVol: (backgroundVol) {
                                backgroundMediaVol = backgroundVol;
                              },
                            )
                          : lastRecording &&
                                  recordedPath != "" &&
                                  isBackgroundMusicAdding
                              ? Container(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        JumpingDotsProgressIndicator(
                                            fontSize: 40.0),
                                        Text(
                                          "Adding background music",
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 60),
                      lastRecording &&
                              recordedPath != "" &&
                              !isBackgroundMusicAdded
                          ? Container(
                              height: 60,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                      color: Color.fromRGBO(88, 165, 196, 1)),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                onPressed: () => {backgroundMusicListPage()},
                                icon: Icon(Icons.library_music,
                                    color: Color.fromRGBO(88, 165, 196, 1)),
                                label: Text('Add Background Music',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            )
                          : lastRecording &&
                                  recordedPath != "" &&
                                  isBackgroundMusicAdded
                              ? Container(
                                  height: 60,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      textStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1)),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                    onPressed: () => {
                                      setState(() {
                                        isBackgroundMusicAdded = false;
                                        backgroundMusicPath = "";
                                      })
                                    },
                                    icon: Icon(Icons.close,
                                        color: Color.fromRGBO(88, 165, 196, 1)),
                                    label: Text(
                                        podcastBgFile != null
                                            ? podcastBgFile.fileName
                                            : " Change BG Music",
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                )
                              : SizedBox(height: 60),
                      const Spacer(
                        flex: 1,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PauseButton(),
                          RecordButton(
                            showLastRecording:
                                (bool newValue, String newPath, int newTime) {
                              setState(() {
                                recordedPath = newPath;
                                lastRecording = newValue;
                                time = newTime;
                              });
                            },
                          ),
                          DirectoryButton(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> backgroundMusicListPage() async {
    podcastBgFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BackgroundMusicList(),
        ));

    if (podcastBgFile != null && podcastBgFile.fileURL != null) {
      setState(() {
        isBackgroundMusicAdding = true;
      });
      var fetchedFile =
          await DefaultCacheManager().getSingleFile(podcastBgFile.fileURL);
      //  _playMashup(fetchedFile.path,"Episode");

      setState(() {
        backgroundMusicPath = fetchedFile.path;
        isBackgroundMusicAdding = false;
        isBackgroundMusicAdded = true;
      });
    }
  }

  void _playMashup(String backgroundMusicPath, String episodeName) async {
    var backgroundMusicFolder =
        await _pathService.createFolderInAppDocDir("BackgroundMusic");
    var outputPath = backgroundMusicFolder + "bgSound.wav";

    if (await File(outputPath).exists()) {
      await File(outputPath).delete();
    }

    // var command = [
    //   "-i",
    //   backgroundMusicPath,
    //   "-i",
    //   recordedPath,
    //   "-shortest",
    //   "-filter_complex",
    //   "[0:a]volume=0.4[a0];[1:a]volume=6.0[a1];[a0][a1]amix=inputs=2:duration=shortest",
    //   outputPath
    // ];

    var command = [
      "-i",
      backgroundMusicPath,
      "-i",
      recordedPath,
      "-filter_complex",
      "[0:a]volume=" +
          backgroundMediaVol.toString() +
          "[a0];[1:a]volume=" +
          mediaVolume.toString() +
          "[a1];[a0][a1]amix=inputs=2:duration=longest",
      outputPath
    ];
    await _flutterFFmpeg
        .executeWithArguments(command)
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    // setState(() {
    //   recordedPath = outputPath;
    //   backgroundMusicPath="";
    //   isBackgroundMusicAdding = false;
    //   isBackgroundMusicAdded=true;
    // });

    createEpisode(episodeName, outputPath);
  }
}
