import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/ui/sliver_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:major_project/models/settings_model.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:major_project/views/pages/login_page/login_page.dart';
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
  User user;
  Settings settings;
  var _db = FirebaseService();

  ChatPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    settings = context.watch<Settings>();
    print("check ");
    print(settings?.getChatPeer());
    print(widget?.peerUID ?? settings?.getChatPeer());
    print(widget?.sessionId ??settings?.getChatSession());
    print(widget?.peerProfileImageURL);
    settings = context.watch<Settings>();
    user = Provider.of<User>(context);
    if (user != null) {
      return StreamProvider<List<ChatSession>>(
        create: (_)=> _db.streamChatSessions(user.uid),
        child: Scaffold(
          appBar: AppBar(),
          drawer: Drawer(
              child: chatListDrawer()
          ),

          body: ChatPane(
            peerUID: widget.peerUID ?? settings.getChatPeer(),
            peerProfileImageURL: widget.peerProfileImageURL ?? settings.getChatImageURL(),
            sessionId: widget.sessionId ??settings.getChatSession(),
          ),
        ),
      );
    }
    return LoginPage();
  }

  Widget chatListDrawer(){
    var _settings = context.watch<Settings>();
    List<ChatSession> listChatSessions =
        Provider.of<List<ChatSession>>(context, listen: true);
    if (listChatSessions != null) {
      return ListView(
        children: listChatSessions.map((value) {
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: value.peerProfileImageURL,
              placeholder: (context, url) => Image.asset('assets/images/bunny.jpg'),
              ),
              title: Text(value.peerUsername),
              onTap: () => {
                widget.peerUID = value.peerUID,
                _settings.saveChatPeer(widget.peerUID),
                widget.sessionId = value.sessionId,
                _settings.saveChatSession(widget.sessionId),
                widget.peerProfileImageURL = value.peerProfileImageURL,
                _settings.saveChatImageURL(widget.peerProfileImageURL),
                setState(() {}),
                Navigator.pop(context)
              },
          );
        }).toList(),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: Text("No friends :("),
    );
  }
}