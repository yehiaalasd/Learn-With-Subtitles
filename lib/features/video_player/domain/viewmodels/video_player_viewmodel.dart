import 'package:auto_orientation/auto_orientation.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class VideoPlayerViewModel extends ChangeNotifier {
  VideoPlayerViewModel(List<String> videoPaths, int initialIndex,
      BuildContext context, this.model) {
    _currentIndex = initialIndex;
    _videoPaths = videoPaths;
    model = Provider.of<KnownWordsModel>(context, listen: true);
    _initializeSubtitleViewModel(initialIndex);
    _initializeController(context);
    AutoOrientation.landscapeAutoMode(forceSensor: true);
    notifyListeners();
  }

  late KnownWordsModel model;
  List<SubtitleViewModel> subtitleViewModel = [];
  late VideoPlayerController _controller;
  bool _isLeftSide = true;

  bool get isLeftSide => _isLeftSide;
  double _brightness = 1.0; // 1.0 is normal brightness
  final bool _canRotation = true;
  int _currentIndex = 0;
  double _volume = 0.5;
  final Duration _currentPosition = Duration.zero;
  String _durationText = '';
  bool _isIconLock = false;
  bool _isLandscape = true;
  bool _isScreenLocked = false;
  bool _isSpeedUp = false;
  bool _showBrightnessProgress = false;
  bool _showControls = false;
  bool _showDuration = false;
  bool _showFastForwardIcon = false;
  bool _showVolume = false;
  Timer? _hideTimer;
  Future<void>? _initializeVideoPlayerFuture;

  List<String> _videoPaths = [];

  @override
  void dispose() {
    saveLastPosition();
    _controller.dispose();
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge); // Restore system UI on exit
    super.dispose();
  }

  VideoPlayerController get controller => _controller;
  List<String> get videoPaths => _videoPaths;
  Future<void>? get initializeVideoPlayerFuture => _initializeVideoPlayerFuture;
  OverlayEntry? _overlayEntry;
  bool get showBrightnessProgress => _showBrightnessProgress;
  bool get showControls => _showControls;
  bool get showVolume => _showVolume;
  bool get canRotation => _canRotation;
  bool get isLandscape => _isLandscape;
  bool get isScreenLocked => _isScreenLocked;
  double get brightness => _brightness;
  String get durationText => _durationText;
  bool get isIconLock => _isIconLock;
  Duration get currentPosition => _currentPosition;
  int get currentIndex => _currentIndex;
  bool get showDuration => _showDuration;
  bool get isSpeedUp => _isSpeedUp;
  double get volume => _volume;

  // Getter for showFastForwardIcon
  bool get showFastForwardIcon => _showFastForwardIcon;
  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  void toggleRotation() {
    notifyListeners();
  }

  void toggleLandscape() {
    _isLandscape = !_isLandscape;
    _isLandscape
        ? AutoOrientation.landscapeAutoMode()
        : AutoOrientation.portraitAutoMode();
    notifyListeners();
  }

  void adjustBrightness(double delta) {
    _brightness = (_brightness + (delta / 100)).clamp(0.0, 1.0);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(_brightness),
    ));
    notifyListeners();
  }

  void pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['srt']);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (result != null && result.files.isNotEmpty) {
      String? originalPath = result.files.first.path;
      if (originalPath != null && await File(originalPath).exists()) {
        var sub = _getCurrentSubtitleViewModel();
        sub.setSubtitlePath(originalPath);
        await prefs.setString(_videoPaths[_currentIndex], originalPath);
        _initializeController(context);
        notifyListeners();
      }
    } else {
      _initializeController(context);
    }
  }

  void hidVolumeIndicator() {
    _showVolume = false; // Hide the volume indicator
    _showBrightnessProgress =
        false; // Also hide the brightness progress indicator
    notifyListeners(); // Notify listeners to update the UI
  }

  void hideSpeedUpWidget() {
    _isSpeedUp = false;
    _controller.setPlaybackSpeed(1.0);
    notifyListeners();
  }

  void lockScreen() {
    _isScreenLocked = true;
    _showControls = false;
    notifyListeners();
  }

  void unlockScreen() {
    _isScreenLocked = false;
    toggleControls();
    notifyListeners();
  }

  void showIconLock() {
    _isIconLock = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      _isIconLock = false;
      notifyListeners();
    });
  }

  void showSpeedUpWidget() {
    _isSpeedUp = true;
    notifyListeners();
  }

  void toggleControls() {
    _showControls = !_showControls;
    if (_showControls) _startHideTimer();
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

  void skipForward() {
    _seekToPosition(5);
  }

  void skipBackward() {
    _seekToPosition(-5);
  }

  void nextVideo(BuildContext context) {
    if (_currentIndex < _videoPaths.length - 1) {
      _currentIndex++;
      _initializeSubtitleViewModel(_currentIndex);
      _changeVideo(context);
    }
  }

  void _changeVideo(BuildContext context) {
    toggleControls();
    _controller.dispose(); // Dispose of the current controller
    _initializeController(
        context); // Reinitialize the controller for the new video
    notifyListeners(); // Notify listeners of the change
  }

  void previousVideo(BuildContext context) {
    if (_currentIndex > 0) {
      _currentIndex--;
      _initializeSubtitleViewModel(_currentIndex);
      _changeVideo(context);
    }
  }

  void adjustVolume(double adjustment) {
    _volume = (_volume + adjustment).clamp(0.0, 1.0);
    _controller.setVolume(_volume);
    notifyListeners();
  }

  void showDurationText() {
    _showDuration = true;
    _durationText = '';
    _hideSubtitle(false);
  }

  void hideDurationText() {
    _showDuration = false;
    _durationText = '';
    _showSubtitle(false);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      _showVolume = false;
      _showBrightnessProgress = true;
      adjustBrightness(details.delta.dy);
    } else {
      _showBrightnessProgress = false;
      _showVolume = true;
      adjustVolume(-details.delta.dy / 1000);
    }
    notifyListeners();
  }

  void onHorizontalDragUpdate(double delta) {
    final position = _controller.value.position +
        Duration(milliseconds: (delta * 100).toInt());
    _controller.seekTo(position);
    _durationText = formatDuration(position);
    notifyListeners();
  }

  void onLongPressDown() {
    controller.setPlaybackSpeed(2.0);
    notifyListeners();
  }

  void handleDoubleTap(double dx, BuildContext context) {
    if (dx < MediaQuery.of(context).size.width / 2) {
      skipBackward();
      showFastForwardFeedback(true);
    } else {
      skipForward();
      showFastForwardFeedback(false);
    }
    notifyListeners();
  }

  void showFastForwardFeedback(bool isLeftSide) {
    _showFastForwardIcon = true;
    _isLeftSide = isLeftSide;
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      _showFastForwardIcon = false;
      notifyListeners();
    });
  }

  Future<int> loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_videoPaths[_currentIndex]}position') ?? 0;
  }

  Future<void> saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentPosition = _controller.value.position.inMilliseconds;
    await prefs.setInt(
        '${_videoPaths[_currentIndex]}position', currentPosition);
  }

  Future<void> _initializeController(BuildContext context) async {
    _controller = VideoPlayerController.file(File(_videoPaths[_currentIndex]));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack,
          overlays: [SystemUiOverlay.top]);
      await loadSubtitles();
      await _seekToLastPosition();
      _controller.setLooping(true);
      _controller.setVolume(_volume);
      notifyListeners();
    });
    var subtitleVM = _getCurrentSubtitleViewModel();
    _controller.addListener(() {
      if (controller.value.isInitialized) {
        subtitleVM.updateSubtitle(_controller);
        notifyListeners();
      }
      _updateOverlay(context);
    });
  }

  void _updateOverlay(BuildContext context) {
    if (showControls) {
      _showOverlay(context);
    } else {
      _hideOverlay();
    }
    // Notify listeners to trigger UI rebuild
    notifyListeners();
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null && !_overlayEntry!.mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> loadSubtitles() async {
    var subtitleVM = _getCurrentSubtitleViewModel();
    subtitleVM.loadIsVisibleSubtitle();
    subtitleVM.getSubtitles(model);
  }

  Future<void> listStreams(String videoPath) async {
    await FFmpegKit.execute('-i "$videoPath" -hide_banner -show_streams')
        .then((session) async {
      final allLogs = await session.getAllLogsAsString();
      print('Streams Info video: $allLogs');
    });
  }

  Future<void> extractSubtitles(String videoPath) async {
    // listStreams(videoPath);
    // // Define the output SRT file path
    // String outputPath = videoPath.replaceAll(RegExp(r'\.[a-zA-Z]+$'), '.srt');

    // // List streams to find the correct subtitle stream index
    // await FFmpegKit.execute(
    //         '-i "$videoPath" -show_streams -of default=noprint_wrappers=1')
    //     .then((session) async {
    //   final allLogs = await session.getAllLogsAsString();
    //   print('Streams Info: $allLogs');

    //   // Adjust this index based on stream info from logs
    //   String command = '-i "$videoPath" -map 0:s:0 "$outputPath"';

    //   await FFmpegKit.execute(command).then((session) async {
    //     final returnCode = await session.getReturnCode();
    //     if (ReturnCode.isSuccess(returnCode)) {
    //       print('Subtitles extracted successfully to $outputPath');
    //     } else {
    //       print('Failed to extract subtitles');
    //       final allLogs = await session.getAllLogsAsString();
    //       print('Logs: $allLogs');
    //     }
    //   });
    // });

    String command = '-i $videoPath';

    // Execute the command
    final session = await FFmpegKit.execute(command);

    // Get the output
    final log = await session.getOutput();

    // Check if there are subtitle streams
    if (log!.contains('Stream #')) {
      RegExp regex = RegExp(r'Stream #\d+:\d+.+Subtitle');
      Iterable<RegExpMatch> matches = regex.allMatches(log);

      if (matches.isNotEmpty) {
        print('Embedded subtitles found:');
        for (var match in matches) {
          print(match.group(0));
        }
      } else {
        print('No embedded subtitles found in the video.');
      }
    } else {
      print('Unable to read video information $videoPath');
    }
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      if (log.contains('Stream #')) {
        // Process log for subtitles...
      } else {
        print('No streams found in the video.');
      }
    } else {
      print('Error vid: ${returnCode?.getValue()}');
      print('Log: $log');
    }
  }

  Future<void> _seekToLastPosition() async {
    int lastPosition = await loadLastPosition();
    _controller.seekTo(Duration(milliseconds: lastPosition));
    _controller.play(); // Start playing after seeking
  }

  void _initializeSubtitleViewModel(int index) {
    var subtitleVM = SubtitleViewModel(_videoPaths[index], index);
    subtitleViewModel.add(subtitleVM);
    loadSubtitles().then((_) => notifyListeners());
  }

  void _updateSubtitle() {
    var subtitleVM = _getCurrentSubtitleViewModel();
    subtitleVM.updateSubtitle(_controller);
  }

  void setVolume(double volume) {
    controller.setVolume(volume);
    notifyListeners(); // Notify listeners if you have UI elements that depend on the volume
  }

  SubtitleViewModel _getCurrentSubtitleViewModel() {
    return subtitleViewModel
        .firstWhere((data) => data.indexOfVide == _currentIndex);
  }

  void hideControls() {
    _showControls = false;
  }

  void _seekToPosition(int seconds) {
    final newPosition = _controller.value.position.inSeconds + seconds;
    _controller.seekTo(Duration(seconds: newPosition));
    notifyListeners();
  }

  void _hideSubtitle(bool isPermenant) {
    if (isPermenant) {
      _getCurrentSubtitleViewModel().hideSubtitlePermanent();
    } else {
      _getCurrentSubtitleViewModel().hideSubtitleTemporary();
    }
    notifyListeners();
  }

  void _showSubtitle(bool isPermenant) {
    if (isPermenant) {
      _getCurrentSubtitleViewModel().showSubtitlePermanent();
    } else {
      _getCurrentSubtitleViewModel().showSubtitleTemporary();
    }
    notifyListeners();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _toggleSystemUI();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      _showControls = false;
      notifyListeners();
    });
  }

  void _toggleSystemUI() {
    _showControls
        ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.top])
        : _hideSystemUI();
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }
}
