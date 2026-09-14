class ActivityItem {
  final String number;
  final String title;
  final String description;
  final String route;

  const ActivityItem({
    required this.number,
    required this.title,
    required this.description,
    required this.route,
  });

  static const List<ActivityItem> activityList = [
    ActivityItem(
      number: 'Activity 2',
      title: 'Active Network Monitor',
      description:
          'Monitor network states in real-time and handle handovers between Wi-Fi and Cellular networks. The activity also demonstrates request queuing and automatic recovery when a connection is temporarily lost.',
      route: '/activity-2',
    ),
  ];
}
