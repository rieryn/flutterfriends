import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:major_project/Posts/post.dart';

class PostWidget extends StatefulWidget {
  Post post;
  PostWidget({Key key, this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
                child: Text(
                    '${widget.post.username.characters.first.toUpperCase()}'),
              ),
            ),
            // Username
            Container(
                padding: EdgeInsets.only(top: _padding, bottom: _padding),
                child: Text('${widget.post.username}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            // spacer to right justify location
            Spacer(),
            // TODO: use interactive location
            Container(
                padding: EdgeInsets.all(_padding),
                child: Text('${widget.post.location}')),
          ]),
        ),
        // text
        Container(
            padding: EdgeInsets.only(left: _padding + 5, right: _padding + 5),
            child: Text('${widget.post.mainText}',
                style: TextStyle(fontSize: 15))),
        Container(
          height: _width,
          width: _width,
          padding: EdgeInsets.all(_padding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_padding),
            child: Image(
              image: NetworkImage(widget.post.image),
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
                Text('${widget.post.numLikes}')
              ],
            ),
          ),
          // likes icon, # likes
          Container(
            padding: EdgeInsets.only(right: _padding),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.chat_bubble), onPressed: null),
                Text('${widget.post.comments.length}')
              ],
            ),
          ),
        ]))
      ]),
    );
  }
}
