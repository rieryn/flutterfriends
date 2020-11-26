import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'file:///X:/git/major-group-project-mobile-group/Major_Project/lib/services/notifications.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/views/components/post_component.dart';
import 'package:provider/provider.dart';

class FeedTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var _notifications = Notifications();
    var postsList = Provider.of<List<Post>>(context);
    _notifications.init();
    if(postsList != null) {
      return ListView(
        children: postsList.map((value) {
          return PostComponent(value);
        }).toList(),
      );
    }
    return CircularProgressIndicator();
  }
}

