import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//todo: streambuilder boilerplate

class fromFirebase extends StatefulWidget {
  const fromFirebase({
    Key key,
  }) : super(key: key);

  @override
  _fromFirebase createState() {
    return _fromFirebase();
  }
}
typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class _fromFirebase extends State<fromFirebase> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildRow(context, data)).toList(),
    );
  }

  Widget _buildRow(BuildContext context, DocumentSnapshot data) {

  }
}

class test {
  String id;
  String username;
  String location;
  String mainText;
  String imageURL;
  int numLikes;
  int numComments;
  final DocumentReference reference;

  test.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['username'] != null),
        assert(map['location'] != null),
        username = map['username'],
        location = map['location'];

  test.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

}