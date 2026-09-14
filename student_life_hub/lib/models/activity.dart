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

  static List<ActivityItem> get activityList => const [];
}
