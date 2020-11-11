import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LiveChat extends StatefulWidget {
  LiveChat({Key key}) : super(key: key);

  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  @override
  void initState() {
    super.initState();
  }

  Future<locationAndDirection> getInitialLocationAndDirection() async {
    Position initialPosition = await Geolocator.getPositionStream().first;
    double initialDirection = await FlutterCompass.events.first;
    return new locationAndDirection(initialPosition, initialDirection);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getInitialLocationAndDirection(),
      builder: (context, fbSnapshot) {
        if (fbSnapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: const Text("ABC")),
            body: StreamBuilder(
              stream: Rx.combineLatest2(
                  Geolocator.getPositionStream(), FlutterCompass.events, (
                  location, direction) =>
                  locationAndDirection(location, direction)),
              initialData: fbSnapshot.data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("snapshot Error: ${snapshot.error}");
                }
                return OuterRing(deviceDirection: snapshot.data.direction,
                    location: snapshot.data.location);
              }
            )
          );
        }
        return Container(
          child: CircularProgressIndicator(),
          alignment: Alignment.center,
        );
      }
    );
  }
}

class locationAndDirection {
  Position location;
  double direction;

  locationAndDirection(this.location, this.direction);
}

class OuterRing extends StatefulWidget {
  OuterRing({Key key, this.deviceDirection, this.location}) : super(key: key);

  double deviceDirection;
  Position location;

  _OuterRingState createState() => _OuterRingState();
}

class _OuterRingState extends State<OuterRing> {
  List<TextBubble> textBubbles = new List<TextBubble>();
  List<Widget> layoutChildren = new List<Widget>();

  void initState() {
    super.initState();
    textBubbles.add(new TextBubble("north", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("east", Position(latitude: widget.location.latitude, longitude: widget.location.longitude + 1)));
    textBubbles.add(new TextBubble("south", Position(latitude: widget.location.latitude - 1, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("west", Position(latitude: widget.location.latitude, longitude: widget.location.longitude - 1)));
    for (int i = 0; i < textBubbles.length; i++) {
      layoutChildren.add(LayoutId(
        id: i,
        child: Container(
            color: Colors.green,
            child: Text(textBubbles[i].text),
            padding: EdgeInsets.all(10.0)
        ),
      ));
    }
  }

  Widget build(BuildContext context) {

    return Container(
      color: Colors.lightBlueAccent,
      child: CustomMultiChildLayout(
        delegate: OuterRingLayoutDelegate(textBubbles, widget.deviceDirection, widget.location),
        children: layoutChildren,
      )
    );
  }
}

class OuterRingLayoutDelegate extends MultiChildLayoutDelegate {
  List<TextBubble> textBubbles;
  double deviceDirection;
  double displayAreaHeight;
  double displayAreaWidth;
  double aspectAngle;
  Position location;

  OuterRingLayoutDelegate(this.textBubbles, double deviceDirection, this.location) {
    this.deviceDirection = (deviceDirection / 360) * 2 * math.pi;
  }

  void performLayout(Size size) {
    displayAreaWidth = size.width;
    displayAreaHeight = size.height;
    aspectAngle = math.atan(displayAreaHeight / displayAreaWidth);
    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {
        Size childSize = layoutChild(
            i,
            BoxConstraints.loose(size)
        );

        double textBubbleDirection = (GeolocatorPlatform.instance.bearingBetween(location.latitude, location.longitude, textBubbles[i].location.latitude, textBubbles[i].location.longitude) / 360) * 2 * math.pi;
        if (textBubbleDirection < 0) {
          textBubbleDirection += 2 * math.pi;
        }
        if (textBubbleDirection > deviceDirection) {
          textBubbleDirection = 2 * math.pi - (textBubbleDirection - deviceDirection);
        }
        else {
          textBubbleDirection = deviceDirection - textBubbleDirection;
        }

        double x;
        double y;
        if ((textBubbleDirection >= ((math.pi / 2) - aspectAngle)) &&
            (textBubbleDirection < ((math.pi / 2) + aspectAngle))) {
          x = 0;
          y = (((displayAreaHeight / 2) - ((displayAreaWidth / 2) *
              math.tan((math.pi / 2) - textBubbleDirection))) / displayAreaHeight) *
              (displayAreaHeight - childSize.height);
        }
        else if ((textBubbleDirection >= ((math.pi / 2) + aspectAngle)) &&
            (textBubbleDirection < (1.5 * math.pi - aspectAngle))) {
          y = displayAreaHeight - childSize.height;
          x = (((displayAreaWidth / 2) -
              ((displayAreaHeight / 2) * math.tan(math.pi - textBubbleDirection))) /
              displayAreaWidth) * (displayAreaWidth - childSize.width);
        }
        else if ((textBubbleDirection >= (1.5 * math.pi - aspectAngle)) &&
            (textBubbleDirection < (1.5 * math.pi + aspectAngle))) {
          x = displayAreaWidth - childSize.width;
          y = (((displayAreaHeight / 2) + ((displayAreaWidth / 2) *
              math.tan((1.5 * math.pi) - textBubbleDirection))) /
              displayAreaHeight) * (displayAreaHeight - childSize.height);
        }
        else {
          y = 0;
          x = (((displayAreaWidth / 2) -
              ((displayAreaHeight / 2) * math.tan(textBubbleDirection))) /
              displayAreaWidth) * (displayAreaWidth - childSize.width);
        }
        positionChild(i, Offset(x, y));

      }
    }
  }

  bool shouldRelayout(OuterRingLayoutDelegate oldDelegate) {
    return oldDelegate.deviceDirection != deviceDirection;
  }

}

class TextBubble {
  String text;
  Position location;

  TextBubble(this.text, this.location);
}