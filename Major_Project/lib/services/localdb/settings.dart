import 'package:flutter/material.dart';
import 'settings_model.dart';

class Settings {
  String type;
  String color;

  Settings({this.type, this.color});

  Settings.fromMap(Map<String, dynamic> map) {
    this.type = map['Type'];
    this.color = map['Color'];
  }
  Map<String, dynamic> toMap() {
    return {
      'Type': this.type,
      'Color': this.color,
    };
  }
}

class PickSetting extends StatefulWidget {
  PickSetting({Key key}) : super(key: key);

  @override
  _PickSetting createState() => _PickSetting();
}

class _PickSetting extends State<PickSetting> {
  final _formkey = GlobalKey<FormState>();

  String _color = 'Blue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // dropdown to select colour for theme
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Theme'),
                      value: _color,
                      items: <String>[
                        'Blue',
                        'Deep Purple',
                        'Amber',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        _color = value;
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formkey.currentState.validate()) {
            _formkey.currentState.save();
            Settings setting = Settings(
              type: 'Theme',
              color: _color,
            );
            SettingsModel.updateSettings(setting);
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Add',
        child: Icon(Icons.check),
      ),
    );
  }
}
