import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:major_project/models/settings_model.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/views/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'chat_pane.dart';
class ChatPage extends StatefulWidget {
  String peerUID;
  String peerProfileImageURL;
  String sessionId;
  ChatPage({Key key, this.sessionId, this.peerUID, this.peerProfileImageURL})
      : super(key: key);
  @override
  State createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  SharedPreferences prefs;
  String peerUID;
  String peerProfileImageURL;
  String sessionId;
  User user;
  Settings settings;
  var _db = FirebaseService();
  ChatPageState({Key key, this.sessionId, this.peerUID, this.peerProfileImageURL});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    settings = context.watch<Settings>();
    user = Provider.of<User>(context);
    if (user != null) {
      return StreamProvider<List<ChatSession>>(
        create: (_)=> _db.streamChatSessions(user.uid),
        child: Scaffold(
          drawer: Drawer(
              child: chatListDrawer()
          ),
          appBar: AppBar(
            title: Text(
              'chat page',
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: ChatPane(
            peerUID: widget.peerUID ?? settings.getChatPeer(),
            peerProfileImageURL: widget.peerProfileImageURL ?? settings.getChatSession(),
            sessionId: widget.sessionId ?? settings.getChatSession(),
          ),
        ),
      );
    }
    return LoginPage();
  }

  Widget chatListDrawer(){
    List<ChatSession> listChatSessions = Provider.of<List<ChatSession>>(context, listen:true);
    if(listChatSessions != null) {
      return ListView(
        children: listChatSessions.map((value) {
          return ListTile(
              leading: CachedNetworkImage(
                imageUrl: value.peerProfileImageURL,
                placeholder: (context, url) => Image.asset('assets/bunny.jpg'),
                ),
              title: Text(value.peerUsername),
              onTap: () => {peerUID = value.peerUID,
                            sessionId = value.sessionId,                print(sessionId),

                peerProfileImageURL = value.peerProfileImageURL,
                            prefs.setString('sessionId', value.sessionId),
                            prefs.setString('peerId', value.peerUID),
                            setState((){}),
                            Navigator.pop(context)},
                );
        }).toList(),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: Text("No friends :("),
    );
  }
  getCurrentSession() async {
    prefs = await SharedPreferences.getInstance();
    sessionId = prefs.getString('sessionId') ?? '';
  }
}