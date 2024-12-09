import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';

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
    currentSubtitle.initializeFirst();

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
              if (currentSubtitle.subtitleViewDataFirst.subtitlePath.isEmpty)
                const Text(
                  'No Subtitle',
                  style: TextStyle(color: white, fontSize: 18),
                ),
              if (currentSubtitle.subtitleViewDataFirst.subtitlePath.isNotEmpty)
                Column(
                  children: [
                    buildSubtitleTile(
                        currentSubtitle.subtitleViewDataFirst, false),
                    if (currentSubtitle
                        .subtitleViewDataSecond.subtitlePath.isEmpty)
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "add another subtitle",
                            style: TextStyle(color: white),
                          ),
                          const SizedBox(
                            width: 13,
                          ),
                          IconButton(
                            onPressed: () {
                              widget.model.pickFile(context);
                              setState(() {});
                            },
                            icon: const Icon(Icons.add),
                            color: white,
                            iconSize: 30,
                          ),
                        ],
                      ),
                    if (currentSubtitle.subtitleViewDataSecond.subtitlePath !=
                        '')
                      buildSubtitleTile(
                          currentSubtitle.subtitleViewDataSecond, true),
                  ],
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

  Widget buildSubtitleTile(SubtitleViewData currentSubtitle, bool isSecond) {
    return SizedBox(
      child: currentSubtitle.subtitlePath.isNotEmpty
          ? ListTile(
              title: Text(
                !currentSubtitle.isArabic
                    ? "[ar] :${currentSubtitle.subtitlePath.split('/').last}"
                    : '[en] :${currentSubtitle.subtitlePath.split('/').last}',
                style: const TextStyle(color: white, fontSize: 14),
              ),
              leading: Checkbox(
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
              trailing: IconButton(
                  onPressed: () {
                    final currentSubtitle = _getCurrentSubtitle();

                    currentSubtitle.removeSubtitle(isSecond);
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete)),
            )
          : const SizedBox(),
    );
  }
}
