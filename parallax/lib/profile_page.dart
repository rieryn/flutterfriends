import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:parallax/profile_content.dart';
import 'package:provider/provider.dart';

import 'game.dart';
import 'game_data.dart';


class GameProfilePage extends StatefulWidget {
  @override
  _GameProfilePageState createState() => _GameProfilePageState();
}

class _GameProfilePageState extends State<GameProfilePage>with SingleTickerProviderStateMixin  {
  MyGame game;
  String text = "test";
  bool paused = false;
  String longtext = "Paragraphs are the building blocks of papers. Many students define paragraphs in terms of length: a paragraph is a group of at least five sentences, a paragraph is half a page long, etc. In reality, though, the unity and coherence of ideas among sentences is what constitutes a paragraph. A paragraph is defined as “a group of sentences or a single sentence that forms a unit” (Lunsford and Connors 116). Length and appearance do not determine whether a section in a paper is a paragraph. For instance, in some styles of writing, particularly journalistic styles, a paragraph can be just one sentence long. Ultimately, a paragraph is a sentence or group of sentences that support one main idea. In this handout, we will refer to this as the “controlling idea,” because it controls what happens in the rest of the paragraph.";
  TabController _controller;

  @override
  void initState() {
    _controller =  TabController(length: 3, vsync: this);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final size = MediaQuery
        .of(context)
        .size;
    GameController.instance.init();
    final widgetSize = Vector2(size.width,size.height*15/40);
    final gameBottom = size.height/3;
    final contentHeight = size.height /3;
    final middleLeft = size.width/4;
    final middleRight = size.width*3/4;
    final avatarRadius = size.width/9;
    final key = GlobalKey<ScaffoldState>();
    game = MyGame(widgetSize, context);

    return Scaffold(
    body: Stack(
    fit: StackFit.expand,
      children: [
        Positioned.fill(
          bottom: gameBottom,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            //this is really inconsistent on emulator
            child: AspectRatio(aspectRatio:4/3,child:
            Container(
              height:size.height*2 / 3,
              width: size.width,
              child: game.widget,
            ),),
          ),
        ),
        Positioned.fill(
          child: GestureDetector( //button layer
            behavior: HitTestBehavior.deferToChild,
          ),
        ),
        Positioned.fill(
          top: contentHeight-avatarRadius/2,
          left: 0,
          right: 0,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: avatarRadius,
                left:0,
                child:Container(
                  height:size.height*2/3,
                  width: size.width,
                  decoration: BoxDecoration(
                    color:Colors.pink[50],
                      border: Border.all(
                        color: Colors.blueGrey[900],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                    //child:


                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                child:SizedBox(
                  height:size.height*2/3,
                  width: size.width,
                  child:  Content(game),
                ),

              ),
            ],
          ),

        ),

        Positioned.fill(
          top: contentHeight,
          left: size.width * 3 / 12,
          right: size.width * 3 / 12,
          bottom: 20,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.only(top: avatarRadius/2),
                      child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding:  EdgeInsets.only(top:avatarRadius*1.5,),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "Aurie",
                                  style: TextStyle(fontSize: avatarRadius/3),
                                ),
                                TabBar(
                                    isScrollable: true,

                                  labelStyle: TextStyle(fontSize: avatarRadius/4),
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
                        child: ClipOval(
                          child: Image(height: avatarRadius*2, width: avatarRadius*2,image:AssetImage('assets/images/test.jpg')),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: size.width *2/3,
                  height: size.height-contentHeight-avatarRadius*11/3-20,
                  child:Container(color:Colors.lightBlue[50],child:ListView(
                    children:<Widget>[

                      Container(
                        height: size.height-contentHeight-avatarRadius*3+10,
                        child: TabBarView(
                          controller: _controller,
                          children: <Widget>[
                            ListView( //About
                              padding: EdgeInsets.all(5),
                              children: <Widget>[
                              Row(
                                  children: <Widget>[
                                    Text("About me",
                                    style: TextStyle(
                                      color: Colors.blueGrey[300],

                                    ),),

                                    Expanded(
                                        child: Divider()
                                    ),
                                  ]
                              ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                    child:Text(longtext)),
                                Row(
                                    children: <Widget>[
                                      Text("Interests",
                                        style: TextStyle(
                                          color: Colors.blueGrey[300],

                                        ),),

                                      Expanded(
                                          child: Divider()
                                      ),
                                    ]
                                ),
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child:Text(longtext)),
                                Row(
                                    children: <Widget>[
                                      Text("Recently at",
                                        style: TextStyle(
                                          color: Colors.blueGrey[300],

                                        ),),

                                      Expanded(
                                          child: Divider()
                                      ),
                                    ]
                                ),
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child:Text(longtext)),
                    ],

                            ),
                            ListView( //Stats
                              children: <Widget>[
                                Image(
                                    width: size.width,
                                    image:
                                    AssetImage('assets/images/prestige_1.jpg')),
                                SizedBox(
                                  height:size.height-contentHeight-avatarRadius*11/3,
                                  width:size.width *2/3-20,
                                  child:                                GridView.count(mainAxisSpacing: 5, crossAxisSpacing: 5,
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                      crossAxisCount: 2,
                                      // Generate 100 widgets that display their index in the List.
                                      children: <Widget>[
                                        Card(child:Column(children:<Widget>[ Text("Kills"),Spacer(),Text("0"),])),
                                        Text(longtext),
                                        Text(longtext),
                                        Text(longtext),
                                        Text(longtext),
                                        Text(longtext),

                                      ]
                                  ),
                                ),
                                Text(longtext),
                                Text(longtext),
                                Text(longtext),
                                Text(longtext),
                                Text(longtext),


                              ],

                            ),
                            ListView( //Shop
                              children: <Widget>[
                                Image(
                                    width: size.width,
                                    image:
                                    AssetImage('assets/images/snow_a.png')),
                                Text("The Village is covered in snow"),
                              ]

                            ),


                          ],
                        ),
                      ),
                      Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider()
                            ),

                            Text("About ME"),

                            Expanded(
                                child: Divider()
                            ),
                          ]
                      ),
                            Card(
                            child:Text("About me: Hello everynyan!",)),

                      Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider()
                            ),

                            Text("OR"),

                            Expanded(
                                child: Divider()
                            ),
                          ]
                      ),
                      Text(longtext),
                      Container(
                        height: size.height/5,
                        child: Card(
                            child:Text(longtext,)),
                      ),                      Container(
                        height: size.height/5,
                        child: Card(
                            child:Text(longtext,)),
                      ),
                    ]
                  ),
                ),
                ),],
            ),
          ),
        ),
      ],
    ),
    key: key,

    floatingActionButton: FloatingActionButton(
    onPressed: () => _togglePause()),
    );
  }

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
    //example
    if(game.redwarrior.hp < game.redwarrior.maxhp&&game.resources['potions']>0){
     game.redwarrior.hp += 1000;
     game.stats["hp"] +=1000;
      game.resources['potions'] -=1;}
  }
}

