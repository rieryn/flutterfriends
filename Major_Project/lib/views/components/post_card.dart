import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:provider/provider.dart';

class PostComponent extends StatefulWidget {
  final Post _post;
  PostComponent(this._post);

  @override
  _PostComponentState createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<User>(context);
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          // top bar
          child: Row(children: [
            // avatar
            Container(
              padding: EdgeInsets.all(_padding),
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
                      : widget._post.username != null &&
                              widget._post.username != ""
                          ? Text(
                              '${widget._post.username.characters.first.toUpperCase()}')
                          : Text('?')),
            ),
            // Username
            Container(
                padding: EdgeInsets.only(top: _padding, bottom: _padding),
                child: Text(
                    widget._post.username == null || widget._post.username == ""
                        ? 'Anonymous'
                        : '${widget._post.username}',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            // spacer to right justify location
            Spacer(),
            Container(
                padding: EdgeInsets.all(_padding),
                child: widget._post.addressName == null
                    ? Text('${widget._post.location}')
                    : Text('${widget._post.addressName}')),
          ]),
        ),
        // text
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
              padding: EdgeInsets.only(
                  left: _padding + 5, right: _padding + 5, bottom: _padding),
              child: Text(
                  widget._post.body == ""
                      ? 'Post Has No Text'
                      : '${widget._post.body}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: isExpanded ? 100 : 3,
                  style: TextStyle(fontSize: 15))),
        ),
        // pic
        if (widget._post.postImgURL != null && widget._post.postImgURL != "")
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_padding),
              // TODO remove redundant check for placeholder
              child: CachedNetworkImage(
                imageUrl: widget._post.postImgURL,
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => Container(
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.image_not_supported_sharp,
                      color: Colors.grey,
                    )),
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
                IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () => like(_user),
                    color:
                        _user != null && widget._post.likes.contains(_user.uid)
                            ? Colors.red
                            : Colors.grey),
                Text('${widget._post.likes.length}')
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
    }
  }
}
