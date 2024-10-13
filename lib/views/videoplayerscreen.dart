import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildControlOverlay.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildDurationText.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildFastForwardIcon.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildFloatingButtonsControlls.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildSpeedUpWidget.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildSubtitleText.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildVolumeIndicator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> videoPaths;
  final int initialIndex;

  const VideoPlayerScreen({
    required this.videoPaths,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VideoPlayerModel(widget.videoPaths, widget.initialIndex, context),
      child: Consumer<VideoPlayerModel>(builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            model.saveLastPosition();
            Navigator.pop(context);
            return true; // Allow pop
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: FutureBuilder(
              future: model.initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return Stack(
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          model.showSpeedUpWidget();
                          model.onLongPressDown();
                        },
                        onLongPressCancel: model.hideSpeedUpWidget,
                        onLongPressEnd: (_) => model.hideSpeedUpWidget(),
                        onLongPressUp: model.hideSpeedUpWidget,
                        onTap: model.toggleControls,
                        onHorizontalDragStart: (detail) {
                          model.showDurationText();
                        },
                        onHorizontalDragUpdate: (details) =>
                            model.onHorizontalDragUpdate(details.delta.dx),
                        onHorizontalDragCancel: model.hideDurationText,
                        onHorizontalDragEnd: (_) => model.hideDurationText(),
                        onVerticalDragUpdate: (details) {
                          final isLandscape =
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape;
                          model.onVerticalDragUpdate(details, isLandscape);
                        },
                        onDoubleTapDown: (details) {
                          model.handleDoubleTap(
                              details.globalPosition.dx, model, context);
                        },
                        onVerticalDragStart: (details) {
                          model.controller.pause();
                          model.hideSubtitleTemporary();
                          // if (details.delta.dy.abs() > details.delta.dx.abs()) {
                          //                               model.showBrightness();
                          //                         } else {
                          //                           model.showVolumeIndicator();
                          //                         }
                        },
                        onVerticalDragEnd: (details) {
                          model.controller.play();
                          model.showSubtitleTemporary();
                          model.hidVolumeIndicator();
                        },
                        onVerticalDragCancel: () {
                          model.controller.play();
                          model.hidVolumeIndicator();
                          model.showSubtitleTemporary();
                        },
                        child: Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio:
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? 1 // Square aspect ratio for portrait
                                        : model.controller.value.aspectRatio,
                                child: VideoPlayer(model.controller),
                              ),
                            ),
                            if (model.showControls)
                              buildControlOverlay(
                                  model, widget.videoPaths, context),
                            if (model.showDuration)
                              buildDurationText(model, context),
                            if (model.showFastForwardIcon)
                              buildFastForwardIcon(model.isLeftSide),
                            if (model.showControls)
                              buildFloatingButtonsControl(
                                  model, widget.videoPaths, context),
                          ],
                        ),
                      ),
                      if (model.isSubtitleVisibleTemporary)
                        buildSubtitleText(model, context),
                      if (model.showVolume) buildVolumeIndicator(model),
                      if (model.showBrightnessProgress)
                        buildBrightnessIndicator(model),
                      if (model.isSpeedUp) buildSpeedUpWidget(context),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
