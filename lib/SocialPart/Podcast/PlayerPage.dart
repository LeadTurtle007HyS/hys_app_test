import 'package:flutter/material.dart';

import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:expandable/expandable.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
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

class _PlayerPageState extends State<PlayerPage> {
  void initState() {
    albumList = [];
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

    /* socialobj.getUserPodcastAudio().then((value) {
      albumdata = value;
      if (albumdata != null) {
        for (int i = 0; i < albumdata.docs.length; i++) {
          albumList[i]=albumdata.docs[i].get('albumname');
        }
        for (int i = 0; i < album; i++) {
          if (albumList[i]==) ;
        }
        print(albumList);
        if (albumList.length.toInt() > 0) {
          setState(() {
            albumflag = true;
          });
        }
      }
    });*/

    // TODO: implement initState
    super.initState();
  }
/*
  @override
  void dispose() {
    audioPlayer1?.dispose();
    // TODO: implement dispose
    super.dispose();
  }*/

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
                /* Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 60.0,
                    ),
                    child: Image.asset('assets/bloglogo.png')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset('assets/bloglogo.png')),*/
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: audioPlayer1.builderRealtimePlayingInfos(
                      builder: (context, infos) {
                    //print("infos: $infos");

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
    if (podcasts != null && episodeCountMap != null && episodes != null) {
      return (podcasts.docs.length == 0)
          ? when_no_blog()
          : ListView.builder(
              itemCount: albumList.length,
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
    return ExpandablePanel(
      header: ListTile(
        leading: Container(
          child: Image.asset('assets/wallpaperPodcast2.jpg'),
          height: 38,
        ),
        title: Text(albumList[i],
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito Sans',
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        subtitle: Text("Eps. ${episodeCountMap[albumList[i]].toString()}",
            style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Nunito Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        onTap: null,
        /*onTap: () async {
          if (audioPlayer1.isPlaying.value) {
            await audioPlayer1.stop();
            audioPlayer1 = AssetsAudioPlayer();
          }
          await audioPlayer1.open(Audio.network(podcasts.docs[i].get('audiourl')),
              forceOpen: true);
          setState(() {
            index = i;
          });
          if (audioPlayer1.realtimePlayingInfos.value != null) {
            setState(() {
              playflagMP = true;
            });
          }
        }*/
      ),
      expanded: Container(
          height: (57 * episodeCountMap[albumList[i]]).toDouble(),
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: episodes[albumList[i]].docs.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () async {
                    if (audioPlayer1.isPlaying.valueWrapper.value) {
                      await audioPlayer1.stop();
                      audioPlayer1 = AssetsAudioPlayer();
                    }
                    String path;
                    path = await episodes[albumList[i]]
                        .docs[index]
                        .get('audiourl');
                    print(path);
                    await audioPlayer1.open(Audio.network(path),
                        autoStart: false);

                    if (audioPlayer1.realtimePlayingInfos.valueWrapper.value != null) {
                      setState(() {
                        playflagMP = true;
                        songname =
                            episodes[albumList[i]].docs[index].get('name');
                      });
                    }
                  },
                  leading: Container(
                    child: Image.asset('assets/wallpaperPodcast2.jpg'),
                    height: 38,
                  ),
                  title: Text(episodes[albumList[i]].docs[index].get('name'),
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                );
              })),
    );
  }

  when_i_zero() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child:
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
          Text("Playlist",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 20,
          )
        ]),
      ),
      SizedBox(
        height: 10,
      ),
      _podcasts(0)
    ]);
  }

  when_no_blog() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () {
              audioPlayer1.stop();
              Navigator.pop(context);
            },
            child: Container(
              width: 25,
              height: 25,
              child: Icon(Icons.arrow_back, size: 21, color: Colors.white),
            ),
          ),
          Text("Playlist",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 20,
          )
        ]),
      ),
      SizedBox(
        height: 10,
      ),
    ]);
  }
}
/*
class PlayerControlWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '0:00',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Flexible(
              flex: 2,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.3),
                  trackHeight: 2,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                ),
                child: Slider(
                  value: 12,
                  max: 100,
                  onChanged: (newPosition) {},
                ),
              ),
            ),
            Text('04:45',
                style: TextStyle(
                  color: Colors.white,
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {},
              ),
            ),
            SizedBox(
                height: 90,
                width: 90,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
            SizedBox(
              height: 90,
              width: 90,
              child: IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {},
              ),
            ),
          ],
        )
      ],
    );
  }
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
            child: Text(durationToString(widget.currentPosition),
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.3),
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
            ),
            child: Expanded(
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
          ),
          SizedBox(
            width: 40,
            child: Text(durationToString(widget.duration),
                style: TextStyle(
                  color: Colors.white,
                )),
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
