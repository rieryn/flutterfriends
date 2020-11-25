import 'dart:async';
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:major_project/Posts/posts.dart';
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
    textBubbles.add(new TextBubble("northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0001)));
    textBubbles.add(new TextBubble("further northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0002)));
    //textBubbles.add(new TextBubble("even\nfurther northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0003)));
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
  chatFieldGrid cFGrid;

  /*
  the maximum allowed angle from [where a TextBubble in the outer is displayed] to [the TextBubbles' actual bearing].
  Used for when display location needs to be shifted to accommodate for other TextBubbles
   */
  double childMaxOffsetAngle = math.pi / 8;
  double childSpacing = 1;

  OuterRingLayoutDelegate(this.textBubbles, double deviceDirection, this.location) {
    this.deviceDirection = (deviceDirection / 360) * 2 * math.pi;
    cFGrid = new chatFieldGrid();
  }

  void performLayout(Size size) {
    displayAreaWidth = size.width;
    displayAreaHeight = size.height;
    cFGrid.init(displayAreaWidth, displayAreaHeight);

    aspectAngle = math.atan(displayAreaHeight / displayAreaWidth);

    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {

        Size childSize = layoutChild(
            i,
            BoxConstraints.loose(size)
        );
        textBubbles[i].displaySize = childSize;

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
        textBubbles[i].displayable = true;
      }
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {
        //check if any textBubbles are overlapping on screen
        List<TextBubble> overlapping = cFGrid.checkOverlap(
            textBubbles[i].displaySize, textBubbles[i].bufferPosition).toList();

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
            nowOverlapping.addAll(cFGrid.checkOverlap(overlapping[i].displaySize, overlapping[i].bufferPosition));
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
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (!textBubbles[i].displayable) {
        textBubbles.removeAt(i);
        i--;
      }
    }
    for (int i = 0; i < textBubbles.length; i++) {
      cFGrid.remove(textBubbles[i]);
      textBubbles[i].displayPosition = textBubbles[i].bufferPosition;
      positionChild(i, textBubbles[i].displayPosition);
    }
  }

  bool shouldRelayout(OuterRingLayoutDelegate oldDelegate) {
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

class TextBubble {
  String text;
  Position location;
  DateTime time;
  Offset displayPosition;
  Size displaySize;
  bool expanded;
  double direction;
  Offset bufferPosition;
  bool displayable;
  bool onGrid = false;

  TextBubble(this.text, this.location);
}

class DisplayLocation {
  Offset dLocation;
  int side;

  DisplayLocation(this.dLocation, this.side);
}

class chatFieldGrid {
  List<List<List<TextBubble>>> grid;
  int gridRows = 16;
  int gridColumns = 10;
  double displayAreaWidth;
  double displayAreaHeight;
  bool initialized;

  chatFieldGrid() {
    initialized = false;
    grid = new List<List<List<TextBubble>>>(gridColumns);
    for (int i = 0; i < gridColumns; i++) {
      grid[i] = new List<List<TextBubble>>(gridRows);
      for (int j = 0; j < gridRows; j++) {
        grid[i][j] = new List<TextBubble>();
      }
    }
  }

  void init(double width, double height) {
    if (initialized) return;
    displayAreaWidth = width;
    displayAreaHeight = height;
    initialized = true;
  }

  Set<TextBubble> checkOverlap(Size textBubbleSize, Offset textBubblePosition) {
    Set<TextBubble> overlapping = new Set<TextBubble>();

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
          TextBubble existingTextBubble = grid[column][row][i];

          if (!overlapping.contains(existingTextBubble)) {
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

            List<Offset> existingVertices = {
              existingTextBubble.bufferPosition,
              Offset(existingTextBubble.bufferPosition.dx +
                  existingTextBubble.displaySize.width,
                  existingTextBubble.bufferPosition.dy),
              Offset(existingTextBubble.bufferPosition.dx +
                  existingTextBubble.displaySize.width,
                  existingTextBubble.bufferPosition.dy +
                      existingTextBubble.displaySize.height),
              Offset(existingTextBubble.bufferPosition.dx,
                  existingTextBubble.bufferPosition.dy +
                      existingTextBubble.displaySize.height)
            }.toList();

            //check if textBubble is within or overlaps existing
            for (Offset vertex in newVertices) {
              if ((vertex.dx >= existingVertices[0].dx) &&
                  (vertex.dx <= existingVertices[1].dx)) {
                if ((vertex.dy >= existingVertices[0].dy) &&
                    (vertex.dy <= existingVertices[3].dy)) {
                  overlapping.add(existingTextBubble);
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
                  overlapping.add(existingTextBubble);
                }
              }
            }
          }
        }
      }
    }
    return overlapping;
  }

  void add(TextBubble textBubble) {
    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    int startRow = textBubble.bufferPosition.dy ~/ gridBlockHeight;
    int endRow = (textBubble.bufferPosition.dy + textBubble.displaySize.height) ~/ gridBlockHeight;
    if (endRow == gridRows) {
      endRow--;
    }
    int startColumn = textBubble.bufferPosition.dx ~/ gridBlockWidth;
    int endColumn = (textBubble.bufferPosition.dx + textBubble.displaySize.width) ~/ gridBlockWidth;
    if (endColumn == gridColumns) {
      endColumn--;
    }

    for (int row = startRow; (row <= endRow); row++) {
      for (int column = startColumn; (column <= endColumn); column++) {
        grid[column][row].add(textBubble);
      }
    }

    textBubble.onGrid = true;
  }

  void remove(TextBubble textBubble) {
    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    int startRow = textBubble.bufferPosition.dy ~/ gridBlockHeight;
    int endRow = (textBubble.bufferPosition.dy + textBubble.displaySize.height) ~/ gridBlockHeight;
    if (endRow == gridRows) {
      endRow--;
    }
    int startColumn = textBubble.bufferPosition.dx ~/ gridBlockWidth;
    int endColumn = (textBubble.bufferPosition.dx + textBubble.displaySize.width) ~/ gridBlockWidth;
    if (endColumn == gridColumns) {
      endColumn--;
    }

    for (int row = startRow; (row <= endRow); row++) {
      for (int column = startColumn; (column <= endColumn); column++) {
        grid[column][row].remove(textBubble);
      }
    }

    textBubble.onGrid = false;
  }
}