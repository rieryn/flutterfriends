//monster states, aggressive, attacking, hitstun, dead
import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flame/flame.dart';


import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/sprite_animation.dart';
import 'package:vector_math/vector_math_64.dart';

import 'bounding_box.dart';

//todo: hurtboxes
//pass in a spriteanimation even if its nothing
class Monster extends SpriteAnimationComponent {
  //default pixels to reduce hitbox by, differs for each sprite
  //multiply this by deflation const, differs by screen
  double deflation = 30;
  @override
  Vector2 size = Vector2(190, 180);
  //init vars    Rect rect =Rect.fromLTWH(0,0,500,300);
  //modify bounds if its like, trapped
  double leftBound;
  double rightBound;
  double topBound;
  double bottomBound;
  Map<String, SpriteAnimation> animations;
  double mass = 100;

  //ticker vars, these are read by the states so we just modify them to control the behavior
  //todo: check if components can be accessed from outside basegame
  //important ones
  double hp = 1000;
  double maxhp = 1000;
  double attack = 20;
  double damage = 50;
  bool isDead = false;
  bool hitstun = false;
  bool isAttacking = false;

  double stepTime = 0.1;
  bool hasAttack = true; //some sprites don't...
  bool combo1 = false; //for the monster class this limits behavior to how many attacks the sprite has
  bool combo2 = false; //
  bool combo3 = false;
  bool collided = false; //collision state
  Rect hitBox;
  Rect enemyBox;
  Vector2 enemyPosition = Vector2(0, 0);

  bool cleanup = false;
  bool battle = true; //battle location
  bool safe = false; //safe location
  bool flipAnimation = false;
  bool enemyDead = false;
  double wallBounces = 0;
  double bounces = 0;
  bool lockPosition = false; //if component can be moved
  bool interruptible = true; //if the animation can be cancelled
  Vector2 velocity = Vector2(0, 0);
  Vector2 acceleration = Vector2(0, 0);
  Vector2 directionToTarget = Vector2(0, 0);
  double speed = 0.02;
  double ticker = 0;
  Map<String, double> stats = {};

  @mustCallSuper
  Monster(SpriteAnimation animation, BoundingBox boundingBox, double deflationConst,Vector2 Size, Vector2 spawnPosition)
      : super(Vector2(190, 180), animation) {
    print("constructing monster");
    leftBound  = boundingBox.leftBound;
    rightBound = boundingBox.rightBound;
    topBound = boundingBox.topBound;
    bottomBound = boundingBox.bottomBound;
    size = Size;
    deflation = Size.x/8;
    position = spawnPosition;
    //process spritesheet
    stats = {
      "hp": 1000,
      "maxhp": 1000,
    };

    init();
  }

  @mustCallSuper
  void init() {
    //starting animation

    hitBox = toRect().deflate(deflation);
  }

  void f() {
    print("animation complete");
  }

  @mustCallSuper
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

  //how do you mark methods as compulsory?
  //these handlers change the animation
  //flipx because there's just one row of sprites going on the wrong direction
  ///make sure you implement these

  void spawnIn(){

  }
  void passiveWalk() {

  }

  void idle() {

  }

  void attack1() {

  }

  void attack2() {

  }

  void attack3() {

  }
  void dying(){

  }
  void dead(){

  }

  //handlers for movement
 /*does monster need this
 void backToStart() {
    stop();
    final Vector2 offset = position - startPosition;
    acceleration -= offset.normalized() * speed * 0.8;
    print(offset.normalized());
  }*/

  void moveForward() {
    acceleration += Vector2(1, 0) * speed;
  }

  void stop() {

    velocity = Vector2(0, 0);
    acceleration = Vector2(0, 0);
  }

  void aggressiveMoveToTarget() {
    acceleration -= directionToTarget * speed * 20;
  }

  void orientTowardsEnemy() {
    if (enemyPosition != null) {
      if (enemyPosition.x < position.x) {
        flipAnimation = true;
      }
      if (enemyPosition.x > position.x) {
        flipAnimation = false;
      }
    }
  }

  //states are functions, they read the ticker and perform a transition to next state
  //i guess a type of bug that can occur is if the function takes longer than the animation
  //usually onAnimationComplete points to the next state
  //if we need to interrupt an animation we call onComplete to force the transition
  //seems like flame stores the animation state so you get it back on that frame if you don't reset
  void spawning(){
    spawnIn();
    animation.onComplete = active;
    //if there's no spawn in animation defined it'll skip
  }
  void active() {
    isAttacking = false;
    idle();
    //moveForward();
    if (enemyPosition != null) {
      aggressiveMoveToTarget();
    }
    animation.onComplete = active;
    if (collided) {
      attack1();
      aggressiveMoveToTarget();
      animation.onComplete = collided ? attacking : active;
    }
    checkDead();
  }

  void attacking(){
    isAttacking = true;
    damage = attack;
    attack1();
    aggressiveMoveToTarget();
    animation.onComplete = collided? combo1? comboAttacking : attacking : active;
    checkDead();

  }
  void comboAttacking(){
    isAttacking = true;
    damage= attack*1.5;
    attack2();
    aggressiveMoveToTarget();
    animation.onComplete = collided? combo2? powerAttacking : attacking : active;
    checkDead();

  }
  void powerAttacking(){
    isAttacking = true;
    damage = attack*2;
    attack3();
    aggressiveMoveToTarget();
    animation.onComplete = collided? attacking : active;
    checkDead();

  }
  void dyingState(){
    lockPosition = true;
    stop();
    dying();
    animation.onComplete = dead;
  }
  //on terminal state notify the game engine
  //the player component should have no terminal state, dead should always call revive after x ticks
  //other components can remove themselves
  void deadState(){
    dead();
    stop();
    lockPosition = true;
    velocity = Vector2(-1,0);
    //maybe add a wait
    //todo: leave component but mark dead, move off scren in x direction
    //nevermind he just gets knocked off the screen
    print("HE DEAD STOP");
    removeOnFinish = true;
  }

  //these fns run in update and override state if necessary
  bool collision() {
    if(lockPosition){return false;}
    if (enemyBox == null) {
      return false;
    }
    collided = hitBox.overlaps(enemyBox);
    if (collided && interruptible) {
      animation.onComplete.call(); //force the state transition
    }
    return collided;
  }

  void bounce(Vector2 direction, double spd, double bounce) {
    bounces += 1;
    velocity = direction * bounces * spd;
    acceleration =
        direction * -0.3 *
            spd; //bounce speed should be constant, actually bounce should increment based on occurences in x time
    //then increasing player speed will allow longer combo chains
  }

  void boundsCollision() { //todo: add a reflection calculation
    wallBounces += 1;
    if (position.x < leftBound) {
      bounce(Vector2(1, 0), 0.2, wallBounces);
    }
    if (position.x > rightBound) {
      bounce(Vector2(-1, 0), 0.2, wallBounces);
    }
    if (position.y < topBound) {
      bounce(Vector2(0, 1), 0.2, wallBounces);
    }
    if (position.y > bottomBound) {
      bounce(Vector2(0, -1), 0.2, wallBounces);
    }
  }
  void checkDead(){
    if(hp<0){
      isAttacking = false;
      isDead = true;
      cleanup = true;
      animation.onComplete = dyingState;
    }
  }


}