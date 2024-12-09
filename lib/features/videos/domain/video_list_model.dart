import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/core.dart';
import 'package:path_provider/path_provider.dart';

class VideoListModel extends ChangeNotifier {
  VideoListModel(FolderWithVideos folder) {
    _videos = folder.videos;
    _directory = folder.folderName;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    notifyListeners();
  }
  String _directory = '';
  String get directory => _directory;
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> get videos => _videos;
  List<Map<String, dynamic>> _filteredVideos = [];
  List<Map<String, dynamic>> get filteredVideos =>
      _filteredVideos.isNotEmpty ? _filteredVideos : _videos;

  Set<int> _selectedVideoIndices = {};
  Set<int> get selectedVideoIndices => _selectedVideoIndices;

  bool _isSelecting = false;
  bool get isSelecting => _isSelecting;

  void toggleCheckbox(value) {
    if (value == true) {
      _selectedVideoIndices = Set<int>.from(_videos.asMap().keys);
    } else {
      selectedVideoIndices.clear();
    }
    _isSelecting = _selectedVideoIndices.isNotEmpty;
    notifyListeners();
  }

  void sortVideos(String option) {
    String mainOption = option.split('_')[0].toLowerCase();
    String direction =
        option.split('_').length > 1 ? option.split('_')[1] : 'asc';

    switch (mainOption) {
      case 'date':
        _videos.sort((a, b) {
          int comparison =
              (a['dateAdded'] as int).compareTo(b['dateAdded'] as int);
          return direction == 'desc' ? -comparison : comparison;
        });
        break;

      case 'modified':
        _videos.sort((a, b) {
          int comparison =
              (a['modifiedDate'] as int).compareTo(b['modifiedDate'] as int);
          return direction == 'desc' ? -comparison : comparison;
        });
        break;

      case 'name':
        _videos.sort((a, b) {
          int comparison = a['name'].toString().compareTo(b['name'].toString());
          return direction == 'desc' ? -comparison : comparison;
        });
        break;

      case 'size':
        _videos.sort((a, b) {
          int sizeA = int.tryParse(a['size'].toString()) ??
              0; // Default to 0 if parsing fails
          int sizeB = int.tryParse(b['size'].toString()) ??
              0; // Default to 0 if parsing fails
          int comparison = sizeA.compareTo(sizeB);
          return direction == 'desc' ? -comparison : comparison;
        });
        break;

      case 'duration':
        _videos.sort((a, b) {
          int comparison =
              (a['duration'] as int).compareTo(b['duration'] as int);
          return direction == 'desc' ? -comparison : comparison;
        });
        break;

      default:
        break;
    }

    notifyListeners(); // Notify listeners after sorting
  }

  void enterSelectionMode(int index) {
    if (!isSelecting) {
      _isSelecting = true;
      _selectedVideoIndices.add(index);
      notifyListeners();
    }
    // Add the initially clicked item to selection
  }

  void toggleSelection(int index) {
    if (_selectedVideoIndices.contains(index)) {
      _selectedVideoIndices.remove(index);
    } else {
      _selectedVideoIndices.add(index);
    }
    _isSelecting = _selectedVideoIndices.isNotEmpty;
    notifyListeners();
  }

  void deleteSelectedVideos() async {
    for (int index in _selectedVideoIndices) {
      final path = _videos[index]['path'];
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _videos.removeWhere((video) {
      int index = _videos.indexOf(video);
      return _selectedVideoIndices.contains(index);
    });

    _selectedVideoIndices.clear();
    _isSelecting = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    if (query.isEmpty) {
      // If the query is empty, reset to the original list
      _filteredVideos.clear();
    } else {
      // Filter the videos based on the query
      _filteredVideos = _videos.where((video) {
        // Assuming the video name is stored under the 'name' key
        return video['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners(); // Notify listeners after updating the search query
  }

  Future<bool> isThereSrt(String videoFileName) async {
    final srtFile =
        '${videoFileName.substring(0, videoFileName.length - 3)}srt';
    return await File(srtFile).exists();
  }
// Your existing code...

  void playVideo(int initialIndex, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPaths: _videos.map((video) => video['path'].toString()).toList(),
          initialIndex: initialIndex,
        ),
      ),
    ).then((_) {
      // Set orientation to portrait mode when returning
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }

  Future<Uint8List?> getThumbnailAsUint8List(String videoFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailPath = '${directory.path}/.thumbnails/$videoFileName.jpg';

    if (await File(thumbnailPath).exists()) {
      return await File(thumbnailPath).readAsBytes();
    } else {
      return null;
    }
  }
}
