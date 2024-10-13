// import 'package:flutter/material.dart';
// import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
// import 'package:mxplayer/model/localeModel/localeModel.dart';
// import 'package:mxplayer/widgets/knowWordsWidget/wordsList.dart';
// import 'package:mxplayer/widgets/localeScreenWidget/folderTile.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';

// class CustomSearchMoviesOrFolder extends SearchDelegate<String> {
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final provider = Provider.of<LocaleModel>(context);
//     final List<String> results = provider.videosPaths
//         .where((item) => item.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         return
//   FolderTile(folder:f ,)
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final provider = Provider.of<KnownWordsModel>(context);
//     final List<String> suggestions = provider.topUsingWords
//         .where((item) => item.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         String word = suggestions[index];
//         bool isKnown = provider.knownWords.contains(word);
//         return WordList(
//           word: word,
//         );
//       },
//     );
//   }
// }
