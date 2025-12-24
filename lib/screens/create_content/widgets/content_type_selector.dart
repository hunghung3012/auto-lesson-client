// content_type_selector.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ContentTypeSelector extends StatelessWidget {
  final List<String> selectedTypes;
  final Function(List<String>) onChanged;

  const ContentTypeSelector({
    Key? key,
    required this.selectedTypes,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContentTypeItem(
          context,
          type: AppConstants.lessonPlan,
          title: 'Kế hoạch giảng dạy',
          subtitle: 'Giáo án chi tiết, mục tiêu, hoạt động',
          icon: Icons.article,
          color: AppColors.lessonPlan,
        ),
        const SizedBox(height: 12),
        _buildContentTypeItem(
          context,
          type: AppConstants.quiz,
          title: 'Bài kiểm tra / Quiz',
          subtitle: 'Trắc nghiệm, tự luận tự động',
          icon: Icons.quiz,
          color: AppColors.quiz,
        ),
        const SizedBox(height: 12),
        _buildContentTypeItem(
          context,
          type: AppConstants.slidePlan,
          title: 'Slide bài giảng',
          subtitle: 'Slide PowerPoint tự động',
          icon: Icons.slideshow,
          color: AppColors.slide,
        ),
      ],
    );
  }

  Widget _buildContentTypeItem(
      BuildContext context, {
        required String type,
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
      }) {
    final isSelected = selectedTypes.contains(type);

    return InkWell(
      onTap: () {
        List<String> newTypes = List.from(selectedTypes);
        if (isSelected) {
          newTypes.remove(type);
        } else {
          newTypes.add(type);
        }
        onChanged(newTypes);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }
}