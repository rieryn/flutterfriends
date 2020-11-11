import 'package:flutter/material.dart';
import 'package:major_project/live%20chat/live_chat.dart';

class LiveChatPage extends StatefulWidget {
  LiveChatPage({Key key}) : super(key: key);

  _LiveChatPageState createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LiveChat();
  }
}