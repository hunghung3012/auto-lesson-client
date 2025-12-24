import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final savedMode = _storageService.getThemeMode();

      switch (savedMode) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error loading theme mode: $e');
    }
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await _storageService.saveThemeMode('dark');
    } else {
      _themeMode = ThemeMode.light;
      await _storageService.saveThemeMode('light');
    }
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      default:
        modeString = 'system';
    }

    await _storageService.saveThemeMode(modeString);
    notifyListeners();
  }

  // Set dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}