// file_upload_area.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class FileUploadArea extends StatelessWidget {
  final List<File> files;
  final VoidCallback onPickFiles;
  final Function(int) onRemoveFile;

  const FileUploadArea({
    Key? key,
    required this.files,
    required this.onPickFiles,
    required this.onRemoveFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPickFiles,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tải lên tài liệu',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, DOC, DOCX (Tùy chọn)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFileItem(file, index);
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildFileItem(File file, int index) {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              extension,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: AppTextStyles.body2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => onRemoveFile(index),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}