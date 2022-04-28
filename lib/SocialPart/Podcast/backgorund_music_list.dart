import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:hys/database/crud.dart';
import 'package:hys/models/podcast_bg_file_model.dart';
import 'package:just_audio/just_audio.dart';

import 'controllers/audio_player_controller.dart';

class BackgroundMusicList extends StatefulWidget {
  const BackgroundMusicList({
    Key key,
  }) : super(key: key);

  @override
  State<BackgroundMusicList> createState() => _BackgroundMusicListState();
}

class _BackgroundMusicListState extends State<BackgroundMusicList> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CrudMethods crudobj = CrudMethods();
  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
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
              "Background Music",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(8.0),
          child: FutureBuilder<List<PodcastBgFile>>(
            //  future: crudobj.allBackgroundMusic(),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<PodcastBgFile>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      PodcastBgFile podcastBgFile = snapshot.data[index];
                      return ChangeNotifierProvider<AudioPlayerController>(
                        create: (_) =>
                            AudioPlayerController(podcastBgFile.fileURL),
                        child: Card(
                          elevation: 10,
                          color: Color.fromRGBO(88, 165, 196, 1),
                          child: Consumer<AudioPlayerController>(
                              builder: (context, apc, child) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                  ),
                                  title: Text(podcastBgFile.fileName,
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      )),
                                  subtitle: Text(
                                      "${_formatNumber((apc.duration?.inSeconds ?? 0) ~/ 60)}:${_formatNumber((apc.duration?.inSeconds ?? 0) % 60)}   ${podcastBgFile.fileType.toUpperCase()}",
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      )),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(podcastBgFile);
                                          },
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            size: 30,
                                            color: Colors.white,
                                          )),
                                      InkWell(
                                        onTap: () async {
                                          HapticFeedback.vibrate();
                                          if (apc.audioPlayer.playing &&
                                              apc.audioPlayer.processingState !=
                                                  ProcessingState.completed) {
                                            apc.stop();
                                          } else {
                                            await apc.setSource(
                                                podcastBgFile.fileURL);
                                            apc.play();
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              apc.audioPlayer.playing &&
                                                      apc.audioPlayer
                                                              .processingState !=
                                                          ProcessingState
                                                              .completed
                                                  ? Icons.stop
                                                  : Icons.play_arrow,
                                              color: Colors.black,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    Container(
                                      height: 2,
                                      width: MediaQuery.of(context).size.width *
                                          0.9 *
                                          (apc.audioPlayer.position
                                                      .inMilliseconds /
                                                  (apc.audioPlayer.duration
                                                          ?.inMilliseconds ??
                                                      1))
                                              .toDouble(),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: const Text('Empty data'));
                }
              } else {
                return Center(
                    child: Text('State: ${snapshot.connectionState}'));
              }
            },
          ),
        ),
      ),
    );
  }
}
