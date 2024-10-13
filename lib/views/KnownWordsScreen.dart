import 'package:flutter/material.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:mxplayer/widgets/knowWordsWidget/searchBar.dart';
import 'package:mxplayer/widgets/knowWordsWidget/wordsList.dart';
import 'package:provider/provider.dart';

class KnownWordsScreen extends StatefulWidget {
  const KnownWordsScreen({Key? key}) : super(key: key);

  @override
  State<KnownWordsScreen> createState() => _KnownWordsScreenState();
}

class _KnownWordsScreenState extends State<KnownWordsScreen> {
  late Future<void> _loadWordsFuture;
  bool _isTopWordsExpanded = false;
  bool _isKnownWordsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadWordsFuture = _loadWords();
  }

  Future<void> _loadWords() async {
    final provider = Provider.of<KnownWordsModel>(context, listen: false);
    await provider.loadWordsFromAsset();
    await provider.loadKnownWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadWordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return _buildWordLists();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWordLists() {
    final provider = Provider.of<KnownWordsModel>(context);
    final topWords = provider.topUsingWords;
    final knownWords = provider.knownWords;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTopWordsExpanded = !_isTopWordsExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Using Words :${topWords.length}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Icon(
                  //       _isTopWordsExpanded
                  //           ? Icons.expand_less
                  //           : Icons.expand_more,
                  //     ),
                  //     const SizedBox(width: 20),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            height:
                MediaQuery.of(context).size.height * 0.38, // Adjusted height
            child: ListView.builder(
              itemCount: topWords.length,
              itemBuilder: (context, index) {
                return WordList(word: topWords[index]);
              },
            ),
          ),
          SizedBox(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isKnownWordsExpanded = !_isKnownWordsExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Words You Know :${knownWords.length}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Icon(
                  //       _isKnownWordsExpanded
                  //           ? Icons.expand_less
                  //           : Icons.expand_more,
                  //     ),
                  //     const SizedBox(width: 20),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            height:
                MediaQuery.of(context).size.height * 0.38, // Adjusted height
            child: ListView.builder(
              itemCount: knownWords.length,
              itemBuilder: (context, index) {
                return WordList(word: knownWords[index]);
              },
            ),
          ),
          const SizedBox(height: 20), // Add some spacing at the bottom
        ],
      ),
    );
  }
}
