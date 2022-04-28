import 'package:flutter/material.dart';
import 'package:hys/SocialPart/Podcast/controllers/record_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/settings_controller.dart';
import 'package:hys/SocialPart/Podcast/painters/wave_painter.dart';
import 'package:hys/SocialPart/Podcast/utils/smoothing.dart';

import 'package:provider/provider.dart';

class AmplitudeWidget extends StatefulWidget {
  const AmplitudeWidget({
    Key key,
     this.child,
  }) : super(key: key);
  final Widget child;
  @override
  State<AmplitudeWidget> createState() => _AmplitudeWidgetState();
}

class _AmplitudeWidgetState extends State<AmplitudeWidget>
    with TickerProviderStateMixin {
   AnimationController controller;
   AnimationController amplitudeController;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat();
    amplitudeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
      setState(() {});
    });
    amplitudeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    amplitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RecordController _recordController =
    Provider.of<RecordController>(context);
    final SettingsController _settingsController =
    Provider.of<SettingsController>(context);
    final SgFilter filter = SgFilter(
        6,
        (_recordController.amplitude != null &&
            _recordController.amplitudeHistory.isNotEmpty)
            ? _recordController.amplitudeHistory.length
            : _recordController.lengthOfHistory);
    return Stack(
      children: [
        CustomPaint(
          painter: _settingsController.realisticData
              ? WavePainter(
            color: Theme.of(context).colorScheme.primary,
            amplitudeHistory: _recordController.amplitude != null &&
                _recordController.amplitudeHistory.isNotEmpty
                ? filter.smooth((_recordController.amplitudeHistory
                .map((e) => e * 80)).toList()) as List<double>
                : List.filled(_recordController.lengthOfHistory, 20),
            phase: _recordController.amplitude != null
                ? 0
                : 360 * controller.value,
            heightPercentage: 0.53,
            waveFrequency: (_recordController.amplitude != null &&
                _recordController.amplitudeHistory.isNotEmpty)
                ? _recordController.amplitudeHistory.length.toDouble()
                : 5,
          )
              : WavePainterOld(
            color: Theme.of(context).colorScheme.primary,
            amplitude: _recordController.amplitude != null
                ? (_recordController.amplitude ?? 0) * 80
                : (amplitudeController.value * 20),
            phase: 360 * controller.value,
            heightPercentage: 0.63,
            waveFrequency: _recordController.amplitude != null ? 10 : 5,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height ,
          ),
        ),
        widget.child,
      ],
    );
  }
}
