import 'dart:io';

// Request Model
class ContentRequest {
  final String grade;
  final String subject;
  final String topic;
  final String? textbook;
  final String? duration;
  final List<String> contentTypes;
  final String? teachingStyle;
  final String? difficulty;
  final String? additionalRequirements;
  final List<File>? files;
  final QuizConfig? quizConfig;
  final SlideConfig? slideConfig;

  ContentRequest({
    required this.grade,
    required this.subject,
    required this.topic,
    this.textbook,
    this.duration,
    required this.contentTypes,
    this.teachingStyle,
    this.difficulty,
    this.additionalRequirements,
    this.files,
    this.quizConfig,
    this.slideConfig,
  });

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'subject': subject,
      'topic': topic,
      'textbook': textbook ?? '',
      'duration': duration ?? '45',
      'content_types': contentTypes,
      'teaching_style': teachingStyle ?? '',
      'difficulty': difficulty ?? 'medium',
      'additional_requirements': additionalRequirements ?? '',
      'quiz_config': quizConfig?.toJson() ?? {},
      'slide_config': slideConfig?.toJson() ?? {},
    };
  }
}

class QuizConfig {
  final String difficulty;
  final int questionCount;

  QuizConfig({
    this.difficulty = 'medium',
    this.questionCount = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'question_count': questionCount,
    };
  }
}

class SlideConfig {
  final String colorScheme;
  final Map<String, bool> export;
  final bool createGoogleSlides;
  final String tone;

  SlideConfig({
    this.colorScheme = 'blue',
    this.export = const {'pptx': true, 'pdf': false},
    this.createGoogleSlides = true,
    this.tone = 'thân thiện',
  });

  Map<String, dynamic> toJson() {
    return {
      'color_scheme': colorScheme,
      'export': export,
      'create_google_slides': createGoogleSlides,
      'tone': tone,
    };
  }
}

// Response Model
class ContentResponse {
  final bool success;
  final String? requestId;
  final String? timestamp;
  final ContentResults? results;
  final String? error;

  ContentResponse({
    required this.success,
    this.requestId,
    this.timestamp,
    this.results,
    this.error,
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    return ContentResponse(
      success: json['success'] ?? false,
      requestId: json['request_id'],
      timestamp: json['timestamp'],
      results: json['results'] != null
          ? ContentResults.fromJson(json['results'])
          : null,
      error: json['error'],
    );
  }
}

class ContentResults {
  final LessonPlanResult? lessonPlan;
  final QuizResult? quiz;
  final SlideResult? slide;

  ContentResults({
    this.lessonPlan,
    this.quiz,
    this.slide,
  });

  factory ContentResults.fromJson(Map<String, dynamic> json) {
    return ContentResults(
      lessonPlan: json['lesson_plan'] != null
          ? LessonPlanResult.fromJson(json['lesson_plan'])
          : null,
      quiz: json['quiz'] != null
          ? QuizResult.fromJson(json['quiz'])
          : null,
      slide: json['slide'] != null
          ? SlideResult.fromJson(json['slide'])
          : null,
    );
  }
}

class LessonPlanResult {
  final bool success;
  final String filename;
  final String downloadUrl;
  final String content;

  LessonPlanResult({
    required this.success,
    required this.filename,
    required this.downloadUrl,
    required this.content,
  });

  factory LessonPlanResult.fromJson(Map<String, dynamic> json) {
    return LessonPlanResult(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class QuizResult {
  final bool success;
  final String filename;
  final String downloadUrl;
  final dynamic content;

  QuizResult({
    required this.success,
    required this.filename,
    required this.downloadUrl,
    required this.content,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      content: json['content'],
    );
  }
}

class SlideResult {
  final bool success;
  final String filename;
  final String downloadUrl;
  final String content;

  SlideResult({
    required this.success,
    required this.filename,
    required this.downloadUrl,
    required this.content,
  });

  factory SlideResult.fromJson(Map<String, dynamic> json) {
    return SlideResult(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// Saved Content Model for Local Storage
class SavedContent {
  final String id;
  final String type; // lesson_plan, quiz, slide_plan
  final String title;
  final String subject;
  final String grade;
  final String filename;
  final String downloadUrl;
  final DateTime createdAt;
  final String? localPath;

  SavedContent({
    required this.id,
    required this.type,
    required this.title,
    required this.subject,
    required this.grade,
    required this.filename,
    required this.downloadUrl,
    required this.createdAt,
    this.localPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subject': subject,
      'grade': grade,
      'filename': filename,
      'download_url': downloadUrl,
      'created_at': createdAt.toIso8601String(),
      'local_path': localPath,
    };
  }

  factory SavedContent.fromJson(Map<String, dynamic> json) {
    return SavedContent(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      subject: json['subject'],
      grade: json['grade'],
      filename: json['filename'],
      downloadUrl: json['download_url'],
      createdAt: DateTime.parse(json['created_at']),
      localPath: json['local_path'],
    );
  }
}