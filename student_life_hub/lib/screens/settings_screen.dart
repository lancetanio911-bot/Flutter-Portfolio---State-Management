import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _programController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ThemeProvider>();
    _nameController = TextEditingController(text: profile.studentName);
    _programController = TextEditingController(text: profile.studentProgram);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: theme.textTheme.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Profile',
                    style: theme.textTheme.h4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalize your app experience',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Student Name',
                        style: theme.textTheme.p,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShadInput(
                    controller: _nameController,
                    placeholder: const Text('Enter your name'),
                    onChanged: (value) {
                      context.read<ThemeProvider>().updateName(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Program',
                        style: theme.textTheme.p,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShadInput(
                    controller: _programController,
                    placeholder: const Text('e.g. BS Computer Science'),
                    onChanged: (value) {
                      context.read<ThemeProvider>().updateProgram(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
