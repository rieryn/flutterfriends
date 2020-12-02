import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/chat_message_model.dart';
import 'package:major_project/services/firebase_storage.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPane extends StatefulWidget {
  final String peerUID;
  final String peerProfileImageURL;
  final String sessionId;

  ChatPane({Key key, @required this.peerUID, @required this.peerProfileImageURL, @required this.sessionId})
      : super(key: key);

  @override
  State createState() => ChatPaneState();
}

class ChatPaneState extends State<ChatPane> {
  final _db = FirebaseService();
  User _user;
  SharedPreferences prefs;

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
  void pushMessage(String message) {
      textController.clear();
      _db.pushMessage(
        sessionId: widget.sessionId,
        user: _user,
        isImage: false,
        body: message,
      );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.sessionId);
    _user = Provider.of<User>(context);
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            messageListView(),
            messageBar(),
          ],
        ),
      ],
    );
  }

  Widget messageListView() {
    return Expanded(
      child: widget.sessionId == null ?
            Center(
          child: Text("No messages :("),
            )
          : StreamBuilder(
              stream: _db.streamChatMessages(widget.sessionId, _user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();}
                return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        messageTile(snapshot.data[index]),
                    itemCount: snapshot.data.length,
                    reverse: true,
                );
             }
            )
    );
  }
  Widget messageTile(ChatMessage message){
    return ListTile(
      title: Text(message.body),
    );
  }

  Widget messageBar() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.camera_enhance),
                //todo: popup image picker onPressed: ,
                color: Colors.black38,
              ),
            ),
            color: Colors.white,
          ),
          Expanded(
            child: TextField(
                style: TextStyle(color: Colors.black38, fontSize: 15.0),
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Message ',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => pushMessage(textController.text),
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Theme.of(context).backgroundColor),
    );
  }
}