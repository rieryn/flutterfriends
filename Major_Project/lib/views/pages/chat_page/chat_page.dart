import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'chat_pane.dart';
class ChatPage extends StatefulWidget {
  String sessionId;
  String peerUID;
  String peerProfileImageURL;
  User user;
  ChatPage({Key key, this.sessionId, this.peerUID, this.user})
      : super(key: key);
  @override
  State createState() =>
      ChatPageState(sessionId: sessionId, peerUID: peerUID);
}

class ChatPageState extends State<ChatPage> {
  SharedPreferences prefs;
  String peerUID = 'bunny';
  String peerProfileImageURL = 'http://placekitten.com/200/300';
  String sessionId;
  User user;
  var _db = FirebaseService();
  ChatPageState({Key key, this.sessionId, this.peerUID, this.user});

  @override
  void initState() {
    if(sessionId == null){getCurrentSession();}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<ChatSession>>.value(
        value: _db.streamChatSessions(user.uid),
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
                    peerUID: peerUID,
                    peerProfileImageURL: peerProfileImageURL,
                    sessionId: sessionId,
                  ),
                ),
    );
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
                            sessionId = value.sessionId,
                            peerProfileImageURL = value.peerProfileImageURL,
                            prefs.setString('sessionId', value.sessionId),
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