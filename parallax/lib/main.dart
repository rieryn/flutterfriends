import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parallax/profile_page.dart';
import 'package:provider/provider.dart';

import 'fab.dart';
import 'game_data.dart';

void main() async {
  GameController.instance.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  await Flame.images.load('rowrow_2.png');
  await Flame.images.load('warrior_sheet.png');
  List<String> ghost_images = [
    'ghost_appear.png',
    'ghost_attack.png',
    'ghost_die.png',
    'ghost_idle.png'
  ];
  await Flame.images.loadAll(ghost_images);
  await Flame.images.load('slime_sheet.png');
  List<String> demon_images = [
    'demon_attack1.png',
    'demon_attack2.png',
    'demon_idle.png'
  ];
  await Flame.images.loadAll(demon_images);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation as a Widget Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameProfilePage(),
    );
  }
}
