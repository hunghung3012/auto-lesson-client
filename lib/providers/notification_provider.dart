import 'package:edu_agent/services/notification_service.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';


class NotificationProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final LocalNotificationService _notificationService = LocalNotificationService();

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  NotificationProvider() {
    _loadNotificationSettings();
  }

  // Load notification settings from storage
  Future<void> _loadNotificationSettings() async {
    try {
      _isEnabled = _storageService.getNotificationEnabled();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading notification settings: $e');
    }
  }

  // Toggle notification
  Future<void> toggleNotification() async {
    _isEnabled = !_isEnabled;
    await _storageService.saveNotificationEnabled(_isEnabled);

    if (!_isEnabled) {
      // Cancel all notifications if disabled
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  // Enable notification
  Future<void> enableNotification() async {
    _isEnabled = true;
    await _storageService.saveNotificationEnabled(true);
    notifyListeners();
  }

  // Disable notification
  Future<void> disableNotification() async {
    _isEnabled = false;
    await _storageService.saveNotificationEnabled(false);
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  // Show notification for content created
  Future<void> showContentCreatedNotification({
    required String title,
    required String type,
  }) async {
    if (!_isEnabled) return;

    String typeText;
    switch (type) {
      case 'lesson_plan':
        typeText = 'Kế hoạch bài giảng';
        break;
      case 'quiz':
        typeText = 'Quiz';
        break;
      case 'slide_plan':
        typeText = 'Slide';
        break;
      default:
        typeText = 'Nội dung';
    }

    await _notificationService.showNotification(
      title: 'Đã tạo $typeText!',
      body: title,
    );
  }

  // Show notification for download completed
  Future<void> showDownloadCompletedNotification({
    required String filename,
  }) async {
    if (!_isEnabled) return;

    await _notificationService.showNotification(
      title: 'Tải xuống hoàn tất',
      body: filename,
    );
  }

  // Show notification with custom message
  Future<void> showCustomNotification({
    required String title,
    required String body,
  }) async {
    if (!_isEnabled) return;

    await _notificationService.showNotification(
      title: title,
      body: body,
    );
  }
}