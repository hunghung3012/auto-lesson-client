import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:edu_agent/models/content_request.dart';
import '../config/api_config.dart';


class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConfig.health);
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // Process Content WITH POLLING (Recommended for long tasks)
  Future<ContentResponse> processContentWithPolling(
      ContentRequest request, {
        Function(String)? onStatusUpdate,
      }) async {
    try {
      // Step 1: Start async processing
      final startResponse = await _startProcessing(request);

      if (!startResponse['success']) {
        return ContentResponse(
          success: false,
          error: startResponse['error'] ?? 'Failed to start processing',
        );
      }

      final requestId = startResponse['request_id'];
      onStatusUpdate?.call('Đã gửi yêu cầu. Đang xử lý...');

      // Step 2: Poll for completion
      return await _pollProcessingStatus(
        requestId,
        onStatusUpdate: onStatusUpdate,
      );
    } catch (e) {
      print('❌ Error: $e');
      return ContentResponse(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  // Start Processing (Send request, get request_id)
  Future<Map<String, dynamic>> _startProcessing(ContentRequest request) async {
    try {
      FormData formData = FormData();

      // Add basic fields
      formData.fields.add(MapEntry('grade', request.grade));
      formData.fields.add(MapEntry('subject', request.subject));
      formData.fields.add(MapEntry('topic', request.topic));
      formData.fields.add(MapEntry('textbook', request.textbook ?? ''));
      formData.fields.add(MapEntry('duration', request.duration ?? '45'));
      formData.fields.add(MapEntry('teaching_style', request.teachingStyle ?? ''));
      formData.fields.add(MapEntry('difficulty', request.difficulty ?? 'medium'));
      formData.fields.add(MapEntry('additional_requirements', request.additionalRequirements ?? ''));

      // Add content_types
      for (var contentType in request.contentTypes) {
        formData.fields.add(MapEntry('content_type[]', contentType));
      }

      // Add configs
      if (request.quizConfig != null) {
        formData.fields.add(MapEntry(
          'quiz_config',
          jsonEncode(request.quizConfig!.toJson()),
        ));
      }

      if (request.slideConfig != null) {
        formData.fields.add(MapEntry(
          'slide_config',
          jsonEncode(request.slideConfig!.toJson()),
        ));
      }

      // Add files
      if (request.files != null && request.files!.isNotEmpty) {
        for (var file in request.files!) {
          String fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'files[]',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
      }

      // Send to async endpoint (or regular endpoint if polling not supported)
      final response = await _dio.post(
        '/api/process-async', // Use async endpoint if available
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 30), // Short timeout for starting
        ),
      );

      return response.data;
    } catch (e) {
      print('❌ Start processing error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Poll Processing Status
  Future<ContentResponse> _pollProcessingStatus(
      String requestId, {
        Function(String)? onStatusUpdate,
        int maxAttempts = 120, // 10 minutes with 5s interval
        Duration pollInterval = const Duration(seconds: 5),
      }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await Future.delayed(pollInterval);
        attempts++;

        final response = await _dio.get(
          '/api/status/$requestId',
          options: Options(
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        final status = response.data['status'];
        final message = response.data['message'] ?? '';

        onStatusUpdate?.call(message);

        if (status == 'completed') {
          // Processing completed
          return ContentResponse.fromJson(response.data);
        } else if (status == 'failed') {
          // Processing failed
          return ContentResponse(
            success: false,
            error: response.data['error'] ?? 'Processing failed',
          );
        }

        // Still processing, continue polling
        print('🔄 Polling... Attempt $attempts/$maxAttempts');
      } catch (e) {
        print('❌ Poll error: $e');
        // Continue polling unless max attempts reached
      }
    }

    // Timeout
    return ContentResponse(
      success: false,
      error: 'Processing timeout. Please try again.',
    );
  }

  // Original Process Content (Direct, with increased timeout)
  Future<ContentResponse> processContent(ContentRequest request) async {
    try {
      FormData formData = FormData();

      // Add basic fields
      formData.fields.add(MapEntry('grade', request.grade));
      formData.fields.add(MapEntry('subject', request.subject));
      formData.fields.add(MapEntry('topic', request.topic));
      formData.fields.add(MapEntry('textbook', request.textbook ?? ''));
      formData.fields.add(MapEntry('duration', request.duration ?? '45'));
      formData.fields.add(MapEntry('teaching_style', request.teachingStyle ?? ''));
      formData.fields.add(MapEntry('difficulty', request.difficulty ?? 'medium'));
      formData.fields.add(MapEntry('additional_requirements', request.additionalRequirements ?? ''));

      // Add content_types
      for (var contentType in request.contentTypes) {
        formData.fields.add(MapEntry('content_type[]', contentType));
      }

      // Add configs
      if (request.quizConfig != null) {
        formData.fields.add(MapEntry(
          'quiz_config',
          jsonEncode(request.quizConfig!.toJson()),
        ));
      }

      if (request.slideConfig != null) {
        formData.fields.add(MapEntry(
          'slide_config',
          jsonEncode(request.slideConfig!.toJson()),
        ));
      }

      // Add files
      if (request.files != null && request.files!.isNotEmpty) {
        for (var file in request.files!) {
          String fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'files[]',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
      }

      print('📦 Sending request with content_types: ${request.contentTypes}');

      final response = await _dio.post(
        ApiConfig.process,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: (sent, total) {
          print('📤 Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200) {
        return ContentResponse.fromJson(response.data);
      } else {
        return ContentResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return ContentResponse(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      print('❌ Error: $e');
      return ContentResponse(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  // Download File
  Future<String?> downloadFile(
      String type,
      String filename,
      String savePath, {
        Function(int, int)? onProgress,
      }) async {
    try {
      final url = ApiConfig.downloadUrl(type, filename);

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      return savePath;
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  // List Files
  Future<List<SavedContent>> listFiles(
      String type, {
        int limit = 50,
        int offset = 0,
      }) async {
    try {
      final response = await _dio.get(
        ApiConfig.filesUrl(type),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> files = response.data['files'] ?? [];
        return files.map((json) {
          return SavedContent(
            id: json['filename'].split('.')[0],
            type: type,
            title: json['filename'],
            subject: 'Unknown',
            grade: 'Unknown',
            filename: json['filename'],
            downloadUrl: json['download_url'],
            createdAt: DateTime.parse(json['modified']),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('❌ List files error: $e');
      return [];
    }
  }

  // Chat Message
  Future<String?> sendChatMessage(
      String message, {
        Map<String, dynamic>? context,
      }) async {
    try {
      final response = await _dio.post(
        ApiConfig.chatUrl,
        data: {
          'message': message,
          'context': context ?? {},
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['response'];
      }

      return null;
    } catch (e) {
      print('❌ Chat error: $e');
      return null;
    }
  }

  // Generate Quiz (standalone)
  Future<Map<String, dynamic>?> generateQuiz({
    required String prompt,
    required List<String> chunks,
    required QuizConfig config,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.generateQuizUrl,
        data: {
          'prompt': prompt,
          'chunks': chunks,
          'config': config.toJson(),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('❌ Generate quiz error: $e');
      return null;
    }
  }

  // Generate Slide (standalone)
  Future<Map<String, dynamic>?> generateSlide({
    required Map<String, dynamic> lessonPlan,
    required SlideConfig
    config,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.generateSlideUrl,
        data: {
          'lesson_plan': lessonPlan,
          'config': config.toJson(),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('❌ Generate slide error: $e');
      return null;
    }
  }

  // Error Handler
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối timeout. Vui lòng thử lại.';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu timeout. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Server đang xử lý quá lâu. Vui lòng thử lại sau.';
      case DioExceptionType.badResponse:
        return 'Lỗi server: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      default:
        return 'Không thể kết nối tới server. Kiểm tra kết nối mạng.';
    }
  }
}