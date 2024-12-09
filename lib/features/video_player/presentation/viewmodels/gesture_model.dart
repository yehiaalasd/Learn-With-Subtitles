import 'dart:async';

import 'package:brightness_volume/brightness_volume.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/core.dart';

class GestureModel extends ChangeNotifier {
  GestureModel(this.model);
  late VideoPlayerViewModel model;
  bool _isLeftSide = true;
  bool get isLeftSide => _isLeftSide;
  double _brightness = 0.0; // 1.0 is normal brightness
  double _volume = 0.0;
  String _durationText = '';
  bool _showIconLock = false;
  bool _isScreenLocked = false;
  bool _isSpeedUp = false;
  bool _showBrightnessProgress = false;
  bool _showControls = false;
  bool _showDuration = false;
  bool _showFastForwardIcon = false;
  bool _showVolume = false;
  Timer? _hideTimer;

  final Duration _currentPosition = Duration.zero;
  bool get showBrightnessProgress => _showBrightnessProgress;
  bool get showControls => _showControls;
  bool get showVolume => _showVolume;
  bool get isScreenLocked => _isScreenLocked;
  double get brightness => _brightness;
  String get durationText => _durationText;
  bool get isShowIconLock => _showIconLock;
  Duration get currentPosition => _currentPosition;
  bool get showDuration => _showDuration;
  bool get isSpeedUp => _isSpeedUp;
  double get volume => _volume;
  bool get showFastForwardIcon => _showFastForwardIcon;

  void unlockScreen() {
    _isScreenLocked = false;
    _showIconLock = false;
    toggleControls();
    notifyListeners();
  }

  void adjustBrightness(double delta) async {
    double newValue = (_brightness + delta).clamp(0.0, 1.0);
    _brightness = newValue;

    notifyListeners();
    BVUtils.setBrightness(_brightness);
  }

  void hidVolumeIndicator() {
    _showVolume = false; // Hide the volume indicator
    _showBrightnessProgress =
        false; // Also hide the brightness progress indicator
    notifyListeners(); // Notify listeners to update the UI
  }

  void hideSpeedUpWidget() {
    _isSpeedUp = false;
    model.controller.setPlaybackSpeed(1.0);
    notifyListeners();
  }

  void lockScreen() {
    _isScreenLocked = true;
    _showControls = false;
    notifyListeners();
  }

  void showIconLock() {
    _showIconLock = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      _showIconLock = false;
      notifyListeners();
    });
  }

  void showSpeedUpWidget() {
    _isSpeedUp = true;
    notifyListeners();
  }

  void toggleControls() {
    _showControls = !_showControls;
    if (!_showControls) {
      hideSystemUI();
    }
    if (_showControls) _startHideTimer();
    notifyListeners();
  }

  void skipForward() {
    _seekToPosition(5);
    notifyListeners();
  }

  void skipBackward() {
    _seekToPosition(-5);
  }

  void hideControls() {
    _showControls = false;
    notifyListeners();
  }

  void _seekToPosition(int seconds) {
    final newPosition = model.controller.value.position.inSeconds + seconds;
    model.controller.seekTo(Duration(seconds: newPosition));
    notifyListeners();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    toggleSystemUI();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      _showControls = false;
      toggleSystemUI();
      notifyListeners();
    });
  }

  void toggleSystemUI() {
    if (_showControls) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

      notifyListeners();
    } else {
      hideSystemUI();

      notifyListeners();
    }
  }

  void hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    notifyListeners();
  }

  // void setVolume(double volume) {
  //   _volume = volume.clamp(0.0, 1.0);
  //   BVUtils.setVolume(_volume).catchError((e) => print('$e volume man'));
  //   notifyListeners();
  // }
  void adjustVolume(double delta) {
    setVolume(_volume + delta);
  }

  void showDurationText() {
    _showDuration = true;
    _durationText = '';
    // var subtitle = _getCurrentSubtitleViewModel();
    // subtitle.showTempAll();
    notifyListeners();
  }

  void hideDurationText() {
    _showDuration = false;
    _durationText = '';
    notifyListeners();
    // var subtitle = _getCurrentSubtitleViewModel();
    // subtitle.hideTempAll();
    // _showSubtitle(false);
  }

  showVolumeIndicator() {
    _showVolume = true;
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void onVerticalDragUpdate(DragUpdateDetails details, BuildContext context) {
    double screenWidth = Get.width;
    double leftBoundary = screenWidth * 0.20;
    double rightBoundary = screenWidth * 0.80;

    if (details.localPosition.dx < leftBoundary) {
      // السحب من الجهة اليسرى
      _showVolume = false;
      _showBrightnessProgress = true;
      adjustBrightness(-details.delta.dy / 370); // Small for smooth change
    } else if (details.localPosition.dx > rightBoundary) {
      // السحب من الجهة اليمنى
      _showBrightnessProgress = false;
      _showVolume = true;
      setVolume(-details.delta.dy / 370);
    }

    notifyListeners();
  }

  hideBrightnessIndicator() {
    _showBrightnessProgress = false;
    notifyListeners();
  }

  showBrightnessIndicator() {
    _showBrightnessProgress = true;
    notifyListeners();
  }

  void onHorizontalDragUpdate(double delta) {
    model.controller.seekTo(model.controller.value.position +
        Duration(milliseconds: (delta * 100).toInt()));
    final position = model.controller.value.position +
        Duration(milliseconds: (delta * 100).toInt());
    model.controller.setCaptionOffset(position);
    _durationText = formatDuration(position);
    notifyListeners();
  }

  void onLongPressDown() {
    model.controller.setPlaybackSpeed(2.0);
    notifyListeners();
  }

  void handleDoubleTap(double dx, BuildContext context) {
    if (dx < Get.width / 2) {
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

  void setVolume(double volume) async {
    double newValue = (_volume + volume).clamp(0.0, 1.0);

    _volume = newValue;
    await BVUtils.setVolume(_volume).catchError((e) => print('$e volume man'));
    notifyListeners();
    // controller.setVolume(volume);
    //// Notify listeners if you have UI elements that depend on the volume
  }

  @override
  void dispose() {
    toggleSystemUI();
    model.dispose;
    super.dispose();
  }
}
