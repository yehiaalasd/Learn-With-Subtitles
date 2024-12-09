import 'package:flutter/material.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/buildSubtitleDownloadDialog.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/showTranslationDialog.dart';

void showTranslationDialogFun(BuildContext context, VideoPlayerViewModel model,
    String translate, String word) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShowTranslationDialog(
          translate: translate, model: model, word: word);
    },
  );
}

void showSubtitleDownloadDialog(
    BuildContext context, VideoPlayerViewModel model) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SubtitleDownloadDialog(model: model);
    },
  );
}
