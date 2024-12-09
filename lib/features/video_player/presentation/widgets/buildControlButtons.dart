import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';

class ControlButtons extends StatefulWidget {
  final VideoPlayerViewModel model;

  const ControlButtons({
    super.key,
    required this.model,
  });

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: const Icon(Icons.lock_open, color: white),
            onPressed: () {
              widget.model.lockScreen();
              setState(() {});
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: white, size: 40),
              onPressed: () {
                widget.model.previousVideo(context);
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(
                    widget.model.controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: white,
                    size: 46,
                  ),
                  onPressed: () {
                    if (widget.model.controller.value.isPlaying) {
                      widget.model.controller.pause();
                      setState(() {});
                    } else {
                      widget.model.controller.play();
                      setState(() {});
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: white,
                size: 40,
              ),
              onPressed: () {
                widget.model.nextVideo(context);
                setState(() {});
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                widget.model.isLandscape
                    ? Icons.stay_current_landscape
                    : Icons.stay_current_portrait,
                color: white,
              ),
              onPressed: () {
                widget.model.toggleLandscape();
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
