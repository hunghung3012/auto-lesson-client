import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_request.dart';
import '../../utils/constants.dart';

class SlideDetailScreen extends StatefulWidget {
  final SavedContent content;
  final String slideContent; // Content từ API response

  const SlideDetailScreen({
    Key? key,
    required this.content,
    required this.slideContent,
  }) : super(key: key);

  @override
  State<SlideDetailScreen> createState() => _SlideDetailScreenState();
}

class _SlideDetailScreenState extends State<SlideDetailScreen> {
  int _currentSlideIndex = 0;
  late List<SlideData> _slides;

  @override
  void initState() {
    super.initState();
    _slides = _parseSlides(widget.slideContent);
  }

  List<SlideData> _parseSlides(String content) {
    // Parse slide content theo format:
    // === SLIDE 1: TITLE ===
    // content
    // Ghi chú: note
    // ---

    final List<SlideData> slides = [];
    final slidePattern = RegExp(
      r'=== SLIDE (\d+): (.+?) ===\n([\s\S]*?)(?=(?:===|$))',
      multiLine: true,
    );

    final matches = slidePattern.allMatches(content);

    for (final match in matches) {
      final slideNumber = int.parse(match.group(1)!);
      final title = match.group(2)!.trim();
      final body = match.group(3)!.trim();

      // Extract note if exists
      String slideBody = body;
      String note = '';

      final notePattern = RegExp(r'Ghi chú:\s*(.+?)(?:\n---|\n\n|$)', multiLine: true);
      final noteMatch = notePattern.firstMatch(body);

      if (noteMatch != null) {
        note = noteMatch.group(1)!.trim();
        slideBody = body.substring(0, noteMatch.start).trim();
      }

      slides.add(SlideData(
        number: slideNumber,
        title: title,
        content: slideBody,
        note: note,
      ));
    }

    return slides;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadFile() async {
    try {
      final url = Uri.parse('http://localhost:5000${widget.content.downloadUrl}');
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
      '🎨 Slide: ${widget.content.title}\n'
          '📖 Môn: ${widget.content.subject} - Lớp ${widget.content.grade}\n'
          '📊 Tổng số slide: ${_slides.length}\n'
          '📅 Tạo ngày: ${_formatDate(widget.content.createdAt)}\n\n'
          'Tải về tại: http://localhost:5000${widget.content.downloadUrl}',
    );
  }

  Future<void> _copySlide() async {
    if (_slides.isEmpty) return;
    final slide = _slides[_currentSlideIndex];
    final text = '${slide.title}\n\n${slide.content}\n\nGhi chú: ${slide.note}';
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã sao chép slide hiện tại')),
    );
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
    }
  }

  void _nextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
    }
  }

  void _goToSlide(int index) {
    setState(() {
      _currentSlideIndex = index;
    });
    Navigator.pop(context);
  }

  void _showSlideList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Danh sách Slide (${_slides.length})',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final isActive = index == _currentSlideIndex;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? AppColors.slide
                            : Colors.grey[300],
                        child: Text(
                          '${slide.number}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        slide.title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? AppColors.slide : null,
                        ),
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: AppColors.slide)
                          : null,
                      onTap: () => _goToSlide(index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Slide')),
        body: const Center(
          child: Text('Không có nội dung slide'),
        ),
      );
    }

    final currentSlide = _slides[_currentSlideIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Slide ${_currentSlideIndex + 1}/${_slides.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Sao chép slide',
            onPressed: _copySlide,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Danh sách slide',
            onPressed: _showSlideList,
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
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.slide.withOpacity(0.1),
                  AppColors.slide.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.slide.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.slideshow,
                    color: AppColors.slide,
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
                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.content.subject} - Lớp ${widget.content.grade}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Slide Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slide Number
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.slide.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SLIDE ${currentSlide.number}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.slide,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Slide Title
                  Center(
                    child: Text(
                      currentSlide.title,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Slide Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentSlide.content,
                      style: AppTextStyles.body1.copyWith(
                        height: 1.8,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Slide Note
                  if (currentSlide.note.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.sticky_note_2,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ghi chú:',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentSlide.note,
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Navigation Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous Button
                ElevatedButton.icon(
                  onPressed: _currentSlideIndex > 0 ? _previousSlide : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Trước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    disabledBackgroundColor: Colors.grey[100],
                    disabledForegroundColor: Colors.grey[400],
                  ),
                ),
                const Spacer(),

                // Progress Indicator
                Text(
                  '${_currentSlideIndex + 1} / ${_slides.length}',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // Next Button
                ElevatedButton.icon(
                  onPressed: _currentSlideIndex < _slides.length - 1
                      ? _nextSlide
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Sau'),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slide,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[100],
                    disabledForegroundColor: Colors.grey[400],
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

class SlideData {
  final int number;
  final String title;
  final String content;
  final String note;

  SlideData({
    required this.number,
    required this.title,
    required this.content,
    required this.note,
  });
}