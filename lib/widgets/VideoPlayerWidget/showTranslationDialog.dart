// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:provider/provider.dart';

class ShowTranslationDialog extends StatefulWidget {
  final String word;
  final String translate;

  final VideoPlayerModel model;
  const ShowTranslationDialog(
      {Key? key,
      required this.translate,
      required this.model,
      required this.word})
      : super(key: key);

  @override
  State<ShowTranslationDialog> createState() => _ShowTranslationDialogState();
}

class _ShowTranslationDialogState extends State<ShowTranslationDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      child: SizedBox(
        width: width > height ? width * 0.4 : 0.7,
        height: width > height ? height * 0.7 : 0.45,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: width > height ? height * 0.45 : 0.35,
                child: SingleChildScrollView(
                  child: Text(
                    widget.translate,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    widget.model.controller.play();
                    // Mark as unknown
                    Navigator.pop(context);
                    provider.updateKnownWords(widget.word, true);
                    print('${provider.knownWords.length} len of known');

                    widget.model.getSubtitles(
                        widget.model.controller.dataSource, context);
                  },
                  child: const Text('I Knew it '),
                ),
                ElevatedButton(
                  onPressed: () async {
                    widget.model.controller.play();
                    provider.updateKnownWords(widget.word, false);
                    Navigator.pop(context);
                  },
                  child: const Text('Not Known'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

void showTranslationDialogFun(BuildContext context, VideoPlayerModel model,
    String translate, String word) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShowTranslationDialog(
          translate: translate, model: model, word: word);
    },
  );
}
