

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:major_project/models/settings_model.dart';

class ProfileDrawer extends StatelessWidget{
  String peerUID;
  String sessionId;
  String peerProfileImageURL;
  User _user;
  Settings _settings;
  @override
  Widget build(BuildContext context) {
    _user = context.watch<User>();
    _settings = context.watch<Settings>();
    if(_user != null) {
      return Column(
          children: <Widget>[

            Container(
              height: 260,
              color: Colors.transparent,
           child: Stack(
              children: <Widget>[
                Container(height:180,
                    width: 600,
                    child:FittedBox(
                      fit: BoxFit.fitWidth,
                      child:CachedNetworkImage(
                        imageUrl: "http://placekitten.com/500/500"),
                )),
                Container(
                  height: 100,
                  color: Colors.transparent,
                ),
                Positioned(
                  top:150 ,
                  left: 10,
                  width:80,
                  height:80,
                  child:ClipOval(
                    child: CachedNetworkImage(imageUrl: "http://placekitten.com/500/500"),
                  ),
                ),
              ],
            ),
          ),
            Container(
              height: 100,
              color: Colors.black45,
              child: InkWell(
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'About me'
                    ),
                  )
              ),
            ),
            InkWell(
                child: ExpansionTile(
                    title: Text("Settings"),
                    children: [
                      InkWell(
                        child: ExpansionTile(
                            title: Text("Map"),
                            children: [
                              InkWell(
                                child: ListTile(
                                  title: Text("dark"),
                                  onTap: () => {_settings.saveMapTheme("/dark.txt")},
                                ),
                              ),
                              InkWell(
                                child: ListTile(
                                  title: Text("forest"),
                                  onTap: () => {_settings.saveMapTheme("/forest.txt")},
                                ),
                              ), InkWell(
                                child: ListTile(
                                  title: Text("night"),
                                  onTap: () => {_settings.saveMapTheme("/night.json")},
                                ),
                              ), InkWell(
                                child: ListTile(
                                  title: Text("candy"),
                                  onTap: () => {_settings.saveMapTheme("/candy.json")},
                                ),
                              ),
                            ]
                        ),
                      ),
                      InkWell(
                        child: ExpansionTile(
                            title: Text("Theme"),
                            children: [
                              InkWell(
                                child: ListTile(
                                  title: Text("blue"),
                                ),
                              )
                            ]
                        ),
                      ),
                      InkWell(
                        child: ExpansionTile(
                            title: Text("Theme"),
                            children: [
                              InkWell(
                                child: ListTile(
                                  title: Text("blue"),
                                ),
                              )
                            ]
                        ),
                      )
                    ]
                ),
              ),
            Container(
              height: 70,
              color: Colors.yellow,
            ),
            Container(
              height: 70,
              color: Colors.pink,
            ),
            Expanded( // add this
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(color: Colors.black12),
              ),
            ),

          ]

      );
    }
    return Center(
      child: Text("sign in or create an account to continue"),
    );
  }
}