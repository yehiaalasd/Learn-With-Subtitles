import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'package:mxplayer/utils/subtitle.dart';
import 'package:mxplayer/utils/srt_parser.dart';
import 'package:mxplayer/utils/functions.dart';
import 'package:provider/provider.dart';

class VideoPlayerModel extends ChangeNotifier {
  VideoPlayerModel(
      List<String> videoPaths, int initialIndex, BuildContext context) {
    _currentIndex = initialIndex;
    _videoPaths = videoPaths;
    _initializeController(context);
    loadIsVisibleSubtitle();
    getSubtitles(videoPaths[_currentIndex], context);
    notifyListeners();
  }

  double _brightness = 1.0; // 1.0 is normal brightness
  late VideoPlayerController _controller;
  int _currentIndex = 0;
  late Duration _currentPosition;
  String _durationText = '';
  Timer? _hideTimer;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isLeftSide = true;
  bool _isShowSubtitle = true;
  bool _isShowedOriginalSubtitle = false;
  bool _isSpeedUp = false;
  bool _isSubtitleVisibleTemporary = true;
  List<Subtitle1> _removedSub = [];
  bool _showBrightnessProgress = false;
  bool _showControls = false;
  bool _showDuration = false;
  bool _showFastForwardIcon = false;
  bool _showSystemUI = false;
  bool _showVolume = false;
  Offset _subtitleOffset = const Offset(0, 50);
  String _subtitlePath = '';
  String _subtitleText = '';
  final List<Subtitle1> _subtitles = [];
  List<String> _videoPaths = [];
  double _volume = 0.5;

