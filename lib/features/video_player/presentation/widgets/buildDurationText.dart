import 'package:flutter/material.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';

class DurationText extends StatelessWidget {
  final VideoPlayerViewModel model;

  const DurationText({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      top: 0,
      child: Center(
        child: Text(
          model.showDuration ? "[${model.durationText}]" : '',
          style: TextStyle(
            fontSize: orientation == Orientation.landscape ? 33 : 20,
            color: Colors.white,
            backgroundColor: Colors.black26,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
