import 'package:flutter/material.dart';
import 'package:major_project/views/pages/home_page/home_page.dart';
import 'package:major_project/views/pages/live%20chat/live_chat_page.dart';
import '../pages/places_page.dart';
import '../pages/people_page.dart';

class NavigationController extends StatefulWidget {
  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  // storage keys allow the pages to not be reloaded every set state and retain their scroll position
  final List<Widget> pages = [
    HomePage(key: PageStorageKey('home_page')),
    PeoplePage(key: PageStorageKey('people_page')),
    MapPage(key: PageStorageKey('map_page')),
    LiveChatPage(key: PageStorageKey('live_chat_page')),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        //home tabs
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // people tab
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'People',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // places tab
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Places',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // live chat app
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Live Chat',
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    print(DateTime.now().toString());
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: PageStorage(
        child: pages[_selectedIndex],
        bucket: bucket,
      ),
    );
  }
}