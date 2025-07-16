import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isMonochrome = false;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isMonochrome => _isMonochrome;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.toString());
  }

  void setMonochrome(bool value) async {
    _isMonochrome = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMonochrome', value);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('themeMode');
    if (modeStr != null) {
      if (modeStr.contains('dark')) _themeMode = ThemeMode.dark;
      else if (modeStr.contains('light')) _themeMode = ThemeMode.light;
      else _themeMode = ThemeMode.system;
    }
    _isMonochrome = prefs.getBool('isMonochrome') ?? false;
    notifyListeners();
  }
} 