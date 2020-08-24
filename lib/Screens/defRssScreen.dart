import 'package:curator/Screens/settingsScreen.dart';
import 'package:curator/Screens/podcastRssScreen.dart';
import 'package:curator/Screens/webRssScreen.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class DefRssScreen extends StatefulWidget {
  DefRssScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DefRssScreenState createState() => _DefRssScreenState();
}

class _DefRssScreenState extends State<DefRssScreen> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: <Widget>[
              WebRssScreen(),
              PodcastRssScreen(),
              SettingsScreen()
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 100), curve: Curves.ease);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(title: Text('Web'), icon: Icon(Icons.web)),
          BottomNavyBarItem(
              title: Text('Podcasts'), icon: Icon(Icons.audiotrack)),
          BottomNavyBarItem(
              title: Text('Settings'), icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
