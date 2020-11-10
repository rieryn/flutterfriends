import 'package:cloud_firestore/cloud_firestore.dart';
//todo: refactor posts.dart
class Post {
  String id;
  String username;
  String location;
  String mainText;
  String imageURL;
  int numLikes;
  int numComments;

  Post({
    this.id,
    this.username,
    this.location,
    this.mainText,
    this.imageURL,
    this.numLikes,
    this.numComments});

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
        id: documentId,
        username: map['name'] ?? '',
        location: map['location'] ?? '',
        mainText: map['mainText'] ?? '',
        imageURL: map['imageURL'] ?? '',
        numLikes: map['numLikes'] ?? '',
        numComments: map['numComments'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'location': location,
      'mainText': mainText,
      'imageURL': imageURL,
      'numLikes': numLikes,
      'numComments': numComments,

    };
  }
}

class CheckIn {
  int index;
  String imageURL;
  String id;

  CheckIn({ this.index, this.imageURL });

  CheckIn.fromMap(Map map, String documentId){
    this.index = map['index'] as int;
    this.imageURL = map['imageURL'] as String;
    this.id = documentId;
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'imageURL': imageURL,
    };
  }
}