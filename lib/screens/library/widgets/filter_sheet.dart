// filter_sheet.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class FilterSheet extends StatefulWidget {
  final Function(String?) onFilterApplied;

  const FilterSheet({
    Key? key,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc theo loại',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          _buildFilterOption(
            'Tất cả',
            null,
            Icons.select_all,
          ),
          const SizedBox(height: 12),
          _buildFilterOption(
            'Kế hoạch giảng dạy',
            AppConstants.lessonPlan,
            Icons.article,
          ),
          const SizedBox(height: 12),
          _buildFilterOption(
            'Quiz',
            AppConstants.quiz,
            Icons.quiz,
          ),
          const SizedBox(height: 12),
          _buildFilterOption(
            'Slide',
            AppConstants.slidePlan,
            Icons.slideshow,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                    });
                    widget.onFilterApplied(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterApplied(_selectedType);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String? type, IconData icon) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}