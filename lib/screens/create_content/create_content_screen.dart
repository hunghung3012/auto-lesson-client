import 'dart:io';
import 'package:edu_agent/models/content_request.dart';
import 'package:edu_agent/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/content_provider.dart';
import '../../utils/constants.dart';
import 'widgets/form_section.dart';
import 'widgets/content_type_selector.dart';
import 'widgets/file_upload_area.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({Key? key}) : super(key: key);

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _topicController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  final _additionalController = TextEditingController();

  // Form values
  String? _selectedGrade;
  String? _selectedSubject;
  String? _selectedDifficulty = 'Trung bình';
  String? _selectedTeachingStyle = 'Thân thiện';

  // Content types
  final List<String> _selectedContentTypes = [];

  // Files
  List<File> _selectedFiles = [];

  @override
  void dispose() {
    _topicController.dispose();
    _durationController.dispose();
    _additionalController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      ErrorDialog.show(
        context,
        message: 'Không thể chọn file: $e',
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedContentTypes.isEmpty) {
      ErrorDialog.show(
        context,
        message: 'Vui lòng chọn ít nhất một loại nội dung',
      );
      return;
    }

    // Create request
    final request = ContentRequest(
      grade: _selectedGrade!,
      subject: _selectedSubject!,
      topic: _topicController.text.trim(),
      duration: _durationController.text.trim(),
      contentTypes: _selectedContentTypes,
      teachingStyle: _selectedTeachingStyle,
      difficulty: _selectedDifficulty,
      additionalRequirements: _additionalController.text.trim(),
      files: _selectedFiles.isEmpty ? null : _selectedFiles,
      quizConfig: QuizConfig(
        difficulty: _selectedDifficulty?.toLowerCase() ?? 'medium',
        questionCount: 10,
      ),
      slideConfig: SlideConfig(
        colorScheme: 'blue',
        tone: _selectedTeachingStyle ?? 'thân thiện',
      ),
    );

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<ContentProvider>(
        builder: (context, provider, child) {
          return ProgressDialog(
            title: 'Đang tạo nội dung',
            currentStep: provider.currentStep,
            progress: provider.progress,
          );
        },
      ),
    );

    // Create content
    final provider = context.read<ContentProvider>();
    final success = await provider.createContent(request);

    // Hide progress dialog
    Navigator.pop(context);

    if (success) {
      SuccessDialog.show(
        context,
        message: 'Đã tạo nội dung thành công!',
        onConfirm: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      );
    } else {
      ErrorDialog.show(
        context,
        message: provider.errorMessage ?? 'Có lỗi xảy ra',
        onRetry: _submit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nội dung mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Basic Info
            FormSection(
              title: 'Thông tin cơ bản',
              icon: Icons.info_outline,
              children: [
                // Grade
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Khối lớp *',
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: AppConstants.grades.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text('Lớp $grade'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedGrade = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Vui lòng chọn khối lớp';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Subject
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Môn học *',
                    prefixIcon: Icon(Icons.book),
                  ),
                  items: AppConstants.subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSubject = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Vui lòng chọn môn học';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Topic
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Chủ đề bài học *',
                    hintText: 'VD: Phương trình bậc 2',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập chủ đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Duration
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian (phút)',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content Types
            FormSection(
              title: 'Loại nội dung',
              icon: Icons.content_paste,
              children: [
                ContentTypeSelector(
                  selectedTypes: _selectedContentTypes,
                  onChanged: (types) {
                    setState(() {
                      _selectedContentTypes.clear();
                      _selectedContentTypes.addAll(types);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Teaching Style
            FormSection(
              title: 'Phong cách & độ khó',
              icon: Icons.psychology,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTeachingStyle,
                  decoration: const InputDecoration(
                    labelText: 'Phong cách giảng dạy',
                    prefixIcon: Icon(Icons.style),
                  ),
                  items: AppConstants.teachingStyles.map((style) {
                    return DropdownMenuItem(
                      value: style,
                      child: Text(style),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTeachingStyle = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Độ khó',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  items: AppConstants.difficulties.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDifficulty = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // File Upload
            FormSection(
              title: 'Tài liệu tham khảo',
              icon: Icons.upload_file,
              children: [
                FileUploadArea(
                  files: _selectedFiles,
                  onPickFiles: _pickFiles,
                  onRemoveFile: _removeFile,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Requirements
            FormSection(
              title: 'Yêu cầu bổ sung',
              icon: Icons.notes,
              children: [
                TextFormField(
                  controller: _additionalController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập các yêu cầu đặc biệt...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo nội dung với AI',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI giảng dạy',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Điền thông tin để tạo nội dung tự động',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}