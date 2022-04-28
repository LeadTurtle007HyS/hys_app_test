import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video_Player extends StatefulWidget {
  String coverImageUrl;
  String videoUrl;
  Video_Player(this.coverImageUrl, this.videoUrl);
  @override
  _Video_PlayerState createState() =>
      _Video_PlayerState(this.coverImageUrl, this.videoUrl);
}

class _Video_PlayerState extends State<Video_Player> {
  String coverImageUrl;
  String videoUrl;
  _Video_PlayerState(this.coverImageUrl, this.videoUrl);

  ChewieController chewieCtrl;
  VideoPlayerController videoPlayerCtrl;

  @override
  void initState() {
    super.initState();
    videoPlayerCtrl = VideoPlayerController.network(widget.videoUrl);
    chewieCtrl = ChewieController(
      videoPlayerController: videoPlayerCtrl,
      autoPlay: true,
      //  aspectRatio: 3 / 2,
      placeholder: Center(
        child: Image.file(File(widget.coverImageUrl)),
      ),
    );
  }

  @override
  void dispose() {
    chewieCtrl.dispose();
    videoPlayerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Chewie(
        controller: chewieCtrl,
      ),
    );
  }
}
