import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/models/task.dart';
import 'package:student_life_hub/widgets/priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.p.copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? theme.colorScheme.mutedForeground
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      PriorityBadge(priority: task.priority),
                      if (task.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
