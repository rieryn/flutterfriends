import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scidart/numdart.dart';

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
                return ChatField(deviceDirection: snapshot.data.direction,
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

class ChatField extends StatefulWidget {
  ChatField({Key key, this.deviceDirection, this.location}) : super(key: key);

  double deviceDirection;
  Position location;
  static Size displaySize = Size(0, 0);

  _ChatFieldState createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatField> {
  List<TextBubble> textBubbles = new List<TextBubble>();
  List<Widget> layoutChildren = new List<Widget>();

  void initState() {
    super.initState();
    textBubbles.add(new TextBubble("north", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0001)));
    textBubbles.add(new TextBubble("further northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0002)));
    //textBubbles.add(new TextBubble("even\nfurther northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0003)));
    textBubbles.add(new TextBubble("east", Position(latitude: widget.location.latitude, longitude: widget.location.longitude + 1)));
    textBubbles.add(new TextBubble("south", Position(latitude: widget.location.latitude - 1, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("west", Position(latitude: widget.location.latitude, longitude: widget.location.longitude - 1)));

    textBubbles.add(new TextBubble("test", Position(latitude: widget.location.latitude, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("test 2", Position(latitude: widget.location.latitude, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("test                 3", Position(latitude: widget.location.latitude, longitude: widget.location.longitude)));
    textBubbles.add(new TextBubble("test\n4\ntall\nmessage", Position(latitude: widget.location.latitude, longitude: widget.location.longitude)));
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
    for (int i = 0; i < textBubbles.length; i++) {
      if (!textBubbles[i].displayable) {
        textBubbles.removeAt(i);
        layoutChildren.removeAt(i);
        i--;
      }
    }
    return Container(
      color: Colors.lightBlueAccent,
      child: CustomMultiChildLayout(
        delegate: ChatFieldLayoutDelegate(textBubbles, widget.deviceDirection, widget.location),
        children: layoutChildren,
      )
    );
  }
}

class ChatFieldLayoutDelegate extends MultiChildLayoutDelegate {
  List<TextBubble> textBubbles;
  double deviceDirection;
  double displayAreaHeight = 0;
  double displayAreaWidth = 0;
  double aspectAngle;
  Position location;
  chatFieldGrid cFGrid;
  /*
  radius (in meters) for textBubbles to be placed in the innerField.  Outside this radius they will be placed in the outer ring.
   */
  double innerFieldRadius;
  double innerFieldHeight;
  double innerFieldWidth;

  /*
  the maximum allowed angle from [where a TextBubble in the outer is displayed] to [the TextBubbles' actual bearing].
  Used for when display location needs to be shifted to accommodate for other TextBubbles
   */
  double childMaxOffsetAngle = math.pi / 8;
  double childSpacing = 1;
  bool displayResized = false;

  ChatFieldLayoutDelegate(this.textBubbles, double deviceDirection, this.location) {
    this.deviceDirection = (deviceDirection / 360) * 2 * math.pi;
    cFGrid = new chatFieldGrid(childSpacing);
    innerFieldRadius = 20; //TODO: make this a user setting
  }

  void performLayout(Size size) {
    //TODO: add support for landscape orientation and dynamic sizing
    if (size != ChatField.displaySize) {
      displayResized = true;
    }
    else {
      displayResized = false;
    }
    ChatField.displaySize = size;
    displayAreaWidth = size.width;
    displayAreaHeight = size.height;
    if (displayAreaHeight > displayAreaWidth) {
      innerFieldWidth = displayAreaWidth / 3;
      innerFieldHeight = displayAreaHeight - 2 * innerFieldWidth;
    }
    else {
      innerFieldHeight = displayAreaHeight / 3;
      innerFieldWidth = displayAreaWidth - 2 * innerFieldHeight;
    }
    cFGrid.init(displayAreaWidth, displayAreaHeight);
    cFGrid.resetInnerField(innerFieldWidth, innerFieldHeight);

    aspectAngle = math.atan(displayAreaHeight / displayAreaWidth);

    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {

        Size childSize = layoutChild(
            i,
            BoxConstraints.loose(size)
        );
        textBubbles[i].displaySize = childSize;
        if (GeolocatorPlatform.instance.distanceBetween(location.latitude, location.longitude, textBubbles[i].location.latitude, textBubbles[i].location.longitude) > innerFieldRadius) {
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

          textBubbles[i].direction = textBubbleDirection;

          textBubbles[i].bufferPosition = getDisplayLocation(textBubbles[i].direction, childSize.height, childSize.width).dLocation;
        }
        else {
          textBubbles[i].direction = -1;
        }
        textBubbles[i].displayable = true;
      }
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {
        if (textBubbles[i].direction != -1) { //calculate positions for textBubbles in outer-ring
          //check if any textBubbles are overlapping on screen
          List<spaceBlock> overlapCheck = cFGrid.checkOverlap(
              textBubbles[i].displaySize, textBubbles[i].bufferPosition, false).toList();

          List<TextBubble> overlapping = new List<TextBubble>();
          for (spaceBlock block in overlapCheck) {
            overlapping.add(block);
          }
          Map<TextBubble, Offset> originalPositions = new Map<TextBubble, Offset>();
          if (overlapping.length != 0) {
            overlapping.add(textBubbles[i]);
            for (int i = 0; i < overlapping.length; i++) {
              originalPositions[overlapping[i]] = overlapping[i].bufferPosition;
              if (overlapping[i].onGrid) {
                cFGrid.remove(overlapping[i]);
              }
            }
          }

          bool doesNotFit = false;

          while ((overlapping.length > 0) && (!doesNotFit)) {
            overlapping.sort((TextBubble t1, TextBubble t2) {
              if ((t1.direction - t2.direction).abs() > math.pi) {
                if (t1.direction < t2.direction) return -1;
                return 1;
              }
              if (t1.direction > t2.direction) return 1;
              else if (t1.direction == t2.direction) return 0;
              return -1;
            });

            double averageAngle = 0;
            for (TextBubble textBubble in overlapping) {
              averageAngle += textBubble.direction;
            }
            averageAngle /= overlapping.length;
            if ((overlapping[0].direction - overlapping.last.direction).abs() > math.pi) {
              averageAngle = (averageAngle + math.pi) % (2 * math.pi);
            }
            DisplayLocation groupLocation = getDisplayLocation(averageAngle, 0, 0);

            Array2d calcPos = calcPositions(groupLocation, overlapping);
            int underflowStart = -1;
            int overflowStart = -1;

            /*
            with clutter restrictions assume that it is impossible to have both underflow and overflow
             */

            if (groupLocation.side == 1) {
              for (int i = 0; i < overlapping.length; i++) {
                if (calcPos[i][0] - (overlapping[i].displaySize.height / 2) < 0) {
                  underflowStart = i;
                }
                if ((overflowStart == -1) && (calcPos[i][0] + (overlapping[i].displaySize.height / 2) > displayAreaHeight)) {
                  overflowStart = i;
                }
              }
            }
            else if (groupLocation.side == 2) {
              for (int i = 0; i < overlapping.length; i++) {
                if (calcPos[i][0] - (overlapping[i].displaySize.width / 2) < 0) {
                  underflowStart = i;
                }
                if ((overflowStart == -1) && (calcPos[i][0] + (overlapping[i].displaySize.width / 2) > displayAreaWidth)) {
                  overflowStart = i;
                }
              }
            }
            else if (groupLocation.side == 3) {
              for (int i = 0; i < overlapping.length; i++) {
                if (calcPos[i][0] - (overlapping[overlapping.length - 1 - i].displaySize.height / 2) < 0) {
                  overflowStart = overlapping.length - 1 - i;
                }
                if ((underflowStart == -1) && (calcPos[i][0] + (overlapping[overlapping.length - 1 - i].displaySize.height / 2) > displayAreaHeight)) {
                  underflowStart = overlapping.length - 1 - i;
                }
              }
            }
            else {
              for (int i = 0; i < overlapping.length; i++) {
                if (calcPos[i][0] - (overlapping[overlapping.length - 1 - i].displaySize.width / 2) < 0) {
                  overflowStart = overlapping.length - 1 - i;
                }
                if ((underflowStart == -1) && (calcPos[i][0] + (overlapping[overlapping.length - 1 - i].displaySize.width / 2) > displayAreaWidth)) {
                  underflowStart = overlapping.length - 1 - i;
                }
              }
            }

            if ((underflowStart != -1) || (overflowStart != -1)) {
              /*
              Track length is the screen distance that the groupLocation must cover over a corner from the starting point
              of no overflow to the ending point of no underflow

              0: total length
              1: clockwise side length
              2: counter-clockwise side length
               */
              List<double> groupTrackLength = new List<double>(3);
              groupTrackLength[0] = 0;
              groupTrackLength[1] = 0;
              groupTrackLength[2] = 0;

              //calculate group track length along corner
              if (underflowStart != -1) {
                if (groupLocation.side == 1) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 2), overlapping);
                  groupTrackLength[1] = groupOthersidePositions[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.width / 2;
                  groupTrackLength[2] = groupLocation.dLocation.dy - calcPos[0][0] + overlapping[0].displaySize.height / 2;
                }
                else if (groupLocation.side == 2) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 1), overlapping);
                  groupTrackLength[1] = groupOthersidePositions[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.height / 2;
                  groupTrackLength[2] = groupLocation.dLocation.dx - calcPos[0][0] + overlapping[0].displaySize.width / 2;
                }
                else if (groupLocation.side == 3) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 2), overlapping);
                  groupTrackLength[1] = groupOthersidePositions[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.width / 2;
                  groupTrackLength[2] = calcPos[overlapping.length - 1][0] - groupLocation.dLocation.dy + overlapping[overlapping.length - 1].displaySize.height / 2;
                }
                else if (groupLocation.side == 4) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 1), overlapping);
                  groupTrackLength[1] = groupOthersidePositions[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.height / 2;
                  groupTrackLength[2] = calcPos[overlapping.length - 1][0] - groupLocation.dLocation.dx + overlapping[0].displaySize.width / 2;
                }
                groupTrackLength[0] = groupTrackLength[1] + groupTrackLength[2];
              }
              if (overflowStart != -1) {
                if (groupLocation.side == 1) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 2), overlapping);
                  groupTrackLength[2] = - groupOthersidePositions[0][0] + overlapping[0].displaySize.width / 2;
                  groupTrackLength[1] = calcPos[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.height / 2 - groupLocation.dLocation.dy;
                }
                else if (groupLocation.side == 2) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 1), overlapping);
                  groupTrackLength[2] = - groupOthersidePositions[0][0] + overlapping[0].displaySize.height / 2;
                  groupTrackLength[1] = calcPos[overlapping.length - 1][0] + overlapping[overlapping.length - 1].displaySize.width / 2 - groupLocation.dLocation.dx;
                }
                else if (groupLocation.side == 3) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 2), overlapping);
                  groupTrackLength[2] = - groupOthersidePositions[0][0] + overlapping[0].displaySize.width / 2;
                  groupTrackLength[1] = groupLocation.dLocation.dy - calcPos[0][0] + overlapping[0].displaySize.height / 2;
                }
                else if (groupLocation.side == 4) {
                  Array2d groupOthersidePositions = calcPositions(DisplayLocation(Offset(0, 0), 1), overlapping);
                  groupTrackLength[2] = - groupOthersidePositions[0][0] + overlapping[0].displaySize.height / 2;
                  groupTrackLength[1] = groupLocation.dLocation.dx - calcPos[0][0] + overlapping[overlapping.length - 1].displaySize.width / 2;
                }
                groupTrackLength[0] = groupTrackLength[1] + groupTrackLength[2];
              }

              //get the movements that need to occur
              List<double> movements = new List<double>(2 * overlapping.length - 2);
              double movementsSum = 0;

              if ((((groupLocation.side == 1) && (overflowStart != -1)) || ((groupLocation.side == 2) && (underflowStart != -1))) || (((groupLocation.side == 3) && (overflowStart != -1)) || ((groupLocation.side == 4) && (underflowStart != -1)))) { //bottom left corner || top right corner
                for (int i = 0; (2 * i) < movements.length; i++) {
                  movements[2 * i] = overlapping[overlapping.length - 2 - i].displaySize.width + childSpacing;
                  movementsSum += movements[2 * i];
                }
                for (int i = 0; (2 * i) + 1 < movements.length; i++) {
                  movements[(2 * i) + 1] = overlapping[overlapping.length - 1 - i].displaySize.height + childSpacing;
                  movementsSum += movements[(2 * i) + 1];
                }
              }
              else if ((((groupLocation.side == 2) && (overflowStart != -1)) || ((groupLocation.side == 3) && (underflowStart != -1))) || (((groupLocation.side == 4) && (overflowStart != -1)) || ((groupLocation.side == 1) && (underflowStart != -1)))) { //bottom right corner || top left corner
                for (int i = 0; (2 * i) < movements.length; i++) {
                  movements[2 * i] = overlapping[overlapping.length - 2 - i].displaySize.height + childSpacing;
                  movementsSum += movements[2 * i];
                }
                for (int i = 0; (2 * i) + 1 < movements.length; i++) {
                  movements[(2 * i) + 1] = overlapping[overlapping.length - 1 - i].displaySize.width + childSpacing;
                  movementsSum += movements[(2 * i) + 1];
                }
              }

              /*
              proportionally divide the [movements that need to occur] over the group track length
              groupTrack: [[length of segment, accumulated previous segment lengths], ...]
               */
              List<List<double>> groupTrack = new List<List<double>>(2 * overlapping.length - 2);
              for (int i = 0; i < groupTrack.length; i++) {
                groupTrack[i] = new List<double>(2);
                groupTrack[i][0] = (movements[i] / movementsSum) * groupTrackLength[0];
                if (i == 0) {
                  groupTrack[i][1] = 0;
                }
                else {
                  groupTrack[i][1] = groupTrack[i - 1][0] + groupTrack[i - 1][1];
                }
              }

              //get how far through track group is
              double placeInTrack = 0;

              if ((groupLocation.side == 1) && (overflowStart != -1)) {
                placeInTrack = groupLocation.dLocation.dy - (displayAreaHeight - groupTrackLength[1]);
              }
              else if ((groupLocation.side == 2) && (underflowStart != -1)) {
                placeInTrack = groupLocation.dLocation.dx + groupTrackLength[1];
              }
              else if ((groupLocation.side == 2) && (overflowStart != -1)) {
                placeInTrack = groupLocation.dLocation.dx - (displayAreaWidth - groupTrackLength[1]);
              }
              else if ((groupLocation.side == 3) && (underflowStart != -1)) {
                placeInTrack = displayAreaHeight - groupLocation.dLocation.dy + groupTrackLength[1];
              }
              else if ((groupLocation.side == 3) && (overflowStart != -1)) {
                placeInTrack = groupTrackLength[1] - groupLocation.dLocation.dy;
              }
              else if ((groupLocation.side == 4) && (underflowStart != -1)) {
                placeInTrack = displayAreaWidth - groupLocation.dLocation.dx + groupTrackLength[1];
              }
              else if ((groupLocation.side == 4) && (overflowStart != -1)) {
                placeInTrack = groupTrackLength[1] - groupLocation.dLocation.dx;
              }
              else if ((groupLocation.side == 1) && (underflowStart != -1)) {
                placeInTrack = groupLocation.dLocation.dy + groupTrackLength[1];
              }

              //find which segment of track group is currently on
              int segmentOfTrack = 0;

              for (int i = 0; i < groupTrack.length; i++) {
                if (placeInTrack < groupTrack[i][1] + groupTrack[i][0]) {
                  segmentOfTrack = i;
                  break;
                }
              }

              //get textBubble that corresponds to track segment | used as starting point / base of positioning
              int baseChild = overlapping.length - 1 - ((segmentOfTrack + 1) / 2).floor();

              //position textBubbles
              if (((groupLocation.side == 1) && (overflowStart != -1)) || ((groupLocation.side == 2) && (underflowStart != -1))) { //bottom left corner
                //position base textBubble
                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition = Offset(((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild - 1].displaySize.width + childSpacing), displayAreaHeight - overlapping[baseChild].displaySize.height);
                }
                else {
                  overlapping[baseChild].bufferPosition = Offset(0, displayAreaHeight - overlapping[baseChild].displaySize.height - childSpacing - overlapping[baseChild + 1].displaySize.height + ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.height + childSpacing));
                }

                //position all following textBubbles
                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  overlapping[i].bufferPosition = Offset(overlapping[i - 1].bufferPosition.dx + overlapping[i - 1].displaySize.width + childSpacing, displayAreaHeight - overlapping[i].displaySize.height);
                }

                //position all preceding textBubbles
                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition = Offset(0, overlapping[i + 1].bufferPosition.dy - overlapping[i].displaySize.height - childSpacing);
                }
              }
              else if (((groupLocation.side == 2) && (overflowStart != -1)) || ((groupLocation.side == 3) && (underflowStart != -1))) { //bottom right corner
                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width, displayAreaHeight - overlapping[baseChild].displaySize.height - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild - 1].displaySize.height + childSpacing));
                }
                else {
                  overlapping[baseChild].bufferPosition = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width - childSpacing - overlapping[baseChild + 1].displaySize.width + ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.width + childSpacing), displayAreaHeight - overlapping[baseChild].displaySize.height);
                }

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  overlapping[i].bufferPosition = Offset(displayAreaWidth - overlapping[i].displaySize.width, overlapping[i - 1].bufferPosition.dy - overlapping[i].displaySize.height - childSpacing);
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition = Offset(overlapping[i + 1].bufferPosition.dx - overlapping[i].displaySize.width - childSpacing, displayAreaHeight - overlapping[i].displaySize.height);
                }
              }
              else if (((groupLocation.side == 3) && (overflowStart != -1)) || ((groupLocation.side == 4) && (underflowStart != -1))) { //top right corner
                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild - 1].displaySize.width + childSpacing), 0);
                }
                else {
                  overlapping[baseChild].bufferPosition = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width, overlapping[baseChild + 1].displaySize.height + childSpacing - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.height + childSpacing));
                }

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  overlapping[i].bufferPosition = Offset(overlapping[i - 1].bufferPosition.dx - overlapping[i].displaySize.width - childSpacing, 0);
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition = Offset(displayAreaWidth - overlapping[i].displaySize.width, overlapping[i + 1].bufferPosition.dy + overlapping[i].displaySize.height + childSpacing);
                }
              }
              else if (((groupLocation.side == 4) && (overflowStart != -1)) || ((groupLocation.side == 1) && (underflowStart != -1))) { //top left corner
                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition = Offset(0, ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild - 1].displaySize.height + childSpacing));
                }
                else {
                  overlapping[baseChild].bufferPosition = Offset(overlapping[baseChild + 1].displaySize.width + childSpacing - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.width + childSpacing), 0);
                }

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  overlapping[i].bufferPosition = Offset(0, overlapping[i - 1].bufferPosition.dy + overlapping[i - 1].displaySize.height + childSpacing);
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition = Offset(overlapping[i + 1].bufferPosition.dx + overlapping[i + 1].displaySize.width + childSpacing, 0);
                }
              }
            }
            else { //place same side textBubbles
              int start = 0;
              int end = overlapping.length;

              if (groupLocation.side == 1) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition = Offset(0, calcPos[i][0] - (overlapping[i].displaySize.height / 2));
                }
              }
              else if (groupLocation.side == 2) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition = Offset(calcPos[i][0] - (overlapping[i].displaySize.width / 2), displayAreaHeight - overlapping[i].displaySize.height);
                }
              }
              else if (groupLocation.side == 3) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition = Offset(displayAreaWidth - overlapping[i].displaySize.width, calcPos[overlapping.length - 1 - i][0] - (overlapping[i].displaySize.height / 2));
                }
              }
              else {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition = Offset(calcPos[overlapping.length - 1 - i][0] - (overlapping[i].displaySize.width / 2), 0);
                }
              }
            }

            //TODO: check if display angle offset exceeds childMaxOffsetAngle

            //check if textBubbles in new positions are overlapping any other textBubbles
            Set<TextBubble> nowOverlapping = new Set<TextBubble>();
            for (int i = 0; i < overlapping.length; i++) {
              List<spaceBlock> overlapCheck = cFGrid.checkOverlap(overlapping[i].displaySize, overlapping[i].bufferPosition, false).toList();
              List<TextBubble> temp = new List<TextBubble>();
              //cant do implicit conversion
              for (spaceBlock block in overlapCheck) {
                temp.add(block);
              }
              nowOverlapping.addAll(temp);
            }


            if (nowOverlapping.length != 0) {
              //redo position calculations and include the new overlapping textBubbles
              originalPositions.forEach((key, value) {key.bufferPosition = value;});
              overlapping.addAll(nowOverlapping);
              for (int i = 0; i < nowOverlapping.length; i++) {
                originalPositions[nowOverlapping.elementAt(i)] = nowOverlapping.elementAt(i).bufferPosition;
                if (nowOverlapping.elementAt(i).onGrid) {
                  cFGrid.remove(nowOverlapping.elementAt(i));
                }
              }
            }
            else {
              for (int i = 0; i < overlapping.length; i++) {
                cFGrid.add(overlapping[i]);
              }
              break;
            }
          }

          //add textBubble to chatFieldGrid
          if ((overlapping.length == 0) && (textBubbles[i].bufferPosition != textBubbles[i].displayPosition)) {
            if (textBubbles[i].onGrid) {
              cFGrid.remove(textBubbles[i]);
            }
            cFGrid.add(textBubbles[i]);
          }
        }
        else { //calculate positions for textBubbles in innerField
          /*
          innerField will be RANDOMLY POPULATED.  textBubbles will be placed randomly wherever there is space.
          The OBJECTIVE IS TO NOT BE EFFICIENT with placement, which will lead to a more pleasant user experience.
          Free space will be tracked via blocks.  Each textBubble will split the blocks it occupies into multiple
          smaller blocks

          rebuild the entire innerField instead of tracking which fragments to re-assemble
           */

          math.Random rng = new math.Random();

          //place existing textBubbles first, since their positions must remain the same.
          //If display size has changed then relayout all textBubbles
          if (textBubbles[i].onInnerField && !displayResized) {
            cFGrid.placeAndBreak(textBubbles[i], textBubbles[i].displayPosition);
          }
          else {
            //find any block that will fit textBubble
            textBubbles[i].onInnerField = false;
            for (spaceBlock block in cFGrid.innerFieldBlocks) {
              if (block.vertices[3].dy - block.vertices[0].dy >= textBubbles[i].displaySize.height + childSpacing) {
                if (block.vertices[1].dx - block.vertices[0].dx >= textBubbles[i].displaySize.width + childSpacing) {
                  //randomly place textBubble inside block
                  double xPos = rng.nextDouble() * (block.vertices[1].dx - block.vertices[0].dx - textBubbles[i].displaySize.width - 0.5 * childSpacing) + block.vertices[0].dx + 0.5 * childSpacing;
                  double yPos = rng.nextDouble() * (block.vertices[3].dy - block.vertices[0].dy - textBubbles[i].displaySize.height - 0.5 * childSpacing) + block.vertices[0].dy + 0.5 * childSpacing;
                  textBubbles[i].bufferPosition = Offset(xPos, yPos);
                  cFGrid.placeAndBreak(textBubbles[i], textBubbles[i].bufferPosition);
                  break;
                }
              }
            }

            //TODO: if there is no space then check if removing collapsed textBubbles creates enough space

            //if still no space then flag textBubble for removal.  textBubble will not be displayed
            if (!textBubbles[i].onInnerField) {
              textBubbles[i].displayable = false;
            }
          }
        }
      }
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (!textBubbles[i].displayable) {
        //child must still be positioned, so position off-screen and remove before next rebuild
        positionChild(i, Offset(displayAreaHeight, displayAreaWidth));
      }
      else {
        cFGrid.remove(textBubbles[i]);
        textBubbles[i].displayPosition = textBubbles[i].bufferPosition;
        positionChild(i, textBubbles[i].displayPosition);
      }
    }
  }

  bool shouldRelayout(ChatFieldLayoutDelegate oldDelegate) {
    return (oldDelegate.deviceDirection != deviceDirection) || (oldDelegate.location != location);
  }

  DisplayLocation getDisplayLocation(double direction, double textBubbleHeight, double textBubbleWidth) {
    double x;
    double y;
    int side;

    if ((direction >= ((math.pi / 2) - aspectAngle)) &&
        (direction < ((math.pi / 2) + aspectAngle))) {
      x = 0;
      y = (((displayAreaHeight / 2) - ((displayAreaWidth / 2) *
          math.tan((math.pi / 2) - direction))) / displayAreaHeight) *
          (displayAreaHeight - textBubbleHeight);
      side = 1;
    }
    else if ((direction >= ((math.pi / 2) + aspectAngle)) &&
        (direction < (1.5 * math.pi - aspectAngle))) {
      y = displayAreaHeight - textBubbleHeight;
      x = (((displayAreaWidth / 2) -
          ((displayAreaHeight / 2) * math.tan(math.pi - direction))) /
          displayAreaWidth) * (displayAreaWidth - textBubbleWidth);
      side = 2;
    }
    else if ((direction >= (1.5 * math.pi - aspectAngle)) &&
        (direction < (1.5 * math.pi + aspectAngle))) {
      x = displayAreaWidth - textBubbleWidth;
      y = (((displayAreaHeight / 2) + ((displayAreaWidth / 2) *
          math.tan((1.5 * math.pi) - direction))) /
          displayAreaHeight) * (displayAreaHeight - textBubbleHeight);
      side = 3;
    }
    else {
      y = 0;
      x = (((displayAreaWidth / 2) -
          ((displayAreaHeight / 2) * math.tan(direction))) /
          displayAreaWidth) * (displayAreaWidth - textBubbleWidth);
      side = 4;
    }

    return DisplayLocation(Offset(x, y), side);
  }

  Array2d calcPositions(DisplayLocation groupLocation, List<TextBubble> overlapping) {
    Array2d A = Array2d(new List<Array>(2 * overlapping.length));
    for (int i = 0; i < (2 * overlapping.length); i++) {
      A[i] = new Array(new List<double>(2 * overlapping.length));
      for (int j = 0; j < (2 * overlapping.length); j++) {
        A[i][j] = 0;
      }
    }

    for (int i = 0; i < overlapping.length; i++) {
      A[0][i + overlapping.length] = 1;
    }

    for (int i = 0; i < overlapping.length; i++) {
      A[1 + i][i] = 1;
      A[1 + i][i + overlapping.length] = -1;
    }

    for (int i = 0; i < overlapping.length - 1; i++) {
      A[overlapping.length + 1 + i][overlapping.length - 1] = 1;
      A[overlapping.length + 1 + i][i] = -1;
    }

    Array2d b = Array2d(new List<Array>(2 * overlapping.length));
    for (int i = 0; i < (2 * overlapping.length); i++) {
      b[i] = new Array(new List<double>(1));
      b[i][0] = 0;
    }

    for (int i = 0; i < overlapping.length; i++) {
      if ((groupLocation.side == 1) || (groupLocation.side == 3)) {
        b[1 + i][0] = groupLocation.dLocation.dy;
      }
      else {
        b[1 + i][0] = groupLocation.dLocation.dx;
      }
    }

    for (int i = 0; i < overlapping.length - 1; i++) {
      if (groupLocation.side == 1) {
        b[overlapping.length + 1 + i][0] =
            overlapping[overlapping.length - 1].displaySize.height / 2 + childSpacing;
        for (int j = 0; j < overlapping.length - 2 - i; j++) {
          b[overlapping.length + 1 + i][0] += overlapping[1 + j].displaySize.height + childSpacing;
        }
        b[overlapping.length + 1 + i][0] += overlapping[i].displaySize.height / 2;
      }
      else if (groupLocation.side == 3) {
        b[overlapping.length + 1 + i][0] =
            overlapping[0].displaySize.height / 2 + childSpacing;
        for (int j = 0; j < overlapping.length - 2 - i; j++) {
          b[overlapping.length + 1 + i][0] += overlapping[overlapping.length - 2 - j].displaySize.height + childSpacing;
        }
        b[overlapping.length + 1 + i][0] += overlapping[overlapping.length - 1 - i].displaySize.height / 2;
      }
      else if (groupLocation.side == 2) {
        b[overlapping.length + 1 + i][0] =
            overlapping[overlapping.length - 1].displaySize.width / 2 + childSpacing;
        for (int j = 0; j < overlapping.length - 2 - i; j++) {
          b[overlapping.length + 1 + i][0] += overlapping[1 + j].displaySize.width + childSpacing;
        }
        b[overlapping.length + 1 + i][0] += overlapping[i].displaySize.width / 2;
      }
      else {
        b[overlapping.length + 1 + i][0] =
            overlapping[0].displaySize.width / 2 + childSpacing;
        for (int j = 0; j < overlapping.length - 2 - i; j++) {
          b[overlapping.length + 1 + i][0] += overlapping[overlapping.length - 2 - j].displaySize.width + childSpacing;
        }
        b[overlapping.length + 1 + i][0] += overlapping[overlapping.length - 1 - i].displaySize.width / 2;
      }
    }

    return matrixSolve(A, b);
  }
}

