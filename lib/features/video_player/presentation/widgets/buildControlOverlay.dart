import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/buildControlButtons.dart';
import 'package:video_player/video_player.dart';

class ControlOverlay extends StatefulWidget {
  final VideoPlayerViewModel model;
  const ControlOverlay({super.key, required this.model});

  @override
  _ControlOverlayState createState() => _ControlOverlayState();
}

class _ControlOverlayState extends State<ControlOverlay> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _createOverlay();
    widget.model.controller
        .addListener(_updateOverlay); // Listen to controller changes
  }

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom:
            widget.model.showControls ? 0 : -100, // Hide controls off-screen
        left: 0,
        right: 0,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).orientation == Orientation.portrait
                ? 40
                : 0,
          ),
          color: Colors.black38,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.model.showControls)
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: widget.model.controller,
                        builder: (context, value, child) {
                          final durationState = value;
                          final progress = durationState.position;
                          final buffered = durationState.buffered.isNotEmpty
                              ? durationState.buffered.last.end
                              : Duration.zero;
                          final total = durationState.duration;
                          return ProgressBar(
                            progress: progress,
                            buffered: buffered,
                            total: total,
                            progressBarColor: Colors.blue,
                            thumbCanPaintOutsideBar: false,
                            thumbColor: Colors.blue,
                            baseBarColor: Colors.grey,
                            bufferedBarColor: Colors.grey[50],
                            timeLabelTextStyle:
                                const TextStyle(color: Colors.white),
                            timeLabelLocation: TimeLabelLocation.sides,
                            onSeek: (duration) {
                              widget.model.controller.seekTo(duration);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              ControlButtons(model: widget.model),
            ],
          ),
        ),
      ),
    );
  }

  void _updateOverlay() {
    if (widget.model.showControls) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null && !_overlayEntry!.mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOverlay();
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    widget.model.controller.removeListener(_updateOverlay); // Clean up listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // This widget itself doesn't render anything
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
