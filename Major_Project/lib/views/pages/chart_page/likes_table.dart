import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/views/pages/chart_page/chart_model.dart';
import 'package:provider/provider.dart';

class LikesTable extends StatefulWidget {
  User user;
  BuildContext context;
  LikesTable(context, {Key key, this.user}) : super(key: key){this.context = context;}

  @override
  _LikesTableState createState() => _LikesTableState();
}

class _LikesTableState extends State<LikesTable> {

  int _sortColumnIndex;
  User _user;
  bool _sortAscending;
  List<Likes> _likes = [];
  List<Post> posts;
  String sortType = 'body';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _sortAscending = true;
    _sortColumnIndex = 0;
  }

  Widget build(BuildContext context) {
    posts = Provider.of<List<Post>>(context);
    _likes = _calculateLikes(sortType);
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "datatable.title")),
        actions: [
          IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LikesChart(
                        likes: _calculateLikes(sortType),
                      )));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: <DataColumn>[
            DataColumn(
                label: Text(FlutterI18n.translate(context, "datatable.posts")),
                numeric: false,
                onSort: (index, ascending) {
                  setState(() {
                    _sortColumnIndex = index;
                    _sortAscending = ascending;
                    sortType = 'body';
                  });
                }),
            DataColumn(
                label: Text(FlutterI18n.translate(context, "datatable.likes")),
                numeric: false,
                onSort: (index, ascending) {
                  setState(() {
                    _sortColumnIndex = index;
                    _sortAscending = ascending;
                    sortType = 'likes';
                  });
                }),
          ],
          rows: _likes
              .map((post) => DataRow(cells: <DataCell>[
                    DataCell(Text(post.body)),
                    DataCell(Text(post.likes.toString())),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  List<Likes> _calculateLikes(String sortType) {
    List<Likes> likeData = [];
    for (Post post in posts) {
      likeData.add(Likes(body: post.body, likes: post.likes.length));
    }
    switch (sortType) {
      case "likes":
        likeData.sort((a, b) {
          if (_sortAscending) {
            return b.likes.compareTo(a.likes);
          } else {
            return a.likes.compareTo(b.likes);
          }
        });
        return likeData;
        break;

      case "body":
        likeData.sort((a, b) {
          if (_sortAscending) {
            return a.body.compareTo(b.body);
          } else {
            return b.body.compareTo(a.body);
          }
        });
        return likeData;
        break;
    }
    return likeData;
  }
}
