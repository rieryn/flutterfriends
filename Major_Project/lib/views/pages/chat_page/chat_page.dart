import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_pane.dart';

class ChatPage extends StatelessWidget {
  SharedPreferences prefs;
  String _peerUID ='bunny';
  String _peerProfileImageURL = 'http://placekitten.com/200/300';
  String _sessionId;

  @override
  Widget build(BuildContext context) {
    getCurrentSession();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'chat page',
          style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
      ChatPane(
        peerUID: _peerUID,
        peerProfileImageURL: _peerProfileImageURL,
        sessionId: _sessionId,
      ),
    );
  }
  getCurrentSession() async {
    prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('sessionId') ?? '';
  }
}