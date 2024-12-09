import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/videos/domain/video_list_model.dart';

class VideoItemWidget extends StatelessWidget {
  const VideoItemWidget({
    super.key,
    required this.model,
    required this.initialIndex,
    required this.text,
    required this.sizeInMB,
    required this.hasSrt,
    required this.leading,
  });

  final VideoListModel model;
  final int initialIndex;
  final String text;
  final double sizeInMB;
  final bool hasSrt;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () =>
          model.enterSelectionMode(initialIndex), // Handle long press
      onTap: () {
        if (model.isSelecting) {
          model.toggleSelection(initialIndex);
        } else {
          model.playVideo(initialIndex, context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: model.selectedVideoIndices.contains(initialIndex)
              ? Colors.redAccent
              : elementColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            text.substring(0, text.length > 50 ? 50 : text.length),
            style: const TextStyle(color: white),
          ),
          subtitle: Row(
            children: [
              Text(
                '${sizeInMB.toStringAsFixed(2)} MB',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 9),
              if (hasSrt)
                SizedBox(
                    width: 30, height: 20, child: Image.asset('assets/srt.png'))
            ],
          ),
          leading: leading,
        ),
      ),
    );
  }
}