  @override
  void dispose() {
    saveLastPosition();
    _controller.removeListener(_updateSubtitle);
    _controller.dispose();
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge); // Restore system UI on exit
    super.dispose();
  }

  Future<void>? get initializeVideoPlayerFuture => _initializeVideoPlayerFuture;

  VideoPlayerController get controller => _controller;
  List<String> get videoPaths => _videoPaths;
  bool get showBrightnessProgress => _showBrightnessProgress;
  bool get showControls => _showControls;
  bool get showVolume => _showVolume;
  double get brightness => _brightness;
  bool get isShowSubtitle => _isShowSubtitle;
  Duration get currentPosition => _currentPosition;
  String get subtitleText => _subtitleText;
  String get durationText => _durationText;
  Offset get subtitleOffset => _subtitleOffset;
  List<Subtitle1> get removedSub => _removedSub;
  int get currentIndex => _currentIndex;
  bool get showDuration => _showDuration;
  bool get isLeftSide => _isLeftSide;
  bool get isSpeedUp => _isSpeedUp;
  String get subtitlePath => _subtitlePath;
  bool get showFastForwardIcon => _showFastForwardIcon;
  bool get isShowOriginalSubtitle => _isShowedOriginalSubtitle;
  double get volume => _volume;

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  void adjustBrightness(double delta) {
    _brightness = (_brightness + (delta / 100)).clamp(0.0, 1.0);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.black.withOpacity(_brightness), // Adjust as needed
    ));
    notifyListeners();
  }

  Future<bool> pickFile(BuildContext context) async {
    // Dispose of the current video player before picking a new file

    print('iam in pick file');
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (result != null && result.files.isNotEmpty) {
      String? originalPath = result.files.first.path;
      print(originalPath.toString() + ' path sub pick');

      if (originalPath != null) {
        File file = File(originalPath);
        print(file.path.toString() + ' done get path');

        if (await file.exists()) {
          print(file.path.toString() + ' i am in if ');

          _subtitlePath = originalPath;
          await prefs.setString(
              _videoPaths[_currentIndex], originalPath.toString());

          // Reinitialize the video player with the new file
          return true;
        } else {
          print('File does not exist at the path: $originalPath');
          return false;
        }
      }
    }
    return false;
  }

  void hideSpeedUpWidget() {
    _isSpeedUp = false;
    _controller.setPlaybackSpeed(1.0);
    notifyListeners();
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

  void playPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    notifyListeners();
  }

  void skipForward() {
    final newPosition = _controller.value.position + Duration(seconds: 5);
    _controller.seekTo(newPosition);
    notifyListeners();
  }

  void skipBackward() {
    final newPosition = _controller.value.position - Duration(seconds: 5);
    _controller.seekTo(newPosition);
    notifyListeners();
  }

  void nextVideo(BuildContext context) {
    if (_currentIndex < _videoPaths.length - 1) {
      _currentIndex++;
      _controller.dispose();
      _initializeController(context); // Pass context here
      notifyListeners();
    }
  }

  void previousVideo(BuildContext context) {
    if (_currentIndex > 0) {
      _currentIndex--;
      _controller.dispose();
      _initializeController(context); // Pass context here
      notifyListeners();
    }
  }

  void adjustVolume(double adjustment) {
    _volume = (_volume + adjustment).clamp(0.0, 1.0);
    _controller.setVolume(_volume);
    notifyListeners();
  }

  void diposeVideo() {
    _controller.removeListener(_updateSubtitle);
    _controller.dispose();
    dispose();
  }

  void showDurationText() {
    _showDuration = true;
    _durationText = '';
    hideSubtitleTemporary();
  }

  void hideDurationText() {
    _showDuration = false;
    _durationText = '';
    showSubtitleTemporary();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  // Subtitle part

  void loadIsVisibleSubtitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isShowSubtitle =
        prefs.getBool('is visible subtitle :${_videoPaths[currentIndex]}') ??
            true;
    notifyListeners();
  }

  void showOriginalSubtitle() {
    _isShowedOriginalSubtitle = !_isShowedOriginalSubtitle;
    notifyListeners();
  }

  String filterString(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
  }

  void getSubtitles(String path, BuildContext context) async {
    loadIsVisibleSubtitle();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString(_videoPaths[_currentIndex]) ?? '';
    if (await File(path).exists()) {
      _subtitlePath = path;
    }
    if (_subtitlePath == '') {
      if (await File(path.replaceAll(RegExp(r'\.[^\.]+$'), '.srt')).exists()) {
        _subtitlePath = path.replaceAll(RegExp(r'\.[^\.]+$'), '.srt');
        await prefs.setString(_videoPaths[_currentIndex], _subtitlePath);
      }
    }
    if (_subtitlePath != '' && _isShowSubtitle) {
      List<Subtitle> subtitles =
          parseSrt(await SubtitleMethods().readSubtitleFile(_subtitlePath));
      final model = Provider.of<KnownWordsModel>(context, listen: false);
      for (Subtitle subtitle in subtitles) {
        _subtitles.add(Subtitle1(
          subtitle.range.beginDuration,
          subtitle.range.endDuration,
          subtitle.rawLines.join(' '),
        ));
      }
      model.loadKnownWords();
      model.loadWordsFromAsset();
      List<String> words = [...model.knownWords, ...model.topUsingWords];

      _removedSub = _subtitles.map((subtitle) {
        String censoredText =
            subtitle.text.toLowerCase().split(' ').map((word) {
          return words.contains(filterString(word)) ? '***' : word;
        }).join(' ');
        return Subtitle1(
          subtitle.start,
          subtitle.end,
          censoredText,
        );
      }).toList();
      notifyListeners();
    }
  }

  Future<void> removeSubtitles() async {
    _subtitles.clear();
    notifyListeners();
  }

  void showSubtitlePermanent() async {
    _isShowSubtitle = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'is visible subtitle :${_videoPaths[currentIndex]}', true);
    notifyListeners();
  }

  void hideSubtitlePermanent() async {
    _isShowSubtitle = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'is visible subtitle :${_videoPaths[currentIndex]}', false);
    notifyListeners();
  }

  Future<void> removeSubtitles1(String videoFileName) async {
    // Implement logic to remove subtitles for a specific video
  }

  void showSubtitleTemporary() async {
    if (_isShowSubtitle) {
      _isSubtitleVisibleTemporary = true;
      notifyListeners();
    }
  }

  void hideSubtitleTemporary() {
    _subtitleText = '';
    _isSubtitleVisibleTemporary = false;
    _showDuration = true;
    notifyListeners();
  }

  void onVerticalDragUpdate(DragUpdateDetails details, bool isLandscape) {
    if (details.delta.dx > 0) {
      // Move right: increase brightness
      _showVolume = false;
      _showBrightnessProgress = true;
      adjustBrightness(details.delta.dy);
    } else {
      // Move left: increase volume
      _showBrightnessProgress = false;
      _showVolume = true;
      _volume += (isLandscape ? -1 : 1) * (details.primaryDelta! / 1000);
      _volume = _volume.clamp(0.0, 1.0);
      _controller.setVolume(_volume);
    }
    notifyListeners();
  }

  void showVolumeIndicator() {
    _showVolume = true;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _controller.setVolume(_volume);
    notifyListeners();
  }

  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void showBrightness() {
    _showBrightnessProgress = true;
    notifyListeners();
  }

  void hidVolumeIndicator() {
    _showVolume = false;
    _showBrightnessProgress = false;
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

  void handleDoubleTap(
      double dx, VideoPlayerModel model, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (dx < width / 2) {
      model.skipBackward();
      showFastForwardFeedback(true);
      _isLeftSide = true;
    } else {
      model.skipForward();
      _isLeftSide = false;
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
    final lastPosition = prefs.getInt(_videoPaths[_currentIndex] + 'position');

    if (lastPosition != null) {
      print('done in get dur: $lastPosition');
      return lastPosition;
    } else {
      print('No last position found, returning 0');
      return 0;
    }
  }

  Future<void> saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentPosition = _controller.value.position.inMilliseconds;
    await prefs.setInt(
        _videoPaths[_currentIndex] + 'position', currentPosition);
    print('done in save :' + currentPosition.toString());
  }

  bool get isSubtitleVisibleTemporary => _isSubtitleVisibleTemporary;

  void onSubtitleDragUpdate(DragUpdateDetails details) {
    _subtitleOffset += Offset(0, details.delta.dy);
    notifyListeners();
  }

  Future<void> _initializeController(BuildContext context) async {
    _controller = VideoPlayerController.file(File(_videoPaths[_currentIndex]));

    _initializeVideoPlayerFuture = _controller.initialize().then((_) async {
      // Ensure options are initialized before accessing
      if (_controller.videoPlayerOptions != null) {
        bool allowBackgroundPlayback = _controller
            .videoPlayerOptions!.allowBackgroundPlayback; // Safe access
        print('Allow Background Playback: $allowBackgroundPlayback');
      }

      int lastPosition = await loadLastPosition();
      _controller.seekTo(Duration(milliseconds: lastPosition));
      _controller.play(); // Start playing after seeking

      _controller.setLooping(true);
      _controller.setVolume(_volume);
      _controller.addListener(_updateSubtitle);

      // Set preferred orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      notifyListeners(); // Notify listeners after initialization
    }).catchError((error) {
      print('Error initializing video player: $error');
    });
  }

  // Control part
  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  void _toggleSystemUI() {
    _showSystemUI = !_showSystemUI;
    if (_showSystemUI) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      _hideSystemUI();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _toggleSystemUI();
    _hideTimer = Timer(Duration(seconds: 5), () {
      _showControls = false;
      notifyListeners();
    });
  }

  void _updateSubtitle() async {
    if (_controller.value.isInitialized &&
        _controller.value.isPlaying &&
        _isShowSubtitle) {
      var pos = await _controller.position;
      if (pos != null && _subtitles.isNotEmpty) {
        _subtitleText = _getCurrentSubtitle(pos);
        notifyListeners();
      }
    }
  }

  String _getCurrentSubtitle(Duration currentTime) {
    if (_isShowedOriginalSubtitle) {
      for (Subtitle1 subtitle in _subtitles) {
        if (currentTime >= subtitle.start && currentTime <= subtitle.end) {
          return subtitle.text;
        }
      }
    } else {
      for (Subtitle1 subtitle
          in removedSub.isNotEmpty ? _removedSub : _subtitles) {
        if (currentTime >= subtitle.start && currentTime <= subtitle.end) {
          return subtitle.text;
        }
      }
    }
    return '';
  }
}
