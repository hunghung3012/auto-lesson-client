import 'dart:convert';
import 'package:edu_agent/models/content_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save Recent Content
  Future<bool> saveRecentContent(SavedContent content) async {
    try {
      List<SavedContent> recentContents = await getRecentContents();

      // Remove if already exists
      recentContents.removeWhere((c) => c.id == content.id);

      // Add to beginning
      recentContents.insert(0, content);

      // Keep only last 50
      if (recentContents.length > 50) {
        recentContents = recentContents.sublist(0, 50);
      }

      // Save
      List<String> jsonList = recentContents
          .map((c) => jsonEncode(c.toJson()))
          .toList();

      return await _prefs!.setStringList(
        AppConstants.keyRecentContents,
        jsonList,
      );
    } catch (e) {
      print('❌ Error saving recent content: $e');
      return false;
    }
  }

  // Get Recent Contents
  Future<List<SavedContent>> getRecentContents() async {
    try {
      List<String>? jsonList = _prefs!.getStringList(
        AppConstants.keyRecentContents,
      );

      if (jsonList == null) return [];

      return jsonList
          .map((json) => SavedContent.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('❌ Error getting recent contents: $e');
      return [];
    }
  }

  // Filter contents by type
  Future<List<SavedContent>> getContentsByType(String type) async {
    List<SavedContent> allContents = await getRecentContents();
    return allContents.where((c) => c.type == type).toList();
  }

  // Delete content
  Future<bool> deleteContent(String id) async {
    try {
      List<SavedContent> contents = await getRecentContents();
      contents.removeWhere((c) => c.id == id);

      List<String> jsonList = contents
          .map((c) => jsonEncode(c.toJson()))
          .toList();

      return await _prefs!.setStringList(
        AppConstants.keyRecentContents,
        jsonList,
      );
    } catch (e) {
      print('❌ Error deleting content: $e');
      return false;
    }
  }

  // Clear all
  Future<bool> clearAllContents() async {
    try {
      return await _prefs!.remove(AppConstants.keyRecentContents);
    } catch (e) {
      print('❌ Error clearing contents: $e');
      return false;
    }
  }

  // Update local path after download
  Future<bool> updateLocalPath(String id, String localPath) async {
    try {
      List<SavedContent> contents = await getRecentContents();
      int index = contents.indexWhere((c) => c.id == id);

      if (index != -1) {
        SavedContent updated = SavedContent(
          id: contents[index].id,
          type: contents[index].type,
          title: contents[index].title,
          subject: contents[index].subject,
          grade: contents[index].grade,
          filename: contents[index].filename,
          downloadUrl: contents[index].downloadUrl,
          createdAt: contents[index].createdAt,
          localPath: localPath,
        );

        contents[index] = updated;

        List<String> jsonList = contents
            .map((c) => jsonEncode(c.toJson()))
            .toList();

        return await _prefs!.setStringList(
          AppConstants.keyRecentContents,
          jsonList,
        );
      }

      return false;
    } catch (e) {
      print('❌ Error updating local path: $e');
      return false;
    }
  }

  // Statistics
  Future<Map<String, int>> getStatistics() async {
    List<SavedContent> contents = await getRecentContents();

    int lessonPlans = contents.where((c) => c.type == AppConstants.lessonPlan).length;
    int quizzes = contents.where((c) => c.type == AppConstants.quiz).length;
    int slides = contents.where((c) => c.type == AppConstants.slidePlan).length;

    return {
      'lesson_plans': lessonPlans,
      'quizzes': quizzes,
      'slides': slides,
      'total': contents.length,
    };
  }

  // Search
  Future<List<SavedContent>> searchContents(String query) async {
    List<SavedContent> allContents = await getRecentContents();

    if (query.isEmpty) return allContents;

    return allContents.where((c) {
      return c.title.toLowerCase().contains(query.toLowerCase()) ||
          c.subject.toLowerCase().contains(query.toLowerCase()) ||
          c.grade.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Theme Mode
  Future<bool> saveThemeMode(String mode) async {
    return await _prefs!.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs!.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  // Notification
  Future<bool> saveNotificationEnabled(bool enabled) async {
    return await _prefs!.setBool(AppConstants.keyNotificationEnabled, enabled);
  }

  bool getNotificationEnabled() {
    return _prefs!.getBool(AppConstants.keyNotificationEnabled) ?? true;
  }
}