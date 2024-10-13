import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/utils/video_properties.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/buildSubtitleDownloadDialog.dart';

Positioned buildFloatingButtonsControl(
    VideoPlayerModel model, List<String> videoPaths, BuildContext context) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.height;
  return Positioned(
    top: model.showControls ? 0 : 150,
    bottom: 358,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: width > height ? height * 0.12 : height * 0.05,
      color: Colors.black54,
      child: Column(
        children: [
          // const SizedBox(
          //   height: 10,
          // ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      showSubtitleDownloadDialog(context, model);
                    },
                    child: IconButton(
                        icon: const Icon(
                          Icons.subtitles,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          model.playPause();
                          showSubtitleDownloadDialog(context, model);
                        }),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      onPressed: () {}),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void showSubtitleDownloadDialog(BuildContext context, VideoPlayerModel model) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return buildDialogGetSubtitle(context, model);
    },
  );
}
