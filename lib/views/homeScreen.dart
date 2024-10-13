import 'package:flutter/material.dart';
import 'package:mxplayer/views/KnownWordsScreen.dart';
import 'package:mxplayer/views/music.dart';
import 'package:mxplayer/widgets/CommonWidgets/bottomNavBar.dart';
import 'package:mxplayer/widgets/CommonWidgets/drawer.dart';
import 'package:mxplayer/widgets/knowWordsWidget/searchBar.dart';
import 'local.dart'; // Import your local, known_words_screen, and music files

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    Local(), // Replace with your actual Local widget
    const KnownWordsScreen(), // Replace with your actual KnownWordsScreen widget
    Music(), // Replace with your actual Music widget
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: const Text("MX PLAYER"),
          actions: [
            _selectedIndex == 1
                ? IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context, delegate: CustomSearchDelegate());
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _widgetOptions[_selectedIndex],
      ),
    );
  }
}
