import 'package:flutter/material.dart';
import 'package:hys/SocialPart/Podcast/controllers/timer_controller.dart';
import 'package:provider/provider.dart';

class RecordDuration extends StatelessWidget {
  const RecordDuration({
    Key key,
  }) : super(key: key);
  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  @override
  Widget build(BuildContext context) {
    final TimerController _timerController =
        Provider.of<TimerController>(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _timerController.recordDuration == 0
          ? Center(
              child: Text(
                'Tap and hold to record audio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Center(
            child: Text(
                '${_formatNumber(_timerController.recordDuration ~/ 60)}:${_formatNumber(_timerController.recordDuration % 60)}',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ),
    );
  }
}