class TextBubble extends spaceBlock {
  String text;
  Position location;
  DateTime time;
  Offset displayPosition;
  bool expanded;
  double direction;
  bool displayable = true;
  bool onInnerField = false;

  TextBubble(this.text, this.location) : super(true);
}

class DisplayLocation {
  Offset dLocation;
  int side;

  DisplayLocation(this.dLocation, this.side);
}

class chatFieldGrid {
  List<List<List<spaceBlock>>> grid;
  List<spaceBlock> innerFieldBlocks;
  int gridRows = 16;
  int gridColumns = 10;
  double displayAreaWidth;
  double displayAreaHeight;
  bool initialized;
  double childSpacing;

  chatFieldGrid(this.childSpacing) {
    initialized = false;
    grid = new List<List<List<spaceBlock>>>(gridColumns);
    for (int i = 0; i < gridColumns; i++) {
      grid[i] = new List<List<spaceBlock>>(gridRows);
      for (int j = 0; j < gridRows; j++) {
        grid[i][j] = new List<spaceBlock>();
      }
    }
    innerFieldBlocks = new List<spaceBlock>();
  }

  void init(double width, double height) {
    if (initialized) return;
    displayAreaWidth = width;
    displayAreaHeight = height;
    initialized = true;
  }

  void resetInnerField(double width, double height) {
    for (spaceBlock block in innerFieldBlocks) {
      remove(block);
    }

    innerFieldBlocks = new List<spaceBlock>();
    double right = (displayAreaWidth - width) / 2;
    double left = (displayAreaWidth + width) / 2;
    double top = (displayAreaHeight - height) / 2;
    double bottom = (displayAreaHeight + height) / 2;
    innerFieldBlocks.add(new spaceBlock.fromVertices(
      Offset(right, top),
      Offset(left, top),
      Offset(left, bottom),
      Offset(right, bottom)
    ));
    add(innerFieldBlocks[0]);
  }

