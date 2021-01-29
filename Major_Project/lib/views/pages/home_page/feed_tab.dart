import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/services/utils/notifications.dart';
import 'package:major_project/views/components/post_card.dart';
import 'package:provider/provider.dart';

class FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _notifications = Notifications();
    var postsList = Provider.of<List<Post>>(context);
    List<Post> _postsList;
    _notifications.init();
    if (postsList != null) {
      _postsList = postsList.where((_post) => _post.type == 'Post').toList()
        ..sort((a, b) {
          if (a.distance.compareTo(b.distance) != 0 ||
              a.postedDate == null ||
              b.postedDate == null) {
            return a.distance.compareTo(b.distance);
          } else {
            return a.postedDate.compareTo(b.postedDate);
          }
        });
    } else {
      _postsList = [];
    }
    if (_postsList.isNotEmpty) {
      return ListView(
        children: _postsList.map((value) {
          return PostComponent(value);
        }).toList(),
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}
