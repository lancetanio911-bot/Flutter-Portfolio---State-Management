import 'package:flutter_test/flutter_test.dart';

import 'package:student_life_hub/main.dart';

void main() {
  testWidgets('Home Dashboard renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Student Life Hub'), findsOneWidget);
    expect(find.text('Tasks Remaining'), findsOneWidget);
    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Class Schedule'), findsOneWidget);
  });
}