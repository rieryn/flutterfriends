import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_project/models/chat_session_model.dart';
import 'package:major_project/views/pages/chart_page/likes_table.dart';
import 'package:major_project/views/pages/login_page/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:major_project/models/settings_model.dart';

//todo
class ProfileDrawer extends StatelessWidget {
  String peerUID;
  String sessionId;
  String peerProfileImageURL;
  User _user;
  Settings _settings;
  @override
  Widget build(BuildContext context) {
    _user = context.watch<User>();
    _settings = context.watch<Settings>();
    if (_user != null) {
      return ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: _user?.photoURL != null && _user?.photoURL != ""
                          ? SizedBox(
                              // width: iconSize,
                              // height: iconSize,
                              child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: _user?.photoURL,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => _user
                                                .displayName !=
                                            null &&
                                        _user?.displayName != ""
                                    ? Text(
                                        '${_user?.displayName.characters.first.toUpperCase()}')
                                    : Text('?'),
                              ),
                            ))
                          : _user?.displayName != null &&
                                  _user?.displayName != ""
                              ? Text(
                                  '${_user?.displayName.characters.first.toUpperCase()}')
                              : Text('?')),
                ),
                Text(
                  _user?.displayName ?? "Default",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          InkWell(
            child: ExpansionTile(
                title: Text(FlutterI18n.translate(context, "drawer.settings")),
                children: [
                  InkWell(
                    child: ExpansionTile(
                        title:
                            Text(FlutterI18n.translate(context, "drawer.map")),
                        children: [
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.dark")),
                              onTap: () =>
                                  {_settings.saveMapTheme("/dark.txt")},
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.forest")),
                              onTap: () =>
                                  {_settings.saveMapTheme("/forest.txt")},
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.night")),
                              onTap: () =>
                                  {_settings.saveMapTheme("/night.json")},
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.candy")),
                              onTap: () =>
                                  {_settings.saveMapTheme("/candy.json")},
                            ),
                          ),
                        ]),
                  ),
                  InkWell(
                    child: ExpansionTile(
                        title: Text(
                            FlutterI18n.translate(context, "drawer.theme")),
                        children: [
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.blue")),
                              onTap: () => _settings.saveTheme('blueTheme'),
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.dark")),
                              onTap: () => _settings.saveTheme('darkTheme'),
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(FlutterI18n.translate(
                                  context, "drawer.sunset")),
                              onTap: () => _settings.saveTheme('sunsetTheme'),
                            ),
                          ),
                        ]),
                  )
                ]),
          ),
          InkWell(
            child: ExpansionTile(
                title: Text(FlutterI18n.translate(context, "drawer.languages")),
                children: [
                  InkWell(
                    child: ListTile(
                      title: Text(
                          FlutterI18n.translate(context, "languages.english")),
                      onTap: () async {
                        Locale newLocale = Locale('en');
                        await FlutterI18n.refresh(context, newLocale);
                      },
                    ),
                  ),
                ]),
          ),
          Container(
            height: 70,
            child: InkWell(
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "drawer.analytics")),
                onTap: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LikesTable(
                            context,
                            user: _user,
                          )))
                },
              ),
            ),
          ),
          Divider(
            thickness: 1,
          ),
          Container(
            height: 70,
            child: InkWell(
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "drawer.logout")),
                onTap: () => {FirebaseAuth.instance.signOut()},
              ),
            ),
          ),
          // Expanded(
          //   // add this
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Container(color: Colors.black12),
          //   ),
          // ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.all(10),
              width: 200,
              child: Text(FlutterI18n.translate(context, "drawer.signin"))),
          FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text("Log In"))
        ],
      ),
    );
  }
}
