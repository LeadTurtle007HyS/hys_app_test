
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hys/SocialPart/Podcast/controllers/audio_player_controller.dart';
import 'package:hys/SocialPart/Podcast/services/logger_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class LastRecordingBubble extends StatelessWidget {
  const LastRecordingBubble({
    Key key,
    this.time,
    this.path,
    this.backgroundMusicPath,
    this.updateMediaVolume,
    this.updateBackgroundMediaVol
  }) : super(key: key);
  final int time;
  final String path;
  final String backgroundMusicPath;
  final Function( double time) updateMediaVolume;
  final Function(double voulume) updateBackgroundMediaVol;


  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Center(
        child: LRPlayPauseButton(path: path,backgroundMusicPath: backgroundMusicPath,updateMediaVolume:updateMediaVolume,updateBackgroundMediaVol:updateBackgroundMediaVol),

      ),
    );
  }
}

class LRPlayPauseButton extends StatefulWidget {
  const LRPlayPauseButton({
    Key key,
    this.path,
    this.backgroundMusicPath,
    this.updateMediaVolume,
    this.updateBackgroundMediaVol
  }) : super(key: key);
  final String path;
  final String backgroundMusicPath;
  final Function( double time) updateMediaVolume;
  final Function(double voulume) updateBackgroundMediaVol;

  @override
  _LRPlayPauseButtonState createState() => _LRPlayPauseButtonState();
}

class _LRPlayPauseButtonState extends State<LRPlayPauseButton>
    with SingleTickerProviderStateMixin {

  bool playing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayerController audioPlayerController = Provider.of<AudioPlayerController>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.backgroundMusicPath!=null && widget.backgroundMusicPath.length>0? Column(
          children: [
            Expanded(
              child: SfSlider.vertical(
                value:audioPlayerController.getVolume(),
                max: 1.0,
                min: 0.1,
                interval: 0.1,
                showLabels: false,
                onChanged: (dynamic newValue){
                 audioPlayerController.setVolume(newValue);
                 widget.updateMediaVolume(newValue);
                  setState(() {

                  });
                },
              ),
            ),
            Text(
              "Recorded Music Vol.",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 10,
                color: Colors.black54
              ),
            )
          ],
        ):SizedBox(height: 100),
        ElevatedButton(
            onPressed: () async {
              logger.d("Button pressed!");
              HapticFeedback.vibrate();
              if (playing) {
               audioPlayerController.pause();
               _audioPlayer.pause();
                setState(() {
                  playing = false;
                });
              } else {

                if(widget.backgroundMusicPath!=null && widget.backgroundMusicPath.length>0){
                  final source = AudioSource.uri(Uri.parse(widget.backgroundMusicPath));
                  await _audioPlayer.setAudioSource(source);
                  await audioPlayerController.setSource(widget.path);
                  setState(() {
                    playing = true;
                  });
                  await _audioPlayer.setLoopMode(LoopMode.one);
                  _audioPlayer.play();
                  await audioPlayerController.play();
                  _audioPlayer.pause();
                  audioPlayerController.pause();
                  setState(() {
                    playing = false;
                  });
                }else{
                  await audioPlayerController.setSource(widget.path);
                  setState(() {
                    playing = true;
                  });
                  await audioPlayerController.play();
                  setState(() {
                    playing = false;
                  });
                }

              }
            },
            child:Icon(playing?Icons.pause:Icons.play_arrow_rounded,color: Colors.white),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(50, 50),
              shape: const CircleBorder(),
            )),
        widget.backgroundMusicPath!=null && widget.backgroundMusicPath.length>0? Column(
          children: [
            Expanded(
              child: SfSlider.vertical(
                value:_audioPlayer.volume,
                max: 1.0,
                min: 0.0,
                interval: 0.1,
                showLabels: false,
                onChanged: (dynamic newValue){
                  _audioPlayer.setVolume(newValue);
                  setState(() {

                  });
                //  widget.updateBackgroundMediaVol(newValue);

                },
              ),
            ),
            Text(
              "Background Music Vol.",
              style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 10,
                  color: Colors.black54
              ),
            )
          ],
        ):SizedBox(height: 100),
      ],
    );
  }
}
