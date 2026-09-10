import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/models/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final (label, bgColor) = switch (priority) {
      TaskPriority.low => ('Low', const Color(0xFF0D9488)),
      TaskPriority.medium => ('Medium', const Color(0xFFD97706)),
      TaskPriority.high => ('High', const Color(0xFFDC2626)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.small.copyWith(
          color: bgColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
