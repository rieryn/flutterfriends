import 'package:flutter/material.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/views/pages/chat_page/chat_page.dart';
import 'package:major_project/views/pages/home_page/home_page.dart';
import 'package:major_project/views/pages/live%20chat/live_chat_page.dart';
import 'package:major_project/views/pages/map_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/people_page.dart';

class NavigationController extends StatefulWidget {
  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  final PageStorageBucket bucket = PageStorageBucket();
  final _db = FirebaseService();
  int _selectedIndex = 0;
  SharedPreferences prefs;
  String sessionId;
  String peerUID;

  @override
  void initState() {
    getCurrentSession();
    super.initState();
  }
  // storage keys allow the pages to not be reloaded every set state and retain their scroll position
  final List<Widget> pages = [
    HomePage(key: PageStorageKey('home_page')),
    ChatPage(key: PageStorageKey('chat_page')),
    MapPage(key: PageStorageKey('map_page')),
    LiveChatPage(key: PageStorageKey('live_chat_page')),
  ];



  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        iconSize: MediaQuery.of(context).size.height/35,
        unselectedFontSize: MediaQuery.of(context).size.height/90,
        selectedFontSize: MediaQuery.of(context).size.height/70,
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
            label: 'connections',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // map tab
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'explore',
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
    return Scaffold(
        bottomNavigationBar: SizedBox(height: MediaQuery.of(context).size.height/14, child:_bottomNavigationBar(_selectedIndex)),
    body: PageStorage(
    child: pages[_selectedIndex],
    bucket: bucket,
    ),
    );
    print(DateTime.now().toString()
    );

  }
  getCurrentSession() async {
    prefs = await SharedPreferences.getInstance();
    sessionId = prefs.getString('sessionId') ?? '';
    peerUID = prefs.getString('peerUID') ?? '';
  }
}
