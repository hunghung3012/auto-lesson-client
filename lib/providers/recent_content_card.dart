import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/content_request.dart';
import '../../../utils/constants.dart';

class RecentContentCard extends StatelessWidget {
  final SavedContent content;

  const RecentContentCard({
    Key? key,
    required this.content,
  }) : super(key: key);

  IconData _getIcon() {
    switch (content.type) {
      case 'lesson_plan':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'slide_plan':
        return Icons.slideshow;
      default:
        return Icons.description;
    }
  }

  Color _getColor() {
    switch (content.type) {
      case 'lesson_plan':
        return AppColors.lessonPlan;
      case 'quiz':
        return AppColors.quiz;
      case 'slide_plan':
        return AppColors.slide;
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel() {
    switch (content.type) {
      case 'lesson_plan':
        return 'Kế hoạch';
      case 'quiz':
        return 'Quiz';
      case 'slide_plan':
        return 'Slide';
      default:
        return 'Nội dung';
    }
  }

  // ✅ Navigate to detail screen
  void _viewContent(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/content-detail',
      arguments: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: () => _viewContent(context), // ✅ Navigate when tapped
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeLabel(),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    content.title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Subject & Grade
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${content.subject} • Lớp ${content.grade}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(content.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}