import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_request.dart';
import '../../utils/constants.dart';

class LessonDetailScreen extends StatelessWidget {
  final SavedContent content;
  final String markdownContent; // Content từ API response

  const LessonDetailScreen({
    Key? key,
    required this.content,
    required this.markdownContent,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final url = Uri.parse('http://localhost:5000${content.downloadUrl}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải file...')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải file: $e')),
      );
    }
  }

  Future<void> _shareContent() async {
    await Share.share(
      '📚 Kế hoạch bài giảng: ${content.title}\n'
          '📖 Môn: ${content.subject} - Lớp ${content.grade}\n'
          '📅 Tạo ngày: ${_formatDate(content.createdAt)}\n\n'
          'Tải về tại: http://localhost:5000${content.downloadUrl}',
    );
  }

  Future<void> _copyContent(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: markdownContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã sao chép nội dung'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch bài giảng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Sao chép',
            onPressed: () => _copyContent(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
            onPressed: _shareContent,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Tải về',
            onPressed: () => _downloadFile(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lessonPlan.withOpacity(0.1),
                  AppColors.lessonPlan.withOpacity(0.05),
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
                        color: AppColors.lessonPlan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: AppColors.lessonPlan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${content.subject} - Lớp ${content.grade}',
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
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Tạo: ${_formatDate(content.createdAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.file_present, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        content.filename,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Markdown Content
          Expanded(
            child: Markdown(
              data: markdownContent,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
                h2: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
                h3: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
                p: AppTextStyles.body1.copyWith(
                  height: 1.6,
                ),
                listBullet: AppTextStyles.body1,
                code: TextStyle(
                  backgroundColor: Colors.grey[100],
                  fontFamily: 'monospace',
                ),
                blockquote: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}