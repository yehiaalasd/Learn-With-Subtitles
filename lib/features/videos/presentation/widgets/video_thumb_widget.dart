import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({
    super.key,
    required this.thumbnailData,
    required this.duration,
  });

  final Uint8List? thumbnailData;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 80,
          width: 100,
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(7),
            child: Image.memory(
              thumbnailData!,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            color: transparentBlack,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              children: [
                Text(
                  duration.inHours > 0
                      ? '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
                      : '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
