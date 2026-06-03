import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isLight => _mode == ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/theme_mode.txt');
      if (await file.exists()) {
        final val = await file.readAsString();
        _mode = val.trim() == 'dark'
            ? ThemeMode.dark
            : val.trim() == 'light'
                ? ThemeMode.light
                : ThemeMode.system;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/theme_mode.txt');
      final val = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
              ? 'light'
              : 'system';
      await file.writeAsString(val);
    } catch (_) {}
  }
}
