import 'dart:io';
import 'package:mxplayer/features/video_player/domain/repositories/video_repository.dart';
import 'package:video_player/video_player.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoPlayerController? _controller;

  @override
  Future<void> loadVideo(String path) async {
    _controller = VideoPlayerController.file(File(path));
    await _controller?.initialize();
    _controller?.setLooping(true);
  }

  @override
  Future<void> playVideo() async {
    if (_controller?.value.isInitialized == true) {
      await _controller?.play();
    } else {
      print('Error: Video is not initialized.');
    }
  }

  @override
  Future<void> adjustVolume(double volume) async {
    if (_controller?.value.isInitialized == true) {
      _controller?.setVolume(volume.clamp(0.0, 1.0));
    } else {
      print('Error: Video is not initialized.');
    }
  }

  // Additional methods to clean up resources
  void dispose() {
    _controller?.dispose();
  }
}
