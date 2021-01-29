import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:provider/provider.dart';
import 'package:major_project/services/utils/notifications.dart' as notif;

class CheckinComponent extends StatefulWidget {
  final Post _post;
  CheckinComponent(this._post);

  @override
  _CheckinComponentState createState() => _CheckinComponentState();
}

class _CheckinComponentState extends State<CheckinComponent> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {

    var _user = Provider.of<User>(context);
    double _width = MediaQuery.of(context).size.width;
    double _padding = 5;
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
      width: _width,
      child: Column(children: [
        Row(children: [
          // avatar
          Container(
            width: MediaQuery.of(context).size.width * 0.18,
            child: CircleAvatar(
                child: widget._post.userImgURL != null &&
                        widget._post.userImgURL != ""
                    ? SizedBox(
                        // width: iconSize,
                        // height: iconSize,
                        child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget._post.userImgURL,
                          fit: BoxFit.fill,
                          errorWidget: (context, url, error) => widget
                                          ._post.username !=
                                      null &&
                                  widget._post.username != ""
                              ? Text(
                                  '${widget._post.username.characters.first.toUpperCase()}')
                              : Text('?'),
                        ),
                      ))
                    : (widget._post.username != null &&
                            widget._post.username != "")
                        ? Text(
                            '${widget._post.username.characters.first.toUpperCase()}')
                        : Text('?')),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              Container(
                  child: Row(
                children: [
                  Text(
                      (widget._post.username == null ||
                              widget._post.username == "")
                          ? 'Anonymous'
                          : '${widget._post.username}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )),
              // location
              Text(
                  (widget._post.addressName == null)
                      ? 'Checked Into: ${widget._post.location}'
                      : 'Checked Into: ${widget._post.addressName}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              // text
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    (widget._post.body == "")
                        ? 'Post Has No Text'
                        : '${widget._post.body}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: isExpanded ? 100 : 1,
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          )
        ]),
        Divider(),
        // likes
        Container(
            child: Row(children: [
          Container(
            height: 30,
            padding: EdgeInsets.only(right: _padding),
            child: Row(
              children: [
                IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.favorite),
                    onPressed: () => like(_user),
                    color: (_user != null &&
                            widget._post.likes.contains(_user?.uid))
                        ? Colors.red
                        : Colors.grey),
                Text(widget._post.likes != null
                    ? '${widget._post.likes.length}'
                    : '0')
              ],
            ),
          ),
        ]))
      ]),
    );
  }

  void like(User _user) {
    if (_user != null) {
      if (widget._post.likes.contains(_user?.uid)) {
        // unlike
        // already liked we are remove user from the list
        widget._post.likes.remove(_user?.uid);
        widget._post.postid.update({'likes': widget._post.likes});
      } else {
        // like
        widget._post.likes.add(_user?.uid);
        widget._post.postid.update({'likes': widget._post.likes});
        // update record
      }
    } //else popup signin
  }
}
