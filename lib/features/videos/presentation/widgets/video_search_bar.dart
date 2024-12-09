import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';

class VideoSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const VideoSearchBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  _VideoSearchBarState createState() => _VideoSearchBarState();
}

class _VideoSearchBarState extends State<VideoSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: _isFocused ? 'Search videos' : '',
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: white),
      ),
      style: const TextStyle(color: white),
    );
  }
}
