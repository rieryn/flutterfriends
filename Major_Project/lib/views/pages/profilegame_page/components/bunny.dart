import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';

import 'package:vector_math/vector_math_64.dart';

import 'bounding_box.dart';
import 'monster.dart';

class Bunny extends Monster{
  Bunny(SpriteAnimation animation, BoundingBox boundingBox, double deflationConst, Vector2 Size, Vector2 spawnPosition) : super(animation, boundingBox, deflationConst, Size, spawnPosition);


  @override
  void onMount() {
    position.y-20;
    bottomBound += 40;

    final bunnysheet = SpriteSheet(
        image: Flame.images.fromCache('bunny_sheet.png'),
        srcSize: Vector2(220/4, 444/6.0),
    );

    animations = {
      'bunnyIdle1': bunnysheet.createAnimation(row: 0, stepTime: 1, to: 4, loop:false),
      'bunnyNibble': bunnysheet.createAnimation(row: 1, stepTime: 0.5, to: 4, loop:false),
      'bunnyRun': bunnysheet.createAnimation(row: 2, stepTime: 0.2, to: 4, loop:false),
      'bunnyJump': bunnysheet.createAnimation(row: 3, stepTime: 0.5, to: 4, loop:false),
      'bunnyAttack': bunnysheet.createAnimation(row: 4, stepTime: 0.5, to: 4, loop:false),
      'bunnyIdle2': bunnysheet.createAnimation(row: 5, stepTime: 0.5, to: 4, loop:false),

    };
    idle();
    animation.onComplete = wander;
    super.onMount();
  }
  //animation handlers
  void idle(){
    animation = animations['bunnyIdle1'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  void attack1(){
    animation = animations['bunnyNibble'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  void attack2(){
    animation = animations['bunnyAttack'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  void move(){
    animation = animations['bunnyRun'];
    animation.stepTime = stepTime;
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  //check distance from player
  void checkLeash(){
    directionToTarget.x = position.x - enemyPosition.x;
    if (directionToTarget.x > 20){
      velocity.x-directionToTarget.normalized().x;
    }
    if (directionToTarget.x < 20){
      velocity.x+directionToTarget.normalized().x;
    }
    if(position.y<(bottomBound-20)){
      velocity.y = 0.5;
    }

  }
  void checkIdle(){
    if (velocity == Vector2(0,0)){
      idle();
    }
  }
  //states
  void wander(){
    move();
    final rng = Random();
    int random = 5- rng.nextInt(10);
    velocity.x += random;
    if(velocity.x >5){velocity.x -= 2*random;}
    if(velocity.x <-5){velocity.x += 2*random;}
    checkLeash();
    checkIdle();
    animation.onComplete = wander;
  }
  @override
  void update(double t) {
    //update velocity by acceleration
    velocity += acceleration;
    //update position by velocity
    position += velocity;
    //update hitbox, the hitbox can be a child component if you have time
    hitBox = toRect().deflate(deflation);
    ticker += 1;
    if (ticker > 1000) {
      ticker = 0;
      print("interval");
    } //avoid overflow
    if (ticker % 159 == 0) {
      bounces = 0;
    }
    collision();
    boundsCollision();
    if (enemyPosition != null) {
      final Vector2 direction = position - enemyPosition;
      directionToTarget = direction.normalized();
    }
    if (collided) {
      bounce(directionToTarget, 2, bounces);
    }
    orientTowardsEnemy();
    super.update(t);
  }

  @override
  bool collision() {

  }

}