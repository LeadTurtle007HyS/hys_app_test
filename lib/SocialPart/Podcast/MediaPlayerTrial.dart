import 'package:flutter/material.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class AlbumPlayer extends StatefulWidget {
  String albumname;
  AlbumPlayer(this.albumname);
  @override
  _AlbumPlayerState createState() => _AlbumPlayerState(this.albumname);
}

QuerySnapshot podcasts;
SocialFeedPost socialobj = SocialFeedPost();
int length;
AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();
QuerySnapshot albumdata;
List albumList = [];
bool albumflag = false;
int episodecount;
Map<String, int> episodeCountMap = Map();
Map<String, QuerySnapshot> episodes = Map();
String author = "";

class _AlbumPlayerState extends State<AlbumPlayer> {
  String albumname;
  _AlbumPlayerState(this.albumname);

  void initState() {
    albumList = [];
    socialobj.getPodcastAudioWhere(albumname).then((value) {
      setState(() {
        albumdata = value;
        if (albumdata != null) {
          setState(() {
            author = albumdata.docs[0].get('username');
          });
        }
      });
    });
    socialobj.getPodcastAudio().then((value) {
      setState(() {
        podcasts = value;
        if (podcasts != null) {
          length = podcasts.docs.length;
          for (int i = 0; i < length; i++) {
            episodecount = 0;
            String albumname = podcasts.docs[i].get('albumname');
            QuerySnapshot episodeSnap;
            if (albumList.contains(podcasts.docs[i].get("albumname")) != true) {
              albumList.add(podcasts.docs[i].get('albumname'));
              print(albumList);
              socialobj.getPodcastAudioWhere(albumname).then((value) {
                setState(() {
                  episodeSnap = value;
                  if (episodeSnap != null) {
                    episodes[albumname] = episodeSnap;
                    print(episodes);
                  }
                });
              });
            }

            for (int i = 0; i < length; i++) {
              if (podcasts.docs[i].get('albumname') == albumname) {
                episodecount++;
              }
            }
            episodeCountMap[albumname] = episodecount;
          }
        }
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFe63946), Colors.black.withOpacity(0.6)],
                    stops: [0.0, 0.4],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    tileMode: TileMode.repeated)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    child: _body(),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.27),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: audioPlayer1.builderRealtimePlayingInfos(
                      builder: (context, infos) {
                    return Column(children: [
                      PositionSeekWidget(
                        currentPosition: (playflagMP == true)
                            ? infos.currentPosition
                            : Duration(minutes: 0, seconds: 0),
                        duration: (playflagMP == true)
                            ? infos.duration
                            : Duration(minutes: 0, seconds: 0),
                        seekTo: (to) {
                          audioPlayer1.seek(to);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 8,
                              child: GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Flexible(
                                        child: Image.asset(
                                      'assets/wallpaperPodcast2.jpg',
                                      height: 60,
                                      width: 60,
                                    )),
                                    Flexible(
                                      flex: 3,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Text(songname,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600))),
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
                                          audioPlayer1
                                              .seekBy(Duration(seconds: -10));
                                        },
                                        child: Icon(Icons.replay_10,
                                            color: Colors.white))),
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
                                          if (audioPlayer1.isPlaying.valueWrapper.value) {
                                            audioPlayer1.pause();
                                          } else {
                                            audioPlayer1.play();
                                          }
                                        },
                                        child: audioPlayer1.isPlaying.valueWrapper.value
                                            ? Icon(Icons.pause,
                                                color: Colors.white)
                                            : Icon(Icons.play_arrow,
                                                color: Colors.white))),
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
                                          audioPlayer1
                                              .seekBy(Duration(seconds: 10));
                                        },
                                        child: Icon(Icons.forward_10,
                                            color: Colors.white))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }),
                )
              ],
            )),
      ),
    );
  }

  _body() {
    if (albumdata != null) {
      return (podcasts.docs.length == 0)
          ? when_no_blog()
          : ListView.builder(
              itemCount: albumdata.docs.length,
              itemBuilder: (BuildContext context, int i) {
                return (i == 0) ? when_i_zero() : _podcasts(i);
              },
            );
    }
  }

  String songname = "Play Podcasts";
  bool playflagMP = false;
  bool flag = false;
  bool resumeflag = false;
  bool iconflag = false;
  AudioPlayer audioplayer = AudioPlayer();
  int index;
  QuerySnapshot snap1;
  _podcasts(int i) {
    return ListTile(
      leading: Container(
        child: Image.asset('assets/wallpaperPodcast2.jpg'),
        height: 38,
      ),
      title: Text(albumdata.docs[i].get('name'),
          style: TextStyle(
              color: Color(0xE0F1F1F1),
              fontFamily: 'Nunito Sans',
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      onTap: () async {
        if (audioPlayer1.isPlaying.valueWrapper.value) {
          await audioPlayer1.stop();
          audioPlayer1 = AssetsAudioPlayer();
        }
        String path;
        path = await albumdata.docs[i].get('audiourl');
        print(path);
        await audioPlayer1.open(Audio.network(path));

        if (audioPlayer1.realtimePlayingInfos.valueWrapper.value != null) {
          setState(() {
            playflagMP = true;
            songname = albumdata.docs[i].get('name');
          });
        }
      },
    );
  }

  when_i_zero() {
    return Column(children: [
      Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
          ),
          height: 300,
          width: MediaQuery.of(context).size.width,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                InkWell(
                  onTap: () {
                    audioPlayer1.stop();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    child: Icon(
                      Icons.arrow_back,
                      size: 21,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/wallpaperPodcast2.jpg')),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    height: 80,
                  ),
                  SizedBox(width: 60),
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(albumname,
                        style: TextStyle(
                            color: Color(0xE0F1F1F1),
                            fontFamily: 'Nunito Sans',
                            fontSize: 19,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("- " + author,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xE0F1F1F1),
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      height: 35,
                    )
                  ])
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Description :",
                      style: TextStyle(
                          color: Color(0xE0F1F1F1),
                          fontFamily: 'Nunito Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )
          ],
        ),
      ]),
      SizedBox(
        height: 7,
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Episodes : " + albumdata.docs.length.toString(),
                style: TextStyle(
                    color: Color(0xE0F1F1F1),
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      SizedBox(
        height: 7,
      ),
      _podcasts(0)
    ]);
  }

  when_no_blog() {
    return Column(children: [
      Stack(children: [
        Container(
          height: 300,
          color: Colors.indigo,
          width: MediaQuery.of(context).size.width,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () {
              audioPlayer1.stop();
              Navigator.pop(context);
            },
            child: Container(
              width: 25,
              height: 25,
              child: Icon(
                Icons.arrow_back,
                size: 21,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ]),
      ]),
      SizedBox(
        height: 10,
      ),
    ]);
  }
}

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
            child: Text(durationToString(widget.currentPosition),
                style: TextStyle(color: Colors.white)),
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
            child: Text(durationToString(widget.duration),
                style: TextStyle(color: Colors.white)),
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
