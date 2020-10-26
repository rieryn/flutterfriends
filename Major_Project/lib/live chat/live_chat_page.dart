import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class LiveChatPage extends StatefulWidget {
  LiveChatPage({Key key}) : super(key: key);

  _LiveChatPageState createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  double _lastRead = 0;
  DateTime _lastReadAt;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter Compass'),
        ),
        body: Builder(builder: (context) {

          return Column(
            children: <Widget>[
              _buildManualReader(),
              Expanded(child: _buildCompass()),
            ],
          );

        }),
      ),
    );
  }

  Widget _buildManualReader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          RaisedButton(
            child: Text('Read Value'),
            onPressed: () async {
              final double tmp = await FlutterCompass.events.first;
              setState(() {
                _lastRead = tmp;
                _lastReadAt = DateTime.now();
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$_lastRead',
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  '$_lastReadAt',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<double>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double direction = snapshot.data;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Container(
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: ((direction ?? 0) * (math.pi / 180) * -1),
          ),
        );
      },
    );
  }
}