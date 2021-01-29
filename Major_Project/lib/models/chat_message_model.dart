
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatMessage {
  final String messageId;
  final String username;
  final String body;
  final String userId;
  final String userImgURL;
  final DateTime createdDate;
  final bool foreignUser;
  final bool isImage;

  ChatMessage({
    //firebase docReference
    this.messageId,
    this.userId,
    //firebase strings
    this.username,
    this.body,
    this.userImgURL,
    //firebase timestamp
    this.createdDate,
    //firebase bool
    this.foreignUser,
    this.isImage
  });
  factory ChatMessage.fromFirestore(DocumentSnapshot doc, String uid) {
    Map<String, dynamic> data = doc.data();
    DateTime parsedTimestamp = DateTime.parse(data['createdDate'].toDate().toString());
    //todo: add some logic to x minutes ago
    return ChatMessage(
      messageId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      body: data['body'] ?? '',
      userImgURL: data['userImgURL'] ?? '',
      createdDate: parsedTimestamp ?? '',
      foreignUser: data['userId']==uid ? false : true,
      isImage: data['isImage'] ?? false,
    );
  }
}