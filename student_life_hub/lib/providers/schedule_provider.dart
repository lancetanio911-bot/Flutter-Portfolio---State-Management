import 'package:flutter/foundation.dart';
import 'package:student_life_hub/models/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<Schedule> _schedules = [
    Schedule(
      id: '1',
      subject: 'Mobile Computing 2',
      day: 'Monday',
      startTime: '8:00 AM',
      endTime: '10:00 AM',
      room: 'Room 301',
    ),
    Schedule(
      id: '2',
      subject: 'Database Management',
      day: 'Monday',
      startTime: '1:00 PM',
      endTime: '3:00 PM',
      room: 'Computer Lab 2',
    ),
    Schedule(
      id: '3',
      subject: 'Object-Oriented Programming',
      day: 'Tuesday',
      startTime: '9:00 AM',
      endTime: '11:00 AM',
      room: 'Room 205',
    ),
    Schedule(
      id: '4',
      subject: 'Web Development',
      day: 'Wednesday',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      room: 'Computer Lab 1',
    ),
  ];

  List<Schedule> get schedules => List.unmodifiable(_schedules);

  void addSchedule(String subject, String day, String startTime, String endTime, String room) {
    _schedules.add(Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      day: day,
      startTime: startTime,
      endTime: endTime,
      room: room,
    ));
    notifyListeners();
  }

  void updateSchedule(String id, String subject, String day, String startTime, String endTime, String room) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        subject: subject,
        day: day,
        startTime: startTime,
        endTime: endTime,
        room: room,
      );
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
