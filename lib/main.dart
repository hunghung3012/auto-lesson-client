import 'package:edu_agent/screens/chat/chat_screen.dart';
import 'package:edu_agent/screens/settings/settings_screen.dart';
import 'package:edu_agent/services/notification_service.dart';
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

          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppColors.primary),
              titleTextStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          // Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
          ),

          themeMode: themeProvider.themeMode,

          // Routes
          initialRoute: '/',
          routes: {
            '/': (context) => const MainScreen(initialIndex: 0),
            '/create-content': (context) => const CreateContentScreen(),
            '/library': (context) => const LibraryScreen(),
            '/chat': (context) => const ChatScreenNew(),
            '/settings': (context) => SettingsScreen(),
          },
        );
      },
    );
  }
}
