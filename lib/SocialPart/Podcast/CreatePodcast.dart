import 'package:flutter/material.dart';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:hys/SocialPart/Podcast/PodcastList.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:audioplayers/audioplayers.dart';
import "package:hys/SocialPart/Podcast/PlayerPage.dart";
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io' as io;
import 'package:hys/database/crud.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:flutter/services.dart';
// import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

class RecorderExample extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  RecorderExample({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new RecorderExampleState();
}

SocialFeedPost socialobj = SocialFeedPost();
final _formKeyEpisode = GlobalKey<FormState>();
AudioPlayer audioPlayer = AudioPlayer();
AudioPlayer audioPlayerbackg = AudioPlayer();
AudioPlayer audioplayer1 = AudioPlayer();
CrudMethods crudobj = CrudMethods();

class RecorderExampleState extends State<RecorderExample> {
  // FlutterAudioRecorder _recorder;
  //
  // Recording _current;
  // RecordingStatus _currentStatus = RecordingStatus.Unset;
  Future<String> _localPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  String audioUrl;
  bool uploaded = false;

  Duration _song1Duration;
  Duration _outputPathDuration;
  /*Future getAudioURL(String name, String finalPath) async {
    setState(() {
      socialobj.uploadPodcastAudio(name, finalPath).then((value) {
        setState(() {
          print(value);
          if (value[0] == true) {
            audioUrl = value[1];
            uploaded = true;

            print(audioUrl);
          } else {
            setState(() {
              uploaded = false;
            });
            _showAlertDialog(value[1]);
          }
        });
      });}
   */
  String ifnoalbum = 'No Album ';
  String albumname = "";
  String episodename1 = "";
  bool episodeflag2 = false;
  String episodename2 = "";
  bool episodeflag1 = false;
  _showAlertDialog() async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height - 200,
            width: MediaQuery.of(context).size.width - 50,
            child: Form(
              key: _formKeyEpisode,
              child: StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  title: Text(
                    "Podcast",
                    style: TextStyle(
                        color: Color.fromRGBO(88, 165, 196, 1),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito Sans'),
                  ),
                  content: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width - 50,
                    child: ListView(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    episodeflag1 = true;
                                    episodeflag2 = false;
                                  });
                                },
                                child: Text(
                                  "Create an Album",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Nunito Sans'),
                                )),
                            (episodeflag1 == true)
                                ? Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          "Enter Name of Album",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Nunito Sans'),
                                        ),
                                        TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Album Name.';
                                            } else
                                              return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              albumname = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Nunito Sans'),
                                              hintText: 'eg. Success Stories'),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Enter Episode Name",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Nunito Sans'),
                                        ),
                                        TextFormField(
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please Enter Episode Name.';
                                              } else
                                                return null;
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                episodename1 = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Nunito Sans'),
                                                hintText: 'eg. Episode 1'))
                                      ]))
                                : SizedBox(),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                "OR",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito Sans'),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Add a Episode to Existing Album",
                              style: TextStyle(
                                  color: (albumflag == false)
                                      ? Colors.black38
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito Sans'),
                            ),
                            Container(
                                width: 200,
                                height: 50,
                                child: DropdownButton<String>(
                                  value: (albumflag == false)
                                      ? ifnoalbum.toString()
                                      : dropdownValue,
                                  icon: const Icon(Icons.expand_more),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 1,
                                    color: Colors.black38,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      dropdownValue = value;
                                      episodeflag2 = true;
                                      episodeflag1 = false;
                                    });
                                  },
                                  items: albumList
                                      .map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            (episodeflag2 == true)
                                ? TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please Enter Episode Name.';
                                      } else
                                        return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        episodename2 = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Nunito Sans'),
                                        hintText: 'eg. Episode 1'))
                                : SizedBox()
                          ]),
                    ]),
                  ),
                  actions: [
                    MaterialButton(
                        onPressed: () {
                          if (_formKeyEpisode.currentState.validate()) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Proceed",
                            style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontWeight: FontWeight.w500,
                                color: Colors.blue)))
                  ],
                );
              }),
            ),
          );
        });
  }

  var dbP;
  Future<String> _storagePath() async {
    final directory = await getExternalStorageDirectory();
    var dbPath1 = [directory.path, '/flutter_audio_recorder_', "backg2.wav"];
    dbP = dbPath1.join("");
    ByteData data = await rootBundle.load("assets/audios/backg1.wav");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await io.File(dbP).writeAsBytes(bytes);
  }

  var finalAudio;
  var _path;
  Future<File> _localFile() async {
    _path = await _localPath();
    finalAudio = io.File('$_path/flutter_audio_recorder_' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".mp3");
  }

  String dropdownValue;
  QuerySnapshot userdetails;
  QuerySnapshot albumdata;
  List albumList = [];
  bool albumflag = false;
  @override
  void initState() {
    _storagePath();

    //   _init();
    //  print(_current);
    //var arguments = ["-i" "concat:""file1.mp3""|""file2.mp3"|"file3.mp3" "-acodec" "copy" "output.mp3"];//["-i", "file1.mp4", "-c:v", "mpeg4", "file2.mp4"];
    print(dbP);
    crudobj.getUserData().then((value) {
      setState(() {
        userdetails = value;
      });
    });
    socialobj.getUserPodcastAudio().then((value) {
      albumdata = value;
      if (albumdata != null) {
        for (int i = 0; i < albumdata.docs.length; i++) {
          if (albumList.contains(albumdata.docs[i].get('albumname')) != true) {
            albumList.add(albumdata.docs[i].get('albumname'));
          }
        }
        print(albumList);
        if (albumList.length.toInt() > 0) {
          setState(() {
            albumflag = true;
            dropdownValue = albumList[0];
            print(dropdownValue);
          });
        }
      }
    });
    if (albumList != null) {
      _showAlertDialog();
    }
    //_flutterFFmpeg.execute()
    /*_flutterFFmpeg
        .execute("-i file1.mp4 -c:v mpeg4 file2.mp4")
        .then((rc) => print("FFmpeg process exited with rc $rc"));*/
    // TODO: implement initState
    super.initState();
  }

  String outputPath;
  bool floatflag = true;
  bool playflag = false;
  bool pauseflag = false;
  bool resumeflag = false;
  String dropdownvalue = 'None';
  AssetsAudioPlayer audioPlayer1 =
      AssetsAudioPlayer(); // this will create a instance object of a class
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool newflag = false;
  bool playflagMP = false;
  bool containerflag = false;
  final _formKey = GlobalKey<FormState>();

  _mediaPlayer() {
    return AnimatedContainer(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFe63946), Colors.black.withOpacity(0.6)],
                stops: [0.0, 0.4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                tileMode: TileMode.repeated)),
        duration: Duration(seconds: 1),
        child: SizedBox(
            height: (containerflag == true) ? 270 : 170,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                audioPlayer1.builderRealtimePlayingInfos(
                    builder: (context, infos) {
                  return Column(children: [
                    PositionSeekWidget(
                      currentPosition: (newflag == true)
                          ? infos.currentPosition
                          : Duration(minutes: 0, seconds: 0),
                      duration: (newflag == true)
                          ? infos.duration
                          : Duration(minutes: 0, seconds: 0),
                      seekTo: (to) {
                        audioPlayer1.seek(to);
                      },
                    )
                  ]);
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 8,
                        child: GestureDetector(
                          onTap: () {
                            /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayerPage()));*/
                          },
                          child: Row(
                            children: [
                              Flexible(
                                  child: Image.asset(
                                'assets/CD.png',
                                height: 60,
                                width: 60,
                              )),
                              Flexible(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Text(
                                      ' Recording',
                                      style: TextStyle(fontSize: 14),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: InkWell(
                                  onTap: () {
                                    audioPlayer1.seekBy(Duration(seconds: -10));
                                  },
                                  child: Icon(Icons.replay_10))),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: InkWell(
                                  onTap: () {
                                    if (audioPlayer1.isPlaying.value) {
                                      audioPlayer1.pause();
                                    } else {
                                      audioPlayer1.play();
                                    }
                                  },
                                  child: audioPlayer1.isPlaying.value
                                      ? Icon(Icons.pause)
                                      : Icon(Icons.play_arrow))),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: InkWell(
                                  onTap: () {
                                    audioPlayer1.seekBy(Duration(seconds: 10));
                                  },
                                  child: Icon(Icons.forward_10))),
                        ),
                      ),
                    ],
                  ),
                ),
                (editedflag == false)
                    ? Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 12, top: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Add Background Music',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Container(
                                  child: Row(children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      containerflag = true;
                                    });
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 23,
                                    color: Color.fromRGBO(88, 165, 196, 1),
                                  ),
                                )
                              ]))
                            ]),
                      )
                    : SizedBox(),
                (containerflag == true)
                    ? RadioButtonGroup(
                        activeColor: Color.fromRGBO(88, 165, 196, 1),
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        labels: [
                          "None",
                          "Track 1",
                        ],
                        onChange: (String label, int index) {
                          if (index == 0) {
                            setState(() {
                              flag = false;
                              _onbackg = 0;
                              audioPlayerbackg.stop();
                            });
                          } else {
                            setState(() {
                              flag = true;
                              _onbackg = 1;
                              audioPlayerbackg.play(dbP);
                              print(flag);
                            });
                          }
                        },
                        onSelected: (String label) => print(label))
                    : SizedBox()
              ],
            )));
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (flag == true) {
            _playMashup();

            setState(() {
              editedflag = true;
              flag = false;
            });
          }
          setState(() {
            playflagMP = false;
            newflag = false;
            containerflag = false;
            audioPlayerbackg.stop();
            audioPlayer1.stop();
            audioPlayer1 = AssetsAudioPlayer();
          });
        },
        child: Form(
          key: _formKey,
          child: Scaffold(
            bottomNavigationBar: (playflagMP == true) ? _mediaPlayer() : null,
            backgroundColor: const Color(0xff048EB0),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          child: Icon(Icons.arrow_back, size: 21),
                        ),
                      ),
                      InkWell(
                          child: Icon(Icons.list),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PlayerPage()));
                          }),
                    ]),
              ),
              Image.asset(
                'assets/wallpaperPodcast2.jpg',
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 30,
              ),
              // Center(
              //     child: (_current == null)
              //         ? Text("00:00:00",
              //             style: TextStyle(
              //                 fontSize: 30,
              //                 fontWeight: FontWeight.bold,
              //                 color: Color.fromRGBO(88, 165, 196, 1)))
              //         : Text(
              //             " ${_current?.duration.inHours.toString()}:${_current?.duration.inMinutes.toString()}:${_current?.duration.inSeconds.toString()}",
              //             style: TextStyle(
              //                 fontSize: 30,
              //                 fontWeight: FontWeight.bold,
              //                 color: Color.fromRGBO(88, 165, 196, 1)))),
              SizedBox(
                height: 20,
              ),
              (floatflag == false)
                  ? Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          InkWell(
                              onTap: () {
                                if (playflag == false) {
                                  //  _start();
                                  setState(() {
                                    playflag = true;
                                    pauseflag = true;
                                    resumeflag = false;
                                  });
                                } else {
                                  if (pauseflag == true) {
                                    _pause();
                                    setState(() {
                                      pauseflag = false;
                                      resumeflag = true;
                                    });
                                  } else if (resumeflag == true) {
                                    _resume();
                                    setState(() {
                                      resumeflag = false;
                                      pauseflag = true;
                                    });
                                  }
                                }
                              },
                              child: Column(children: [
                                Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    child: (pauseflag == true)
                                        ? Icon(Icons.pause,
                                            size: 20,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1))
                                        : Icon(
                                            Icons.play_arrow,
                                            size: 20,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                          )),
                                SizedBox(
                                  height: 7,
                                ),
                                Text("Start",
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ])),
                          InkWell(
                              onTap: () async {
                                //  await _stop();
                              },
                              child: Column(children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Icon(Icons.stop,
                                      size: 20,
                                      color: Color.fromRGBO(88, 165, 196, 1)),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text("Stop",
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ])),
                          InkWell(
                              onTap: () async {
                                //   await _save();
                              },
                              child: Column(children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Icon(
                                    Icons.save,
                                    size: 20,
                                    color: Color.fromRGBO(88, 165, 196, 1),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text("Save",
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ]))
                        ]))
                  : SizedBox(),
              SizedBox(
                height: 40,
              ),
              (recordedflag == true)
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Last Recorded Audio:",
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ]),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Voice Recording',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Container(
                                    child: Row(
                                  children: [
                                    InkWell(
                                        onTap: () async {
                                          if (audioPlayer1
                                                  .realtimePlayingInfos.value !=
                                              null) {
                                            setState(() {
                                              newflag = true;
                                              playflagMP = true;
                                              audioPlayer1.play();
                                            });
                                          } else {
                                            await audioPlayer1.open(
                                                Audio.file(outputPathRecorded),
                                                autoStart: false);
                                            if (audioPlayer1
                                                    .realtimePlayingInfos
                                                    .value !=
                                                null) {
                                              setState(() {
                                                newflag = true;
                                                playflagMP = true;
                                              });
                                            }
                                          }
                                        },
                                        child: Text("Play",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            )))
                                  ],
                                ))
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            (editedflag == true)
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Synced Recording',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Container(
                                          child: Row(
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                await audioPlayer1.open(
                                                    Audio.file(outputPath),
                                                    autoStart: false);
                                                if (audioPlayer1
                                                        .realtimePlayingInfos
                                                        .value !=
                                                    null) {
                                                  setState(() {
                                                    newflag = true;
                                                    playflagMP = true;
                                                    _outputPathDuration =
                                                        audioPlayer1
                                                            .realtimePlayingInfos
                                                            .value
                                                            .duration;
                                                  });
                                                }
                                              },
                                              child: Text("Play",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontFamily: 'Nunito Sans',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                  ))),
                                        ],
                                      ))
                                    ],
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 30,
              ),
              /* (floatflag == false)
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Add Background Music',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                            Container(
                              child: Row(children: [
                                InkWell(
                                    onTap: () {
                                      if (_onbackg == 1) {
                                        setState(() {
                                          audioPlayerbackg.pause();
                                          _onbackg = 0;
                                        });
                                      } else {
                                        setState(() {
                                          audioPlayerbackg.resume();
                                          _onbackg = 1;
                                        });
                                      }
                                    },
                                    child: (audioPlayerbackg.state ==
                                            AudioPlayerState.PLAYING)
                                        ? Icon(Icons.pause,
                                            size: 20,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1))
                                        : Icon(Icons.play_arrow,
                                            size: 20,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1))),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    showBarModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            _handlepressbutton());
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 20,
                                    color: Color.fromRGBO(88, 165, 196, 1),
                                  ),
                                )
                              ]),
                            )
                          ]),
                    )
                  : SizedBox(),
              (recordedflag == true)
                  ? Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            child:
                                Text("Mix", style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              _playMashup();
                              Fluttertoast.showToast(
                                  msg: "Background Music Added.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor:
                                      Color.fromRGBO(37, 36, 36, 1.0),
                                  textColor: Colors.white,
                                  fontSize: 12.0);
                            },
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),*/
              SizedBox(
                height: 5,
              ),
              /*(recordedflag == true)
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Save As:",
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                              /* Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 30,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Enter Name.';
                                        } else
                                          return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          name = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          hintText:
                                              'Give a name to your podcast',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          )),
                                    ),
                                  ),
                                ],
                              )*/
                            ],
                          )),
                    )
                  : SizedBox(),*/
              SizedBox(height: 5),
              (recordedflag == true)
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Text("Create",
                                  style: TextStyle(
                                    color: Color.fromRGBO(88, 165, 196, 1),
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  )),
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  if (editedflag == false) {
                                    socialobj.uploadPodcastAudio(
                                        userdetails.docs[0].get('firstname') +
                                            " " +
                                            userdetails.docs[0].get('lastname'),
                                        userdetails.docs[0].get('profilepic'),
                                        episodeflag1 == true
                                            ? albumname
                                            : dropdownValue,
                                        episodeflag1 == true
                                            ? episodename1
                                            : episodename2,
                                        _song1Duration.toString(),
                                        outputPathRecorded);

                                    Navigator.pop(context);
                                  } else {
                                    socialobj.uploadPodcastAudio(
                                        userdetails.docs[0].get('firstname') +
                                            " " +
                                            userdetails.docs[0].get('lastname'),
                                        userdetails.docs[0].get('profilepic'),
                                        episodeflag1 == true
                                            ? albumname
                                            : dropdownValue,
                                        episodeflag1 == true
                                            ? episodename1
                                            : episodename2,
                                        _outputPathDuration.toString(),
                                        outputPath);

                                    Navigator.pop(context);
                                  }
                                }
                              },
                            )
                          ]),
                    )
                  : SizedBox(),
              SizedBox(
                height: 5,
              ),
            ]),
            floatingActionButton: (floatflag == true)
                ? FloatingActionButton(
                    onPressed: () {
                      // _start();
                      playflag = true;
                      floatflag = false;
                      pauseflag = true;
                      resumeflag = false;
                    },
                    child: Icon(Icons.mic),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
    /*return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Wrap(children: [
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new FlatButton(
                        onPressed: () {
                          switch (_currentStatus) {
                            case RecordingStatus.Initialized:
                              {
                                _start();
                                break;
                              }
                            case RecordingStatus.Recording:
                              {
                                _pause();
                                break;
                              }
                            case RecordingStatus.Paused:
                              {
                                _resume();
                                break;
                              }
                            case RecordingStatus.Stopped:
                              {
                                _init();
                                break;
                              }
                            default:
                              break;
                          }
                        },
                        child: _buildText(_currentStatus),
                        color: Colors.lightBlue,
                      ),
                    ),
                    new FlatButton(
                      onPressed: _currentStatus != RecordingStatus.Unset
                          ? _stop
                          : null,
                      child: new Text("Stop",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    new FlatButton(
                      onPressed: onPlayAudio,
                      child: new Text("Play",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    new FlatButton(
                      onPressed: () {
                        _storagePath();
                      },
                      child: new Text("Play Mashup",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                  ],
                ),
                new Text("Status : $_currentStatus"),
                new Text('Avg Power: ${_current?.metering?.averagePower}'),
                new Text('Peak Power: ${_current?.metering?.peakPower}'),
                new Text("File path of the record: ${_current?.path}"),
                new Text("Format: ${_current?.audioFormat}"),
                new Text(
                    "isMeteringEnabled: ${_current?.metering?.isMeteringEnabled}"),
                new Text("Extension : ${_current?.extension}"),
                new Text(
                    "Audio recording duration : ${_current?.duration.toString()}"),
                SizedBox(
                  width: 8,
                ),
                new FlatButton(
                  onPressed: () {
                    _playMashup();
                  },
                  child: new Text("Play Mashup",
                      style: TextStyle(color: Colors.white)),
                  color: Colors.blueAccent.withOpacity(0.5),
                ),
              ]),
            ]),
      ),
    );*/
  }

