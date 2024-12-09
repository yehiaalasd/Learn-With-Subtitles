import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_search_bar.dart';
// Ensure this points to your VideoSearchBar

class AppBarWidget extends StatelessWidget {
  final int selectedIndex;

  const AppBarWidget({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBarColor,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const Text(
                "Mx Player",
                style: TextStyle(color: white, fontSize: 20),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sort, color: white),
                    onPressed: () {
                      // Add your sort functionality here
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          VideoSearchBar(
            onSearchChanged: (text) {},
          ), // Use VideoSearchBar directly
        ],
      ),
    );
  }
}
