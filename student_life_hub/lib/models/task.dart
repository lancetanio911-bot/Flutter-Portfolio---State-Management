enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
