import 'package:flutter_test/flutter_test.dart';

import 'package:student_life_hub/main.dart';

void main() {
  testWidgets('Flutter Portfolio dashboard renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Portfolio'), findsOneWidget);
    expect(
      find.text('Master Compilation of Laboratory Activities'),
      findsOneWidget,
    );
    expect(find.text('Laboratory Activities'), findsOneWidget);
    expect(find.text('Activity 2'), findsOneWidget);
    expect(find.text('Active Network Monitor'), findsOneWidget);
    expect(find.text('Open Activity'), findsWidgets);
  });
}
