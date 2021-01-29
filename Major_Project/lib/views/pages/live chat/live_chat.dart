import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:major_project/models/live_chat_message_model.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:major_project/services/utils/location_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scidart/numdart.dart';
import 'package:provider/provider.dart';

//todo: _db.pushLiveChatMessage()
class LiveChat extends StatefulWidget {
  LiveChat({Key key}) : super(key: key);

  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final _db = FirebaseService();
  Stream<Position> geolocatorStream;
  Future<locationAndDirection> future;
  Stream<TextBubble> textBubbleStream;
  Stream<List<LiveChatMessage>> liveChatStream;
  String userMessage = "";
  bool demo = true;

  @override
  void initState() {
    super.initState();
    geolocatorStream = Geolocator.getPositionStream();
    future = getInitialLocationAndDirection();
    //liveChatStream = _db.streamLiveChatMessages(radius: 1, currentLocation: LocationService.instance.currentLocation);
  }

  Future<locationAndDirection> getInitialLocationAndDirection() async {
    Position initialPosition = await geolocatorStream.first;
    //Position initialPosition = await Geolocator.getPositionStream().first;
    double initialDirection = await FlutterCompass.events.first;
    return new locationAndDirection(initialPosition, initialDirection);
  }

  @override
  Widget build(BuildContext context) {
    if (demo) {
      textBubbleStream = randomTextBubbleStream();
    }
    else {
      textBubbleStream = latestMessage(_db.streamLiveChatMessages(radius: 1, currentLocation: LocationService.instance.currentLocation));
    }
    double textInputWidth = MediaQuery.of(context).size.width;
    double textInputHeight = 50;

    double chatFieldWidth = MediaQuery.of(context).size.width;
    double chatFieldHeight = MediaQuery.of(context).size.height - textInputHeight - 56;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: FittedBox(
                child: Container (
                  child: FutureBuilder(
                    future: future, //getInitialLocationAndDirection(),
                    builder: (context, fbSnapshot) {
                      if (fbSnapshot.connectionState == ConnectionState.done) {
                        return StreamBuilder(
                          stream: Rx.combineLatest3(geolocatorStream, FlutterCompass.events, textBubbleStream, (location, direction, textBubble) => locationDirectionTextBubble(location, direction, textBubble)),
                          initialData: locationDirectionTextBubble.fromLAD(fbSnapshot.data, null),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text("snapshot Error: ${snapshot.error}");
                            }
                            return ChatField(deviceDirection: snapshot.data.direction,
                                location: snapshot.data.location, newTextBubble: snapshot.data.textBubble);
                          }
                        );
                      }
                      return Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment.center,
                      );
                    }
                  ),
                  width: chatFieldWidth,
                  height: chatFieldHeight,
                ),
                fit: BoxFit.none,
              ),
              width: chatFieldWidth,
            )
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder()
                      ),
                      onChanged: (value) {
                        userMessage = value;
                      },
                    ),
                    margin: EdgeInsets.all(5),
                  )
                ),
                IconButton(
                    icon: CircleAvatar(child: Icon(Icons.send),),
                    onPressed: pushUserMessage
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      demo = !demo;
                    });
                  },
                  child: Text("Press To Toggle Demo"),
                )
              ],
            ),
            width: textInputWidth,
            height: textInputHeight,
          ),
        ]
      )
    );
  }

  void pushUserMessage() async {
    _db.pushLiveChatMessage(text: userMessage, dateTime: DateTime.now(), position: await Geolocator.getCurrentPosition());
    userMessage = "";
  }
}

class locationAndDirection {
  Position location;
  double direction;

  locationAndDirection(this.location, this.direction);
}

class locationDirectionTextBubble extends locationAndDirection {
  TextBubble textBubble;

  locationDirectionTextBubble(location, direction, this.textBubble) : super(location, direction);

  locationDirectionTextBubble.fromLAD(locationAndDirection lad, this.textBubble) : super(lad.location, lad.direction);
}

class ChatField extends StatefulWidget {
  ChatField({Key key, this.deviceDirection, this.location, this.newTextBubble}) : super(key: key);

  double deviceDirection;
  Position location;
  TextBubble newTextBubble;
  static Size displaySize = Size(0, 0);

  _ChatFieldState createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatField> {
  List<TextBubble> textBubbles = new List<TextBubble>();
  List<Widget> layoutChildren = new List<Widget>();

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    if ((widget.newTextBubble != null) && !textBubbles.contains(widget.newTextBubble)) {
      textBubbles.add(widget.newTextBubble);
      setLayoutChildren();
    }
    bool recreateChildren = false;
    for (int i = 0; i < textBubbles.length; i++) {
      if (!textBubbles[i].displayable) {
        textBubbles.removeAt(i);
        layoutChildren.removeAt(i);
        i--;
        recreateChildren = true;
      }
    }

    if (recreateChildren) {
      //recreate the layoutChildren to reset their id
      setLayoutChildren();
    }

    return Container(
      color: Colors.lightBlueAccent,
      child: CustomMultiChildLayout(
        delegate: ChatFieldLayoutDelegate(textBubbles, widget.deviceDirection, widget.location),
        children: layoutChildren,
      )
    );
  }

