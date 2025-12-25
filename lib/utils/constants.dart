import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = "http://192.168.1.5:5000";
  // App Info
  static const String appName = 'EduMate';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyRecentContents = 'recent_contents';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationEnabled = 'notification_enabled';

  // Content Types
  static const String lessonPlan = 'lesson_plan';
  static const String quiz = 'quiz';
  static const String slidePlan = 'slide_plan';

  // Form Options
  static const List<String> grades = [
    '1', '2', '3', '4', '5', '6',
    '7', '8', '9', '10', '11', '12'
  ];

  static const List<String> subjects = [
    'Toán', 'Văn', 'Anh', 'Lý', 'Hóa', 'Sinh',
    'Sử', 'Địa', 'GDCD', 'Tin học', 'Công nghệ', 'Khác'
  ];

  static const List<String> difficulties = [
    'Dễ - Cơ bản',
    'Trung bình',
    'Khó - Nâng cao'
  ];

  static const List<String> teachingStyles = [
    'Thân thiện',
    'Tương tác - Thảo luận nhóm',
    'Nghiêm túc',
    'Sáng tạo',
  ];

  static const Map<String, String> colorSchemes = {
    'blue': 'Xanh dương',
    'green': 'Xanh lá',
    'purple': 'Tím',
    'orange': 'Cam',
  };
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF53B175);
  static const Color primaryDark = Color(0xFF3D8A5A);
  static const Color primaryLight = Color(0xFF7BC99E);

  // Secondary Colors
  static const Color secondary = Color(0xFF9C27B0);
  static const Color accent = Color(0xFFFF6B6B);

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color divider = Color(0xFFE9ECEF);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Content Type Colors
  static const Color lessonPlan = Color(0xFF4CAF50);
  static const Color quiz = Color(0xFF2196F3);
  static const Color slide = Color(0xFFFF9800);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}