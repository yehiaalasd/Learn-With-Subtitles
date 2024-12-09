import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/videos/domain/video_list_model.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_search_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VideoListModel model;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onSearchChanged;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    required this.onSearchChanged,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: appBarColor,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: white),
                onPressed: onBackPressed,
              ),
              Text(
                title,
                style: TextStyle(color: white, fontSize: width * 0.035),
              ),
              IconButton(
                icon: const Icon(Icons.sort, color: white),
                onPressed: () => _showSortingDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          VideoSearchBar(
            onSearchChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }

  void _showSortingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SortingDialog(model: model);
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150.0);
}

class SortingDialog extends StatefulWidget {
  final VideoListModel model;

  const SortingDialog({super.key, required this.model});

  @override
  _SortingDialogState createState() => _SortingDialogState();
}

class _SortingDialogState extends State<SortingDialog> {
  String? _selectedMainOption; // Track selected main option
  String _defaultSubOption = 'date_asc'; // Default sorting option

  final List<Map<String, dynamic>> sortingOptions = [
    {
      'label': 'Date Added',
      'icon': Icons.date_range,
      'subOptions': [
        {'value': 'date_asc', 'label': 'Ascending'},
        {'value': 'date_desc', 'label': 'Descending'},
      ],
    },
    {
      'label': 'Modified Date',
      'icon': Icons.update,
      'subOptions': [
        {'value': 'modified_asc', 'label': 'Ascending'},
        {'value': 'modified_desc', 'label': 'Descending'},
      ],
    },
    {
      'label': 'Name',
      'icon': Icons.sort_by_alpha,
      'subOptions': [
        {'value': 'name_asc', 'label': 'Ascending'},
        {'value': 'name_desc', 'label': 'Descending'},
      ],
    },
    {
      'label': 'Size',
      'icon': Icons.format_size,
      'subOptions': [
        {'value': 'size_asc', 'label': 'Ascending'},
        {'value': 'size_desc', 'label': 'Descending'},
      ],
    },
    {
      'label': 'Duration',
      'icon': Icons.timer,
      'subOptions': [
        {'value': 'duration_asc', 'label': 'Ascending'},
        {'value': 'duration_desc', 'label': 'Descending'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: const Text(
        'Sort Options',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortingOptions.map((option) {
            return _buildMainOption(option);
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Set default sorting option if no sub-option is selected
            Navigator.pop(context);
            widget.model.sortVideos(_defaultSubOption);
          },
          child: const Text(
            'Apply Default',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMainOption(Map<String, dynamic> option) {
    bool isExpanded = _selectedMainOption == option['label'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedMainOption = isExpanded ? null : option['label'];
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(option['icon'], color: Colors.white),
                const SizedBox(width: 8.0),
                Text(
                  option['label'],
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Column(
            children: option['subOptions'].map<Widget>((subOption) {
              return ListTile(
                title: Text(
                  subOption['label'],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Set the selected sub-option
                  _defaultSubOption = subOption['value'];
                  widget.model.sortVideos(subOption['value']);
                  Navigator.of(context).pop(); // Close dialog after selection
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
