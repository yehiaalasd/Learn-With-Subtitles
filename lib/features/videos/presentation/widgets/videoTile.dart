import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/features/videos/domain/video_list_model.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_item.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_thumb_widget.dart';

class VideoTile extends StatelessWidget {
  final VideoListModel model;
  final int initialIndex;
  const VideoTile({
    super.key,
    required this.model,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final videoPath =
        model.filteredVideos[initialIndex]['path'].toString().split('/').last;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        model.getThumbnailAsUint8List(videoPath),
        model.isThereSrt(model.filteredVideos[initialIndex]['path']),
      ]),
      builder: (context, snapshot) {
        Widget leading;
        bool hasSrt = false;
        if (snapshot.connectionState == ConnectionState.waiting) {
          leading = buildWaitingContainer();
        } else if (snapshot.hasError) {
          leading = const Icon(Icons.error);
        } else {
          hasSrt = snapshot.data![1];
          final Uint8List? thumbnailData = snapshot.data![0];
          String durationInString =
              model.filteredVideos[initialIndex]['duration'].toString();
          Duration duration =
              Duration(milliseconds: int.parse(durationInString));
          leading = thumbnailData != null
              ? ThumbnailWidget(
                  thumbnailData: thumbnailData, duration: duration)
              : const Icon(Icons.video_call);
        }

        return VideoItemWidget(
            model: model,
            initialIndex: initialIndex,
            text: nameFromPath(),
            sizeInMB: convertSizeToMegaByte(),
            hasSrt: hasSrt,
            leading: leading);
      },
    );
  }

  double convertSizeToMegaByte() {
    return int.parse(model.filteredVideos[initialIndex]['size']) /
        (1024 * 1024);
  }

  String nameFromPath() {
    return model.filteredVideos[initialIndex]['path'].split('/').last;
  }

  Container buildWaitingContainer() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
