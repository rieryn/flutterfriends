import 'package:major_project/Posts/posts.dart';
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
    return ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return Post(
            username: 'Username$index',
            location: 'Petrinas - 21 Harwood Ave. South',
            mainText:
                'description or text of post goes here. it should span from one end '
                'to the other; under the avatar. there should be a limit to the '
                'number of charachters this description should be.\n\nor the post '
                'should truncate into a shorter version and expanded by tapping on '
                'the post',
            image: NetworkImage(
              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            ),
            comments: [
              'comment1',
              'comment2',
              'look another one',
              'one more time'
            ],
            numLikes: index,
          );
        });
  }
}
