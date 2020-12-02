
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/

class ChatSession {
  final String sessionId;
  final String peerUID;
  final String peerUsername;
  final String peerProfileImageURL;


  ChatSession({
    //firebase docReference
    this.sessionId,
    this.peerUID,
    this.peerUsername,
    this.peerProfileImageURL,
    //subcollection messages
  });
  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    print(doc);
    return ChatSession(
        sessionId: doc.id,
        peerUID: doc['peerUID']?? '',
        peerUsername: doc['peerUsername']?? '',
        peerProfileImageURL: doc['peerProfileImageURL'] ?? ''
    );
  }
}