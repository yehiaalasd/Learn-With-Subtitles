import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';

Widget buildVolumeIndicator(VideoPlayerModel model) {
  return Positioned(
    bottom: 70,
    left: 20, // Position the volume slider on the left
    child: SizedBox(
      height: 300,
      child: RotatedBox(
        quarterTurns: 3, // Rotates the slider 270 degrees
        child: Slider(
          onChanged: (value) {
            model.setVolume(value);
          },
          value: model.volume,
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(model.volume * 100).round()}%',
        ),
      ),
    ),
  );
}

Widget buildBrightnessIndicator(VideoPlayerModel model) {
  return Positioned(
    bottom: 70,
    right: 20, // Position the brightness slider on the right
    child: SizedBox(
      height: 300,
      child: RotatedBox(
        quarterTurns: 3, // Rotates the slider 270 degrees
        child: Slider(
          onChanged: (value) {
            model.setBrightness(
                value); // Assuming you have a setBrightness method
          },
          value: model.brightness, // Ensure you have brightness in your model
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(model.brightness * 100).round()}%',
        ),
      ),
    ),
  );
}
