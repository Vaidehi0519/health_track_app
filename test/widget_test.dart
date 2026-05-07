// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_track_app/main.dart';

void main() {
  testWidgets('shows animated splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Health Tracker'), findsOneWidget);
    expect(find.text('Track better. Feel stronger.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3400));
    await tester.pumpAndSettle();

    expect(find.text('Hello !'), findsOneWidget);
  });
}