  Set<spaceBlock> checkOverlap(Size textBubbleSize, Offset textBubblePosition, bool sBlock) {
    Set<spaceBlock> overlapping = new Set<spaceBlock>();

    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    int startRow = textBubblePosition.dy ~/ gridBlockHeight;
    int endRow = (textBubblePosition.dy + textBubbleSize.height) ~/ gridBlockHeight;
    if (endRow == gridRows) {
      endRow--;
    }
    int startColumn = textBubblePosition.dx ~/ gridBlockWidth;
    int endColumn = (textBubblePosition.dx + textBubbleSize.width) ~/ gridBlockWidth;
    if (endColumn == gridColumns) {
      endColumn--;
    }

    for (int row = startRow; (row <= endRow); row++) {
      for (int column = startColumn; (column <= endColumn); column++) {
        for (int i = 0; i < grid[column][row].length; i++) {
          spaceBlock existingSBlock = grid[column][row][i];
          if (existingSBlock.textBubble && sBlock) {
            continue;
          }
          else if ((!existingSBlock.textBubble) && (!sBlock)) {
            continue;
          }

          if (!overlapping.contains(existingSBlock)) {
            bool overlappingFound = false;

            List<Offset> newVertices = {
              textBubblePosition,
              Offset(textBubblePosition.dx + textBubbleSize.width,
                  textBubblePosition.dy),
              Offset(textBubblePosition.dx + textBubbleSize.width,
                  textBubblePosition.dy + textBubbleSize.height),
              Offset(textBubblePosition.dx,
                  textBubblePosition.dy + textBubbleSize.height)
            }.toList();

            List<Offset> existingVertices;
            if (!sBlock) {
              existingVertices = [
                existingSBlock.bufferPosition,
                Offset(existingSBlock.bufferPosition.dx +
                    existingSBlock.displaySize.width,
                    existingSBlock.bufferPosition.dy),
                Offset(existingSBlock.bufferPosition.dx +
                    existingSBlock.displaySize.width,
                    existingSBlock.bufferPosition.dy +
                        existingSBlock.displaySize.height),
                Offset(existingSBlock.bufferPosition.dx,
                    existingSBlock.bufferPosition.dy +
                        existingSBlock.displaySize.height)
              ];
            }
            else {
              existingVertices = existingSBlock.vertices;
            }

            //check if textBubble is within or overlaps existing
            for (Offset vertex in newVertices) {
              if ((vertex.dx >= existingVertices[0].dx) &&
                  (vertex.dx <= existingVertices[1].dx)) {
                if ((vertex.dy >= existingVertices[0].dy) &&
                    (vertex.dy <= existingVertices[3].dy)) {
                  overlapping.add(existingSBlock);
                  overlappingFound = true;
                  break;
                }
              }
            }

            if (overlappingFound) {
              continue;
            }

            //check if existing is within textBubble
            for (Offset vertex in existingVertices) {
              if ((vertex.dx >= newVertices[0].dx) &&
                  (vertex.dx <= newVertices[1].dx)) {
                if ((vertex.dy >= newVertices[0].dy) &&
                    (vertex.dy <= newVertices[3].dy)) {
                  overlapping.add(existingSBlock);
                }
              }
            }
          }
        }
      }
    }
    return overlapping;
  }

