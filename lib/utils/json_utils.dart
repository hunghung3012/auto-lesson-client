// lib/utils/json_utils.dart
import 'dart:convert';

/// Utility class for safe JSON operations and type conversions
class JsonUtils {
  /// Recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
  /// Handles nested maps and lists safely
  static Map<String, dynamic> convertToStringKeyMap(dynamic input) {
    if (input == null) {
      return {};
    }

    if (input is! Map) {
      print('⚠️ Input is not a Map, got ${input.runtimeType}');
      return {};
    }

    final result = <String, dynamic>{};

    try {
      input.forEach((key, value) {
        final stringKey = key.toString();

        if (value is Map) {
          // Recursively convert nested maps
          result[stringKey] = convertToStringKeyMap(value);
        } else if (value is List) {
          // Convert list items if they are maps
          result[stringKey] = value.map((item) {
            if (item is Map) {
              return convertToStringKeyMap(item);
            }
            return item;
          }).toList();
        } else {
          result[stringKey] = value;
        }
      });
    } catch (e, stackTrace) {
      print('❌ Error in convertToStringKeyMap: $e');
      print('📜 Stack: $stackTrace');
      return {};
    }

    return result;
  }

  /// Safe JSON decode with automatic type conversion
  /// Returns Map<String, dynamic> regardless of input
  static Map<String, dynamic> safeDecodeMap(String jsonString) {
    if (jsonString.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is Map) {
        return convertToStringKeyMap(decoded);
      } else if (decoded is List) {
        // If root is array, wrap in object
        return {'items': decoded};
      } else {
        return {'value': decoded};
      }
    } catch (e) {
      print('❌ Error decoding JSON: $e');
      print('📄 Content preview: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
      return {};
    }
  }

  /// Validate and parse quiz data specifically
  /// Returns properly structured quiz data or empty template
  static Map<String, dynamic> parseQuizData(String? content) {
    if (content == null || content.isEmpty) {
      print('ℹ️ Empty content, returning empty quiz structure');
      return _emptyQuizStructure();
    }

    final trimmed = content.trim();

    // Check if it's JSON format
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        print('🔍 Attempting to parse as JSON...');
        final parsed = safeDecodeMap(content);

        // Validate it has quiz-like structure
        if (parsed.containsKey('answers') ||
            parsed.containsKey('explanation') ||
            parsed.containsKey('statistics')) {
          print('✅ Valid quiz structure detected');
          return _ensureQuizStructure(parsed);
        } else {
          print('⚠️ JSON parsed but no quiz structure, wrapping...');
          return _emptyQuizStructure(rawContent: content);
        }
      } catch (e) {
        print('⚠️ Failed to parse JSON: $e');
        return _emptyQuizStructure(rawContent: content);
      }
    } else {
      // Markdown or plain text format
      print('ℹ️ Content is Markdown/Text format');
      return _emptyQuizStructure(rawContent: content);
    }
  }

  /// Ensure quiz data has all required fields
  static Map<String, dynamic> _ensureQuizStructure(Map<String, dynamic> data) {
    return {
      'answers': data['answers'] ?? {},
      'explanation': data['explanation'] ?? {},
      'statistics': data['statistics'] ?? {
        'total_questions': 0,
        'by_type': {},
      },
      if (data.containsKey('raw_content')) 'raw_content': data['raw_content'],
    };
  }

  /// Create empty quiz structure
  static Map<String, dynamic> _emptyQuizStructure({String? rawContent}) {
    final structure = <String, dynamic>{
      'answers': <String, dynamic>{},
      'explanation': <String, dynamic>{},
      'statistics': <String, dynamic>{
        'total_questions': 0,
        'by_type': <String, dynamic>{},
      },
    };

    if (rawContent != null) {
      structure['raw_content'] = rawContent;
    }

    return structure;
  }

  /// Validate quiz data structure
  static bool isValidQuizData(Map<String, dynamic> data) {
    return data.containsKey('answers') ||
        data.containsKey('explanation') ||
        data.containsKey('raw_content');
  }

  /// Pretty print JSON for debugging
  static String prettyPrint(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  /// Safe get value from nested map
  static dynamic safeGet(Map<String, dynamic> map, String key, {dynamic defaultValue}) {
    try {
      return map[key] ?? defaultValue;
    } catch (e) {
      print('⚠️ Error getting key "$key": $e');
      return defaultValue;
    }
  }

  /// Safe get nested value with dot notation (e.g., "statistics.total_questions")
  static dynamic safeGetNested(Map<String, dynamic> map, String path, {dynamic defaultValue}) {
    try {
      final keys = path.split('.');
      dynamic current = map;

      for (final key in keys) {
        if (current is Map) {
          current = current[key];
          if (current == null) return defaultValue;
        } else {
          return defaultValue;
        }
      }

      return current ?? defaultValue;
    } catch (e) {
      print('⚠️ Error getting nested path "$path": $e');
      return defaultValue;
    }
  }
}