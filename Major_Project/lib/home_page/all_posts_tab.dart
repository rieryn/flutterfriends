import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/Posts/post.dart';
import 'package:major_project/Posts/post_widget.dart';
import 'package:flutter/material.dart';

class AllPostsTab extends StatefulWidget {
  @override
  _AllPostsTabState createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab>
    with AutomaticKeepAliveClientMixin<AllPostsTab> {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  var postSnap = snapshot.data.documents[index];
                  Post post = Post.fromMap(postSnap.data(),
                      reference: postSnap.reference);

                  return PostWidget(post: post);
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
