import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/flame.dart';
import 'package:flame/assets/images.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/components/particle_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/particle.dart';
import 'package:flame/particles/circle_particle.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

import 'bounding_box.dart';
import 'monster.dart';

class Demon extends Monster {
  Demon(SpriteAnimation animation, BoundingBox boundingBox,
      double deflationConst, Vector2 size, Vector2 spawnPosition)
      : super(animation, boundingBox, deflationConst, size, spawnPosition) {
    print("loading demon component");
    List<String> demon_images = [
      'demon_attack1.png',
      'demon_attack2.png',
      'demon_idle.png'
    ];
    Flame.images.loadAll(demon_images);
  }

  @override
  double stepTime = 0.2;
  @override
  bool combo1 = true;

  @override
  void onMount() {
    final demonAttack1 = SpriteSheet(
      image: Flame.images.fromCache('demon_attack1.png'),
      srcSize: Vector2(2640 / 11, 192),
    );
    final demonAttack2 = SpriteSheet(
      image: Flame.images.fromCache('demon_attack2.png'),
      srcSize: Vector2(1536 / 8, 176),
    );

    final demonIdle = SpriteSheet(
      image: Flame.images.fromCache('demon_idle.png'),
      srcSize: Vector2(960 / 6, 144),
    );
    animations = {
      'demonIdle':
          demonIdle.createAnimation(row: 0, stepTime: 0.1, to: 6, loop: false),
      'demonAttack1': demonAttack1.createAnimation(
          row: 0, stepTime: 0.1, to: 8, loop: false),
      'demonAttack2': demonAttack2.createAnimation(
          row: 0, stepTime: 0.1, to: 11, loop: false),
      'demonCorpse':
          demonIdle.createAnimation(row: 0, stepTime: 0.1, to: 20, loop: false),
    };
    active();
    super.onMount();
  }

  @override
  void idle() {
    animation = animations['demonIdle'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }

  @override
  void attack1() {
    animation = animations['demonAttack1'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }

  @override
  void attack2() {
    animation = animations['demonAttack2'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }

  @override
  void dying() {
    animation = animations['demonIdle'];
    animation.reset(); //have him spray out particles i don't know
  }

  @override
  void dead() {
    animation = animations['demonCorpse'];
    animation.reset();
  }
}
