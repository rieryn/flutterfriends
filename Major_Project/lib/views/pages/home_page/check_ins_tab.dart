import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/services/utils/notifications.dart';
import 'package:major_project/views/components/post_card.dart';
import 'package:provider/provider.dart';

import 'components/checkin_card.dart';

class CheckInTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _notifications = Notifications();
    var postsList = Provider.of<List<Post>>(context);
    _notifications.init();
    var _postsList =
        postsList.where((_post) => _post.type == 'Checkin').toList()
          ..sort((a, b) {
            if (a.distance.compareTo(b.distance) != 0 ||
                a.postedDate == null ||
                b.postedDate == null) {
              return a.distance.compareTo(b.distance);
            } else {
              return a.postedDate.compareTo(b.postedDate);
            }
          });

    if (_postsList.isNotEmpty) {
      return ListView(
        children: _postsList.map((value) {
          return CheckinComponent(value);
        }).toList(),
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}
