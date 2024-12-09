import 'package:flutter/material.dart';
import 'package:mxplayer/features/videos/domain/video_list_model.dart';
import 'package:mxplayer/features/videos/presentation/widgets/videoTile.dart';

class VideoList extends StatelessWidget {
  final VideoListModel model;

  const VideoList({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: model.videos.length,
      itemBuilder: (context, index) {
        return VideoTile(
          model: model,
          initialIndex: index,
// Pass selection state
        );
      },
    );
  }
}
