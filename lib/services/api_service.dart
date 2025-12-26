import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/content_request.dart';
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
      logPrint: (obj) => print('🌐 API: $obj'),
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

  // Process Content (JSON ONLY - FIXED)
  Future<ContentResponse> processContent(ContentRequest request) async {
    try {
      print('=' * 60);
      print('🚀 API REQUEST START (JSON MODE)');
      print('=' * 60);

      final payload = request.toJson();

      print('📤 Sending JSON payload:');
      print(const JsonEncoder.withIndent('  ').convert(payload));

      final response = await _dio.post(
        ApiConfig.process,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('=' * 60);
      print('📥 API RESPONSE RECEIVED');
      print('=' * 60);
      print('Status: ${response.statusCode}');
      print('Response type: ${response.data.runtimeType}');

      if (response.data is Map) {
        print('Response keys: ${(response.data as Map).keys.toList()}');
      }

      if (response.statusCode == 200) {
        final parsed = ContentResponse.fromJson(response.data);

        print('=' * 60);
        print('✅ RESPONSE PARSED');
        print('=' * 60);
        print('Success: ${parsed.success}');
        print('Lesson Plan: ${parsed.lessonPlan != null ? '✅' : '❌'}');
        print('Quiz: ${parsed.quiz != null ? '✅' : '❌'}');
        print('Slide: ${parsed.slidePlan != null ? '✅' : '❌'}');
        print('=' * 60);

        return parsed;
      }

      return ContentResponse(
        success: false,
        error: 'Server error: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('❌ DIO ERROR: ${e.message}');
      print('❌ RESPONSE: ${e.response?.data}');
      return ContentResponse(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e, stack) {
      print('❌ UNEXPECTED ERROR: $e');
      print(stack);
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
      print('📥 Downloading from: $url');

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      print('✅ Downloaded to: $savePath');
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