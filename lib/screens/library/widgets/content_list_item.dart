// content_list_item.dart
import 'package:edu_agent/models/content_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';

class ContentListItem extends StatelessWidget {
  final SavedContent content;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ContentListItem({
    Key? key,
    required this.content,
    required this.onTap,
    required this.onDownload,
    required this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(), color: color, size: 28),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${content.subject} • Lớp ${content.grade}',
                        style: AppTextStyles.caption.copyWith(
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
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(content.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: onDownload,
                  color: AppColors.primary,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: AppColors.error,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
