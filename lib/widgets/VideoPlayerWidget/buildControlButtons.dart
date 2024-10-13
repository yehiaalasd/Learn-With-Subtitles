import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/utils/video_properties.dart';

Row buildControlButtons(
    VideoPlayerModel model, List<String> videoPaths, BuildContext context) {
  // double height = MediaQuery.of(context).size.height * 0.1;
  // double width = MediaQuery.of(context).size.height * 0.1;
  //

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: const Icon(Icons.lock, color: Colors.white),
        onPressed: model.skipBackward,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
          onPressed: () => model.previousVideo(context),
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: Icon(
            model.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 40,
          ),
          onPressed: model.playPause,
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () => model.nextVideo(context),
        ),
      ]),
      // IconButton(
      //   icon: const Icon(Icons.forward_5, color: Colors.white),
      //   onPressed: model.skipForward,
      // ),
      // IconButton(
      //   icon: Icon(Icons.volume_up, color: Colors.white),
      //   onPressed: () => model.adjustVolume(0.1),
      // ),
      // IconButton(
      //   icon: Icon(Icons.volume_down, color: Colors.white),
      //   onPressed: () => model.adjustVolume(-0.1),
      // ),
      IconButton(
        icon: const Icon(Icons.fullscreen, color: Colors.white),
        onPressed: () {
          toggleFullscreen(context);
        },
      ),
    ],
  );
}
