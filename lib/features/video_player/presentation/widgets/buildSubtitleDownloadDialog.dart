import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';

class SubtitleDownloadDialog extends StatefulWidget {
  final VideoPlayerViewModel model;

  const SubtitleDownloadDialog({super.key, required this.model});

  @override
  State<SubtitleDownloadDialog> createState() => _SubtitleDownloadDialogState();
}

class _SubtitleDownloadDialogState extends State<SubtitleDownloadDialog> {
  @override
  void initState() {
    super.initState();
    _loadSubtitles();
  }

  void _loadSubtitles() {
    final currentSubtitle = _getCurrentSubtitle();
    currentSubtitle.getSubtitles(widget.model.model);
    setState(() {});
  }

  SubtitleViewModel _getCurrentSubtitle() {
    return widget.model.subtitleViewModel.firstWhere(
      (data) => data.indexOfVide == widget.model.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final currentSubtitle = _getCurrentSubtitle();
    final subtitlePath = currentSubtitle.subtitlePath;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      child: SizedBox(
        width: width > height ? width * 0.4 : width * 0.8,
        height: width > height ? height * 0.6 : height * 0.30,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitlePath.isEmpty)
                const Text(
                  'No Subtitle',
                  style: TextStyle(color: white, fontSize: 18),
                ),
              const SizedBox(height: 16),
              if (subtitlePath.isNotEmpty)
                SizedBox(
                  child: ListTile(
                    title: Text(
                      subtitlePath.split('/').last,
                      style: const TextStyle(color: white, fontSize: 18),
                    ),
                    trailing: Checkbox(
                      value: currentSubtitle.isShowSubtitlePermenant,
                      onChanged: (value) {
                        if (value == true) {
                          currentSubtitle.showSubtitlePermanent();
                        } else {
                          currentSubtitle.hideSubtitlePermanent();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      widget.model.controller.pause();
                      widget.model.pickFile(context);
                      setState(() {});
                    },
                    child: const Text('Choose Subtitle'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.model.controller.play();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
