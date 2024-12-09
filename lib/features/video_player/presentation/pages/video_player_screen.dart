// import 'package:flutter/material.dart';
// import 'package:mxplayer/core.dart';
// import 'package:mxplayer/features/video_player/presentation/widgets/buildAppBar.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final List<String> videoPaths;
//   final int initialIndex;

//   const VideoPlayerScreen({
//     super.key,
//     required this.videoPaths,
//     required this.initialIndex,
//   });

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final submodel = Provider.of<SubtitleViewModel>(context, listen: true);
//     final knownModel = Provider.of<KnownWordsModel>(context);

//     return ChangeNotifierProvider(
//       create: (_) => VideoPlayerViewModel(
//         widget.videoPaths,
//         widget.initialIndex,
//         context,
//         submodel,
//         knownModel,
//       ),
//       child: Consumer<VideoPlayerViewModel>(
//         builder: (context, model, child) {
//           return WillPopScope(
//             onWillPop: () async {
//               model.saveLastPosition();
//               Navigator.pop(context);
//               return true; // Allow pop
//             },
//             child: Scaffold(
//               backgroundColor: Colors.black,
//               body: FutureBuilder(
//                 future: model.initializeVideoPlayerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     }

//                     return Stack(
//                       children: [
//                         GestureDetector(
//                           onLongPress: () {
//                             if (!model.isScreenLocked) {
//                               model.showSpeedUpWidget();
//                               model.onLongPressDown();
//                             }
//                           },
//                           onLongPressCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onLongPressEnd: (_) {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onLongPressUp: () {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onTap: () {
//                             if (!model.isScreenLocked) {
//                               setState(() {
//                                 model.toggleControls();
//                               });
//                             } else {
//                               model.showIconLock();
//                             }
//                           },
//                           onHorizontalDragStart: (detail) {
//                             if (!model.isScreenLocked) {
//                               model.showDurationText();
//                             }
//                           },
//                           onHorizontalDragUpdate: (details) {
//                             if (!model.isScreenLocked) {
//                               model.onHorizontalDragUpdate(details.delta.dx);
//                             }
//                           },
//                           onHorizontalDragCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.hideDurationText();
//                             }
//                           },
//                           onHorizontalDragEnd: (_) {
//                             if (!model.isScreenLocked) {
//                               model.hideDurationText();
//                             }
//                           },
//                           onVerticalDragUpdate: (details) {
//                             if (!model.isScreenLocked) {
//                               final isLandscape =
//                                   MediaQuery.of(context).orientation ==
//                                       Orientation.landscape;
//                               model.onVerticalDragUpdate(details, isLandscape);
//                             }
//                           },
//                           onDoubleTapDown: (details) {
//                             if (!model.isScreenLocked) {
//                               model.handleDoubleTap(
//                                   details.globalPosition.dx, model, context);
//                             }
//                           },
//                           onVerticalDragStart: (details) {
//                             if (!model.isScreenLocked) {
//                               model.controller.pause();
//                               model.subtitleViewModel.hideSubtitleTemporary();
//                             }
//                           },
//                           onVerticalDragEnd: (details) {
//                             if (!model.isScreenLocked) {
//                               model.controller.play();
//                               model.subtitleViewModel.showSubtitleTemporary();
//                               model.hidVolumeIndicator();
//                             }
//                           },
//                           onVerticalDragCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.controller.play();
//                               model.hidVolumeIndicator();
//                               model.subtitleViewModel.showSubtitleTemporary();
//                             }
//                           },
//                           child: Stack(
//                             children: [
//                               Center(
//                                 child: AspectRatio(
//                                     aspectRatio: MediaQuery.of(context)
//                                                 .orientation ==
//                                             Orientation.portrait
//                                         ? 1 // Square aspect ratio for portrait
//                                         : model.controller.value.aspectRatio,
//                                     child: VideoPlayer(model.controller)),
//                               ),
//                               if (model.isIconLock) IconLock(model: model),
//                               if (model.showControls)
//                                 ControlOverlay(
//                                   model: model,
//                                 ),
//                               if (model.showDuration)
//                                 DurationText(model: model),
//                               if (model.showFastForwardIcon)
//                                 FastForwardIcon(isLeftSide: model.isLeftSide),
//                               if (model.showControls)
//                                 AppBarWidget(
//                                   model: model,
//                                   videoPaths: widget.videoPaths,
//                                 ),
//                               if (model.showControls)
//                                 BuildFloatingButtonIcons(model: model),
//                             ],
//                           ),
//                         ),
//                         if (model
//                                 .subtitleViewModel.isSubtitleVisibleTemporary &&
//                             model.subtitleViewModel.isShowSubtitlePermenant)
//                           ChangeNotifierProvider(
//                             create: (_) => model.subtitleViewModel,
//                             child: Consumer<SubtitleViewModel>(
//                               builder: (context, subModel, child) {
//                                 return WillPopScope(
//                                     onWillPop: () async {
//                                       model.saveLastPosition();
//                                       Navigator.pop(context);
//                                       return true; // Allow pop
//                                     },
//                                     child: FutureBuilder(
//                                         future: subModel.getSubtitles(model
//                                             .videoPaths[model.currentIndex]),
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.done) {
//                                             if (snapshot.hasError) {
//                                               return Center(
//                                                   child: Text(
//                                                       'Error: ${snapshot.error}'));
//                                             } else {
//                                               return SubtitleText(model: model);
//                                             }
//                                           } else {
//                                             return SizedBox();
//                                           }
//                                         }));
//                               },
//                             ),
//                           ),
//                         if (model.showVolume) VolumeIndicator(model: model),
//                         if (model.showBrightnessProgress)
//                           BrightnessIndicator(
//                             model: model,
//                           ),
//                         if (model.isSpeedUp) const SpeedUpWidget(),
//                       ],
//                     );
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:mxplayer/core.dart';
// import 'package:mxplayer/features/video_player/presentation/widgets/buildAppBar.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final List<String> videoPaths;
//   final int initialIndex;

//   const VideoPlayerScreen({
//     super.key,
//     required this.videoPaths,
//     required this.initialIndex,
//   });

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final knownModel = Provider.of<KnownWordsModel>(context);

//     return ChangeNotifierProvider(
//       create: (_) => VideoPlayerViewModel(
//         widget.videoPaths,
//         widget.initialIndex,
//         context,
//         knownModel,
//       ),
//       child: Consumer<VideoPlayerViewModel>(
//         builder: (context, model, child) {
//           return WillPopScope(
//             onWillPop: () async {
//               model.saveLastPosition();
//               Navigator.pop(context);
//               return true; // Allow pop
//             },
//             child: Scaffold(
//               backgroundColor: Colors.black,
//               body: FutureBuilder(
//                 future: model.initializeVideoPlayerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     }

//                     return Stack(
//                       children: [
//                         GestureDetector(
//                           onLongPress: () {
//                             if (!model.isScreenLocked) {
//                               model.showSpeedUpWidget();
//                               model.onLongPressDown();
//                             }
//                           },
//                           onLongPressCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onLongPressEnd: (_) {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onLongPressUp: () {
//                             if (!model.isScreenLocked) {
//                               model.hideSpeedUpWidget();
//                             }
//                           },
//                           onTap: () {
//                             if (!model.isScreenLocked) {
//                               setState(() {
//                                 model.toggleControls();
//                               });
//                             } else {
//                               model.showIconLock();
//                             }
//                           },
//                           onHorizontalDragStart: (detail) {
//                             if (!model.isScreenLocked) {
//                               model.showDurationText();
//                             }
//                           },
//                           onHorizontalDragUpdate: (details) {
//                             if (!model.isScreenLocked) {
//                               model.onHorizontalDragUpdate(details.delta.dx);
//                             }
//                           },
//                           onHorizontalDragCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.hideDurationText();
//                             }
//                           },
//                           onHorizontalDragEnd: (_) {
//                             if (!model.isScreenLocked) {
//                               model.hideDurationText();
//                             }
//                           },
//                           onVerticalDragUpdate: (details) {
//                             if (!model.isScreenLocked) {
//                               final isLandscape =
//                                   MediaQuery.of(context).orientation ==
//                                       Orientation.landscape;
//                               model.onVerticalDragUpdate(details);
//                             }
//                           },
//                           onDoubleTapDown: (details) {
//                             if (!model.isScreenLocked) {
//                               model.handleDoubleTap(
//                                   details.globalPosition.dx,  context);
//                             }
//                           },
//                           onVerticalDragStart: (details) {
//                             if (!model.isScreenLocked) {
//                               model.controller.pause();
//                               model.subtitleViewModel
//                                   .where((data) =>
//                                       data.indexOfVide == model.currentIndex)
//                                   .toList()
//                                   .first
//                                   .hideSubtitleTemporary();
//                             }
//                           },
//                           onVerticalDragEnd: (details) {
//                             if (!model.isScreenLocked) {
//                               model.controller.play();
//                               model.subtitleViewModel
//                                   .where((data) =>
//                                       data.indexOfVide == model.currentIndex)
//                                   .toList()
//                                   .first
//                                   .showSubtitleTemporary();
//                               model.hidVolumeIndicator();
//                             }
//                           },
//                           onVerticalDragCancel: () {
//                             if (!model.isScreenLocked) {
//                               model.controller.play();
//                               model.hidVolumeIndicator();
//                               model.subtitleViewModel
//                                   .where((data) =>
//                                       data.indexOfVide == model.currentIndex)
//                                   .toList()
//                                   .first
//                                   .showSubtitleTemporary();
//                             }
//                           },
//                           child: Stack(
//                             children: [
//                               Center(
//                                 child: AspectRatio(
//                                   aspectRatio: MediaQuery.of(context)
//                                               .orientation ==
//                                           Orientation.portrait
//                                       ? 1 // Square aspect ratio for portrait
//                                       : model.controller.value.aspectRatio,
//                                   child: VideoPlayer(model.controller),
//                                 ),
//                               ),
//                               if (model.isIconLock) IconLock(model: model),
//                               if (model.showControls)
//                                 ControlOverlay(
//                                   model: model,
//                                 ),
//                               if (model.showDuration)
//                                 DurationText(model: model),
//                               if (model.showFastForwardIcon)
//                                 FastForwardIcon(isLeftSide: model.isLeftSide),
//                               if (model.showControls)
//                                 AppBarWidget(
//                                   model: model,
//                                   videoPaths: widget.videoPaths,
//                                 ),
//                               if (model.showControls)
//                                 BuildFloatingButtonIcons(model: model),
//                             ],
//                           ),
//                         ),
//                         if (model.subtitleViewModel
//                                 .where((data) =>
//                                     data.indexOfVide == model.currentIndex)
//                                 .toList()
//                                 .first
//                                 .isSubtitleVisibleTemporary &&
//                             model.subtitleViewModel
//                                 .where((data) =>
//                                     data.indexOfVide == model.currentIndex)
//                                 .toList()
//                                 .first
//                                 .isShowSubtitlePermenant)
//                           SubtitleText(model: model),
//                         if (model.showVolume) VolumeIndicator(model: model),
//                         if (model.showBrightnessProgress)
//                           BrightnessIndicator(
//                             model: model,
//                           ),
//                         if (model.isSpeedUp) const SpeedUpWidget(),
//                       ],
//                     );
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/buildAppBar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> videoPaths;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videoPaths,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final knownModel = Provider.of<KnownWordsModel>(context);

    return ChangeNotifierProvider(
      create: (_) => VideoPlayerViewModel(
        widget.videoPaths,
        widget.initialIndex,
        context,
        knownModel,
      ),
      child: Consumer<VideoPlayerViewModel>(builder: (context, model, child) {
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
                      if (!model.isScreenLocked)
                        GestureDetector(
                          onLongPress: () {
                            if (!model.isScreenLocked) {
                              model.showSpeedUpWidget();
                              model.onLongPressDown();
                            }
                          },
                          onLongPressCancel: () {
                            if (!model.isScreenLocked) {
                              model.hideSpeedUpWidget();
                            }
                          },
                          onLongPressEnd: (_) {
                            if (!model.isScreenLocked) {
                              model.hideSpeedUpWidget();
                            }
                          },
                          onLongPressUp: () {
                            if (!model.isScreenLocked) {
                              model.hideSpeedUpWidget();
                            }
                          },
                          onTap: () {
                            if (!model.isScreenLocked) {
                              setState(() {
                                model.toggleControls();
                              });
                            } else {
                              model.showIconLock();
                            }
                          },
                          onHorizontalDragStart: (detail) {
                            if (!model.isScreenLocked) {
                              model.showDurationText();
                            }
                          },
                          onHorizontalDragUpdate: (details) {
                            if (!model.isScreenLocked) {
                              model.onHorizontalDragUpdate(details.delta.dx);
                            }
                          },
                          onHorizontalDragCancel: () {
                            if (!model.isScreenLocked) {
                              model.hideDurationText();
                            }
                          },
                          onHorizontalDragEnd: (_) {
                            if (!model.isScreenLocked) {
                              model.hideDurationText();
                            }
                          },
                          onVerticalDragUpdate: (details) {
                            if (!model.isScreenLocked) {
                              final isLandscape =
                                  MediaQuery.of(context).orientation ==
                                      Orientation.landscape;
                              model.onVerticalDragUpdate(
                                details,
                              );
                            }
                          },
                          onDoubleTapDown: (details) {
                            if (!model.isScreenLocked) {
                              model.handleDoubleTap(
                                  details.globalPosition.dx, context);
                            }
                          },
                          onVerticalDragStart: (details) {
                            if (!model.isScreenLocked) {
                              model.controller.pause();
                              model.subtitleViewModel
                                  .where((data) =>
                                      data.indexOfVide == model.currentIndex)
                                  .first
                                  .hideSubtitleTemporary();
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (!model.isScreenLocked) {
                              model.controller.play();
                              model.subtitleViewModel
                                  .where((data) =>
                                      data.indexOfVide == model.currentIndex)
                                  .first
                                  .showSubtitleTemporary();
                              model.hidVolumeIndicator();
                            }
                          },
                          onVerticalDragCancel: () {
                            if (!model.isScreenLocked) {
                              model.controller.play();
                              model.hidVolumeIndicator();
                              model.subtitleViewModel
                                  .where((data) =>
                                      data.indexOfVide == model.currentIndex)
                                  .first
                                  .showSubtitleTemporary();
                            }
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: MediaQuery.of(context)
                                              .orientation ==
                                          Orientation.portrait
                                      ? 1 // Square aspect ratio for portrait
                                      : model.controller.value.aspectRatio,
                                  child: VideoPlayer(model.controller),
                                ),
                              ),
                              if (model.isIconLock) IconLock(model: model),
                              if (model.showControls)
                                ControlOverlay(model: model),
                              if (model.showDuration)
                                DurationText(model: model),
                              if (model.showFastForwardIcon)
                                FastForwardIcon(isLeftSide: model.isLeftSide),
                              if (model.showControls)
                                AppBarWidget(
                                    model: model,
                                    videoPaths: widget.videoPaths),
                              // if (model.showControls)
                              //   BuildFloatingButtonIcons(model: model),
                            ],
                          ),
                        ),
                      if (model.subtitleViewModel
                              .where((data) =>
                                  data.indexOfVide == model.currentIndex)
                              .first
                              .isSubtitleVisibleTemporary &&
                          model.subtitleViewModel
                              .where((data) =>
                                  data.indexOfVide == model.currentIndex)
                              .first
                              .isShowSubtitlePermenant)
                        SubtitleText(model: model),
                      if (model.showVolume) VolumeIndicator(model: model),
                      if (model.showBrightnessProgress)
                        BrightnessIndicator(model: model),
                      if (model.isSpeedUp) const SpeedUpWidget(),
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
