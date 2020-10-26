import 'package:flutter/material.dart';
import 'home_page/home_page.dart';
import 'places_page/places_page.dart';
import 'people_page/people_page.dart';
import 'live chat/live_chat_page.dart';

class NavigationController extends StatefulWidget {
  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  final List<Widget> pages = [
    HomePage(
      key: PageStorageKey('home_page'),
    ),
    PeoplePage(key: PageStorageKey('people_page')),
    MapPage(
      key: PageStorageKey('map_page'),
    ),
    LiveChatPage(
      key: PageStorageKey('live_chat_page')
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('People')),
          BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('Places')),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text("Live Chat")),
        ],
        backgroundColor: Colors.blue,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: PageStorage(
        child: pages[_selectedIndex],
        bucket: bucket,
      ),
    );
  }
}
