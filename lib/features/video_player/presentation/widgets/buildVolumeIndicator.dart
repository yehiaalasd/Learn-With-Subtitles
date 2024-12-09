import 'package:flutter/material.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';

class VolumeIndicator extends StatelessWidget {
  final VideoPlayerViewModel model;

  VolumeIndicator({required this.model});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: width > height ? 70 : 240,
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
}

class BrightnessIndicator extends StatelessWidget {
  final VideoPlayerViewModel model;

  BrightnessIndicator({required this.model});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: width > height ? 70 : 200,
      right: 20, // Position the brightness slider on the right
      child: SizedBox(
        height: 300,
        child: RotatedBox(
          quarterTurns: 3, // Rotates the slider 270 degrees
          child: Slider(
            onChanged: (value) {
              // model.setBrightness(
              //     value); // Assuming you have a setBrightness method
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
}
