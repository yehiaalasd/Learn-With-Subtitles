import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar(
      {Key? key, required this.selectedIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: selectedIndex == 0
              ? const Icon(FontAwesomeIcons.folderOpen)
              : const Icon(FontAwesomeIcons.folder),
          label: 'Local',
        ),
        BottomNavigationBarItem(
          icon: selectedIndex == 1
              ? const Icon(Icons.play_circle_fill)
              : const Icon(Icons.play_circle_outline),
          label: 'Video',
        ),
        BottomNavigationBarItem(
          icon: selectedIndex == 2
              ? const Icon(Icons.music_note)
              : const Icon(Icons.music_off_outlined),
          label: 'Music',
        ),
      ],
    );
  }
}
