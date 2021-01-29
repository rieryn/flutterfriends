
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


class Ghost extends Monster{
  Ghost(SpriteAnimation animation, BoundingBox boundingBox, double deflationConst, Vector2 size, Vector2 spawnPosition) : super(animation, boundingBox, deflationConst, size,spawnPosition){
    print("loading ghost component");
    List<String> ghost_images = ['ghost_appear.png','ghost_attack.png','ghost_die.png','ghost_idle.png'];
    Flame.images.loadAll(ghost_images);
    //seems like this doesn't work so well
  }
  @override
  void onMount() {
    final ghost_appear = SpriteSheet(
        image: Flame.images.fromCache('ghost_appear.png'),
        srcSize: Vector2(384/6,44),
    );
    final ghost_attack = SpriteSheet(
    image: Flame.images.fromCache('ghost_attack.png'),
    srcSize: Vector2(256/4,80),
    );
    final ghost_die = SpriteSheet(
    image: Flame.images.fromCache('ghost_die.png'),
    srcSize: Vector2(448/7,64),
    );
    final ghost_idle = SpriteSheet(
    image: Flame.images.fromCache('ghost_idle.png'),
    srcSize: Vector2(448/7,80),
    );
    animations = {
      'ghostSpawn': ghost_appear.createAnimation(row: 0, stepTime: 0.1, to: 6,loop:false),
      'ghostAttack': ghost_attack.createAnimation(row: 0, stepTime: 0.1, to: 4,loop:false),
      'ghostIdle': ghost_idle.createAnimation(row: 0, stepTime: 0.1, to: 7,loop:false),
      'ghostDie': ghost_die.createAnimation(row: 0, stepTime: 0.1, to: 8,loop:false),

    };
    spawning();
    super.onMount();
  }

  @override
  void spawnIn(){
    animation = animations['ghostSpawn'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  @override
  void idle(){
    animation = animations['ghostIdle'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  @override
  void attack1(){
    animation = animations['ghostAttack'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }

  @override
  void dying(){
    animation = animations['ghostDie'];
    renderFlipX = !flipAnimation;
    animation.reset(); //have him spray out particles i don't know
  }


}