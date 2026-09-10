import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/providers/theme_provider.dart';
import 'package:student_life_hub/providers/task_provider.dart';
import 'package:student_life_hub/providers/schedule_provider.dart';
import 'package:student_life_hub/screens/home_screen.dart';
import 'package:student_life_hub/screens/task_screen.dart';
import 'package:student_life_hub/screens/schedule_screen.dart';
import 'package:student_life_hub/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ShadApp(
            title: 'Student Life Hub',
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            routes: {
              '/': (context) => const HomeScreen(),
              '/tasks': (context) => const TaskScreen(),
              '/schedule': (context) => const ScheduleScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
