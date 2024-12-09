import 'package:mxplayer/features/folders/data/folderRepository.dart';
import 'package:mxplayer/features/folders/data/folder_data_source.dart';
import 'package:mxplayer/features/folders/data/local_repository_impl.dart';
import 'package:mxplayer/features/folders/domain/get_folder_videos.dart';
import 'package:mxplayer/features/known_words/data/known_words_data_source.dart';
import 'package:mxplayer/features/known_words/data/known_words_repository.dart';
import 'package:mxplayer/features/known_words/domain/known_words_model.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  // ChangeNotifierProvider(create: (context) => KnownWordsModel()),

  Provider<FolderDataSource>(create: (_) => FolderDataSource()),
  Provider<FolderRepository>(
    create: (context) => FolderRepositoryImpl(context.read<FolderDataSource>()),
  ),
  Provider<GetFolderVideos>(
    create: (context) => GetFolderVideos(context.read<FolderRepository>()),
  ),
  // Add KnownWordsModel provider
  ChangeNotifierProvider(
    create: (context) => KnownWordsModel(
      KnownWordsRepository(
          KnownWordsDataSource()), // Ensure the repository and data source are set up
    ),
  ),

  ChangeNotifierProvider(
      create: (context) => VideoPlayerViewModel(
            [],
            0,
            context,
            context.read<KnownWordsModel>(),
          )),
];
