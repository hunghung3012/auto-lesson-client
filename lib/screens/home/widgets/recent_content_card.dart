// ==========================================

// recent_content_card.dart
import 'package:edu_agent/models/content_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _getTypeName() {
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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/content-detail',
          arguments: content,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getTypeName(),
                          style: AppTextStyles.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${content.subject} - Lớp ${content.grade}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(content.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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