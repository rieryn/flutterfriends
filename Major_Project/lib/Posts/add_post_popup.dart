import 'package:flutter/material.dart';
import 'package:major_project/Posts/post.dart';

import 'post_widget.dart';

class AddPostPopup extends StatefulWidget {
  @override
  _AddPostPopupState createState() => _AddPostPopupState();
}

class _AddPostPopupState extends State<AddPostPopup> {
  String _text;
  String _location;
  String _image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 20,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 4),
              child: TextFormField(
                minLines: 5,
                maxLines: 10,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Check In",
                  hintText: 'What are you up to?',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    _text = value;
                  });
                },
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Location",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _location = value;
                    });
                  },
                )),
            Container(
                padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Image",
                    //TODO: pick image from device
                    hintText: "URL of image",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _image = value;
                    });
                  },
                )),
            Container(
              padding: EdgeInsets.only(top: 4, bottom: 8),
              child: RaisedButton(
                child: Text('Check In'),
                onPressed: () => Navigator.of(context).pop(Post(
                  username: "Username",
                  location: _location,
                  mainText: _text,
                  image: _image,
                  numLikes: 0,
                  comments: [],
                  postedDate: DateTime.now(),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
