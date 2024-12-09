import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/folders/presentation/pages/folder_screen.dart';
import 'package:mxplayer/features/known_words/presentation/known_words_screen.dart';
import 'package:mxplayer/features/shared/widgets/customAppBar.dart';
import 'package:mxplayer/views/music.dart';
import 'package:mxplayer/features/shared/widgets/bottomNavBar.dart';
import 'package:mxplayer/features/shared/widgets/drawer.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const FolderScreen(),
    Music(),
    const KnownWordsScreen(),
    Music(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child:
              AppBarWidget(selectedIndex: _selectedIndex), // Use AppBarWidget
        ),
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
