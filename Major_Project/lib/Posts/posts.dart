import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
  String username;
  // TODO: use real location
  String location;
  String mainText;
  NetworkImage image;
  int numLikes;
  List<String> comments;
  DocumentReference reference;
  DateTime postedDate;

  Post({
    Key key,
    this.username,
    this.location,
    this.mainText,
    this.image,
    this.numLikes,
    this.comments,
    this.postedDate,
  }) : super(key: key);

  Post.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['useername'];
    this.location = map['location'];
    this.mainText = map['mainText'];
    this.image = map['image'];
    this.numLikes = map['numLikes'];
    this.comments = map['comments'];
    this.postedDate = DateTime.parse(map['postedDate']);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'location': this.location,
      'mainText': this.mainText,
      'image': this.image,
      'numLikes': this.numLikes,
      'comments': this.comments,
      'datePosted': this.postedDate.toString(),
    };
  }
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _padding = 10;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          //bottomLeft: Radius.circular(10),
          //bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      width: _width,
      child: Column(children: [
        Container(
          // top bar
          child: Row(children: [
            // avatar
            Container(
              padding: EdgeInsets.all(_padding),
              child: CircleAvatar(
                child:
                    Text('${widget.username.characters.first.toUpperCase()}'),
              ),
            ),
            // Username
            Container(
                padding: EdgeInsets.only(top: _padding, bottom: _padding),
                child: Text('${widget.username}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            // spacer to right justify location
            Spacer(),
            // TODO: use interactive location
            Container(
                padding: EdgeInsets.all(_padding),
                child: Text('${widget.location}')),
          ]),
        ),
        // text
        Container(
            padding: EdgeInsets.only(left: _padding + 5, right: _padding + 5),
            child: Text('${widget.mainText}', style: TextStyle(fontSize: 15))),
        Container(
          height: _width,
          width: _width,
          padding: EdgeInsets.all(_padding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_padding),
            child: Image(
              image: widget.image,
              fit: BoxFit.fill,
            ),
          ),
        ),
        // bottom bar
        Container(
            child: Row(children: [
          Container(
            padding: EdgeInsets.only(right: _padding),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.favorite), onPressed: null),
                Text('${widget.numLikes}')
              ],
            ),
          ),
          // likes icon, # likes
          Container(
            padding: EdgeInsets.only(right: _padding),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.chat_bubble), onPressed: null),
                Text('${widget.comments.length}')
              ],
            ),
          ),
        ]))
      ]),
    );
  }
}
