import 'package:flutter/material.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:provider/provider.dart';

class WordList extends StatefulWidget {
  final String word;

  const WordList({
    super.key,
    required this.word,
  });
  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context);
    bool isKnown = provider.knownWords.contains(widget.word);

    return ListTile(
      title: Text(widget.word),
      trailing: Checkbox(
        value: isKnown,
        onChanged: (isChecked) {
          setState(() {
            provider.updateKnownWords(widget.word, isChecked!);
          });
        },
      ),
    );
  }
}
