import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';

Positioned buildDurationText(VideoPlayerModel model, BuildContext context) {
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
          backgroundColor: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
