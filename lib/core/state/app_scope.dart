import 'package:flutter/widgets.dart';
import 'package:health_track_app/core/state/app_state.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<AppScope>()
        ?.widget;
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return (scope! as AppScope).notifier!;
  }
}
