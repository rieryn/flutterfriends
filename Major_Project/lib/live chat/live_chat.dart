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
    textBubbles = new TextBubble();
    textBubbles.direction = 0;
    textBubbles.text = "an\nexample\n/\ntest\nlarge\ntext\npost\n" + widget.deviceDirection.toString();
    return Container(
      color: Colors.lightBlueAccent,
      child: CustomMultiChildLayout(
        delegate: OuterRingLayoutDelegate(textBubbles, widget.deviceDirection),
        children: [
          LayoutId(
            id: 1,
            child: Container(
              color: Colors.green,
              child: Text(textBubbles.text),
              padding: EdgeInsets.all(10.0),
            )
          )
        ],
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

  OuterRingLayoutDelegate(this.textBubbles, double deviceDirection) {

    this.deviceDirection = (deviceDirection / 360) * 2 * math.pi;
  }

  void performLayout(Size size) {
    displayAreaWidth = size.width;
    displayAreaHeight = size.height;
    aspectAngle = math.atan(displayAreaHeight / displayAreaWidth);
    if (hasChild(1)) {
      Size childSize = layoutChild(
        1,
        BoxConstraints.loose(size)
      );

      double x;
      double y;
      if ((deviceDirection >= ((math.pi / 2) - aspectAngle)) && (deviceDirection < ((math.pi / 2) + aspectAngle))) {
        x = 0;
        y = (((displayAreaHeight / 2) - ((displayAreaWidth / 2) * math.tan((math.pi / 2) - deviceDirection))) / displayAreaHeight) * (displayAreaHeight - childSize.height);
      }
      else if ((deviceDirection >= ((math.pi / 2) + aspectAngle)) && (deviceDirection < (1.5 * math.pi - aspectAngle))){
        y = displayAreaHeight - childSize.height;
        x = (((displayAreaWidth / 2) - ((displayAreaHeight / 2) * math.tan(math.pi - deviceDirection))) / displayAreaWidth) * (displayAreaWidth - childSize.width);
      }
      else if ((deviceDirection >= (1.5 * math.pi - aspectAngle)) && (deviceDirection < (1.5 * math.pi + aspectAngle))) {
        x = displayAreaWidth - childSize.width;
        y = (((displayAreaHeight / 2) + ((displayAreaWidth / 2) * math.tan((1.5 * math.pi) - deviceDirection))) / displayAreaHeight) * (displayAreaHeight - childSize.height);
      }
      else {
        y = 0;
        x = (((displayAreaWidth / 2) - ((displayAreaHeight / 2) * math.tan(deviceDirection))) / displayAreaWidth) * (displayAreaWidth - childSize.width);
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