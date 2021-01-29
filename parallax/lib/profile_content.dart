import 'dart:ui';
import 'dart:ui';

import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import 'game.dart';
import 'game_data.dart';

class Content extends StatefulWidget {
  MyGame game;
  Content(MyGame mygame){
    game = mygame;
  }
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  String text = "test";
  bool paused = false;
  String longtext =
      "Paragraphs are the building blocks of papers. Many students define paragraphs in terms of length: a paragraph is a group of at least five sentences, a paragraph is half a page long, etc. In reality, though, the unity and coherence of ideas among sentences is what constitutes a paragraph. A paragraph is defined as “a group of sentences or a single sentence that forms a unit” (Lunsford and Connors 116). Length and appearance do not determine whether a section in a paper is a paragraph. For instance, in some styles of writing, particularly journalistic styles, a paragraph can be just one sentence long. Ultimately, a paragraph is a sentence or group of sentences that support one main idea. In this handout, we will refer to this as the “controlling idea,” because it controls what happens in the rest of the paragraph.";
  List<Widget> stats = [];
  List<Widget> enemystats = [];
  List<Widget> resources = [];
  List<Widget> upgrades = []; //why is dart like this??
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final size = MediaQuery.of(context).size;
    GameController.instance.init();
    final widgetSize = Vector2(size.width, size.height / 3);
    final gameBottom = size.height / 3;
    final contentHeight = size.height / 3;
    final middleLeft = size.width / 4;
    final middleRight = size.width * 3 / 4;
    final avatarRadius = size.width / 9;
    final Map<String, List<String>> upgradeTree  = {
      'combo1': ['combo2'],
      'combo2': ['combo3'],
    };
    GameData gamedata;
    return StreamBuilder<GameData>(
        stream: GameController.instance.streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<GameData> snapshot) {
          gamedata = snapshot.data;
          if (snapshot.data != null) {
            stats?.clear();
            snapshot.data.stats.forEach((k, v) {
              stats.add(Text(k + ": " + v.toString()));
            });
            enemystats?.clear();
            snapshot.data.enemystats.forEach((k, v) {
              enemystats.add(Text(k + ": " + v.toString()));
            });
            resources?.clear();
            snapshot.data.resources.forEach((k, v) {
              if(v!=0){
                resources.add(Text(k + ": " + v.toString()));
              };
            });
            upgrades?.clear();
            //if you want images standardize them to png and use the key name
            snapshot.data.upgrades.forEach((k, v) {
              if(v==1) {upgrades.add(
                ElevatedButton(
                  onPressed: () {
                    //problem: buy the upgrade, then enable dependent upgrades with only a string
                    //brute force: store another map of lists of keys for each upgrade, when upgrade is flipped iterate over the list and use the key to flip the other values
                    //smart way? ???
                    if(upgradeTree[k]!=null){
                      for (String i in upgradeTree[k]){
                        widget.game.redwarrior.upgrades[i] = 1;
                        widget.game.upgrades[i] = 1;
                      }
                    }
                    widget.game.redwarrior.upgrades[k] = 2;
                    widget.game.upgrades[k] = 2;
                    print(widget.game.upgrades);},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue[50]),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(100000, 40)),
                    elevation: MaterialStateProperty.all(8),
                  ),
                  child: Text(
                    k,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[850]),
                  ),
                ),
              );}
            });

            return Row(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: SizedBox(
                  width: avatarRadius * 2,
                  height: size.height * 4 / 5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomLeft,
                          height: avatarRadius * 2,
                          width: avatarRadius * 2,
                          child: LiquidCircularProgressIndicator(
                            value: snapshot.data.stats["hp"] / 5000,
                            // Defaults to 0.5.
                            valueColor:
                                AlwaysStoppedAnimation(Colors.pink[300]),
                            // Defaults to the current Theme's accentColor.
                            backgroundColor: Colors.transparent,
                            // Defaults to the current Theme's backgroundColor.
                            borderColor: Colors.white,
                            borderWidth: 3.0,
                            direction: Axis
                                .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: size.height * 2 / 3 -  avatarRadius * 2.5,
                          child: Card(
                            semanticContainer: false,
                            color: Colors.blue[50].withOpacity(0.7),
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                        ),
                                      ),
                                      child: Image(
                                          height: avatarRadius / 2,
                                          width: avatarRadius / 2,
                                          image:
                                          AssetImage('assets/images/snip.png')),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                        ),
                                      ),
                                      child: Image(
                                          height: avatarRadius / 2,
                                          width: avatarRadius / 2,
                                          image:
                                          AssetImage('assets/images/bun.png')),
                                    ),
                                  ]

                              ),

                              Divider(thickness:3),
                              Expanded(child:Padding(padding:EdgeInsets.all(4),child:ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: false,
                                  children: <Widget>[
                                    ...stats,
                                    Divider(thickness:3),
                                    ...enemystats,
                                    Divider(thickness:3),
                                    ...resources,
                                    Divider(thickness:3),
                                    Divider(),
                                    Text("bunnies "),
                                    Text("houses "),
                                    Divider(),
                                  ]),),),
                            ],
                          )),
                        ),
                      ]),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(4),
                child: SizedBox(
                  width: avatarRadius * 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomLeft,
                          height: avatarRadius * 2,
                          width: avatarRadius * 2,
                          child: LiquidCircularProgressIndicator(
                            value: 1,
                            // Defaults to 0.5.
                            valueColor: AlwaysStoppedAnimation(
                                Colors.lightBlueAccent[100]),
                            // Defaults to the current Theme's accentColor.
                            backgroundColor: Colors.transparent,
                            // Defaults to the current Theme's backgroundColor.
                            borderColor: Colors.white,
                            borderWidth: 3.0,
                            direction: Axis
                                .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: size.height * 2 / 3 -  avatarRadius * 2.5,
                          child: Card(
                              semanticContainer: false,
                              color: Colors.blue[50].withOpacity(0.7),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Enemy"),
                                  Divider(thickness:3),
                                  Expanded(child:Padding(padding:EdgeInsets.all(4),child:ListView(
                                      physics:
                                      const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: false,
                                      children: <Widget>[
                                        ...enemystats,
                                        Divider(thickness:3),
                                        ...upgrades,
                                        Divider(thickness:3),
                                        Divider(),
                                        Text("bunnies "),
                                        Text("houses "),
                                        Divider(),
                                      ]),),),
                                ],
                              )),
                        ),
                      ]),
                ),
              ),
            ]);
          }
          return Container();
        });
  }
}
