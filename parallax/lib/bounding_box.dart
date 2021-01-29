import 'package:flame/particle.dart';
import 'package:flame/particles/circle_particle.dart';
import 'package:flutter/material.dart';

class BoundingBox{
  double leftBound = -50;
  double rightBound = 300;
  double topBound = 50;
  double bottomBound = 250; //what you can do that?
}

Particle gradientParticles() {
  Color color = Colors.redAccent;
  double opacity = 0.5;
  const offset = const Offset(10,10);
  var gradient = RadialGradient(
    colors: [
      Color.fromRGBO(
          color.red, color.green, color.blue, opacity),
      Color.fromRGBO(
          color.red, color.green, color.blue,  opacity/2),
    ],
    stops: const [0.0, 0.5],
  );
  final Paint painter = Paint()
    ..style = PaintingStyle.fill
    ..shader = gradient.createShader(
        Rect.fromCircle(center: offset, radius: 2));
  return CircleParticle(
    paint: painter,
  );
}