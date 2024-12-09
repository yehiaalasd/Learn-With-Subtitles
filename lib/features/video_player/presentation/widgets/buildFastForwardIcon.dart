import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';

class FastForwardIcon extends StatelessWidget {
  final bool isLeftSide;

  FastForwardIcon({required this.isLeftSide});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLeftSide ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 120),
        child: Row(
          mainAxisAlignment:
              !isLeftSide ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(
              !isLeftSide ? Icons.fast_forward_sharp : Icons.fast_rewind_sharp,
              size: 50,
              color: white,
            ),
            const SizedBox(width: 8),
            const Text('[5]', style: TextStyle(color: white)),
          ],
        ),
      ),
    );
  }
}

class IconLock extends StatelessWidget {
  final VideoPlayerViewModel model;

  IconLock({required this.model});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 0,
      child: IconButton(
        onPressed: () => model.unlockScreen(),
        icon: const Icon(
          Icons.lock,
          size: 30,
          color: white,
        ),
      ),
    );
  }
}
