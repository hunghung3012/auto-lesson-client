import 'dart:convert';
import 'package:edu_agent/utils/json_utils.dart';
import 'package:flutter/material.dart';
import '../models/content_request.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum ContentStatus {
  idle,
  uploading,
  processing,
  generating,
  success,
  error,
}

class ContentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final LocalNotificationService _notificationService = LocalNotificationService();

  ContentStatus _status = ContentStatus.idle;
  ContentStatus get status => _status;

  double _progress = 0.0;
  double get progress => _progress;

  String _currentStep = '';
  String get currentStep => _currentStep;

  ContentResponse? _lastResponse;
  ContentResponse? get lastResponse => _lastResponse;

  List<SavedContent> _recentContents = [];
  List<SavedContent> get recentContents => _recentContents;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Initialize
  Future<void> initialize() async {
    await loadRecentContents();
  }

  // Load Recent Contents
  Future<void> loadRecentContents() async {
    _recentContents = await _storageService.getRecentContents();
    notifyListeners();
  }

  // Create Content
  Future<bool> createContent(ContentRequest request) async {
    try {
      _status = ContentStatus.uploading;
      _progress = 0.0;
      _currentStep = 'Đang tải lên dữ liệu...';
      _errorMessage = null;
      notifyListeners();

      await _updateProgress(0.2, 'Đang xử lý yêu cầu...');

      _status = ContentStatus.processing;
      await _updateProgress(0.4, 'Đang phân tích nội dung...');

      // Call API
      print('🚀 Calling API...');
      final response = await _apiService.processContent(request);

      print('📦 API Response received:');
      print('  - success: ${response.success}');
      print('  - lessonPlan: ${response.lessonPlan != null ? '✅' : '❌'}');
      print('  - quiz: ${response.quiz != null ? '✅' : '❌'}');
      print('  - slidePlan: ${response.slidePlan != null ? '✅' : '❌'}');

      if (!response.success) {
        _status = ContentStatus.error;
        _errorMessage = response.error ?? 'Có lỗi xảy ra';
        notifyListeners();
        return false;
      }

      _status = ContentStatus.generating;
      await _updateProgress(0.6, 'Đang tạo nội dung...');

      _lastResponse = response;

      // Save to storage
      print('💾 Saving to storage...');
      await _saveResultsToStorage(response, request);

      await _updateProgress(0.9, 'Hoàn tất!');

      _status = ContentStatus.success;
      _progress = 1.0;
      notifyListeners();

      await loadRecentContents();
      print('✅ Content saved. Recent contents: ${_recentContents.length}');

      // Show notifications
      await _showContentCreatedNotifications(response, request);

      return true;
    } catch (e, stack) {
      print('❌ Error in createContent: $e');
      print('📜 Stack trace: $stack');
      _status = ContentStatus.error;
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  // Helper: Update Progress
  Future<void> _updateProgress(double value, String step) async {
    _progress = value;
    _currentStep = step;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Helper: Save Results to Storage (FIXED)
  Future<void> _saveResultsToStorage(
      ContentResponse response,
      ContentRequest request,
      ) async {
    print('💾 _saveResultsToStorage called');

    final timestamp = DateTime.now();

    // Save Lesson Plan
    if (response.lessonPlan != null) {
      print('📚 Saving lesson plan...');
      final lesson = response.lessonPlan!;

      try {
        await _storageService.saveRecentContent(SavedContent(
          id: '${timestamp.millisecondsSinceEpoch}_lesson',
          type: 'lesson_plan',
          title: 'Kế hoạch: ${request.topic}',
          subject: request.subject,
          grade: request.grade,
          filename: lesson.displayFilename,
          downloadUrl: lesson.downloadUrl ?? '',
          createdAt: timestamp,
          content: lesson.content, // ✅ Markdown content
        ));
        print('✅ Lesson plan saved');
      } catch (e) {
        print('❌ Error saving lesson plan: $e');
      }
    }

    // ✅ Save Quiz - FIX TRIỆT ĐỂ
    if (response.quiz != null) {
      print('🧪 Saving quiz...');
      final quiz = response.quiz!;

      try {
        String quizContentString = '';

        // Priority 1: Use quizContent (structured data)
        if (quiz.quizContent != null) {
          print('  📦 Using quizContent (structured)');

          try {
            // ✅ Sử dụng JsonUtils để convert an toàn
            final convertedMap = JsonUtils.convertToStringKeyMap(quiz.quizContent!);
            quizContentString = jsonEncode(convertedMap);
            print('  ✅ Converted successfully');
          } catch (e) {
            print('  ⚠️ Conversion failed: $e, using raw encode');
            quizContentString = jsonEncode(quiz.quizContent);
          }
        }
        // Priority 2: Use answerKey
        else if (quiz.answerKey != null) {
          print('  📦 Using answerKey');

          try {
            final answersMap = JsonUtils.convertToStringKeyMap(quiz.answerKey!);
            final metadataMap = quiz.metadata != null
                ? JsonUtils.convertToStringKeyMap(quiz.metadata!)
                : <String, dynamic>{};

            quizContentString = jsonEncode({
              'answers': answersMap,
              'explanation': <String, dynamic>{},
              'statistics': metadataMap,
            });
            print('  ✅ Built from answerKey successfully');
          } catch (e) {
            print('  ⚠️ Failed to build from answerKey: $e');
            quizContentString = jsonEncode({
              'answers': quiz.answerKey,
              'explanation': {},
              'statistics': quiz.metadata ?? {},
            });
          }
        }
        // Priority 3: Try to parse content string
        else if (quiz.content.isNotEmpty) {
          print('  📦 Checking content string...');

          if (quiz.content.trim().startsWith('{') || quiz.content.trim().startsWith('[')) {
            print('  ℹ️ Content appears to be JSON');

            try {
              // ✅ Sử dụng JsonUtils.safeDecodeMap
              final parsedMap = JsonUtils.safeDecodeMap(quiz.content);
              quizContentString = jsonEncode(parsedMap);
              print('  ✅ Parsed and converted successfully');
            } catch (e) {
              print('  ⚠️ Parse failed: $e, using raw content');
              quizContentString = quiz.content;
            }
          } else {
            // Markdown format
            print('  ℹ️ Content is Markdown, wrapping in structure');
            quizContentString = jsonEncode({
              'answers': <String, dynamic>{},
              'explanation': <String, dynamic>{},
              'statistics': {'total_questions': 0},
              'raw_content': quiz.content,
            });
          }
        }

        // Fallback: Create empty structure
        if (quizContentString.isEmpty) {
          print('  ⚠️ No valid content, creating empty structure');
          quizContentString = jsonEncode({
            'answers': <String, dynamic>{},
            'explanation': <String, dynamic>{},
            'statistics': {'total_questions': 0},
          });
        }

        print('  📏 Final quiz content length: ${quizContentString.length}');

        // ✅ Validate trước khi save
        try {
          final testDecode = JsonUtils.safeDecodeMap(quizContentString);
          if (!JsonUtils.isValidQuizData(testDecode)) {
            print('  ⚠️ Invalid quiz structure after processing');
          }
        } catch (e) {
          print('  ⚠️ Validation failed: $e');
        }

        await _storageService.saveRecentContent(SavedContent(
          id: '${timestamp.millisecondsSinceEpoch}_quiz',
          type: 'quiz',
          title: 'Quiz: ${request.topic}',
          subject: request.subject,
          grade: request.grade,
          filename: quiz.displayFilename,
          downloadUrl: quiz.downloadUrl ?? '',
          createdAt: timestamp,
          content: quizContentString, // ✅ JSON string đã được convert an toàn
        ));
        print('✅ Quiz saved successfully');
      } catch (e, stackTrace) {
        print('❌ Error saving quiz: $e');
        print('📜 Stack: $stackTrace');
      }
    }

    // Save Slide
    if (response.slidePlan != null) {
      print('📊 Saving slide...');
      final slide = response.slidePlan!;

      try {
        await _storageService.saveRecentContent(SavedContent(
          id: '${timestamp.millisecondsSinceEpoch}_slide',
          type: 'slide_plan',
          title: 'Slide: ${request.topic}',
          subject: request.subject,
          grade: request.grade,
          filename: slide.displayFilename,
          downloadUrl: slide.downloadUrl ?? '',
          createdAt: timestamp,
          content: slide.content, // ✅ Markdown content
        ));
        print('✅ Slide saved');
      } catch (e) {
        print('❌ Error saving slide: $e');
      }
    }
  }

  // Search
  Future<List<SavedContent>> searchContents(String query) async {
    return await _storageService.searchContents(query);
  }

  // Filter by type
  Future<List<SavedContent>> filterByType(String type) async {
    return await _storageService.getContentsByType(type);
  }

  // Get Statistics
  Future<Map<String, int>> getStatistics() async {
    return await _storageService.getStatistics();
  }

  // Reset Status
  void resetStatus() {
    _status = ContentStatus.idle;
    _progress = 0.0;
    _currentStep = '';
    _errorMessage = null;
    _lastResponse = null;
    notifyListeners();
  }

  // Check Server Health
  Future<bool> checkServerHealth() async {
    return await _apiService.checkHealth();
  }

  // Show notifications after content created
  Future<void> _showContentCreatedNotifications(
      ContentResponse response,
      ContentRequest request,
      ) async {
    if (response.lessonPlan != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Kế hoạch bài giảng',
        body: request.topic,
      );
    }

    if (response.quiz != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Quiz',
        body: request.topic,
      );
    }

    if (response.slidePlan != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Slide',
        body: request.topic,
      );
    }
  }
  // Delete Content
  Future<bool> deleteContent(String contentId) async {
    try {
      print('🗑️ Deleting content: $contentId');

      await _storageService.deleteContent(contentId);

      // cập nhật lại danh sách
      _recentContents.removeWhere((c) => c.id == contentId);
      notifyListeners();

      print('✅ Content deleted');
      return true;
    } catch (e, stack) {
      print('❌ Error deleting content: $e');
      print('📜 Stack: $stack');
      _errorMessage = 'Không thể xóa nội dung';
      notifyListeners();
      return false;
    }
  }

}