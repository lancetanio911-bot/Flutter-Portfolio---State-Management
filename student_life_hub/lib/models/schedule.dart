class Schedule {
  final String id;
  final String subject;
  final String day;
  final String startTime;
  final String endTime;
  final String room;

  Schedule({
    required this.id,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  Schedule copyWith({
    String? subject,
    String? day,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return Schedule(
      id: id,
      subject: subject ?? this.subject,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}
