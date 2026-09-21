class ActivityItem {
  final String number;
  final String title;
  final String description;
  final String summary;
  final String route;

  const ActivityItem({
    required this.number,
    required this.title,
    required this.description,
    required this.summary,
    required this.route,
  });

  static List<ActivityItem> get activityList => const [
    ActivityItem(
      number: 'Activity 2',
      title: 'Active Network Monitor',
      description:
          'Monitor network states in real-time and handle handovers between Wi-Fi and Cellular networks. The activity also demonstrates request queuing and automatic recovery when a connection is temporarily lost.',
      summary: 'Network monitoring',
      route: '/network-monitor',
    ),
    ActivityItem(
      number: 'Activity 3',
      title: 'Dynamic Performance Throttle App',
      description:
          'Run a real network diagnostic, classify connection health, and adapt content quality dynamically for the current network.',
      summary: 'Network diagnostics',
      route: '/network-diagnostic',
    ),
  ];
}
