import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:hys/SocialPart/Podcast/album_sheet.dart';
import 'package:hys/SocialPart/Podcast/record_page.dart';
import 'package:hys/database/crud.dart';
import 'package:hys/models/album_episode_model.dart';
import 'package:hys/models/podcast_album_model.dart';
import 'package:just_audio/just_audio.dart';
import 'controllers/audio_player_controller.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({Key key}) : super(key: key);

  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  int _index = 0;
  PodcastAlbumModel podcastAlbumModel;
  CrudMethods crudobj = CrudMethods();
  bool isLoading = false;

  TextEditingController _textFieldController = TextEditingController();
  String codeDialog;
  String valueText;

  @override
  void initState() {
    super.initState();
    fetchUserAlbum();
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  createAlbum(String albumName) {}

  fetchUserAlbum() {
    setState(() {
      isLoading = true;
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Album'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter album name"),
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
                  createAlbum(valueText);
                  valueText = "";
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : podcastAlbumModel != null
                  ? _body()
                  : InkWell(
                      onTap: () {
                        _displayTextInputDialog(context);
                      },
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "You don't have any album. Create a album",
                            style: TextStyle(
                                color: Color.fromRGBO(7, 120, 168, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Icon(
                            Icons.add_circle_outline,
                            color: Color.fromRGBO(7, 120, 168, 1.0),
                            size: 30,
                          )
                        ],
                      ))),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Color.fromRGBO(88, 165, 196, 1),
              onPressed: () {
                if (podcastAlbumModel != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecordPage(
                              podcastAlbumModel: podcastAlbumModel)));
                }
              },
              tooltip: '',
              child: Icon(
                Icons.add,
                color: Colors.white,
              )),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked),
    );
  }

  Future _openAddEntryDialog() async {
    var save = await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return new AlbumSheet();
        },
        fullscreenDialog: true));
    if (save != null) {
      setState(() {
        podcastAlbumModel = save;
      });
    }
  }

  _body() {
    return new Stack(
      children: <Widget>[
        Center(
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("podcast_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: Color.fromRGBO(88, 165, 196, 1),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _openAddEntryDialog();
                    },
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              size: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                              text: podcastAlbumModel.albumName,
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Podcast",
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // ElevatedButton(
                  //   style: ButtonStyle(
                  //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(18.0),
                  //         side: BorderSide(
                  //           color: Colors.teal,
                  //           width: 2.0,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   child: Text('Publish'),
                  //   onPressed: () {
                  //
                  //   },
                  // ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 100,
              child: StreamBuilder<List<AlbumEpisode>>(
                //  stream: crudobj.albumEpisodeList(podcastAlbumModel.albumID),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<AlbumEpisode>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (snapshot.hasData && snapshot.data.length > 0) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          AlbumEpisode albumEpisodeModel = snapshot.data[index];
                          return ChangeNotifierProvider<AudioPlayerController>(
                            create: (_) => AudioPlayerController(
                                albumEpisodeModel.audioURL),
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
                                      title: Text(albumEpisodeModel.episodeName,
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      subtitle: Text(
                                          "${_formatNumber((apc.duration?.inSeconds ?? 0) ~/ 60)}:${_formatNumber((apc.duration?.inSeconds ?? 0) % 60)}   ${albumEpisodeModel.fileType.toUpperCase()}",
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
                                          InkWell(
                                            onTap: () async {
                                              HapticFeedback.vibrate();
                                              if (apc.audioPlayer.playing &&
                                                  apc.audioPlayer
                                                          .processingState !=
                                                      ProcessingState
                                                          .completed) {
                                                apc.stop();
                                              } else {
                                                await apc.setSource(
                                                    albumEpisodeModel.audioURL);
                                                apc.play();
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                      return InkWell(
                          onTap: () {
                            if (podcastAlbumModel != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RecordPage(
                                          podcastAlbumModel:
                                              podcastAlbumModel)));
                            }
                          },
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "This album doesn't have any episode. Tap plus button to add to this album",
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                    color: Color.fromRGBO(7, 120, 168, 1.0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              Icon(
                                Icons.add_circle_outline,
                                color: Color.fromRGBO(7, 120, 168, 1.0),
                                size: 30,
                              )
                            ],
                          )));
                    }
                  }
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
