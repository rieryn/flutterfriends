
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/models/profile_model.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:major_project/views/pages/chat_page/chat_page.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget{
  final _db = FirebaseService();
  final Profile _profile;
  ProfileCard(this._profile);
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    bool loggedIn = user != null;
    String sessionId;
    return Card(
        child: ListTile(
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: _profile.profileImgURL,
              placeholder: (context, url) => Image.asset('assets/images/bunny.jpg'),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(_profile.username),
          subtitle: Text(_profile.distance.toString()),
            onTap: () async =>{
                  if (sessionId == null)
                    {
                      sessionId = await _db.guessChatSessionId(
                          user.uid,
                          _profile.profileId,
                          user.photoURL,
                          _profile.profileImgURL,
                          user.displayName,
                          _profile.username)
                    },
                  MaterialPageRoute(
                    builder: (context) {
                      return ChatPage(
                        sessionId: sessionId,
                        peerUID: _profile.profileId,
                      );
                    },
                  )
                })
      //todo:something something on button pressed if logged in update likes else navigate to login/signup
    );}
}