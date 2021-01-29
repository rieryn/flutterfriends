import 'dart:math';
import 'dart:ui';

import 'package:flame/components/parallax_component.dart';
import 'package:flame/components/particle_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/particle.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';
import 'package:parallax/red_warrior.dart';
import 'package:parallax/slime.dart';
import 'package:provider/provider.dart';

import 'bounding_box.dart';
import 'demon.dart';
import 'game_data.dart';
import 'ghost.dart';
import 'monster.dart';

class MyGame extends BaseGame with ChangeNotifier {
  Particle g;
  SpriteAnimation debugAnimation;
  ParticleComponent particle;
  BoundingBox boundingBox = BoundingBox();
  RedWarrior redwarrior;
  SpriteSheet warriorSheet;
  Monster monster;
  Monster demon;
  SpriteComponent vampireSpriteComponent;
  SpriteComponent bg;
  ParallaxComponent background;
  Vector2 spawnPosition;
  Vector2 enemySpawnPosition;
  Vector2 playerSize;
  Vector2 monsterSize;
  bool battle;
  GameData data;
  List<ParallaxImage> bg_images =[];
  Map<String, double> stats = {};
  Map<String, double> enemystats = {};
  Map<String, int> resources = {};
  Map<String, int> upgrades = {};

  @override
  Future<void> onLoad() async {}

