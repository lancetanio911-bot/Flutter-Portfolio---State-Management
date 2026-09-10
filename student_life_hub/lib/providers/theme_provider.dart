import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _studentName = 'Student';
  String _studentProgram = '';

  ThemeMode get themeMode => _themeMode;
  String get studentName => _studentName;
  String get studentProgram => _studentProgram;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void updateName(String name) {
    _studentName = name.isEmpty ? 'Student' : name;
    notifyListeners();
  }

  void updateProgram(String program) {
    _studentProgram = program;
    notifyListeners();
  }

  ShadThemeData get lightTheme => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme(
          background: Color(0xFFF0FDFB),
          foreground: Color(0xFF0F1F1E),
          card: Color(0xFFFFFFFF),
          cardForeground: Color(0xFF0F1F1E),
          popover: Color(0xFFFFFFFF),
          popoverForeground: Color(0xFF0F1F1E),
          primary: Color(0xFF0D9488),
          primaryForeground: Color(0xFFFFFFFF),
          secondary: Color(0xFFCCFBF1),
          secondaryForeground: Color(0xFF065F46),
          muted: Color(0xFFF0FDFB),
          mutedForeground: Color(0xFF6B7280),
          accent: Color(0xFFD1FAE5),
          accentForeground: Color(0xFF065F46),
          destructive: Color(0xFF14B8A6),
          destructiveForeground: Color(0xFFFFFFFF),
          border: Color(0xFFD1D5DB),
          input: Color(0xFFD1D5DB),
          ring: Color(0xFF0D9488),
          selection: Color(0xFFCCFBF1),
        ),
      );

  ShadThemeData get darkTheme => ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadColorScheme(
          background: Color(0xFF0C1B1A),
          foreground: Color(0xFFD1F2EB),
          card: Color(0xFF142C2A),
          cardForeground: Color(0xFFD1F2EB),
          popover: Color(0xFF142C2A),
          popoverForeground: Color(0xFFD1F2EB),
          primary: Color(0xFF5EEAD4),
          primaryForeground: Color(0xFF0C1B1A),
          secondary: Color(0xFF1A3C3A),
          secondaryForeground: Color(0xFF99F6E4),
          muted: Color(0xFF1E3836),
          mutedForeground: Color(0xFF6B7280),
          accent: Color(0xFF1A3C3A),
          accentForeground: Color(0xFF99F6E4),
          destructive: Color(0xFF14B8A6),
          destructiveForeground: Color(0xFFFFFFFF),
          border: Color(0xFF2D5250),
          input: Color(0xFF2D5250),
          ring: Color(0xFF5EEAD4),
          selection: Color(0xFF2D5250),
        ),
      );
}
