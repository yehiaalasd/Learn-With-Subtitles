import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildControlButtons.dart';
import 'package:video_player/video_player.dart';

Positioned buildControlOverlay(
    VideoPlayerModel model, List<String> videoPaths, BuildContext context) {
  return Positioned(
    bottom: model.showControls ? 0 : -100,
    left: 0,
    right: 0,
    child: Container(
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).orientation == Orientation.portrait
              ? 40
              : 0),
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                child: Text(
                  model.controller.value.position.toString().split('.').first,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              SizedBox(
                height: 18,
                width: MediaQuery.of(context).size.width * 0.88,
                child: VideoProgressIndicator(
                  model.controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                      playedColor: Colors.blue, backgroundColor: Colors.grey),
                ),
                //   ],
                // ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          buildControlButtons(model, videoPaths, context),
        ],
      ),
    ),
  );
}
