import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mxplayer/utils/folder_info.dart';
import 'package:mxplayer/widgets/CommonWidgets/tile.dart';

class FolderTile extends StatelessWidget {
  final FolderVideoCount folder;
  final VoidCallback onTap;

  const FolderTile({
    Key? key,
    required this.folder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        tiles(
          folder.folderPath.split('/').last,
          folder.videoCount.toString(),
          onTap,
          Uint8List(0),
          true,
        ),
        const Divider(height: 2),
      ],
    );
  }
}