//_on=0-->stopped;_on=1->>playing;
  int _on = 0;
  int _onbackg = 0;
  bool flag = false;

  _handlepressbutton() {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(children: [
          SizedBox(
            height: 15,
          ),
          RadioButtonGroup(
              activeColor: Color.fromRGBO(88, 165, 196, 1),
              labelStyle: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'Nunito Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              labels: [
                "None",
                "Track 1",
              ],
              onChange: (String label, int index) {
                if (index == 0) {
                  setState(() {
                    flag = false;
                    _onbackg = 0;
                    audioPlayerbackg.stop();
                  });
                } else {
                  setState(() {
                    flag = true;
                    _onbackg = 1;
                    audioPlayerbackg.play(dbP);
                    print(flag);
                  });
                }
              },
              onSelected: (String label) => print(label))

          /*Text('None',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              fontWeight: FontWeight.w400,
            )),
        SizedBox(
          height: 15,
        ),
        Text('Track 1',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ))*/
        ]),
      );
    });
  }

  String _mashupPath;
  String customPath;
//   Future<bool> _init() async {
//     try {
//       if (await FlutterAudioRecorder.hasPermissions) {
//         customPath = '/flutter_audio_recorder_';
//         io.Directory appDocDirectory;
// //        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
//         if (io.Platform.isIOS) {
//           appDocDirectory = await getApplicationDocumentsDirectory();
//         } else {
//           appDocDirectory = await getExternalStorageDirectory();
//         }
//
//         // can add extension like ".mp4" ".wav" ".m4a" ".aac"
//         customPath = appDocDirectory.path +
//             customPath +
//             DateTime.now().millisecondsSinceEpoch.toString();
//         setState(() {
//           _mashupPath = customPath;
//           print(_mashupPath);
//         });
//
//         // .wav <---> AudioFormat.WAV
//         // .mp4 .m4a .aac <---> AudioFormat.AAC
//         // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
//         _recorder =
//             FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
//
//         await _recorder.initialized;
//         // after initialization
//         var current = await _recorder.current(channel: 0);
//         print(current);
//         // should be "Initialized", if all working fine
//         setState(() {
//           _current = current;
//           _currentStatus = current.status;
//           print(_currentStatus);
//         });
//       } else {
//         Scaffold.of(context).showSnackBar(
//             new SnackBar(content: new Text("You must accept permissions")));
//       }
//     } catch (e) {
//       print(e);
//     }
//     return true;
//   }

  // _start() async {
  //   try {
  //     await _recorder.start();
  //     var recording = await _recorder.current(channel: 0);
  //     setState(() {
  //       _current = recording;
  //     });
  //     Fluttertoast.showToast(
  //         msg: "Recording Started",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 2,
  //         backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
  //         textColor: Colors.white,
  //         fontSize: 12.0);
  //     const tick = const Duration(milliseconds: 50);
  //     new Timer.periodic(tick, (Timer t) async {
  //       if (_currentStatus == RecordingStatus.Stopped) {
  //         t.cancel();
  //       }
  //
  //       var current = await _recorder.current(channel: 0);
  //       // print(current.status);
  //       setState(() {
  //         _current = current;
  //         _currentStatus = _current.status;
  //         print(_currentStatus);
  //       });
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  _resume() async {
    //  await _recorder.resume();
  }

  _pause() async {
    //  await _recorder.pause();
  }

