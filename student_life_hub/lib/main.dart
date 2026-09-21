import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_life_hub/models/activity.dart';
import 'package:student_life_hub/providers/network_diagnostic_provider.dart';
import 'package:student_life_hub/providers/theme_provider.dart';
import 'package:student_life_hub/screens/activity_detail_screen.dart';
import 'package:student_life_hub/screens/home_screen.dart';
import 'package:student_life_hub/screens/network_diagnostic_dashboard_screen.dart';
import 'package:student_life_hub/screens/network_monitor_screen.dart';
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
        ChangeNotifierProvider(create: (_) => NetworkDiagnosticProvider()),
      ],
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
              '/activity-detail': (context) => ActivityDetailScreen(
                activity: ActivityItem.activityList.first,
              ),
              '/network-monitor': (context) => const NetworkMonitorScreen(),
              '/network-diagnostic': (context) =>
                  const NetworkDiagnosticDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}
