// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_track_app/core/session_store.dart';
import 'package:health_track_app/core/state/app_state.dart';
import 'package:health_track_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows animated splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SessionStore.setLoggedIn(false);
    final appState = await AppState.load();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(appState: appState));

    expect(find.text('Health Tracker'), findsOneWidget);
    expect(find.text('Track better. Feel stronger.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}
