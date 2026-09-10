import 'package:flutter/foundation.dart';
import 'package:student_life_hub/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Complete Flutter Lab Activity',
      description: 'Build the Student Life Hub app',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Task(
      id: '2',
      title: 'Read Mobile Computing Notes',
      description: 'Chapter 5: State Management',
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Task(
      id: '3',
      title: 'Buy Supplies',
      description: 'Notebooks and pens',
      priority: TaskPriority.low,
    ),
    Task(
      id: '4',
      title: 'Submit Lab Report',
      description: 'Activity 1 documentation',
      priority: TaskPriority.high,
      isCompleted: true,
    ),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get remaining => _tasks.where((t) => !t.isCompleted).length;

  int get completed => _tasks.where((t) => t.isCompleted).length;

  void addTask(String title, String description, TaskPriority priority, DateTime? dueDate) {
    _tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    ));
    notifyListeners();
  }

  void updateTask(String id, String title, String description, TaskPriority priority, DateTime? dueDate) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }
}
