import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/providers/theme_provider.dart';
import 'package:student_life_hub/providers/task_provider.dart';
import 'package:student_life_hub/widgets/activity_card.dart';
import 'package:student_life_hub/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.school,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Life Hub',
                          style: theme.textTheme.h2,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_greeting()}, ${themeProvider.studentName}!',
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => themeProvider.toggleTheme(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.border),
                      ),
                      child: Icon(
                        themeProvider.isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.today_outlined,
                          color: Color(0xFF0D9488),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Date',
                              style: theme.textTheme.small,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(),
                              style: theme.textTheme.p,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Quick Overview',
                subtitle: 'Your productivity at a glance',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ShadCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.pending_actions_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${taskProvider.remaining}',
                              style: theme.textTheme.h2.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tasks Remaining',
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF0D9488),
                              size: 20,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${taskProvider.completed}',
                              style: theme.textTheme.h2.copyWith(
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Completed',
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Activities',
                subtitle: 'Navigate to your tools',
              ),
              const SizedBox(height: 14),
              ActivityCard(
                icon: Icons.check_circle_outline,
                title: 'Task Manager',
                description: 'Organize and track your tasks',
                onTap: () => Navigator.pushNamed(context, '/tasks'),
              ),
              const SizedBox(height: 10),
              ActivityCard(
                icon: Icons.schedule_outlined,
                title: 'Class Schedule',
                description: 'View and manage your classes',
                onTap: () => Navigator.pushNamed(context, '/schedule'),
              ),
              const SizedBox(height: 10),
              ActivityCard(
                icon: Icons.settings_outlined,
                title: 'Settings',
                description: 'Customize your app experience',
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}, ${now.year}';
  }
}
