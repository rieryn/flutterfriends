import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flame/flame.dart';

import 'bounding_box.dart';
import 'main.dart';

enum State {
  running,
  attacking,
  sliding,
  dying,
  dead,
}
//only 4-6 inputs, so a simple switch is fine
enum Input {
  attack,//do an attack animation
  comboAttack,
  useItem,
  none, //null
}

//todo: attach more components to it it's hillarious
class RedWarrior extends SpriteAnimationComponent {
  //init vars    Rect rect =Rect.fromLTWH(0,0,500,300);
  double leftBound;
  double rightBound;
  double topBound;
  double bottomBound;
  Vector2 startPosition;
  Map<String, int> upgrades ={};
  Map<String, SpriteAnimation> animations;
  final double deflation = 70;

  //ticker vars, these are read by the states so we just modify them to control the behavior
  //todo: check if components can be accessed from outside basegame
  @override
  Vector2 position;
  @override
  Vector2 size = Vector2(190,180);
  double stepTime = 0.1; //steptime: warriorFlourish? *3 warriorDie? *20
  //important
  double hp = 4000;
  double maxhp = 4000;
  double attack = 20;
  double damage = 50;
  bool isAttacking = false;
  bool isDead = false;
  bool hitstun = false;
  bool invuln = false;

  Input input = Input.none;
  bool enableInput = true;
  bool combo1 = true;       //combo attacks unlocked
  bool combo2 = true;       //todo:set to false after testing
  bool combo3 = true;
  bool battle = false;      //battle location
  bool safe = false;        //safe location
  bool collided = false;    //collision state
  bool flipAnimation = false;
  Rect hitBox;
  Rect enemyBox;
  Vector2 enemyPosition = Vector2(0,0);
  bool enemyDead = false;
  double wallBounces = 0;
  double bounces = 0;
  bool lockPosition = false; //if component can be moved
  bool interruptible = true; //if the animation can be cancelled
  Vector2 velocity = Vector2(0,0);
  Vector2 acceleration = Vector2(0,0);
  Vector2 directionToTarget = Vector2(0,0);
  double speed = 0.02;
  RedWarrior(SpriteSheet warriorSheet, SpriteAnimation animation, BoundingBox boundingBox, Vector2 playerSize, Vector2 spawnPosition) : super(Vector2(190,180),  animation) {
    upgrades = {
      "combo1": 1,
      'combo2': 0,
      'combo3': 0,
    };
    size = playerSize;
    print("loading warrior component");
    leftBound  = boundingBox.leftBound;
    rightBound = boundingBox.rightBound;
    topBound = boundingBox.topBound;
    bottomBound = boundingBox.bottomBound;
    position = spawnPosition;
    startPosition = spawnPosition;
   //process spritesheet
    animations = {
      "warriorSpin" : warriorSheet.createAnimation(row: 0, stepTime: 0.1, to: 4,loop:false),
     'warriorWalkDown': warriorSheet.createAnimation(row: 1, stepTime: 0.1, to: 12,loop:false),
     'warriorWalkSideActive': warriorSheet.createAnimation(row: 2, stepTime: 0.1, to: 12,loop:false),
     'warriorWalkSidePassive' : warriorSheet.createAnimation(row: 3, stepTime: 0.1, to: 12,loop:false),
     'warriorWalkUp' : warriorSheet.createAnimation(row: 4, stepTime: 0.1, to: 12,loop:false),
     'warriorAttackDown' : warriorSheet.createAnimation(row: 5, stepTime: 0.1, to: 10,loop:false),
      'warriorComboDown' : warriorSheet.createAnimation(row: 6, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerDown' : warriorSheet.createAnimation(row: 7, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackSide' : warriorSheet.createAnimation(row: 8, stepTime: 0.1, to: 10,loop:false),
      'warriorComboSide' : warriorSheet.createAnimation(row: 9, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerSide' : warriorSheet.createAnimation(row: 10, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackSideR' : warriorSheet.createAnimation(row: 11, stepTime: 0.1, to: 10,loop:false),
      'warriorComboSideR' : warriorSheet.createAnimation(row: 12, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerSideR' : warriorSheet.createAnimation(row: 13, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackUp' : warriorSheet.createAnimation(row: 14, stepTime: 0.1, to: 10,loop:false),
      'warriorComboUp' : warriorSheet.createAnimation(row: 15, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerUp' : warriorSheet.createAnimation(row: 16, stepTime: 0.1, to: 15,loop:false),
      'warriorFall' : warriorSheet.createAnimation(row: 17, stepTime: 0.1, to: 5,loop:false),
      'warriorDash' : warriorSheet.createAnimation(row: 18, stepTime: 0.1, to: 5,loop:false),
      'warriorDashR' : warriorSheet.createAnimation(row: 19, stepTime: 0.1, to: 5,loop:false),
      'warriorDashUp' : warriorSheet.createAnimation(row: 20, stepTime: 0.1, to: 5,loop:false),
      'warriorGlowFront' : warriorSheet.createAnimation(row: 21, stepTime: 0.2, to: 2,loop:false),
      'warriorGlowSide' : warriorSheet.createAnimation(row: 22, stepTime: 0.1, to: 2,loop:false),
      'warriorGlowSideR' : warriorSheet.createAnimation(row: 23, stepTime: 0.1, to: 2,loop:false),
      'warriorBlink' : warriorSheet.createAnimation(row: 24, stepTime: 0.3, to: 13,loop:false),
      'warriorFlourish' : warriorSheet.createAnimation(row: 25, stepTime: 0.3, to: 15,loop:false),
      'warriorDie' : warriorSheet.createAnimation(row: 26, stepTime: 2, to: 3,loop:false),
      //type animation for simplicity but flame will convert it to a static sprite
      'warriorDead': warriorSheet.createAnimation(row: 26, stepTime: 2, from: 1, to: 2,loop:false),
    };
    //starting animation
    init();
  }
  void init(){
    animation=animations["warriorWalkSidePassive"];
    animation.loop = false;
    //initial state
    animation.onComplete = passive;
    hitBox = toRect().deflate(deflation);
  }
  void f (){
    print("animation complete");
  }
  double ticker= 0;
  @override
  void update(double t) {
    //check for overrides every update, override the state machine
    enableInput? overrideState(input): print("input disabled");
    //update velocity by acceleration
    if(!lockPosition)
      {velocity += acceleration;
    //update position by velocity
    position += velocity;}
    if(position==startPosition){stop();}
    //update hitbox, the hitbox can be a child component if you have time
    hitBox = toRect().deflate(deflation);
    ticker+=1;
    if(ticker>1000){ticker = 0;}//avoid overflow
    if(ticker%159==0){bounces = 0;wallBounces = 0;}
    collided = collision();
    boundsCollision();
    if(enemyPosition!= null){
      final Vector2 direction = position - enemyPosition;
      directionToTarget = direction.normalized();
    }
    if(collided) {
      bounce(directionToTarget, 2, bounces);
    }
    orientTowardsEnemy();
    super.update(t);
  }
  //override state on manual input
  void overrideState(Input input){
    switch (input){
      case Input.none:
        return;
      case Input.attack:
        return;
    }
  }
  //these handlers change the animation
  //flipx because there's just one row of sprites going on the wrong direction
  void passiveWalk(){
    animation = animations["warriorWalkSidePassive"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void weaponOutWalk(){
    animation = animations["warriorWalkSideActive"];
    renderFlipX = !flipAnimation;
    animation.reset();
  }
  void attack1(){
    animation = animations["warriorAttackSideR"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void attack2(){
    animation = animations["warriorComboSideR"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void attack3(){
    animation = animations["warriorPowerSideR"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void dying(){
    animation = animations["warriorDie"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void dead(){
    animation = animations["warriorDead"];
    renderFlipX = flipAnimation;
    animation.reset();
  }
  void revive(){
    animation = animations["warriorGlowFront"];
    renderFlipX = flipAnimation;
    animation.loop = true;
    animation.reset();
  }
  //handlers for movement
  void backToStart(){
    stop();
    final Vector2 offset = position-startPosition;
    acceleration -= offset.normalized()*speed*0.8;
  }
  void moveForward(){
    acceleration += Vector2(1,0)*speed;
  }
  void stop(){
    velocity = Vector2(0,0);
    acceleration = Vector2(0,0);
  }
  void aggressiveMoveToTarget(){
    acceleration -= directionToTarget*speed*20;

  }
  void checkIfInitialPosition(){
    if (position==startPosition){
      stop();
      passiveWalk();
      animation.onComplete = passive;
    }
  }
  void orientTowardsEnemy(){
    if(enemyPosition!=null && lockPosition !=true){
      if(enemyPosition.x<position.x){
        flipAnimation = true;
      }
      if(enemyPosition.x>position.x){
        flipAnimation = false;
      }
    }
  }
  //states are functions, they read the ticker and perform a transition to next state
  //usually onAnimationComplete points to the next state
  //if we need to interrupt an animation we call onComplete to force the transition
  //seems like flame stores the animation state so you get it back on that frame if you don't reset
  void passive(){
    isAttacking = false;
    print("passive state");
    passiveWalk();
    backToStart();
    animation.onComplete = passive; //loop
    animation.onComplete = battle? active : passive;
    checkDead();
  }
  void active(){
    isAttacking = false;
    print("active state");
    weaponOutWalk();
    //moveForward();
    if(enemyPosition!=null) {
      aggressiveMoveToTarget();}
      animation.onComplete = battle? active : passive;
      if(collided){
        attack1();
        aggressiveMoveToTarget();
        animation.onComplete = collided? attacking : active;
      }
    checkDead();
    }
  void attacking(){
    isAttacking = true;
    damage = attack;
    attack1();
    aggressiveMoveToTarget();
    animation.onComplete = collided? upgrades['combo1'] == 2? comboAttacking : attacking : active;
    checkDead();
  }
  void comboAttacking(){
    isAttacking = true;
    damage = attack*1.5;
    attack2();
    aggressiveMoveToTarget();
    animation.onComplete = collided? upgrades['combo2'] == 2? powerAttacking : attacking : active;
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
  void dyingState() async {
    isAttacking = false;
    lockPosition = true;
    stop();
    dying();
    await Future<void>.delayed(const Duration(seconds : 2));
    animation.onComplete = revivingState;
  }
  //on terminal state notify the game engine
  //the player component should have no terminal state, dead should always call revive after x ticks
  //other components can remove themselves
  void revivingState() async {
    isAttacking = false;
    revive();
    position = startPosition;
    stop();
    hp = maxhp;
    stop();
    await Future<void>.delayed(const Duration(seconds : 5));
    animation.loop = false;
    lockPosition = false;
    invuln=false;
    isDead = false;
    animation.onComplete = passive;
  }
  //these fns run in update and override state if necessary
  bool collision() {
    if(battle == false){return false;}
    if(lockPosition == true){return false;}
    if(enemyBox == null){return false;}
    collided = hitBox.overlaps(enemyBox);
    if(collided && interruptible) {
      animation.onComplete.call(); //force the state transition
    }
    return collided;
  }
  void bounce(Vector2 direction, double spd,double bounce){
    bounces+=0.5;
    velocity = direction*bounce*spd;
    acceleration =
        direction * -0.3*spd; //bounce speed should be constant, actually bounce should increment based on occurences in x time
    //then increasing player speed will allow longer combo chains
  }
  void boundsCollision(){

    wallBounces +=0.1;
    if(position.x < leftBound){stop();position = Vector2(leftBound,position.y);bounce(Vector2(1,0), 0.2,wallBounces);}
    if(position.x > rightBound){stop();position = Vector2(rightBound,position.y);bounce(Vector2(-1,0),0.2,wallBounces);}
    if(position.y < topBound){stop();position = Vector2(position.x,topBound);bounce(Vector2(0,1),0.2,wallBounces);}
    if(position.y > bottomBound){stop();position = Vector2(position.x,bottomBound);bounce(Vector2(0,-1),0.2,wallBounces);}
  }
  void checkDead(){
    if(hp<0){
      invuln = true;
      isDead = true;
      isAttacking = false;
      animation.onComplete = dyingState;
    }
  }
}
