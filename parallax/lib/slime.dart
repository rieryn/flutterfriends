
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


class Slime extends Monster{
  Slime(SpriteAnimation animation, BoundingBox boundingBox, double deflationConst, Vector2 size,Vector2 spawnPosition) : super(animation, boundingBox, deflationConst, size,spawnPosition){
    print("loading slime component");
    Flame.images.load('slime_sheet.png');
  }

  @override
  void onMount() {
    final slime_sheet = SpriteSheet(
        image: Flame.images.fromCache('slime_sheet.png'),
        srcSize: Vector2(256/8,75/3),
    );
    animations = {
      'slimeIdle': slime_sheet.createAnimation(row: 0, stepTime: 0.1, to: 8,loop:false),
      'slimeAttack': slime_sheet.createAnimation(row: 1, stepTime: 0.1, to: 8,loop:false),
      'slimeDie': slime_sheet.createAnimation(row: 2, stepTime: 0.1, to: 8,loop:false),

    };
    active();
    super.onMount();
  }

  @override
  void idle(){
    animation = animations['slimeIdle'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  @override
  void attack1(){
    animation = animations['slimeAttack'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }

  @override
  void dying(){
    animation = animations['slimeDie'];
    renderFlipX = !flipAnimation;
    animation.reset(); //have him spray out particles i don't know
  }


}