  void setLayoutChildren() {
    layoutChildren = new List<Widget>();
    for (int i = 0; i < textBubbles.length; i++) {
      layoutChildren.add(LayoutId(
        id: i,
        child: ConstrainedBox(
            child: Container(
                color: Colors.green,
                child: Text(textBubbles[i].text),
                padding: EdgeInsets.all(10.0)
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 3.2, //3.2 instead of 3 to leave space between outer-ring textBubbles and inner-field textBubbles
              maxHeight: MediaQuery.of(context).size.width / 3.2,
            )
        ),
      ));
    }
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

    //deviceDirection = 0;

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

          textBubbles[i].bufferPosition = getDisplayLocation(textBubbles[i].direction, childSize.height, childSize.width);
        }
        else {
          textBubbles[i].direction = -1;
        }
      }
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (hasChild(i)) {
        if (textBubbles[i].direction != -1) { //calculate positions for textBubbles in outer-ring
          //check if any textBubbles are overlapping on screen
          List<spaceBlock> overlapCheck = cFGrid.checkOverlap(textBubbles[i], false).toList();

          List<TextBubble> overlapping = new List<TextBubble>();
          for (spaceBlock block in overlapCheck) {
            overlapping.add(block);
          }
          Map<TextBubble, Offset> originalPositions = new Map<TextBubble, Offset>();
          if (overlapping.length != 0) {
            overlapping.add(textBubbles[i]);
            for (int i = 0; i < overlapping.length; i++) {
              originalPositions[overlapping[i]] = overlapping[i].bufferPosition.dLocation;
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
            with clutter restrictions assume that it is impossible to have both underflow and overflow.
            TODO: ^
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
                  groupTrackLength[2] = calcPos[overlapping.length - 1][0] - groupLocation.dLocation.dy + overlapping[0].displaySize.height / 2;
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
                  //find widest textBubble within height of current
                  int current = overlapping.length - 1 - (i + 1) ~/ 2;
                  double remainingHeight = overlapping[current].displaySize.height - overlapping[current - 1].displaySize.height;
                  int widest = current - 1;
                  for (int j = widest - 1; (j >= 0) && (remainingHeight > 0); j--) {
                    remainingHeight -= overlapping[j].displaySize.height + childSpacing;
                    if (overlapping[j].displaySize.width > overlapping[widest].displaySize.width) {
                      widest = j;
                    }
                  }
                  movements[2 * i] = overlapping[widest].displaySize.width + childSpacing;
                  movementsSum += movements[2 * i];
                }
                for (int i = 0; (2 * i) + 1 < movements.length; i++) {
                  movements[(2 * i) + 1] = overlapping[overlapping.length - 1 - i].displaySize.height + childSpacing;
                  movementsSum += movements[(2 * i) + 1];
                }
              }
              else if ((((groupLocation.side == 2) && (overflowStart != -1)) || ((groupLocation.side == 3) && (underflowStart != -1))) || (((groupLocation.side == 4) && (overflowStart != -1)) || ((groupLocation.side == 1) && (underflowStart != -1)))) { //bottom right corner || top left corner
                for (int i = 0; (2 * i) < movements.length; i++) {
                  //find tallest textBubble within width of current
                  int current = overlapping.length - 1 - (i + 1) ~/ 2;
                  double remainingWidth = overlapping[current].displaySize.width - overlapping[current - 1].displaySize.width;
                  int tallest = current - 1;
                  for (int j = tallest - 1; (j >= 0) && (remainingWidth > 0); j--) {
                    remainingWidth -= overlapping[j].displaySize.width + childSpacing;
                    if (overlapping[j].displaySize.height > overlapping[tallest].displaySize.height) {
                      tallest = j;
                    }
                  }
                  movements[2 * i] = overlapping[tallest].displaySize.height + childSpacing;
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
                double xpos;

                //position base textBubble
                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (movements[segmentOfTrack]), displayAreaHeight - overlapping[baseChild].displaySize.height);
                  overlapping[baseChild].bufferPosition.side = 2;
                  if ((baseChild != overlapping.length - 1) && (overlapping[baseChild].bufferPosition.dLocation.dx + overlapping[baseChild].displaySize.width + childSpacing < movements[segmentOfTrack])) {
                    xpos = movements[segmentOfTrack];
                  }
                  else {
                    xpos = overlapping[baseChild].bufferPosition.dLocation.dx + overlapping[baseChild].displaySize.width;
                  }
                }
                else {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(0, displayAreaHeight - overlapping[baseChild].displaySize.height - childSpacing - overlapping[baseChild + 1].displaySize.height + ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.height + childSpacing));
                  overlapping[baseChild].bufferPosition.side = 1;
                  xpos = movements[segmentOfTrack - 1];
                }
                overlapping[baseChild].cornerAnchor = 1;
                setCornerAnchorVertices(overlapping[baseChild], xpos, overlapping[baseChild].bufferPosition.dLocation.dy);

                //position all following textBubbles
                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  int segmentOffset = 1;
                  if (segmentOfTrack.isEven) {
                    segmentOffset = 0;
                  }
                  if (overlapping[i - 1].bufferPosition.dLocation.dx + overlapping[i - 1].displaySize.width + childSpacing < movements[segmentOfTrack - segmentOffset]) {
                    overlapping[i].bufferPosition.dLocation = Offset(movements[segmentOfTrack - segmentOffset], displayAreaHeight - overlapping[i].displaySize.height);
                  }
                  else {
                    overlapping[i].bufferPosition.dLocation = Offset(overlapping[i - 1].bufferPosition.dLocation.dx + overlapping[i - 1].displaySize.width + childSpacing, displayAreaHeight - overlapping[i].displaySize.height);
                  }
                }

                //position all preceding textBubbles
                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition.dLocation = Offset(0, overlapping[i + 1].bufferPosition.dLocation.dy - overlapping[i].displaySize.height - childSpacing);
                }
              }
              else if (((groupLocation.side == 2) && (overflowStart != -1)) || ((groupLocation.side == 3) && (underflowStart != -1))) { //bottom right corner
                double ypos;

                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width, displayAreaHeight - overlapping[baseChild].displaySize.height - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (movements[segmentOfTrack]));
                  overlapping[baseChild].bufferPosition.side = 3;
                  if ((baseChild != overlapping.length - 1) && (overlapping[baseChild].bufferPosition.dLocation.dy + childSpacing < movements[segmentOfTrack])) {
                    ypos = displayAreaHeight - movements[segmentOfTrack];
                  }
                  else {
                    ypos = overlapping[baseChild].bufferPosition.dLocation.dy;
                  }
                }
                else {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width - childSpacing - overlapping[baseChild + 1].displaySize.width + ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.width + childSpacing), displayAreaHeight - overlapping[baseChild].displaySize.height);
                  overlapping[baseChild].bufferPosition.side = 2;
                  ypos = displayAreaHeight - movements[segmentOfTrack - 1];
                }
                overlapping[baseChild].cornerAnchor = 2;
                setCornerAnchorVertices(overlapping[baseChild], overlapping[baseChild].bufferPosition.dLocation.dx, ypos);

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  int segmentOffset = 1;
                  if (segmentOfTrack.isEven) {
                    segmentOffset = 0;
                  }
                  if (displayAreaHeight - overlapping[i - 1].bufferPosition.dLocation.dy - childSpacing < movements[segmentOfTrack - segmentOffset]) {
                    overlapping[i].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[i].displaySize.width, displayAreaHeight - overlapping[i].displaySize.height - movements[segmentOfTrack - segmentOffset]);
                  }
                  else {
                    overlapping[i].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[i].displaySize.width, overlapping[i - 1].bufferPosition.dLocation.dy - overlapping[i].displaySize.height - childSpacing);
                  }
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition.dLocation = Offset(overlapping[i + 1].bufferPosition.dLocation.dx - overlapping[i].displaySize.width - childSpacing, displayAreaHeight - overlapping[i].displaySize.height);
                }
              }
              else if (((groupLocation.side == 3) && (overflowStart != -1)) || ((groupLocation.side == 4) && (underflowStart != -1))) { //top right corner
                double xpos;

                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (movements[segmentOfTrack]), 0);
                  overlapping[baseChild].bufferPosition.side = 4;
                  if ((baseChild != overlapping.length - 1) && (displayAreaWidth - overlapping[baseChild].bufferPosition.dLocation.dx - childSpacing < movements[segmentOfTrack])) {
                    xpos = displayAreaWidth - movements[segmentOfTrack];
                  }
                  else {
                    xpos = overlapping[baseChild].bufferPosition.dLocation.dx;
                  }
                }
                else {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[baseChild].displaySize.width, overlapping[baseChild + 1].displaySize.height + childSpacing - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.height + childSpacing));
                  overlapping[baseChild].bufferPosition.side = 3;
                  xpos = displayAreaWidth - movements[segmentOfTrack - 1];
                }
                overlapping[baseChild].cornerAnchor = 3;
                setCornerAnchorVertices(overlapping[baseChild], xpos, overlapping[baseChild].bufferPosition.dLocation.dy + overlapping[baseChild].displaySize.height);

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  int segmentOffset = 1;
                  if (segmentOfTrack.isEven) {
                    segmentOffset = 0;
                  }
                  if (displayAreaWidth - overlapping[i - 1].bufferPosition.dLocation.dx - childSpacing < movements[segmentOfTrack - segmentOffset]) {
                    overlapping[i].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[i].displaySize.width - movements[segmentOfTrack - segmentOffset], 0);
                  }
                  else {
                    overlapping[i].bufferPosition.dLocation = Offset(overlapping[i - 1].bufferPosition.dLocation.dx - overlapping[i].displaySize.width - childSpacing, 0);
                  }
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[i].displaySize.width, overlapping[i + 1].bufferPosition.dLocation.dy + overlapping[i + 1].displaySize.height + childSpacing);
                }
              }
              else if (((groupLocation.side == 4) && (overflowStart != -1)) || ((groupLocation.side == 1) && (underflowStart != -1))) { //top left corner
                double ypos;

                if (segmentOfTrack.isEven) {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(0, ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (movements[segmentOfTrack]));
                  overlapping[baseChild].bufferPosition.side = 1;
                  if ((baseChild != overlapping.length - 1) && (overlapping[baseChild].bufferPosition.dLocation.dy + overlapping[baseChild].displaySize.height + childSpacing < movements[segmentOfTrack])) {
                    ypos = movements[segmentOfTrack];
                  }
                  else {
                    ypos = overlapping[baseChild].bufferPosition.dLocation.dy + overlapping[baseChild].displaySize.height;
                  }
                }
                else {
                  overlapping[baseChild].bufferPosition.dLocation = Offset(overlapping[baseChild + 1].displaySize.width + childSpacing - ((placeInTrack - groupTrack[segmentOfTrack][1]) / groupTrack[segmentOfTrack][0]) * (overlapping[baseChild + 1].displaySize.width + childSpacing), 0);
                  overlapping[baseChild].bufferPosition.side = 4;
                  ypos = movements[segmentOfTrack - 1];
                }
                overlapping[baseChild].cornerAnchor = 4;
                setCornerAnchorVertices(overlapping[baseChild], overlapping[baseChild].bufferPosition.dLocation.dx + overlapping[baseChild].displaySize.width, ypos);

                for (int i = baseChild + 1; i < overlapping.length; i++) {
                  int segmentOffset = 1;
                  if (segmentOfTrack.isEven) {
                    segmentOffset = 0;
                  }
                  if (overlapping[i - 1].bufferPosition.dLocation.dy + overlapping[i - 1].displaySize.height + childSpacing < movements[segmentOfTrack - segmentOffset]) {
                    overlapping[i].bufferPosition.dLocation = Offset(0, movements[segmentOfTrack - segmentOffset]);
                  }
                  else {
                    overlapping[i].bufferPosition.dLocation = Offset(0, overlapping[i - 1].bufferPosition.dLocation.dy + overlapping[i - 1].displaySize.height + childSpacing);
                  }
                }

                for (int i = baseChild - 1; i >= 0; i--) {
                  overlapping[i].bufferPosition.dLocation = Offset(overlapping[i + 1].bufferPosition.dLocation.dx + overlapping[i + 1].displaySize.width + childSpacing, 0);
                }
              }
            }
            else { //place same side textBubbles
              int start = 0;
              int end = overlapping.length;

              if (groupLocation.side == 1) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition.dLocation = Offset(0, calcPos[i][0] - (overlapping[i].displaySize.height / 2));
                }
              }
              else if (groupLocation.side == 2) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition.dLocation = Offset(calcPos[i][0] - (overlapping[i].displaySize.width / 2), displayAreaHeight - overlapping[i].displaySize.height);
                }
              }
              else if (groupLocation.side == 3) {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition.dLocation = Offset(displayAreaWidth - overlapping[i].displaySize.width, calcPos[overlapping.length - 1 - i][0] - (overlapping[i].displaySize.height / 2));
                }
              }
              else {
                for (int i = start; i < end; i++) {
                  overlapping[i].bufferPosition.dLocation = Offset(calcPos[overlapping.length - 1 - i][0] - (overlapping[i].displaySize.width / 2), 0);
                }
              }
            }

            //TODO: check if display angle offset exceeds childMaxOffsetAngle.  If all textBubbles in group are already being displayed then ignore this
            bool newTextBubble = false;
            for (TextBubble textBubble in overlapping) {
              if (!textBubble.onScreen) {
                newTextBubble = true;
                break;
              }
            }

            if (newTextBubble) {
              for (TextBubble textBubble in overlapping) {
                //if ()
              }
            }

            //check clutter
            for (int i = 0; i < overlapping.length; i++) {
              cFGrid.add(overlapping[i]);
            }
            if (cFGrid.tooCluttered()) {
              for (int i = 0; i < overlapping.length; i++) {
                cFGrid.remove(overlapping[i]);
              }

              //flag textBubble for removal and restore the original positions of the remaining textBubbles
              originalPositions.forEach((key, value) {key.bufferPosition.dLocation = value;});
              for (int j = 0; j < overlapping.length; j++) {
                if (overlapping[j] != textBubbles[i]) {
                  cFGrid.add(overlapping[j]);
                }
              }
              textBubbles[i].displayable = false;
              break;
            }
            else {
              for (int i = 0; i < overlapping.length; i++) {
                cFGrid.remove(overlapping[i]);
              }
            }

            //check if textBubbles in new positions are overlapping any other textBubbles
            Set<TextBubble> nowOverlapping = new Set<TextBubble>();
            for (int i = 0; i < overlapping.length; i++) {
              List<spaceBlock> overlapCheck = cFGrid.checkOverlap(overlapping[i], false).toList();
              List<TextBubble> temp = new List<TextBubble>();
              //cant do implicit conversion
              for (spaceBlock block in overlapCheck) {
                temp.add(block);
              }
              nowOverlapping.addAll(temp);
            }

            if (nowOverlapping.length != 0) {
              //redo position calculations and include the new overlapping textBubbles
              originalPositions.forEach((key, value) {key.bufferPosition.dLocation = value;});
              for (int i = 0; i < overlapping.length; i++) {
                overlapping[i].cornerAnchor = -1;
              }
              overlapping.addAll(nowOverlapping);
              for (int i = 0; i < nowOverlapping.length; i++) {
                originalPositions[nowOverlapping.elementAt(i)] = nowOverlapping.elementAt(i).bufferPosition.dLocation;
                if (nowOverlapping.elementAt(i).onGrid) {
                  cFGrid.remove(nowOverlapping.elementAt(i));
                }
              }
            }
            else { //overlap has been dealt with
              for (int i = 0; i < overlapping.length; i++) {
                cFGrid.add(overlapping[i]);
              }

              if (cFGrid.tooCluttered()) {
                for (int i = 0; i < overlapping.length; i++) {
                  cFGrid.remove(overlapping[i]);
                }

                //flag textBubble for removal and restore the original positions of the remaining textBubbles
                originalPositions.forEach((key, value) {key.bufferPosition.dLocation = value;});
                for (int j = 0; j < overlapping.length; j++) {
                  if (overlapping[j] != textBubbles[i]) {
                    cFGrid.add(overlapping[j]);
                  }
                }
                textBubbles[i].displayable = false;
              }
              break;
            }
          }

          //add textBubble to chatFieldGrid
          if (overlapping.length == 0) {
            if (textBubbles[i].onGrid) {
              cFGrid.remove(textBubbles[i]);
            }
            cFGrid.add(textBubbles[i]);

            if (cFGrid.tooCluttered()) {
              //flag textBubble for removal
              textBubbles[i].displayable = false;
              cFGrid.remove(textBubbles[i]);
            }
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
          textBubbles[i].bufferPosition.dLocation = textBubbles[i].displayPosition;
          if (textBubbles[i].onInnerField && !displayResized) {
            cFGrid.placeAndBreak(textBubbles[i]);
          }
          else {
            textBubbles[i].onInnerField = false;
            findSpot(textBubbles[i], cFGrid);

            if (!textBubbles[i].onInnerField) {
              //if there is no space then check if removing collapsed textBubbles creates enough space
              chatFieldGrid tempGrid = new chatFieldGrid(childSpacing);
              tempGrid.resetInnerField(innerFieldWidth, innerFieldHeight);
              for (int j = 0; j < i; j++) {
                if (textBubbles[j].onInnerField && !textBubbles[j].collapsed) {
                  tempGrid.placeAndBreak(textBubbles[j]);
                }
              }

              findSpot(textBubbles[i], tempGrid);

              if (textBubbles[i].onInnerField) {
                //find which collapsed textBubbles need to be removed
                List<spaceBlock> overlapCheck = cFGrid.checkOverlap(textBubbles[i], false).toList();

                List<TextBubble> overlapping = new List<TextBubble>();
                for (spaceBlock block in overlapCheck) {
                  overlapping.add(block);
                }

                cFGrid.resetInnerField(innerFieldWidth, innerFieldHeight);
                for (int j = 0; j <= i; j++) {
                  if ((textBubbles[j].onInnerField && !overlapping.contains(textBubbles[j])) || (j == i)) {
                    cFGrid.placeAndBreak(textBubbles[j]);
                  }
                }
              }
              else {
                //if still no space then flag textBubble for removal.  textBubble will not be displayed
                textBubbles[i].displayable = false;
              }
            }
          }
        }
      }
    }

    for (int i = 0; i < textBubbles.length; i++) {
      if (!textBubbles[i].displayable) {
        //child must still be positioned, so position off-screen and remove before next rebuild
        positionChild(i, Offset(displayAreaHeight + 1, displayAreaWidth + 1));
      }
      else {
        cFGrid.remove(textBubbles[i]);
        textBubbles[i].displayPosition = textBubbles[i].bufferPosition.dLocation;
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
      y = (((displayAreaHeight / 2) - ((displayAreaWidth / 2) * math.tan((math.pi / 2) - direction))) / displayAreaHeight) * (displayAreaHeight - textBubbleHeight);
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

  double getDisplayAngle(TextBubble textBubble) {
    int side;
    //if ()
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

  //find any block that will fit textBubble
  void findSpot(TextBubble textBubble, chatFieldGrid grid) {
    math.Random rng = new math.Random();
    for (spaceBlock block in grid.innerFieldBlocks) {
      if (block.vertices[3].dy - block.vertices[0].dy >= textBubble.displaySize.height + childSpacing) {
        if (block.vertices[1].dx - block.vertices[0].dx >= textBubble.displaySize.width + childSpacing) {
          //randomly place textBubble inside block
          double xPos = rng.nextDouble() * (block.vertices[1].dx - block.vertices[0].dx - textBubble.displaySize.width - 0.5 * childSpacing) + block.vertices[0].dx + 0.5 * childSpacing;
          double yPos = rng.nextDouble() * (block.vertices[3].dy - block.vertices[0].dy - textBubble.displaySize.height - 0.5 * childSpacing) + block.vertices[0].dy + 0.5 * childSpacing;
          textBubble.bufferPosition.dLocation = Offset(xPos, yPos);
          cFGrid.placeAndBreak(textBubble);
          break;
        }
      }
    }
  }
  
  void setCornerAnchorVertices(TextBubble textBubble, xpos, ypos) {
    double top;
    double right;
    double bottom;
    double left;

    if ((textBubble.cornerAnchor == 3) && (textBubble.bufferPosition.side == 3)) {
      top = 0;
    }
    else if ((textBubble.cornerAnchor == 4) && (textBubble.bufferPosition.side == 1)) {
      top = 0;
    }
    else if ((textBubble.cornerAnchor == 3) && (textBubble.bufferPosition.side == 4)) {
      top = 0;
    }
    else if ((textBubble.cornerAnchor == 4) && (textBubble.bufferPosition.side == 4)) {
      top = 0;
    }
    else {
      top = ypos;
    }

    if ((textBubble.cornerAnchor == 1) && (textBubble.bufferPosition.side == 1)) {
      bottom = displayAreaHeight;
    }
    else if ((textBubble.cornerAnchor == 2) && (textBubble.bufferPosition.side == 3)) {
      bottom = displayAreaHeight;
    }
    else if ((textBubble.cornerAnchor == 1) && (textBubble.bufferPosition.side == 2)) {
      bottom = displayAreaHeight;
    }
    else if ((textBubble.cornerAnchor == 2) && (textBubble.bufferPosition.side == 2)) {
      bottom = displayAreaHeight;
    }
    else {
      bottom = ypos;
    }

    if ((textBubble.cornerAnchor == 1) && (textBubble.bufferPosition.side == 2)) {
      left = 0;
    }
    else if ((textBubble.cornerAnchor == 4) && (textBubble.bufferPosition.side == 4)) {
      left = 0;
    }
    else if ((textBubble.cornerAnchor == 1) && (textBubble.bufferPosition.side == 1)) {
      left = 0;
    }
    else if ((textBubble.cornerAnchor == 4) && (textBubble.bufferPosition.side == 1)) {
      left = 0;
    }
    else {
      left = xpos;
    }

    if ((textBubble.cornerAnchor == 2) && (textBubble.bufferPosition.side == 2)) {
      right = displayAreaWidth;
    }
    else if ((textBubble.cornerAnchor == 3) && (textBubble.bufferPosition.side == 4)) {
      right = displayAreaWidth;
    }
    else if ((textBubble.cornerAnchor == 2) && (textBubble.bufferPosition.side == 3)) {
      right = displayAreaWidth;
    }
    else if ((textBubble.cornerAnchor == 3) && (textBubble.bufferPosition.side == 3)) {
      right = displayAreaWidth;
    }
    else {
      right = xpos;
    }

    textBubble.vertices = [Offset(left, top), Offset(right, top), Offset(right, bottom), Offset(left, bottom)];
  }
}

class TextBubble extends spaceBlock {
  String text;
  Position location;
  DateTime time;
  Offset displayPosition;
  bool collapsed;
  double direction;
  bool displayable = true;
  bool onInnerField = false;
  Duration collapseAt;
  bool onScreen = false;
  DateTime postTime;
  String id;

  TextBubble(this.text, this.location, this.postTime) : super(true) {
    //calculate how long textBubble will be expanded.  Duration is based on amount of text
    Duration timePerCharacter = new Duration(milliseconds: 100);
    Duration baseTime = new Duration(seconds: 1);
    collapseAt = (timePerCharacter * text.length) + baseTime;

    Timer(collapseAt, () { this.displayable = false; });
  }
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
  double innerFieldWidth;
  double innerFieldHeight;

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
    innerFieldWidth = width;
    innerFieldHeight = height;
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

  Set<spaceBlock> checkOverlap(spaceBlock sBlock, bool sb) {
    Set<spaceBlock> overlapping = new Set<spaceBlock>();

    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    int startRow;
    int endRow;
    int startColumn;
    int endColumn;

    if (sBlock.cornerAnchor == -1) {
      startRow = sBlock.bufferPosition.dLocation.dy ~/ gridBlockHeight;
      endRow = (sBlock.bufferPosition.dLocation.dy + sBlock.displaySize.height) ~/ gridBlockHeight;

      startColumn = sBlock.bufferPosition.dLocation.dx ~/ gridBlockWidth;
      endColumn = (sBlock.bufferPosition.dLocation.dx + sBlock.displaySize.width) ~/ gridBlockWidth;
    }
    else {
      startRow = sBlock.vertices[0].dy ~/ gridBlockHeight;
      endRow = sBlock.vertices[3].dy ~/ gridBlockHeight;
      startColumn = sBlock.vertices[0].dx ~/ gridBlockWidth;
      endColumn = sBlock.vertices[1].dx ~/ gridBlockWidth;
    }

    if (endRow == gridRows) {
      endRow--;
    }
    if (endColumn == gridColumns) {
      endColumn--;
    }

    for (int row = startRow; (row <= endRow); row++) {
      for (int column = startColumn; (column <= endColumn); column++) {
        for (int i = 0; i < grid[column][row].length; i++) {
          spaceBlock existingSBlock = grid[column][row][i];
          if (existingSBlock.textBubble && sb) {
            continue;
          }
          else if ((!existingSBlock.textBubble) && (!sb)) {
            continue;
          }

          if (!overlapping.contains(existingSBlock)) {
            bool overlappingFound = false;

            List<Offset> newVertices;
            List<Offset> existingVertices;
            if (sBlock.cornerAnchor == -1) {
              newVertices = {
                sBlock.bufferPosition.dLocation,
                Offset(sBlock.bufferPosition.dLocation.dx + sBlock.displaySize.width,
                    sBlock.bufferPosition.dLocation.dy),
                Offset(sBlock.bufferPosition.dLocation.dx + sBlock.displaySize.width,
                    sBlock.bufferPosition.dLocation.dy + sBlock.displaySize.height),
                Offset(sBlock.bufferPosition.dLocation.dx,
                    sBlock.bufferPosition.dLocation.dy + sBlock.displaySize.height)
              }.toList();
            }
            else {
              newVertices = sBlock.vertices;
            }

            if (!sb && (existingSBlock.cornerAnchor == -1)) {
              existingVertices = [
                existingSBlock.bufferPosition.dLocation,
                Offset(existingSBlock.bufferPosition.dLocation.dx +
                    existingSBlock.displaySize.width,
                    existingSBlock.bufferPosition.dLocation.dy),
                Offset(existingSBlock.bufferPosition.dLocation.dx +
                    existingSBlock.displaySize.width,
                    existingSBlock.bufferPosition.dLocation.dy +
                        existingSBlock.displaySize.height),
                Offset(existingSBlock.bufferPosition.dLocation.dx,
                    existingSBlock.bufferPosition.dLocation.dy +
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
                  overlappingFound = true;
                  break;
                }
              }
            }

            if (overlappingFound) {
              continue;
            }

            //check if textBubble stretches across existing
            if ((newVertices[0].dy >= existingVertices[0].dy) && (newVertices[0].dy <= existingVertices[3].dy) && (newVertices[0].dx <= existingVertices[0].dx) && (newVertices[1].dx >= existingVertices[1].dx)) {
              overlapping.add(existingSBlock);
            }
            else if ((newVertices[3].dy >= existingVertices[0].dy) && (newVertices[3].dy <= existingVertices[3].dy) && (newVertices[0].dx <= existingVertices[0].dx) && (newVertices[1].dx >= existingVertices[1].dx)) {
              overlapping.add(existingSBlock);
            }
            else if ((newVertices[0].dx >= existingVertices[0].dx) && (newVertices[0].dx <= existingVertices[3].dx) && (newVertices[0].dy <= existingVertices[0].dy) && (newVertices[3].dy >= existingVertices[3].dy)) {
              overlapping.add(existingSBlock);
            }
            else if ((newVertices[1].dx >= existingVertices[0].dx) && (newVertices[1].dx <= existingVertices[3].dx) && (newVertices[0].dy <= existingVertices[0].dy) && (newVertices[3].dy >= existingVertices[3].dy)) {
              overlapping.add(existingSBlock);
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
    int startRow;
    int endRow;
    int startColumn;
    int endColumn;

    if (sBlock.cornerAnchor == -1) {
      startRow = sBlock.bufferPosition.dLocation.dy ~/ gridBlockHeight;
      if (sBlock.textBubble) {
        endRow = (sBlock.bufferPosition.dLocation.dy + sBlock.displaySize.height) ~/ gridBlockHeight;
      }
      else {
        endRow = sBlock.vertices[3].dy ~/ gridBlockHeight;
      }

      startColumn = sBlock.bufferPosition.dLocation.dx ~/ gridBlockWidth;
      if (sBlock.textBubble) {
        endColumn = (sBlock.bufferPosition.dLocation.dx + sBlock.displaySize.width) ~/ gridBlockWidth;
      }
      else {
        endColumn = sBlock.vertices[1].dx ~/ gridBlockWidth;
      }

    }
    else {
      startRow = sBlock.vertices[0].dy ~/ gridBlockHeight;
      endRow = sBlock.vertices[3].dy ~/ gridBlockHeight;
      startColumn = sBlock.vertices[0].dx ~/ gridBlockWidth;
      endColumn = sBlock.vertices[1].dx ~/ gridBlockWidth;
    }

    if (endRow == gridRows) {
      endRow--;
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
    if (!add) {
      sBlock.cornerAnchor = -1;
    }
  }

  void placeAndBreak(TextBubble textBubble) {
    //quickly determine if there is overlap before determining how the textBubble overlaps each block
    List<spaceBlock> blocks = checkOverlap(textBubble, true).toList();

    for (spaceBlock block in blocks) {
      //remove block from grid
      remove(block);
      innerFieldBlocks.remove(block);

      //break block according to overlap
      List<Offset> textBubbleVertices = [
        textBubble.bufferPosition.dLocation,
        Offset(textBubble.bufferPosition.dLocation.dx + textBubble.displaySize.width,
            textBubble.bufferPosition.dLocation.dy),
        Offset(textBubble.bufferPosition.dLocation.dx + textBubble.displaySize.width,
            textBubble.bufferPosition.dLocation.dy + textBubble.displaySize.height),
        Offset(textBubble.bufferPosition.dLocation.dx,
            textBubble.bufferPosition.dLocation.dy + textBubble.displaySize.height)
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

  /*
  go around the perimeter of the grid an ensure that there is enough free space
  to avoid grid-lock
   */
  bool tooCluttered() {
    double gridBlockWidth = displayAreaWidth / gridColumns;
    double gridBlockHeight = displayAreaHeight / gridRows;

    double maxSpace = displayAreaWidth * 2 / 3;
    double consecutiveSpaceOccupied = 0;
    int squaresInPerimeter = 2 * gridRows + 2 * (gridColumns - 2);
    Set<spaceBlock> textBubbles = new Set<spaceBlock>();
    List<int> sides = new List<int>();

    /*
    need to cover the perimeter + a distance >= maxSpace in case the check starts
    in the middle of a group
     */
    for (int i = 0; i < squaresInPerimeter + gridColumns; i++) {
      int column;
      int row;
      int side;
      if (i < gridRows) {
        column = 0;
        row = i;
        side = 1;
      }
      else if (i < gridRows + gridColumns - 2) {
        column = i - gridRows + 1;
        row = gridRows - 1;
        side = 2;
      }
      else if (i < 2 * gridRows + gridColumns - 2) {
        column = gridColumns - 1;
        row = gridRows - (i - (gridRows + gridColumns - 2)) - 1;
        side = 3;
      }
      else if (i < squaresInPerimeter) {
        column = gridColumns - (i - (2 * gridRows + gridColumns - 2)) - 2;
        row = 0;
        side = 4;
      }
      else {
        column = 0;
        row = i - squaresInPerimeter;
        side = 1;
      }

      //remove far back textBubbles from textBubbles Set
      if ((column == 0) && (row == 0)) {
        for (int j = 0; j < textBubbles.length; j++) {
          if (sides[j] == 2) {
            textBubbles.remove(textBubbles.elementAt(j));
            sides.removeAt(j);
            i--;
          }
        }
      }
      else if ((column == gridColumns - 1) && (row == 0)) {
        for (int j = 0; j < textBubbles.length; j++) {
          if (sides[j] == 1) {
            textBubbles.remove(textBubbles.elementAt(j));
            sides.removeAt(j);
            i--;
          }
        }
      }

      if (grid[column][row].isEmpty) {
        if ((column == 0) && (row == 0)) {
          consecutiveSpaceOccupied -= gridBlockHeight + gridBlockWidth;
        }
        else if ((column == 0) && (row == gridRows - 1)) {
          consecutiveSpaceOccupied -= gridBlockHeight + gridBlockWidth;
        }
        else if ((column == gridColumns - 1) && (row == gridRows - 1)) {
          consecutiveSpaceOccupied -= gridBlockHeight + gridBlockWidth;
        }
        else if ((column == gridColumns - 1) && (row == 0)) {
          consecutiveSpaceOccupied -= gridBlockHeight + gridBlockWidth;
        }
        else if ((side == 1) || (side == 3)) {
          consecutiveSpaceOccupied -= gridBlockHeight;
        }
        else {
          consecutiveSpaceOccupied -= gridBlockWidth;
        }

        if (consecutiveSpaceOccupied < 0) {
          consecutiveSpaceOccupied = 0;
        }
      }
      else {
        Set<spaceBlock> textBubblesInGridSquare = Set.from(grid[column][row]);
        Set<spaceBlock> newTextBubbles = textBubblesInGridSquare.difference(textBubbles);

        if (!newTextBubbles.isEmpty) {
          for (spaceBlock textBubble in newTextBubbles) {
            consecutiveSpaceOccupied += textBubble.displaySize.width;
            sides.add(side);
          }
          textBubbles.addAll(newTextBubbles);
        }
      }

      if (consecutiveSpaceOccupied > maxSpace) {
        return true;
      }
    }

    return false;
  }
}

class spaceBlock {
  List<Offset> vertices;
  DisplayLocation bufferPosition = new DisplayLocation(Offset(0, 0), -1);
  bool textBubble = false;
  Size displaySize;
  bool onGrid = false;
  int cornerAnchor = -1;

  spaceBlock(this.textBubble);

  spaceBlock.fromVertices(Offset topLeft, Offset topRight, Offset bottomRight, Offset bottomLeft) {
    vertices = new List<Offset>(4);
    vertices[0] = topLeft;
    vertices[1] = topRight;
    vertices[2] = bottomRight;
    vertices[3] = bottomLeft;
    bufferPosition.dLocation = topLeft;
  }
}

Stream<TextBubble> randomTextBubbleStream() {
  StreamController<TextBubble> controller = BehaviorSubject<TextBubble>();
  int interval = 1;

  Timer.periodic(Duration(seconds: interval), (timer) => generateRandomTextBubble(controller));
  //Timer.periodic(Duration(seconds: interval), (timer) => insertTestTextBubble(controller));

  return controller.stream;
}

void generateRandomTextBubble(StreamController<TextBubble> controller) async {
  int charLimit = 50;
  math.Random rng = new math.Random();
  int messageLength = rng.nextInt(charLimit) + 1;
  String message = "";
  for (int i = 0; i < messageLength; i++) {
    message += String.fromCharCode(rng.nextInt(90) + 32);
  }

  Position textBubblePosition;
  if ((DateTime.now().second % 3) == 0) {
    textBubblePosition = await Geolocator.getCurrentPosition();
  }
  else {
    textBubblePosition = new Position(latitude: 30 + rng.nextDouble() * 20, longitude: - 70 - rng.nextDouble() * 20);
  }
  DateTime textBubblePostTime = DateTime.now();
  controller.add(new TextBubble(message, textBubblePosition, textBubblePostTime));
}

int testTextBubble = 0;

void insertTestTextBubble(StreamController<TextBubble> controller) async {
  List<TextBubble> textBubbles = new List<TextBubble>();

  Position currentPosition = await Geolocator.getCurrentPosition();


  textBubbles.add(new TextBubble("o)Pwf;ABZ5:'munipP:uM/_()C]w8CBaYO>pn(I,'fxm+[[':Q", Position(latitude: 35.501595840209866, longitude: -86.73006837635258), DateTime.now()));
  textBubbles.add(new TextBubble("3+Y'Gu&IZ,xpe\"r", Position(latitude: 30.564209077344955, longitude: -84.85985819387241), DateTime.now()));
  //textBubbles.add(new TextBubble("big test text\n1\n", Position(latitude: currentPosition.latitude + 1, longitude: currentPosition.longitude), DateTime.now()));
  //textBubbles.add(new TextBubble("st", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0001), DateTime.now()));
  //textBubbles.add(new TextBubble("further northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0002), DateTime.now()));
  //textBubbles.add(new TextBubble("big test text\n2\n", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0003), DateTime.now()));
  //textBubbles.add(new TextBubble("even further northEast", Position(latitude: widget.location.latitude + 1, longitude: widget.location.longitude + 0.0004), DateTime.now()));
  //textBubbles.add(new TextBubble("east", Position(latitude: currentPosition.latitude, longitude: currentPosition.longitude + 1), DateTime.now()));
  //textBubbles.add(new TextBubble("south", Position(latitude: currentPosition.latitude - 1, longitude: currentPosition.longitude), DateTime.now()));
  //textBubbles.add(new TextBubble("west", Position(latitude: currentPosition.latitude, longitude: currentPosition.longitude - 1), DateTime.now()));

  //textBubbles.add(new TextBubble("test", currentPosition, DateTime.now()));
  //textBubbles.add(new TextBubble("test 2", currentPosition, DateTime.now()));
  //textBubbles.add(new TextBubble("test                 3", currentPosition, DateTime.now()));
  //textBubbles.add(new TextBubble("test\n4\ntall\nmessage", currentPosition, DateTime.now()));

  if (testTextBubble < textBubbles.length) {
    controller.add(textBubbles[testTextBubble]);
    testTextBubble++;
  }
}

Stream<TextBubble> latestMessage(Stream<List<LiveChatMessage>> chatMessageStream) async* {
  List<LiveChatMessage> chatMessages = await chatMessageStream.first;
  chatMessages.sort((message1, message2) {
    if (message1.time.isBefore(message2.time)) {
      return -1;
    }
    return 1;
  });
  yield new TextBubble(chatMessages.last.text, chatMessages.last.location, DateTime.now());
}