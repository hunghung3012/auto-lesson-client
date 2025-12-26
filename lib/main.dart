import 'dart:convert';
import 'package:edu_agent/models/content_request.dart';

import 'package:edu_agent/screens/content_detail/lesson_detail_screen.dart';
import 'package:edu_agent/screens/content_detail/quiz_detail.dart';
import 'package:edu_agent/screens/content_detail/quiz_detail_screen.dart';
import 'package:edu_agent/screens/content_detail/slide_detail_screen.dart';
import 'package:edu_agent/screens/login/login.dart';
import 'package:edu_agent/screens/settings/settings_screen.dart';
import 'package:edu_agent/services/notification_service.dart';
import 'package:edu_agent/utils/json_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Services
import 'services/api_service.dart';
import 'services/storage_service.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/content_provider.dart';

// Screens
import 'main_screen.dart';

import 'screens/create_content/create_content_screen.dart';
import 'screens/library/library_screen.dart';

// Utils
import 'utils/constants.dart';

// Helper function to recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
Map<String, dynamic> _convertToStringKeyMap(Map map) {
  final result = <String, dynamic>{};

  map.forEach((key, value) {
    final stringKey = key.toString();

    if (value is Map) {
      // Recursively convert nested maps
      result[stringKey] = _convertToStringKeyMap(value);
    } else if (value is List) {
      // Convert list items if they are maps
      result[stringKey] = value.map((item) {
        if (item is Map) {
          return _convertToStringKeyMap(item);
        }
        return item;
      }).toList();
    } else {
      result[stringKey] = value;
    }
  });

  return result;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('❌ Flutter Error: ${details.exception}');
  };

  // Custom error widget builder
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                details.exception.toString(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  };

  // Load environment variables (optional - continue if file doesn't exist)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print(
      '⚠️ Warning: .env file not found. Continuing without environment variables.',
    );
  }

  // Initialize Services with error handling
  try {
    await StorageService().initialize();
    ApiService().initialize();
    await LocalNotificationService().initialize();
  } catch (e) {
    print('❌ Error initializing services: $e');
    // Continue anyway - app should still work
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: const EduMateApp(),
    ),
  );
}

class EduMateApp extends StatelessWidget {
  const EduMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'EduMate - AI Teaching Assistant',
          debugShowCheckedModeBanner: false,

          // ✅ Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // ✅ Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // ✅ Theme Mode từ Provider
          themeMode: themeProvider.themeMode,

          initialRoute: '/login',

          routes: {
            '/login': (context) => const LoginScreen(),
            '/': (context) => const MainScreen(initialIndex: 0),
            '/settings': (context) => SettingsScreen(),
            '/content-detail': (context) {
              final content = ModalRoute.of(context)!.settings.arguments as SavedContent;

              print('📍 Navigation to content detail:');
              print('  Type: ${content.type}');
              print('  Title: ${content.title}');
              print('  Content length: ${content.content?.length ?? 0}');

              // ✅ LESSON PLAN
              if (content.type == AppConstants.lessonPlan) {
                print('  ➡️ Navigating to LessonDetailScreen');
                return LessonDetailScreen(
                  content: content,
                  markdownContent: content.content ?? '',
                );
              }

              else if (content.type == AppConstants.quiz) {
                return QuizDetailSecond();
              }

              // ✅ SLIDE
              else if (content.type == AppConstants.slidePlan) {
                return SlideDetailSecond();
              }

              // ❌ Fallback nếu type không khớp
              return Scaffold(
                appBar: AppBar(title: const Text('Lỗi')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy loại nội dung phù hợp',
                        style: AppTextStyles.body1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${content.type}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                ),
              );
            },
          },
        );
      },
    );
  }
}