  void add(spaceBlock sBlock) {
    addOrRemove(sBlock, true);
  }

  void remove(spaceBlock sBlock) {
    addOrRemove(sBlock, false);
  }

  void addOrRemove(spaceBlock sBlock, bool add) {
    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    int startRow = sBlock.bufferPosition.dy ~/ gridBlockHeight;
    int endRow;
    if (sBlock.textBubble) {
      endRow = (sBlock.bufferPosition.dy + sBlock.displaySize.height) ~/ gridBlockHeight;
    }
    else {
      endRow = sBlock.vertices[3].dy ~/ gridBlockHeight;
    }
    if (endRow == gridRows) {
      endRow--;
    }
    int startColumn = sBlock.bufferPosition.dx ~/ gridBlockWidth;
    int endColumn;
    if (sBlock.textBubble) {
      endColumn = (sBlock.bufferPosition.dx + sBlock.displaySize.width) ~/ gridBlockWidth;
    }
    else {
      endColumn = sBlock.vertices[1].dx ~/ gridBlockWidth;
    }
    if (endColumn == gridColumns) {
      endColumn--;
    }

    for (int row = startRow; (row <= endRow); row++) {
      for (int column = startColumn; (column <= endColumn); column++) {
        if (add) {
          grid[column][row].add(sBlock);
        }
        else {
          grid[column][row].remove(sBlock);
        }
      }
    }

    sBlock.onGrid = add;
  }

