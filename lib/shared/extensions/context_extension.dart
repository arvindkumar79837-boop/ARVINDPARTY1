// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/extensions/context_extension.dart
// ARVIND PARTY - CONTEXT EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;

  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
