import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_life_hub/providers/theme_provider.dart';
import 'package:student_life_hub/screens/activity_detail_screen.dart';
import 'package:student_life_hub/screens/home_screen.dart';
import 'package:student_life_hub/screens/network_monitor_screen.dart';
import 'package:student_life_hub/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Flutter Portfolio',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/activity-detail': (context) => const ActivityDetailScreen(),
              '/network-monitor': (context) => const NetworkMonitorScreen(),
            },
          );
        },
      ),
    );
  }
}