  void placeAndBreak(TextBubble textBubble, Offset textBubblePosition) {
    //quickly determine if there is overlap before determining how the textBubble overlaps each block
    List<spaceBlock> blocks = checkOverlap(textBubble.displaySize, textBubblePosition, true).toList();

    for (spaceBlock block in blocks) {
      //remove block from grid
      remove(block);
      innerFieldBlocks.remove(block);

      //break block according to overlap
      List<Offset> textBubbleVertices = [
        textBubblePosition,
        Offset(textBubblePosition.dx + textBubble.displaySize.width,
            textBubblePosition.dy),
        Offset(textBubblePosition.dx + textBubble.displaySize.width,
            textBubblePosition.dy + textBubble.displaySize.height),
        Offset(textBubblePosition.dx,
            textBubblePosition.dy + textBubble.displaySize.height)
      ];

      List<spaceBlock> newBlocks = new List<spaceBlock>();

      //check which textBubbleVertices are inside the block
      List<bool> inside = [false, false, false, false];

      for (int i = 0; i < 4; i++) {
        if ((textBubbleVertices[i].dx > block.vertices[0].dx + 0.5 * childSpacing) && (textBubbleVertices[i].dx < block.vertices[1].dx - 0.5 * childSpacing) && (textBubbleVertices[i].dy > block.vertices[0].dy + 0.5 * childSpacing) && (textBubbleVertices[i].dy < block.vertices[3].dy - 0.5 * childSpacing)) {
          inside[i] = true;
        }
      }

      if (!inside[0] && !inside[1] && !inside[2] && !inside[3]) {
        continue;
      }

      if (!((!inside[0] && !inside[1] && !inside[2] && inside[3]) || (inside[0] && !inside[1] && !inside[2] && inside[3]) || (inside[0] && !inside[1] && !inside[2] && !inside[3]))) {
        //add a block to right of the textBubble
        newBlocks.add(new spaceBlock.fromVertices(
          Offset(textBubbleVertices[1].dx, block.vertices[0].dy),
          block.vertices[1],
          block.vertices[2],
          Offset(textBubbleVertices[1].dx, block.vertices[3].dy)
        ));
      }
      if (!((inside[0] && !inside[1] && !inside[2] && !inside[3]) || (inside[0] && inside[1] && !inside[2] && !inside[3]) || (!inside[0] && inside[1] && !inside[2] && !inside[3]))) {
        //add a block to the bottom of the textBubble
        newBlocks.add(new spaceBlock.fromVertices(
            Offset(block.vertices[0].dx, textBubbleVertices[3].dy),
            Offset(block.vertices[1].dx, textBubbleVertices[3].dy),
            block.vertices[2],
            block.vertices[3]
        ));
      }
      if (!((!inside[0] && inside[1] && !inside[2] && !inside[3]) || (!inside[0] && inside[1] && inside[2] && !inside[3]) || (!inside[0] && !inside[1] && inside[2] && !inside[3]))) {
        //add a block to the left of the textBubble
        newBlocks.add(new spaceBlock.fromVertices(
            block.vertices[0],
            Offset(textBubbleVertices[0].dx, block.vertices[1].dy),
            Offset(textBubbleVertices[0].dx, block.vertices[2].dy),
            block.vertices[3]
        ));
      }
      if (!((!inside[0] && !inside[1] && inside[2] && !inside[3]) || (!inside[0] && !inside[1] && inside[2] && inside[3]) || (!inside[0] && !inside[1] && !inside[2] && inside[3]))) {
        //add a block to the top of the textBubble
        newBlocks.add(new spaceBlock.fromVertices(
            block.vertices[0],
            block.vertices[1],
            Offset(block.vertices[2].dx, textBubbleVertices[0].dy),
            Offset(block.vertices[3].dx, textBubbleVertices[0].dy)
        ));
      }

      //add new blocks to grid
      for (spaceBlock newBlock in newBlocks) {
        add(newBlock);
        innerFieldBlocks.add(newBlock);
      }
    }

    //add textBubble to grid
    if (textBubble.onGrid) {
      remove(textBubble);
    }
    add(textBubble);
    textBubble.onInnerField = true;
  }
}

class spaceBlock {
  List<Offset> vertices;
  Offset bufferPosition;
  bool textBubble = false;
  Size displaySize;
  bool onGrid = false;

  spaceBlock(this.textBubble);

  spaceBlock.fromVertices(Offset topLeft, Offset topRight, Offset bottomRight, Offset bottomLeft) {
    vertices = new List<Offset>(4);
    vertices[0] = topLeft;
    vertices[1] = topRight;
    vertices[2] = bottomRight;
    vertices[3] = bottomLeft;
    bufferPosition = topLeft;
  }
}