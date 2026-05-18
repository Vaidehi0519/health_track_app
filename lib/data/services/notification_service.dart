class NotificationService {
  const NotificationService();

  Future<void> requestPermission() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Future<void> scheduleHydrationReminder({required bool enabled}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Future<void> scheduleMealReminder({required bool enabled}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}
