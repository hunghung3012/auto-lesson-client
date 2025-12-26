import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_request.dart';
import '../../utils/constants.dart';
import '../../utils/json_utils.dart'; // ✅ ADD THIS

class QuizDetailScreen extends StatefulWidget {
  final SavedContent content;
  final Map<String, dynamic> quizData;

  const QuizDetailScreen({
    Key? key,
    required this.content,
    required this.quizData,
  }) : super(key: key);

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _showAnswers = false;
  String _selectedFilter = 'Tất cả';

  // ✅ Safe getter cho answers
  Map<String, dynamic> get _answers {
    try {
      final answers = widget.quizData['answers'];
      if (answers == null) return {};

      if (answers is Map<String, dynamic>) {
        return answers;
      } else if (answers is Map) {
        return JsonUtils.convertToStringKeyMap(answers);
      }
      return {};
    } catch (e) {
      print('⚠️ Error getting answers: $e');
      return {};
    }
  }

  // ✅ Safe getter cho explanations
  Map<String, dynamic> get _explanations {
    try {
      final exp = widget.quizData['explanation'];
      if (exp == null) return {};

      if (exp is Map<String, dynamic>) {
        return exp;
      } else if (exp is Map) {
        return JsonUtils.convertToStringKeyMap(exp);
      }
      return {};
    } catch (e) {
      print('⚠️ Error getting explanations: $e');
      return {};
    }
  }

  // ✅ Safe getter cho statistics
  Map<String, dynamic> get _statistics {
    try {
      final stats = widget.quizData['statistics'];
      if (stats == null) {
        return {'total_questions': 0, 'by_type': {}};
      }

      if (stats is Map<String, dynamic>) {
        return stats;
      } else if (stats is Map) {
        return JsonUtils.convertToStringKeyMap(stats);
      }
      return {'total_questions': 0, 'by_type': {}};
    } catch (e) {
      print('⚠️ Error getting statistics: $e');
      return {'total_questions': 0, 'by_type': {}};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<MapEntry<String, dynamic>> _getFilteredQuestions() {
    return _answers.entries.toList();
  }

  String _getQuestionType(String questionId) {
    // Try to determine question type from explanation or other fields
    try {
      final questionNum = int.tryParse(questionId) ?? 0;

      if (questionNum <= 10) {
        return 'NHẬN BIẾT';
      } else if (questionNum <= 15) {
        return 'THÔNG HIỂU';
      } else if (questionNum <= 18) {
        return 'VẬN DỤNG';
      } else {
        return 'VẬN DỤNG CAO';
      }
    } catch (e) {
      return 'NHẬN BIẾT';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'NHẬN BIẾT':
        return Colors.green;
      case 'THÔNG HIỂU':
        return Colors.blue;
      case 'VẬN DỤNG':
        return Colors.orange;
      case 'VẬN DỤNG CAO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadFile() async {
    try {
      final url = Uri.parse('http://localhost:5000${widget.content.downloadUrl}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang tải file...')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải file: $e')),
        );
      }
    }
  }

  Future<void> _shareContent() async {
    final totalQuestions = _statistics['total_questions'] ?? _answers.length;

    await Share.share(
      '📝 Quiz: ${widget.content.title}\n'
          '📖 Môn: ${widget.content.subject} - Lớp ${widget.content.grade}\n'
          '📊 Tổng số câu: $totalQuestions\n'
          '📅 Tạo ngày: ${_formatDate(widget.content.createdAt)}\n\n'
          'Tải về tại: http://localhost:5000${widget.content.downloadUrl}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = _statistics['total_questions'] ?? _answers.length;

    // ✅ Safe access to by_type
    Map<String, dynamic> byType = {};
    try {
      final byTypeRaw = _statistics['by_type'];
      if (byTypeRaw is Map<String, dynamic>) {
        byType = byTypeRaw;
      } else if (byTypeRaw is Map) {
        byType = JsonUtils.convertToStringKeyMap(byTypeRaw);
      }
    } catch (e) {
      print('⚠️ Error getting by_type: $e');
    }

    // ✅ Kiểm tra nếu không có dữ liệu
    if (_answers.isEmpty && !widget.quizData.containsKey('raw_content')) {
      return Scaffold(
          appBar: AppBar(title: const Text('Chi tiết Quiz')),
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu quiz',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng thử tải lại hoặc tạo quiz mới',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Quiz'),
        actions: [
          IconButton(
            icon: Icon(_showAnswers ? Icons.visibility_off : Icons.visibility),
            tooltip: _showAnswers ? 'Ẩn đáp án' : 'Hiện đáp án',
            onPressed: () {
              setState(() {
                _showAnswers = !_showAnswers;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
            onPressed: _shareContent,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Tải về',
            onPressed: _downloadFile,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.quiz.withOpacity(0.1),
                  AppColors.quiz.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.quiz.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        color: AppColors.quiz,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.content.title,
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.content.subject} - Lớp ${widget.content.grade}',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Statistics
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                        'Tổng số câu', totalQuestions.toString(), Colors.blue),
                    if (byType.isNotEmpty) ...[
                      if (byType['NHẬN BIẾT'] != null)
                        _buildStatChip('Nhận biết',
                            byType['NHẬN BIẾT'].toString(), Colors.green),
                      if (byType['THÔNG HIỂU'] != null)
                        _buildStatChip('Thông hiểu',
                            byType['THÔNG HIỂU'].toString(), Colors.blue),
                      if (byType['VẬN DỤNG'] != null)
                        _buildStatChip('Vận dụng',
                            byType['VẬN DỤNG'].toString(), Colors.orange),
                      if (byType['VẬN DỤNG CAO'] != null)
                        _buildStatChip('VD Cao',
                            byType['VẬN DỤNG CAO'].toString(), Colors.red),
                    ],
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Tạo: ${_formatDate(widget.content.createdAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: _answers.isEmpty
                ? Center(
              child: Text(
                'Không có câu hỏi',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _answers.length,
              itemBuilder: (context, index) {
                try {
                  final entry = _answers.entries.elementAt(index);
                  final questionId = entry.key;
                  final answer = entry.value;
                  final explanation = _explanations[questionId] ?? '';
                  final questionType = _getQuestionType(questionId);

                  return _buildQuestionCard(
                    questionNumber:
                    int.tryParse(questionId) ?? (index + 1),
                    answer: answer.toString(),
                    explanation: explanation.toString(),
                    type: questionType,
                  );
                } catch (e) {
                  print('⚠️ Error building question $index: $e');
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildQuestionCard({
    required int questionNumber,
    required String answer,
    required String explanation,
    required String type,
  }) {
    final typeColor = _getTypeColor(type);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.quiz.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.quiz,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu $questionNumber',
                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: AppTextStyles.caption.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Answer (Always visible or with toggle)
            if (_showAnswers) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đáp án: ',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      answer,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Explanation
              if (explanation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Giải thích:',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: AppTextStyles.body2.copyWith(
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}