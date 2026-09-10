import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:student_life_hub/models/schedule.dart';
import 'package:student_life_hub/providers/schedule_provider.dart';
import 'package:student_life_hub/widgets/schedule_card.dart';
import 'package:student_life_hub/widgets/custom_button.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _times = [
    '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM',
    '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
    '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM',
  ];

  void _showScheduleDialog(BuildContext context, {Schedule? schedule}) {
    final subjectController = TextEditingController(text: schedule?.subject ?? '');
    final roomController = TextEditingController(text: schedule?.room ?? '');
    String selectedDay = schedule?.day ?? 'Monday';
    String selectedStartTime = schedule?.startTime ?? '8:00 AM';
    String selectedEndTime = schedule?.endTime ?? '10:00 AM';

    showShadDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => ShadDialog(
          title: Text(schedule == null ? 'Add Schedule' : 'Edit Schedule'),
          actions: [
            CustomButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
            CustomButton(
              label: schedule == null ? 'Add' : 'Save',
              onPressed: () {
                if (subjectController.text.isNotEmpty && roomController.text.isNotEmpty) {
                  final provider = context.read<ScheduleProvider>();
                  if (schedule == null) {
                    provider.addSchedule(subjectController.text, selectedDay, selectedStartTime, selectedEndTime, roomController.text);
                  } else {
                    provider.updateSchedule(schedule.id, subjectController.text, selectedDay, selectedStartTime, selectedEndTime, roomController.text);
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadInput(
                  controller: subjectController,
                  placeholder: const Text('Subject name'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Day', style: ShadTheme.of(context).textTheme.muted),
                ),
                const SizedBox(height: 8),
                ShadSelect<String>(
                  placeholder: const Text('Select day'),
                  initialValue: selectedDay,
                  options: _days.map((day) => ShadOption(value: day, child: Text(day))).toList(),
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedDay = value);
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Start Time', style: ShadTheme.of(context).textTheme.muted),
                ),
                const SizedBox(height: 8),
                ShadSelect<String>(
                  placeholder: const Text('Select start time'),
                  initialValue: selectedStartTime,
                  options: _times.map((time) => ShadOption(value: time, child: Text(time))).toList(),
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedStartTime = value);
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('End Time', style: ShadTheme.of(context).textTheme.muted),
                ),
                const SizedBox(height: 8),
                ShadSelect<String>(
                  placeholder: const Text('Select end time'),
                  initialValue: selectedEndTime,
                  options: _times.map((time) => ShadOption(value: time, child: Text(time))).toList(),
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedEndTime = value);
                  },
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: roomController,
                  placeholder: const Text('Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Schedule schedule) {
    showShadDialog(
      context: context,
      builder: (dialogContext) => ShadDialog.alert(
        title: const Text('Delete Schedule'),
        description: Text('Are you sure you want to delete "${schedule.subject}"?'),
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
              context.read<ScheduleProvider>().deleteSchedule(schedule.id);
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
    final schedules = context.watch<ScheduleProvider>().schedules;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Class Schedule', style: theme.textTheme.h3),
      ),
      floatingActionButton: CustomButton(
        label: 'Add Subject',
        icon: Icons.add,
        onPressed: () => _showScheduleDialog(context),
      ),
      body: schedules.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 56,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No classes yet',
                    style: theme.textTheme.p.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add Subject" to get started',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ScheduleCard(
                    schedule: schedule,
                    onEdit: () => _showScheduleDialog(context, schedule: schedule),
                    onDelete: () => _confirmDelete(context, schedule),
                  ),
                );
              },
            ),
    );
  }
}