  MyGame(Vector2 widgetSize, BuildContext context) {
    data = GameData.pack();
    //just modify this directly
    stats = {
      "hp": 5000,
      "maxhp": 5000,
      "atk": 20,
      "armor": 0,
      "spd": 40,
      "dex": 10,
      "luck": 0, //doesn't do anything as usual
    };
    enemystats = {
      "hp": 1000,
      "maxhp": 1000,
      "atk": 20,
    };
    resources = {
      "gold": 0,
      "potions": 0,
      "souls": 0,
      "carrots": 0,
      "eggs": 0,
      "faith": 0,
    };
    upgrades = { //0> disabled 1 > enabled, 2> bought
      "combo1": 1,
      'combo2': 0,
      'combo3': 0,
      'rocks': 1,
      'throwing knives':0,
      'shuriken': 0,
      'rifle': 0,
      'machinegun': 0,
      'laser cannon':0,
    };
    onResize(widgetSize);
    print("^ widget size > size size");
    boundingBox.rightBound = widgetSize.x - 100;
    boundingBox.bottomBound = widgetSize.y - 150;
    spawnPosition = Vector2(widgetSize.x / 15, widgetSize.y * 4 / 5);
    enemySpawnPosition = Vector2(widgetSize.x * 4 / 5, widgetSize.y * 2 / 5);
    playerSize = widgetSize /2;
    monsterSize = widgetSize/3;
    Flame.images.load('warrior_sheet.png');
    final image = Flame.images.fromCache('rowrow_2.png');
    final _animationSpriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(74, 70),
    );
    debugAnimation =
        _animationSpriteSheet.createAnimation(row: 0, stepTime: 0.03);
    bg_images = [
      /*
      ParallaxImage('dwood_1.png'),
      ParallaxImage('dwood_2.png'),
      ParallaxImage('dwood_3.png'),
      ParallaxImage('dwood_4.png'),*/
      ParallaxImage('redawn_1.png', fill: LayerFill.height),
      ParallaxImage('redawn_2.png'),
      ParallaxImage('redawn_3.png'),
      ParallaxImage('redawn_4.png'),
      ParallaxImage('redawn_5.png'),
      ParallaxImage('redawn_6.png'),
    ];
    background = ParallaxComponent(
      bg_images,
      baseSpeed: Vector2(0, 0),
      layerDelta: Vector2(100, 0),
    );
    add(background);
    warriorSheet = SpriteSheet(
      image: Flame.images.fromCache('warrior_sheet.png'),
      srcSize: Vector2(1110 / 15, 1998 / 27),
    );
    Flame.images.load('rowrow_2.png');
    List<String> ghost_images = [
      'ghost_appear.png',
      'ghost_attack.png',
      'ghost_die.png',
      'ghost_idle.png'
    ];
    Flame.images.loadAll(ghost_images);
    Flame.images.load('slime_sheet.png');
    List<String> demon_images = [
      'demon_attack1.png',
      'demon_attack2.png',
      'demon_idle.png'
    ];
    Flame.images.loadAll(demon_images);
    redwarrior = RedWarrior(
        warriorSheet, debugAnimation, boundingBox, playerSize, spawnPosition);
    add(redwarrior);
    demon = Slime(
        debugAnimation, boundingBox, 1, monsterSize, enemySpawnPosition);
    add(demon);
    battle = true;
  }

  @override
  void update(t) {
    redwarrior?.enemyBox = null;
    demon?.enemyBox = null;
    if (demon.isDead == false && battle == true) {
      combatHandler(redwarrior, demon);
    }
    cleanUp();

    //if(data.playerhp!=redwarrior.hp.toInt()){data.playerHp=redwarrior.hp.toInt();}
    updateGameData();
    GameController.instance.updateStream(data);
    super.update(t);
  }

  @override
  void render(Canvas c) {
    Paint paint = Paint();
    paint.color = Colors.amber;
    //Rect rect =Rect.fromLTWH(0,0,500,300);
    //c.drawRect(demon.hitBox, paint);
    super.render(c);
  }

  void updateGameData() {
    data?.stats = stats;
    data?.resources = resources;
    data?.upgrades = upgrades;
    data?.enemystats = enemystats;
  }

  //we can extend this by doing like a spatial hash and feeding the player the
  //closest target or closest 2-3 boxes, same for implementing multiplayer
  void combatHandler(RedWarrior redWarrior, Monster monster) {
    background.layerDelta = Vector2(150, 0);
    redwarrior.battle = true;
    targetHandler(redWarrior, monster);
    damageHandler(redWarrior, monster);
  }

  void targetHandler(RedWarrior redWarrior, Monster monster) {
    redwarrior.enemyBox = monster.hitBox;
    monster.enemyBox = redwarrior.hitBox;
    redwarrior.enemyPosition = monster.position;
    monster.enemyPosition = redwarrior.position;
  }

  void damageHandler(RedWarrior redWarrior, Monster monster) {
    if (redwarrior.collided && monster.collided) {
      if (redwarrior.isAttacking) {
        monster.hp -= redwarrior.damage;
        enemystats['hp'] = monster.hp;
      }
      if (monster.isAttacking && !redwarrior.invuln) {
        redwarrior.hp -= monster.damage;
        stats['hp'] = redwarrior.hp;
      }
    }
  }

  void cleanUp() async {
    if (demon.cleanup == true) {
      battle = false;
      background.layerDelta = Vector2(300, 0);
      redwarrior.enemyBox = null;
      redwarrior.enemyPosition = Vector2(1000, 1000);
      redwarrior.battle = false;
      demon.cleanup = false;
      demon.remove();
      await Future<void>.delayed(const Duration(seconds: 15));
      demon = newMonster();
      demon.position = Vector2(200, 200);
      add(demon);
      enemystats = demon.stats;
      demon.isDead = false;
    }
    if (redwarrior.isDead) {
      demon.hitBox = null;
    }
  }

  //
  void lootHandler() {
    final rng = Random();
    int random = rng.nextInt(400);
    resources['gold'] += random;
    final rng2 = Random();
    random = rng2.nextInt(5);
    resources['souls'] += random;
    final rng3 = Random();
    random = rng3.nextDouble().toInt();
    resources['potions'] += random;
  }

  Monster newMonster() {
    battle = true;
    print("running newmonter");
    //pick a new monster
    //list the current monsters here so i don't forget
    //demon, ghost, slime
    lootHandler();
    final rng = Random();
    int random = rng.nextInt(3);
    final rng2 = Random();
    double randomDub = 1+2*rng2.nextDouble();
    switch (random) {
      case 0:
        monster = Slime(debugAnimation, boundingBox, 1,monsterSize*randomDub,
            enemySpawnPosition);
        break;
      case 1:
        monster = Ghost(debugAnimation, boundingBox, 1, monsterSize*randomDub,
            enemySpawnPosition);
        break;
      case 2:
        monster = Demon(debugAnimation, boundingBox, 1, monsterSize*randomDub,
            enemySpawnPosition);
        break;
    }
    print("created new component");
    print(monster);
    return monster;
  }

  void updateListeners() {}

  @override
  void onTap() {
    redwarrior.battle = !redwarrior.battle;
    print("tapped, battle:" + redwarrior.battle.toString());
  }
//pause bg
//parallaxComponent.layerDelta = Vector2(0,0);

}
