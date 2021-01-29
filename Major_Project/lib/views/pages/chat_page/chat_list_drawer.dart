

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListDrawer extends StatelessWidget{
  String peerUID;
  String sessionId;
  String peerProfileImageURL;
  @override
  Widget build(BuildContext context) {
    var prefs = SharedPreferences.getInstance();
    List<ChatSession> listChatSessions = Provider.of<List<ChatSession>>(context, listen:true);
     if(listChatSessions != null) {
        return ListView(
          children: listChatSessions.map((value) {
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl: value.peerProfileImageURL,
                placeholder: (context, url) => Image.asset('assets/images/bunny.jpg'),
              ),
              title: Text(value.peerUsername),
              onTap: () => {setPrefs(value.sessionId,value.peerUID),
                Navigator.pushNamed(context, '/ChatPage', arguments: value)},
            );
          }).toList(),
        );
      }
      return Container(
        alignment: Alignment.center,
        child: Text("No friends :("),
      );
  }
  setPrefs(String sessionId, String peerUID) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionId', sessionId);
    prefs.setString('peerId', peerUID);
  }
}