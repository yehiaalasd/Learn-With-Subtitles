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
      backgroundColor: Color(0xFF1F2937),
      currentIndex: selectedIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF1F2937),
          icon: selectedIndex == 0
              ? const Icon(
                  FontAwesomeIcons.folderOpen,
                  color: Color(0xFFF28C0F),
                )
              : const Icon(
                  FontAwesomeIcons.folder,
                  color: Color(0xFF6B7682),
                ),
          label: 'Local',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF1F2937),
          icon: selectedIndex == 1
              ? const Icon(
                  Icons.music_note,
                  color: Color(0xFFF28C0F),
                )
              : const Icon(
                  Icons.music_off_outlined,
                  color: Color(0xFF6B7682),
                ),
          label: 'Music',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF1F2937),
          icon: selectedIndex == 2
              ? const Icon(
                  Icons.subtitles,
                  color: Color(0xFFF28C0F),
                )
              : const Icon(
                  Icons.subtitles,
                  color: Color(0xFF6B7682),
                ),
          label: 'Music',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF1F2937),
          icon: selectedIndex == 3
              ? const Icon(
                  Icons.play_circle_fill,
                  color: Color(0xFFF28C0F),
                )
              : const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF6B7682),
                ),
          label: 'Video',
        ),
      ],
    );
  }
}
