import 'dart:io';

// ============================================
// REQUEST MODELS
// ============================================

class ContentRequest {
  final String grade;
  final String subject;
  final String topic;
  final String? textbook;
  final String? duration;
  final String? teachingStyle;
  final String? difficulty;
  final String? additionalRequirements;
  final List<String> contentTypes;
  final QuizConfig? quizConfig;
  final SlideConfig? slideConfig;

  ContentRequest({
    required this.grade,
    required this.subject,
    required this.topic,
    required this.contentTypes,
    this.textbook,
    this.duration,
    this.teachingStyle,
    this.difficulty,
    this.additionalRequirements,
    this.quizConfig,
    this.slideConfig, List<File>? files,
  });

  Map<String, dynamic> toJson() {
    return {
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "textbook": textbook,
      "duration": duration ?? "45",
      "teaching_style": teachingStyle,
      "difficulty": difficulty ?? "medium",
      "additional_requirements": additionalRequirements,
      "content_types": contentTypes, // ⭐ QUAN TRỌNG
      "quiz_config": quizConfig?.toJson(),
      "slide_config": slideConfig?.toJson(),
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

// ============================================
// RESPONSE MODELS (FIXED)
// ============================================

class ContentResponse {
  final bool success;
  final String? timestamp;
  final LessonPlanResult? lessonPlan;
  final QuizResult? quiz;
  final SlideResult? slidePlan;
  final FileLinks? files;
  final String? error;

  ContentResponse({
    required this.success,
    this.timestamp,
    this.lessonPlan,
    this.quiz,
    this.slidePlan,
    this.files,
    this.error,
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing ContentResponse from JSON...');
    print('🔑 Root keys: ${json.keys.toList()}');

    try {
      // Parse lesson_plan (direct from root)
      LessonPlanResult? lessonPlan;
      if (json.containsKey('lesson_plan') && json['lesson_plan'] != null) {
        print('📚 Found lesson_plan in response');
        lessonPlan = LessonPlanResult.fromJson(
          json['lesson_plan'],
          json['files']?['lesson_plan'],
        );
      }

      // Parse quiz (direct from root)
      QuizResult? quiz;
      if (json.containsKey('quiz') && json['quiz'] != null) {
        print('🧪 Found quiz in response');
        quiz = QuizResult.fromJson(
          json['quiz'],
          json['files']?['quiz'],
        );
      }

      // Parse slide_plan (direct from root)
      SlideResult? slidePlan;
      if (json.containsKey('slide_plan') && json['slide_plan'] != null) {
        print('📊 Found slide_plan in response');
        slidePlan = SlideResult.fromJson(
          json['slide_plan'],
          json['files']?['slide_plan'],
        );
      }

      // Parse files
      FileLinks? files;
      if (json.containsKey('files') && json['files'] != null) {
        files = FileLinks.fromJson(json['files']);
      }

      return ContentResponse(
        success: json['success'] ?? false,
        timestamp: json['timestamp'],
        lessonPlan: lessonPlan,
        quiz: quiz,
        slidePlan: slidePlan,
        files: files,
        error: json['error'],
      );
    } catch (e, stack) {
      print('❌ Error parsing ContentResponse: $e');
      print('📜 Stack trace: $stack');
      return ContentResponse(
        success: false,
        error: 'Parse error: $e',
      );
    }
  }

  // Helper getter for backward compatibility
  ContentResults? get results {
    if (lessonPlan == null && quiz == null && slidePlan == null) {
      return null;
    }
    return ContentResults(
      lessonPlan: lessonPlan,
      quiz: quiz,
      slide: slidePlan,
    );
  }
}

// Backward compatibility wrapper
class ContentResults {
  final LessonPlanResult? lessonPlan;
  final QuizResult? quiz;
  final SlideResult? slide;

  ContentResults({
    this.lessonPlan,
    this.quiz,
    this.slide,
  });
}

// ============================================
// LESSON PLAN RESULT
// ============================================

class LessonPlanResult {
  final bool success;
  final String? completeMarkdown;
  final Map<String, dynamic>? detailedContent;
  final Map<String, dynamic>? metadata;
  final String? markdownPath;
  final String? outputPath;

  // From files object
  final String? filename;
  final String? downloadUrl;

  LessonPlanResult({
    required this.success,
    this.completeMarkdown,
    this.detailedContent,
    this.metadata,
    this.markdownPath,
    this.outputPath,
    this.filename,
    this.downloadUrl,
  });

  factory LessonPlanResult.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic>? filesData,
      ) {
    print('📚 Parsing LessonPlanResult...');
    print('🔑 Keys: ${json.keys.toList()}');

    return LessonPlanResult(
      success: json['success'] ?? true,
      completeMarkdown: json['complete_markdown'],
      detailedContent: json['detailed_content'],
      metadata: json['metadata'],
      markdownPath: json['markdown_path'],
      outputPath: json['output_path'],
      filename: filesData?['filename'],
      downloadUrl: filesData?['download_url'],
    );
  }

  // Get content for display
  String get content {
    return completeMarkdown ??
        detailedContent?.toString() ??
        'No content available';
  }

  // Get display filename
  String get displayFilename {
    return filename ??
        markdownPath?.split('/').last ??
        outputPath?.split('/').last ??
        'lesson_plan.md';
  }
}

// ============================================
// QUIZ RESULT
// ============================================

class QuizResult {
  final bool success;
  final String? completeMarkdown;
  final String? markdownContent;
  final Map<String, dynamic>? quizContent;
  final Map<String, dynamic>? answerKey;
  final Map<String, dynamic>? metadata;
  final String? markdownPath;
  final String? outputPath;

  // From files object
  final String? filename;
  final String? downloadUrl;

  QuizResult({
    required this.success,
    this.completeMarkdown,
    this.markdownContent,
    this.quizContent,
    this.answerKey,
    this.metadata,
    this.markdownPath,
    this.outputPath,
    this.filename,
    this.downloadUrl,
  });

  factory QuizResult.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic>? filesData,
      ) {
    print('🧪 Parsing QuizResult...');
    print('🔑 Keys: ${json.keys.toList()}');

    return QuizResult(
      success: json['success'] ?? true,
      completeMarkdown: json['complete_markdown'],
      markdownContent: json['markdown_content'],
      quizContent: json['quiz_content'],
      answerKey: json['answer_key'],
      metadata: json['metadata'],
      markdownPath: json['markdown_path'],
      outputPath: json['output_path'],
      filename: filesData?['filename'],
      downloadUrl: filesData?['download_url'],
    );
  }

  // Get content for display (prioritize markdown)
  String get content {
    return completeMarkdown ??
        markdownContent ??
        quizContent?.toString() ??
        'No content available';
  }

  // Get display filename
  String get displayFilename {
    return filename ??
        markdownPath?.split('/').last ??
        outputPath?.split('/').last ??
        'quiz.json';
  }
}

// ============================================
// SLIDE RESULT
// ============================================

class SlideResult {
  final bool success;
  final String? contentPreview;
  final int? slideCount;
  final Map<String, dynamic>? metadata;
  final String? markdownPath;
  final String? outputPath;

  // From files object
  final String? filename;
  final String? downloadUrl;

  SlideResult({
    required this.success,
    this.contentPreview,
    this.slideCount,
    this.metadata,
    this.markdownPath,
    this.outputPath,
    this.filename,
    this.downloadUrl,
  });

  factory SlideResult.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic>? filesData,
      ) {
    print('📊 Parsing SlideResult...');
    print('🔑 Keys: ${json.keys.toList()}');

    return SlideResult(
      success: json['success'] ?? true,
      contentPreview: json['content_preview'],
      slideCount: json['slide_count'],
      metadata: json['metadata'],
      markdownPath: json['markdown_path'],
      outputPath: json['output_path'],
      filename: filesData?['filename'],
      downloadUrl: filesData?['download_url'],
    );
  }

  // Get content for display
  String get content {
    return contentPreview ?? 'No content available';
  }

  // Get display filename
  String get displayFilename {
    return filename ??
        markdownPath?.split('/').last ??
        outputPath?.split('/').last ??
        'slide_plan.md';
  }
}

// ============================================
// FILE LINKS
// ============================================

class FileLinks {
  final FileInfo? lessonPlan;
  final FileInfo? quiz;
  final FileInfo? slidePlan;

  FileLinks({
    this.lessonPlan,
    this.quiz,
    this.slidePlan,
  });

  factory FileLinks.fromJson(Map<String, dynamic> json) {
    return FileLinks(
      lessonPlan: json['lesson_plan'] != null
          ? FileInfo.fromJson(json['lesson_plan'])
          : null,
      quiz: json['quiz'] != null
          ? FileInfo.fromJson(json['quiz'])
          : null,
      slidePlan: json['slide_plan'] != null
          ? FileInfo.fromJson(json['slide_plan'])
          : null,
    );
  }
}

class FileInfo {
  final String filename;
  final String downloadUrl;

  FileInfo({
    required this.filename,
    required this.downloadUrl,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      filename: json['filename'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}

// ============================================
// SAVED CONTENT (Local Storage)
// ============================================

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
  final String? content; // Store content locally

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
    this.content,
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
      'content': content,
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
      content: json['content'],
    );
  }
}