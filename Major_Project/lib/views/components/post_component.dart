
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:provider/provider.dart';

class PostComponent extends StatelessWidget{
  final Post _post;
  PostComponent(this._post);
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    bool loggedIn = user != null;
    if(_post !=null){
      return Card(
          child: ListTile(
            leading: Text(_post.body),
          )
        //todo:something something on button pressed if logged in update likes else navigate to login/signup
      );}

      throw UnimplementedError();
    }
}