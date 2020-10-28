import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class LiveChat extends StatefulWidget {
  LiveChat({Key key}) : super(key: key);

  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("ABC")),
      body: StreamBuilder(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error reading heading: ${snapshot.error}');
          }

          DateTime now = DateTime.now();
          double direction = snapshot.data;
          if (direction == null) {
            direction = 0;
          }
          //return Text("direction: $direction");
          return OuterRing(deviceDirection: direction);
        }
      )
    );
  }
}

class OuterRing extends StatefulWidget {
  OuterRing({Key key, this.deviceDirection}) : super(key: key);

  double deviceDirection = 0;

  _OuterRingState createState() => _OuterRingState();
}

class _OuterRingState extends State<OuterRing> {
  //List<TextBubble> textBubbles;
  TextBubble textBubbles;

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    double displayAreaWidth = 300;
    double displayAreaHeight = 450;
    textBubbles = new TextBubble();
    textBubbles.direction = 0;
    textBubbles.text = "abcdefg";
    return SizedBox(
      width: displayAreaWidth,
      height: displayAreaHeight,
      child: Container(
        color: Colors.lightBlueAccent,
        child: CustomMultiChildLayout(
          delegate: OuterRingLayoutDelegate(textBubbles, widget.deviceDirection, displayAreaHeight, displayAreaWidth),
          children: [
            LayoutId(
              id: 1,
              child: Text(textBubbles.text)
            )
          ],
        )
      )
    );
  }
}

class OuterRingLayoutDelegate extends MultiChildLayoutDelegate {
  //List<TextBubble> textBubbles;
  TextBubble textBubbles;
  double deviceDirection;
  double displayAreaHeight;
  double displayAreaWidth;
  double aspectAngle;

  OuterRingLayoutDelegate(this.textBubbles, double deviceDirection, this.displayAreaHeight, this.displayAreaWidth) {
    aspectAngle = math.atan(displayAreaHeight / displayAreaWidth);
    this.deviceDirection = (deviceDirection / 360) * 2 * math.pi;
  }

  void performLayout(Size size) {

    if (hasChild(1)) {
      layoutChild(
        1,
        BoxConstraints.tight(size)
      );

      double x;
      double y;
      if ((deviceDirection >= ((math.pi / 2) - aspectAngle)) && (deviceDirection < ((math.pi / 2) + aspectAngle))) {
        x = 0;
        y = (displayAreaHeight / 2) - ((displayAreaWidth / 2) * math.tan((math.pi / 2) - deviceDirection));
      }
      else if ((deviceDirection >= ((math.pi / 2) + aspectAngle)) && (deviceDirection < (1.5 * math.pi - aspectAngle))){
        y = displayAreaHeight - 50;
        x = (displayAreaWidth / 2) - ((displayAreaHeight / 2) * math.tan(math.pi - deviceDirection));
      }
      else if ((deviceDirection >= (1.5 * math.pi - aspectAngle)) && (deviceDirection < (1.5 * math.pi + aspectAngle))) {
        x = displayAreaWidth - 100;
        y = (displayAreaHeight / 2) + ((displayAreaWidth / 2) * math.tan((1.5 * math.pi) - deviceDirection));
      }
      else {
        y = 0;
        x = (displayAreaWidth / 2) - ((displayAreaHeight / 2) * math.tan(deviceDirection));
      }
      /*
      if (deviceDirection < ((math.pi / 2) - aspectAngle)) {
        y = 0;
        x = (displayAreaWidth / 2) - ((displayAreaHeight / 2) * math.tan(deviceDirection));
      }
      else if (deviceDirection >= (1.5 * math.pi + aspectAngle)) {
        y = 0;
        x = (displayAreaWidth / 2) + ((displayAreaHeight / 2) * math.tan(2 * math.pi - deviceDirection));
      }
      else if (deviceDirection >= (math.pi + ((math.pi / 2) - aspectAngle))) {
        x = 0;
        y = 
      }
       */
      positionChild(1, Offset(x, y));
    }
  }

  bool shouldRelayout(OuterRingLayoutDelegate oldDelegate) {
    return oldDelegate.deviceDirection != deviceDirection;
  }
}

class TextBubble {
  String text;
  double direction;
}