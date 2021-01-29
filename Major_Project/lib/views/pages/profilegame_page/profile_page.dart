import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:major_project/models/settings_model.dart';
import 'package:major_project/views/pages/profilegame_page/profile_content.dart';
import 'package:provider/provider.dart';

import 'about_tab.dart';
import 'components/game.dart';
import 'components/game_data.dart';

class GameProfilePage extends StatefulWidget {
  @override
  _GameProfilePageState createState() => _GameProfilePageState();
}

class _GameProfilePageState extends State<GameProfilePage>
    with SingleTickerProviderStateMixin {
  MyGame game;
  String text = "test";
  bool paused = false;
  String longtext =
      "Paragraphs are the building blocks of papers. Many students define paragraphs in terms of length: a paragraph is a group of at least five sentences, a paragraph is half a page long, etc. In reality, though, the unity and coherence of ideas among sentences is what constitutes a paragraph. A paragraph is defined as “a group of sentences or a single sentence that forms a unit” (Lunsford and Connors 116). Length and appearance do not determine whether a section in a paper is a paragraph. For instance, in some styles of writing, particularly journalistic styles, a paragraph can be just one sentence long. Ultimately, a paragraph is a sentence or group of sentences that support one main idea. In this handout, we will refer to this as the “controlling idea,” because it controls what happens in the rest of the paragraph.";
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    GameController.instance.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild triggered");
    final _user = context.watch<User>();
    final appBarHeight = AppBar().preferredSize.height;
    final size = MediaQuery.of(context).size;
    final widgetSize = Vector2(size.width, size.height * 15 / 40);
    final gameBottom = size.height / 3;
    final contentHeight = size.height / 3;
    final middleLeft = size.width / 4;
    final middleRight = size.width * 3 / 4;
    final avatarRadius = size.width / 9;
    final key = GlobalKey<ScaffoldState>();
    game = MyGame(widgetSize, context);

    // if (_user !=null){

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: gameBottom,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              //this is really inconsistent on emulator
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  height: size.height * 2 / 3,
                  width: size.width,
                  child: game.widget,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              //button layer
              behavior: HitTestBehavior.deferToChild,
            ),
          ),
          Positioned.fill(
            top: contentHeight - avatarRadius / 2,
            left: 0,
            right: 0,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: avatarRadius,
                  left: 0,
                  child: Container(
                    height: size.height * 2 / 3,
                    width: size.width,
                    decoration: BoxDecoration(
                        color: Colors.pink[50],
                        border: Border.all(
                          color: Colors.blueGrey[900],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    //child:
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: size.height * 2 / 3,
                    width: size.width,
                    child: Content(game), // Content(game),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: contentHeight,
            left: size.width * 3 / 12,
            right: size.width * 3 / 12,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.only(top: avatarRadius / 2),
                        child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: avatarRadius * 1.5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    _user?.displayName ?? "Red",
                                    //_user.displayName,
                                    style:
                                        TextStyle(fontSize: avatarRadius / 3),
                                  ),
                                  TabBar(
                                    isScrollable: true,
                                    labelStyle:
                                        TextStyle(fontSize: avatarRadius / 4),
                                    labelColor: Colors.black45,
                                    controller: _controller,
                                    tabs: [
                                      Tab(
                                        text: 'About',
                                      ),
                                      Tab(
                                        text: 'Shop',
                                      ),
                                      Tab(
                                        text: 'Village',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: .0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: avatarRadius * 2,
                            width: avatarRadius * 2,
                            child: ClipOval(
                                child: CachedNetworkImage(
                              imageUrl: _user?.photoURL ?? '',
                              width: avatarRadius * 2,
                              height: avatarRadius * 2,
                              placeholder: (context, url) => Image(
                                  height: avatarRadius * 2,
                                  width: avatarRadius * 2,
                                  image: AssetImage(
                                      'assets/images/game_placeholder.png')),
                              errorWidget: (context, url, error) => Image(
                                  height: avatarRadius * 2,
                                  width: avatarRadius * 2,
                                  image: AssetImage(
                                      'assets/images/game_placeholder.png')),
                            )),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: size.width * 2 / 3,
                    height: size.height - contentHeight - avatarRadius * 5,
                    child: Container(
                      color: Colors.lightBlue[50],
                      child: ListView(children: <Widget>[
                        Container(
                          height: size.height -
                              contentHeight -
                              avatarRadius * 3 +
                              10,
                          child: TabBarView(
                            controller: _controller,
                            children: <Widget>[
                              AboutTab(),
                              ListView(
                                //Stats
                                children: <Widget>[
                                  Image(
                                      width: size.width,
                                      image: AssetImage(
                                          'assets/images/prestige_1.jpg')),
                                  SizedBox(
                                    height: size.height -
                                        contentHeight -
                                        avatarRadius * 11 / 3,
                                    width: size.width * 2 / 3 - 20,
                                    child: GridView.count(
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 5,
                                        // Create a grid with 2 columns. If you change the scrollDirection to
                                        // horizontal, this produces 2 rows.
                                        crossAxisCount: 2,
                                        // Generate 100 widgets that display their index in the List.
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            child:InkWell(child:
                                            Card(
                                                child:
                                                    Column(children: <Widget>[
                                              Text("buy a sword"),
                                              Image(
                                                  height: avatarRadius,
                                                  width: avatarRadius,
                                                  image: AssetImage(
                                                      'assets/images/glowsword.png')),
                                            ])),
                                              onTap: (){game.addSword();
                                            game.redwarrior.attack+1;}),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child:InkWell(child:
                                            Card(
                                                child:
                                                    Column(children: <Widget>[
                                              Text("buy potions"),
                                              Image(
                                                  height: avatarRadius,
                                                  width: avatarRadius,
                                                  image: AssetImage(
                                                      'assets/images/potion.png')),
                                            ])),
                                              onTap: (){if(game.resources['gold']>100){
                                                game.resources['gold']-100;
                                                game.resources['potion']+1;
                                              }
                                            }),
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                              ListView(//Shop
                                  children: <Widget>[
                                Image(
                                    width: size.width,
                                    image:
                                        AssetImage('assets/images/snow_a.png')),
                                Text("The village is covered in snow"),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      key: key,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _togglePause(),
        child: Image(
            height: avatarRadius,
            width: avatarRadius,
            image: AssetImage('assets/images/potion.png')),
      ),
    );
  }

  //   else {return Container(color: Colors.deepPurple[200]);}
  //}

  void _togglePause() {
    /*
    paused = !paused;
    if (paused) {
      game.resumeEngine();
      return;
    }
    game.pauseEngine();
    return;
    */
    if (game.redwarrior.hp < game.redwarrior.maxhp &&
        game.resources['potions'] > 0) {
      game.redwarrior.hp += 1000;
      game.stats["hp"] += 1000;
      game.resources['potions'] -= 1;
    }
  }
}
