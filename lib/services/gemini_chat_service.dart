// services/gemini_chat_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiChatService {
  // Thay đổi URL này theo server của bạn
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_IP:5000'; // Real device

  /// Stream text response từ server
  Stream<String> streamTextResponse(String message) async* {
    try {
      final url = Uri.parse('$baseUrl/api/chat/stream');

      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'history': [], // Có thể thêm history nếu cần
      });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        yield '❌ Lỗi: ${streamedResponse.statusCode}';
        return;
      }

      // Parse SSE stream
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // SSE format: "data: {json}\n\n"
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6); // Remove "data: "

            try {
              final data = jsonDecode(jsonStr);

              if (data['done'] == true) {
                return; // End of stream
              }

              if (data['error'] != null) {
                yield '❌ ${data['error']}';
                return;
              }

              if (data['text'] != null) {
                yield data['text'];
              }
            } catch (e) {
              // Invalid JSON, skip
              continue;
            }
          }
        }
      }
    } catch (e) {
      yield '❌ Lỗi kết nối: $e';
    }
  }

  /// Stream image analysis response
  Stream<String> streamImageAnalysis(File image, String prompt) async* {
    try {
      final url = Uri.parse('$baseUrl/api/chat/image-stream');

      final request = http.MultipartRequest('POST', url);

      // Add image
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      // Add prompt if provided
      if (prompt.isNotEmpty) {
        request.fields['prompt'] = prompt;
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        yield '❌ Lỗi: ${streamedResponse.statusCode}';
        return;
      }

      // Parse SSE stream
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);

            try {
              final data = jsonDecode(jsonStr);

              if (data['done'] == true) {
                return;
              }

              if (data['error'] != null) {
                yield '❌ ${data['error']}';
                return;
              }

              if (data['text'] != null) {
                yield data['text'];
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      yield '❌ Lỗi phân tích ảnh: $e';
    }
  }

  /// Send simple message (non-streaming fallback)
  Future<String?> sendMessage(String message) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat/message');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      }

      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Get teaching suggestions
  Future<String?> getTeachingSuggestions({
    required String topic,
    required String grade,
    required String subject,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat/teaching-suggestions');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
          'grade': grade,
          'subject': subject,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['suggestions'];
      }

      return null;
    } catch (e) {
      print('Error getting suggestions: $e');
      return null;
    }
  }

  /// Generate quiz questions
  Future<String?> generateQuiz({
    required String topic,
    int count = 10,
    String difficulty = 'medium',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat/generate-quiz');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
          'count': count,
          'difficulty': difficulty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['quiz'];
      }

      return null;
    } catch (e) {
      print('Error generating quiz: $e');
      return null;
    }
  }
}