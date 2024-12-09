import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/data/entities/subtitles.dart';

class SubtitleManger extends ChangeNotifier {
  SubtitleManger(
    this.videoPlayerModel,
  ) {
    videoWithSubtitles = videoPlayerModel.currentSubtitle.videoWithSubtitles;
    addListenre();
  }

  late VideoPlayerViewModel videoPlayerModel;
  late VideoWithSubtitles videoWithSubtitles;

  Offset subtitleOffset = const Offset(0, 50);
  bool subtitleOn = true;

  void setSubtitleOff() {
    subtitleOn = false;
    notifyListeners();
  }

  void setSubtitleOn() {
    subtitleOn = true;
    notifyListeners();
  }

  void onSubtitleDragUpdate(DragUpdateDetails details) {
    double screenHeight = Get.height;

    double newDy = subtitleOffset.dy + details.delta.dy;

    newDy = Get.orientation == Orientation.portrait
        ? newDy.clamp(
            screenHeight * 0.1,
            screenHeight * 1.5,
          )
        : newDy.clamp(
            screenHeight * 0.1,
            screenHeight * 0.29,
          );

    subtitleOffset = Offset(subtitleOffset.dx, newDy);
    notifyListeners();
  }

  

  void removeSubtitle(Subtitles sub) {
    videoWithSubtitles.subtitles.remove(sub);
    SubtitleRepositoryImpl()
        .removeSubtitlePaths(sub.subtitlePath, videoWithSubtitles.video);
    notifyListeners();
  }

  void updateSubtitle() async {
    videoWithSubtitles = videoPlayerModel.currentSubtitle.videoWithSubtitles;
    final subs = videoWithSubtitles.subtitles.where((sub) => sub.isEnabled);
    var pos = await videoPlayerModel.controller.position;
    for (Subtitles subtitle in subs) {
      if (pos != null && subtitle.subtitle.isNotEmpty) {
        subtitle.getByPosition(pos);
      }
    }

    notifyListeners();
  }

  void addListenre() {
    videoPlayerModel.controller.addListener(() {
      updateSubtitle();
    });
  }

  void removeListenerSub() {
    videoPlayerModel.controller.removeListener(() {
      updateSubtitle();
    });
  }
}
