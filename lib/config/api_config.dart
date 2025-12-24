class ApiConfig {
  // Base URL
  static const String baseUrl = 'http://192.168.1.5:5000';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(minutes: 10);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Endpoints
  static const String health = '/api/health';
  static const String process = '/api/process';
  static const String download = '/api/download'; // /{type}/{filename}
  static const String files = '/api/files'; // /{type}
  static const String chatMessage = '/api/chat/message';
  static const String generateQuiz = '/api/generate/quiz';
  static const String generateSlide = '/api/generate/slide';

  // Content Types
  static const String contentTypeLesson = 'lesson';
  static const String contentTypeQuiz = 'quiz';
  static const String contentTypeSlide = 'slide';

  // Full URLs
  static String get healthUrl => '$baseUrl$health';
  static String get processUrl => '$baseUrl$process';
  static String get chatUrl => '$baseUrl$chatMessage';
  static String get generateQuizUrl => '$baseUrl$generateQuiz';
  static String get generateSlideUrl => '$baseUrl$generateSlide';

  static String downloadUrl(String type, String filename) =>
      '$baseUrl$download/$type/$filename';

  static String filesUrl(String type) => '$baseUrl$files/$type';
}