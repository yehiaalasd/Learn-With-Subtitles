import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/data/model/video_with_subtitles_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

class VideoPlayerViewModel extends ChangeNotifier {
  VideoPlayerViewModel(List<Video> videoPaths, int initialIndex,
      BuildContext context, this.model) {
    _currentIndex = initialIndex;
    _videos = videoPaths;

    model = Provider.of<KnownWordsModel>(context, listen: false);
    _initializeController(context);
    AutoOrientation.landscapeAutoMode(forceSensor: true);
    currentSubtitle = VideoWithSubtitlesModel(
        videoPath: videoPaths[initialIndex].path,
        context: context,
        model: model);
    VideoRepositoryImpl().saveLastVideo(videoPaths[initialIndex].path);
    notifyListeners();
  }
  late KnownWordsModel model;
  late VideoWithSubtitlesModel currentSubtitle;
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  List<Video> _videos = [];
  final bool _canRotation = true;
  int _currentIndex = 0;
  bool _isLandscape = true;
  VideoPlayerController get controller => _controller;
  List<Video> get video => _videos;
  Future<void>? get initializeVideoPlayerFuture => _initializeVideoPlayerFuture;
  bool get canRotation => _canRotation;
  bool get isLandscape => _isLandscape;
  int get currentIndex => _currentIndex;

  @override
  void dispose() {
    VideoRepositoryImpl()
        .saveLastPosition(_controller, video[currentIndex].path);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge); // Restore system UI on exit
    super.dispose();
  }

  void nextVideo(BuildContext context) {
    if (_currentIndex < _videos.length - 1) {
      _currentIndex++;
      _changeVideo(context);
    }
  }

  void _changeVideo(BuildContext context) {
    _controller.dispose(); // Dispose of the current controller
    _initializeController(context);
    currentSubtitle = VideoWithSubtitlesModel(
        videoPath: _videos[_currentIndex].path, context: context, model: model);
            VideoRepositoryImpl().saveLastVideo(_videos[_currentIndex].path);

    notifyListeners(); // Notify listeners of the change
  }

  void previousVideo(BuildContext context) {
    if (_currentIndex > 0) {
      _currentIndex--;
      _changeVideo(context);
    }
  }

  void toggleLandscape() {
    _isLandscape = !_isLandscape;
    _isLandscape
        ? AutoOrientation.landscapeAutoMode()
        : AutoOrientation.portraitAutoMode();
    notifyListeners();
  }

  Future<void> playPause() async {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      if (!controller.value.isInitialized) {
        await controller.initialize();
      }
      controller.play();
    }
    notifyListeners();
  }

  void pickFile(BuildContext context) async {
    await SubtitleRepositoryImpl().pickFile(context, currentSubtitle);
  }

  Future<void> _initializeController(BuildContext context) async {
    if (_videos.isNotEmpty) {
      _controller = VideoPlayerController.file(
          File(_videos[_currentIndex].path),
          videoPlayerOptions:
              VideoPlayerOptions(allowBackgroundPlayback: true));
      _initializeVideoPlayerFuture = _controller.initialize().then((_) async {
        await _seekToLastPosition();
        _controller.videoPlayerOptions!.allowBackgroundPlayback;
        _controller.value.caption.end;
        _controller.setLooping(true);
        _controller.setVolume(1.0);
        notifyListeners();
      });
    }
  }

  Future<void> _seekToLastPosition() async {
    int lastPosition =
        await VideoRepositoryImpl().loadLastPosition(video[_currentIndex].path);
    _controller.seekTo(Duration(milliseconds: lastPosition));
    _controller.play(); // Start playing after seeking
  }
}
