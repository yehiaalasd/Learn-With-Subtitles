import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:path/path.dart';

// class SubtitleDownloadDialog extends StatefulWidget {
//   final VideoPlayerModel model;
//   const SubtitleDownloadDialog({super.key, required this.model});

//   @override
//   _SubtitleDownloadDialogState createState() => _SubtitleDownloadDialogState();
// }

// class _SubtitleDownloadDialogState extends State<SubtitleDownloadDialog> {
//   bool _isLoading = false; // Variable to track loading state

//   @override
//   Widget build(BuildContext context) {

//   }
// }
Dialog buildDialogGetSubtitle(BuildContext context, VideoPlayerModel model) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  return Dialog(
    backgroundColor: Colors.black.withOpacity(0.8),
    child: SizedBox(
      width: width > height ? width * 0.4 : 0.7,
      height: width > height ? height * 0.6 : 0.45,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (model.subtitlePath.isEmpty)
              SizedBox(
                child: Text(
                  'No Subtitle',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            const SizedBox(height: 16),
            if (model.subtitlePath.isNotEmpty)
              SizedBox(
                child: ListTile(
                  title: Text(
                    model.subtitlePath.split('/').last,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  trailing: Checkbox(
                    value: model.isShowSubtitle,
                    onChanged: (value) {
                      if (value!) {
                        model.showSubtitlePermanent();
                      } else {
                        model.hideSubtitlePermanent();
                      }
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                onPressed: () async {
                  model.controller.pause();
                  print("Picking file...");
                  bool x = await model.pickFile(context);

                  print(model.controller.value.errorDescription.toString() +
                      'error desc');
                  print('done picked it ' + x.toString());
                },
                child: const Text('Choose Subtitle'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}
