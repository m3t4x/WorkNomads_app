import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Check if current theme is light
  bool get isLightMode => !isDarkMode;

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateSystemUIOverlay();
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  /// Set light theme
  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }

  /// Set system theme
  void setSystemTheme() {
    setThemeMode(ThemeMode.system);
  }

  /// Update system UI overlay based on current theme
  void _updateSystemUIOverlay() {
    if (isDarkMode) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF231F20),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFFFDF5E5),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }

  /// Initialize theme provider
  void initialize() {
    _updateSystemUIOverlay();
  }
}
