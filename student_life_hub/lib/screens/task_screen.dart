import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/models/task.dart';
import 'package:student_life_hub/providers/task_provider.dart';
import 'package:student_life_hub/widgets/task_card.dart';
import 'package:student_life_hub/widgets/custom_button.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    TaskPriority selectedPriority = task?.priority ?? TaskPriority.medium;
    DateTime? selectedDate = task?.dueDate;

    showShadDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => ShadDialog(
          title: Text(task == null ? 'Add Task' : 'Edit Task'),
          actions: [
            CustomButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
            CustomButton(
              label: task == null ? 'Add' : 'Save',
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final provider = context.read<TaskProvider>();
                  if (task == null) {
                    provider.addTask(titleController.text, descController.text, selectedPriority, selectedDate);
                  } else {
                    provider.updateTask(task.id, titleController.text, descController.text, selectedPriority, selectedDate);
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadInput(
                controller: titleController,
                placeholder: const Text('Task title'),
              ),
              const SizedBox(height: 12),
              ShadInput(
                controller: descController,
                placeholder: const Text('Description (optional)'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Priority', style: ShadTheme.of(context).textTheme.muted),
              ),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = selectedPriority == p;
                  final label = p == TaskPriority.low
                      ? 'Low'
                      : p == TaskPriority.medium
                          ? 'Medium'
                          : 'High';
                  final color = p == TaskPriority.low
                      ? const Color(0xFF0D9488)
                      : p == TaskPriority.medium
                          ? const Color(0xFFD97706)
                          : const Color(0xFFDC2626);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShadButton.outline(
                        onPressed: () => setDialogState(() => selectedPriority = p),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? color : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: selectedDate != null
                    ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                    : 'Set Due Date',
                variant: ButtonVariant.outline,
                icon: Icons.calendar_today,
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showShadDialog(
      context: context,
      builder: (dialogContext) => ShadDialog.alert(
        title: const Text('Delete Task'),
        description: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          CustomButton(
            label: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          CustomButton(
            label: 'Delete',
            variant: ButtonVariant.destructive,
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final remaining = taskProvider.remaining;
    final completed = taskProvider.completed;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Task Manager', style: theme.textTheme.h3),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: CustomButton(
                label: 'Add Task',
                icon: Icons.add,
                onPressed: () => _showTaskDialog(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _StatChip(
                  label: '$remaining remaining',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: '$completed completed',
                  color: const Color(0xFF059669),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 56,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: theme.textTheme.p.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Task" to get started',
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          onToggle: () => context.read<TaskProvider>().toggleTask(task.id),
                          onEdit: () => _showTaskDialog(context, task: task),
                          onDelete: () => _confirmDelete(context, task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.small.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
