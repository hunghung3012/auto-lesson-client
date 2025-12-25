import 'dart:convert';

import 'package:edu_agent/models/content_request.dart';
import 'package:edu_agent/services/notification_service.dart';
import 'package:edu_agent/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/storage_service.dart';


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

      // Simulate upload progress
      await _updateProgress(0.2, 'Đang xử lý yêu cầu...');

      _status = ContentStatus.processing;
      await _updateProgress(0.4, 'Đang phân tích nội dung...');

      // Call API
      final response = await _apiService.processContent(request);

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
      await _saveResultsToStorage(response, request);

      await _updateProgress(0.9, 'Hoàn tất!');

      _status = ContentStatus.success;
      _progress = 1.0;
      notifyListeners();

      await loadRecentContents();

      // Show notification
      await _showContentCreatedNotifications(response, request);

      return true;
    } catch (e) {
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

  // Helper: Save Results to Storage
  Future<void> _saveResultsToStorage(
      ContentResponse response,
      ContentRequest request,
      ) async {
    if (response.results == null) return;

    // Save Lesson Plan
    if (response.results!.lessonPlan != null) {
      final lesson = response.results!.lessonPlan!;
      await _storageService.saveRecentContent(SavedContent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'lesson_plan',
        title: 'Kế hoạch: ${request.topic}',
        subject: request.subject,
        grade: request.grade,
        filename: lesson.filename,
        downloadUrl: lesson.downloadUrl,
        createdAt: DateTime.now(),
      ));
    }

    // Save Quiz
    if (response.results!.quiz != null) {
      final quiz = response.results!.quiz!;
      await _storageService.saveRecentContent(SavedContent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'quiz',
        title: 'Quiz: ${request.topic}',
        subject: request.subject,
        grade: request.grade,
        filename: quiz.filename,
        downloadUrl: quiz.downloadUrl,
        createdAt: DateTime.now(),
      ));
    }

    // Save Slide
    if (response.results!.slide != null) {
      final slide = response.results!.slide!;
      await _storageService.saveRecentContent(SavedContent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'slide_plan',
        title: 'Slide: ${request.topic}',
        subject: request.subject,
        grade: request.grade,
        filename: slide.filename,
        downloadUrl: slide.downloadUrl,
        createdAt: DateTime.now(),
      ));
    }
  }

  // Delete Content
  Future<bool> deleteContent(String id) async {
    final result = await _storageService.deleteContent(id);
    if (result) {
      await loadRecentContents();
    }
    return result;
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
    if (response.results == null) return;

    if (response.results!.lessonPlan != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Kế hoạch bài giảng',
        body: request.topic,
      );
    }

    if (response.results!.quiz != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Quiz',
        body: request.topic,
      );
    }

    if (response.results!.slide != null) {
      await _notificationService.showNotification(
        title: '✅ Đã tạo Slide',
        body: request.topic,
      );
    }
  }
  /// Load lesson plan content from server
  Future<String> loadLessonPlanContent(String contentId) async {
    try {
      final content = _recentContents.firstWhere((c) => c.id == contentId);
      final url = Uri.parse('${AppConstants.baseUrl}/api/download/lesson/${content.filename}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        throw Exception('Failed to load lesson plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading lesson plan: $e');
      rethrow;
    }
  }

  /// Load quiz content from server
  Future<Map<String, dynamic>> loadQuizContent(String contentId) async {
    try {
      final content = _recentContents.firstWhere((c) => c.id == contentId);
      final url = Uri.parse('${AppConstants.baseUrl}/api/download/quiz/${content.filename}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading quiz: $e');
      rethrow;
    }
  }

  /// Load slide content from server
  Future<String> loadSlideContent(String contentId) async {
    try {
      final content = _recentContents.firstWhere((c) => c.id == contentId);
      final url = Uri.parse('${AppConstants.baseUrl}/api/download/slide/${content.filename}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        throw Exception('Failed to load slide: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading slide: $e');
      rethrow;
    }
  }

}