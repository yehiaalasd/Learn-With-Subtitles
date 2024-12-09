import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/presentation/viewmodels/gesture_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class GestureWidget extends StatelessWidget {
  const GestureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gestureModel = Provider.of<GestureModel>(context, listen: true);
    final subModel = Provider.of<SubtitleManger>(context, listen: false);
    bool isScreenLocked() => gestureModel.isScreenLocked;
    return GestureDetector(
        onLongPress: () {
          if (!isScreenLocked()) {
            gestureModel.showSpeedUpWidget();
            gestureModel.onLongPressDown();
          }
        },
        onLongPressCancel: () =>
            _hideSpeedUpWidget(isScreenLocked(), gestureModel),
        onLongPressEnd: (_) =>
            _hideSpeedUpWidget(isScreenLocked(), gestureModel),
        onLongPressUp: () => _hideSpeedUpWidget(isScreenLocked(), gestureModel),
        onTap: () {
          if (!isScreenLocked()) {
            gestureModel.toggleControls();
          } else {
            gestureModel.showIconLock();
          }
        },
        onHorizontalDragStart: (detail) {
          if (!isScreenLocked()) {
            gestureModel.showDurationText();
          }
        },
        onHorizontalDragUpdate: (details) {
          if (!isScreenLocked()) {
            gestureModel.onHorizontalDragUpdate(details.delta.dx);
          }
        },
        onHorizontalDragCancel: () =>
            _hideDurationText(isScreenLocked(), gestureModel),
        onHorizontalDragEnd: (_) =>
            _hideDurationText(isScreenLocked(), gestureModel),
        onDoubleTapDown: (details) {
          if (!isScreenLocked()) {
            gestureModel.handleDoubleTap(details.globalPosition.dx, context);
          }
        },
        onVerticalDragStart: (details) {
          if (!isScreenLocked()) {
            subModel.setSubtitleOff();
          }
        },
        onVerticalDragEnd: (details) {
          if (!isScreenLocked()) {
            subModel.setSubtitleOn();
            gestureModel.hidVolumeIndicator();
          }
        },
        onVerticalDragUpdate: (details) {
          gestureModel.onVerticalDragUpdate(details, context);
          subModel.setSubtitleOff();
        },
        onVerticalDragCancel: () {
          if (!isScreenLocked()) {
            gestureModel.hidVolumeIndicator();
            subModel.setSubtitleOn();
          }
        },
        child: Consumer<VideoPlayerViewModel>(builder: (context, model, child) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: FittedBox(
              fit: model.isLandscape ? BoxFit.fill : BoxFit.contain,
              child: SizedBox(
                height: model.controller.value.size.height,
                width: model.controller.value.size.width,
                child: VideoPlayer(model.controller),
              ),
            ),
          );
          //  Center(
          //   child:
          //    AspectRatio(
          //     aspectRatio:
          //         MediaQuery.of(context).orientation == Orientation.portrait
          //             ? 16 / 9 // Square aspect ratio for portrait
          //             : model.controller.value.aspectRatio,
          //     child: VideoPlayer(model.controller),
          //   ),
          // );
        }));
  }

  void _hideSpeedUpWidget(bool isLocked, GestureModel model) {
    if (!isLocked) {
      model.hideSpeedUpWidget();
    }
  }

  void _hideDurationText(bool isLocked, GestureModel model) {
    if (!isLocked) {
      model.hideDurationText();
    }
  }
}
