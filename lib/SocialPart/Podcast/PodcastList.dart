import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:hys/SocialPart/database/feedpostDB.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PodcastList extends StatefulWidget {
  @override
  _PodcastListState createState() => _PodcastListState();
}

QuerySnapshot podcasts;
SocialFeedPost socialobj = SocialFeedPost();
int length;
AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();

class _PodcastListState extends State<PodcastList> {
  @override
  void initState() {
    socialobj.getPodcastAudio().then((value) {
      setState(() {
        podcasts = value;
        if (podcasts != null) {
          length = podcasts.docs.length;
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
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'My Awesome Playlist',
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0.0,
            ),
            body: Column(children: [
              _body(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: PlayerControlWidget())
            ])));
  }

  bool flag = false;

  _body() {
    if (podcasts != null) {
      return (podcasts.docs.length == 0)
          ? when_no_blog()
          : ListView.builder(
              itemCount: podcasts.docs.length,
              itemBuilder: (BuildContext context, int i) {
                return (i == 0) ? when_i_zero() : _podcasts(i);
              },
            );
    }
  }

  bool resumeflag = false;
  bool iconflag = false;
  AudioPlayer audioplayer = AudioPlayer();

  _podcasts(int i) {
    return ListTile(
      leading: (iconflag == false) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      title: Text(podcasts.docs[i].get("name")),
      onTap: () {
        if (flag == false) {
          audioplayer.play(podcasts.docs[i].get("audiourl"));
          setState(() {
            flag = true;
            iconflag = true;
          });
        } else if (resumeflag == true) {
          audioplayer.resume();
          setState(() {
            resumeflag = false;
            iconflag = true;
          });
        } else {
          audioplayer.pause();
          setState(() {
            resumeflag = true;
            iconflag = false;
          });
        }
      },
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
              Navigator.pop(context);
            },
            child: Container(
              width: 25,
              height: 25,
              child: Icon(Icons.arrow_back, size: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 5), blurRadius: 8, spreadRadius: -4)
                ],
              ),
            ),
          ),
          Text(
            "Playlist",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              Navigator.pop(context);
            },
            child: Container(
              width: 25,
              height: 25,
              child: Icon(Icons.arrow_back, size: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 5), blurRadius: 8, spreadRadius: -4)
                ],
              ),
            ),
          ),
          Text(
            "Playlist",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

  /*if (podcasts != null) {
      return ListView.builder(
          itemCount: length,
          itemBuilder: (BuildContext context, int index) {
            
          });*/

}

class PlayerControlWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('0:00'),
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
            Text('04:45'),
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
                  size: 40,
                ),
                onPressed: () {},
              ),
            ),
            SizedBox(height: 90, width: 90, child: Icon(Icons.play_arrow)),
            SizedBox(
              height: 90,
              width: 90,
              child: IconButton(
                icon: Icon(
                  Icons.skip_next,
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
}
