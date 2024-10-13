import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildWordButtons.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/showTranslationDialog.dart';
import 'package:provider/provider.dart';

Positioned buildSubtitleText(VideoPlayerModel model, BuildContext context) {
  final provider = Provider.of<KnownWordsModel>(context, listen: false);

  return Positioned(
    left: model.subtitleOffset.dx,
    right: 0,
    top: MediaQuery.of(context).size.height / 2 + model.subtitleOffset.dy,
    child: GestureDetector(
      onDoubleTap: () {
        model.showOriginalSubtitle();
      },
      onPanUpdate: (details) {
        model.onSubtitleDragUpdate(details);
      },
      child: Column(
        children: [
          WordButtons(
            model: model,
            provider: provider,
          ),
          const SizedBox(height: 10),
          IconButton(
            onPressed: () {
              model.showOriginalSubtitle();
            },
            icon: Icon(
              model.isShowOriginalSubtitle
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