//  Recording _song1;
//  Recording _song2;
  AssetsAudioPlayer assetplayer = AssetsAudioPlayer();
  // Future<bool> _stop() async {
  //   await _recorder.stop();
  //   setState(() {
  //     playflag = false;
  //     resumeflag = false;
  //     pauseflag = false;
  //   });
  //
  //   Fluttertoast.showToast(
  //       msg: "Recording Stopped",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 2,
  //       backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
  //       textColor: Colors.white,
  //       fontSize: 12.0);
  //   bool y = await _init();
  //   return y;
  // }

  bool recordedflag = false;
  // Future<void> _save() async {
  //   recordedflag = true;
  //
  //   var result = await _recorder.stop();
  //   print("Stop recording: ${result.path}");
  //   print("Stop recording: ${result.duration}");
  //   File file = widget.localFileSystem.file(result.path);
  //   print("File length: ${await file.length()}");
  //
  //   setState(() {
  //     _on = 1;
  //     _current = result;
  //     _song1 = _current;
  //     _currentStatus = _current.status;
  //
  //     print("song 1 recorded");
  //     print(_song1.path);
  //   });
  //   bool x = await _stop();
  //   print(x);
  //   if (x) {
  //     await _cleanAudio();
  //   }
  // }

  void onPlayAudio() async {
    AudioPlayer audioplayer = AudioPlayer();
    // await audioplayer.play(_song1.path, isLocal: true);
  }

  int _onfinal = 0;
  void onPlayM(String out) async {
    await audioplayer1.play(out, isLocal: true);
    _onfinal = 1;
  }

  /* var backpath;
  void onPlayAsset() async {
    assetplayer.open(Audio(
      "assets/audios/backg1.wav",
    ));
    backpath = Audio("assets/audios/backg1.wav").path;
  }*/
  bool editedflag = false;

  void _playMashup() async {
    List path1 = [_mashupPath, ".wav"];
    outputPath = path1.join("");
    setState(() {
      editedflag = true;
    });

    print(outputPath);
    print(dbP);
    var command = [
      "-i",
      dbP.toString(),
      "-i",
      outputPathRecorded,
      "-shortest",
      "-filter_complex",
      "[0:a]volume=0.4[a0];[1:a]volume=6.0[a1];[a0][a1]amix=inputs=2:duration=shortest",
      outputPath
    ];
    await _flutterFFmpeg
        .executeWithArguments(command)
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    await audioPlayer1.open(Audio.file(outputPath), autoStart: false);
    if (audioPlayer1.realtimePlayingInfos.value != null) {
      _outputPathDuration = audioPlayer1.realtimePlayingInfos.value.duration;
      print(_outputPathDuration);
    }
  }

  String outputPathRecorded;
  Future<void> _cleanAudio() async {
    List path1 = [_mashupPath, ".wav"];
    outputPathRecorded = path1.join("");

    /*var command2 = [
      "-i",
      _song1.path,
      "-af",
      "arnndn=m=assets/somnolent-hogwash/sh.rnnn",
      outputPathRecorded
    ];*/
    // var command2 = [
    //   "-i",
    //   _song1.path,
    //   "-af",
    //   "highpass=f=200,lowpass=f=3000",
    //   outputPathRecorded
    // ];
    // await _flutterFFmpeg
    //     .executeWithArguments(command2)
    //     .then((rc) => print("FFmpeg process exited with rc $rc"));
    // await audioPlayer1.open(Audio.file(outputPathRecorded), autoStart: false);
    //
    // if (audioPlayer1.realtimePlayingInfos.value != null) {
    //   _song1Duration = audioPlayer1.realtimePlayingInfos.value.duration;
    //   print(_song1Duration);
    // }
    //  await _init();
  }
}
/*_saveAudio(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text("Save Podcast"),
        content: Container(
            width: 200,
            height: 150,
            child: Column(
              children: [
                Text("Give a Name To Your Podcast",
                    style: TextStyle(
                      color: Color.fromRGBO(88, 165, 196, 1),
                      fontFamily: 'Nunito Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    )),
                Container(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                    width: 120)
              ],
            )),
        actions: [
          MaterialButton(
              child: Text("Save", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                socialobj.addPodcastAudio("", "", "", "", audioUrl);
              })
        ],
      );
    });
  }*/

class PositionSeekWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  const PositionSeekWidget({
    this.currentPosition,
    this.duration,
    this.seekTo,
  });

  @override
  _PositionSeekWidgetState createState() => _PositionSeekWidgetState();
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  Duration _visibleValue;
  bool listenOnlyUserInterraction = false;
  double get percent => widget.duration.inMilliseconds == 0
      ? 0
      : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(durationToString(widget.currentPosition)),
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: percent * widget.duration.inMilliseconds.toDouble(),
              onChangeEnd: (newValue) {
                setState(() {
                  listenOnlyUserInterraction = false;
                  widget.seekTo(_visibleValue);
                });
              },
              onChangeStart: (_) {
                setState(() {
                  listenOnlyUserInterraction = true;
                });
              },
              onChanged: (newValue) {
                setState(() {
                  final to = Duration(milliseconds: newValue.floor());
                  _visibleValue = to;
                });
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(durationToString(widget.duration)),
          ),
        ],
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds =
      twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
