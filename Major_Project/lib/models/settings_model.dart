import 'package:flutter/material.dart';
import 'package:major_project/data/themes/blue_theme.dart';
import 'package:major_project/data/themes/dark_theme.dart';
import 'package:major_project/data/themes/sunset_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings with ChangeNotifier {
  SharedPreferences _prefs;
  String _theme;
  String _currentChatSession;
  String _currentChatPeer;
  ThemeData _themeData;
  String _mapTheme;
  String _peerProfileImageURL;
  //todo: more settings
  Settings(){
    init();
  }
  void init () async {
    _prefs = await SharedPreferences.getInstance();
    this._themeData =  parseTheme(_prefs.getString('theme'));
    this._currentChatSession = _prefs.getString('currentChatSession');
    this._currentChatPeer = _prefs.getString('currentChatPeer');
    this._mapTheme = _prefs.getString('mapTheme');
    notifyListeners();
  }
  getChatImageURL() => _peerProfileImageURL;
  getChatSession() => _currentChatSession;
  getChatPeer() => _currentChatPeer;
  getMapTheme() => _mapTheme;
  getTheme() => _themeData;

  saveTheme(String theme) async {
    _theme = theme;
    _themeData = parseTheme(theme);
    await _prefs.setString('theme', theme);
    notifyListeners();
  }
  saveChatPeer(String chatSession) async {
    _currentChatSession = chatSession;
    await _prefs.setString('currentChatSession', _currentChatSession);
    notifyListeners();
  }
  saveChatImageURL(String chatImageURL) async {
    _peerProfileImageURL = chatImageURL;
    await _prefs.setString('_currentChatImageURL', _peerProfileImageURL);
    notifyListeners();
  }
  saveChatSession(String chatPeer) async {
    _currentChatPeer = chatPeer;
    await _prefs.setString('currentChatPeer', chatPeer);
    notifyListeners();
  }
  saveMapTheme(String mapTheme) async {
    _mapTheme = mapTheme;
    await _prefs.setString('theme', mapTheme);
    notifyListeners();
  }
  ThemeData parseTheme(String theme){
    switch (theme) {
      case "blueTheme": return blueTheme;
        break;
      case "darkTheme": return darkTheme;
        break;
      case "sunsetTheme":return sunsetTheme;
        break;
      default: return blueTheme;
    }
  }
}