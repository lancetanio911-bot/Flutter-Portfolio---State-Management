enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;

  static const Object _unset = Object();

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
    Object? description = _unset,
    TaskPriority? priority,
    Object? dueDate = _unset,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description == _unset
          ? this.description
          : (description as String?) ?? '',
      priority: priority ?? this.priority,
      dueDate: dueDate == _unset ? this.dueDate : dueDate as DateTime?,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
