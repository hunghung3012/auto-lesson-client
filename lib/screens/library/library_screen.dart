import 'package:edu_agent/models/content_request.dart';
import 'package:edu_agent/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../utils/constants.dart';
import '../../services/download_service.dart';
import 'widgets/content_list_item.dart';
import 'widgets/filter_sheet.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadRecentContents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterSheet(
        onFilterApplied: (type) {
          setState(() {
            _filterType = type;
          });
        },
      ),
    );
  }

  List<SavedContent> _filterContents(List<SavedContent> contents) {
    var filtered = contents;

    // Filter by tab
    if (_tabController.index > 0) {
      String type = '';
      switch (_tabController.index) {
        case 1:
          type = AppConstants.lessonPlan;
          break;
        case 2:
          type = AppConstants.quiz;
          break;
        case 3:
          type = AppConstants.slidePlan;
          break;
      }
      filtered = filtered.where((c) => c.type == type).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterSheet,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              onTap: (_) => setState(() {}),
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Kế hoạch'),
                Tab(text: 'Quiz'),
                Tab(text: 'Slide'),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<ContentProvider>().loadRecentContents();
              },
              child: Consumer<ContentProvider>(
                builder: (context, provider, child) {
                  final contents = _filterContents(provider.recentContents);

                  if (contents.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: contents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ContentListItem(
                        content: contents[index],
                        onTap: () => _viewContent(contents[index]),
                        onDownload: () => _downloadContent(contents[index]),
                        onDelete: () => _deleteContent(contents[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có nội dung',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo nội dung mới để bắt đầu!',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _viewContent(SavedContent content) {
    Navigator.pushNamed(
      context,
      '/content-detail',
      arguments: content,
    );
  }

  Future<void> _downloadContent(SavedContent content) async {
    LoadingDialog.show(context, message: 'Đang tải xuống...');

    final downloadService = DownloadService();
    final filePath = await downloadService.downloadFile(
      type: content.type == AppConstants.lessonPlan ? 'lesson' :
      content.type == AppConstants.quiz ? 'quiz' : 'slide',
      filename: content.filename,
      contentId: content.id,
    );

    LoadingDialog.hide(context);

    if (filePath != null) {
      SuccessDialog.show(
        context,
        message: 'Đã tải xuống: $filePath',
        onConfirm: () async {
          await downloadService.openFile(filePath);
        },
      );
    } else {
      ErrorDialog.show(
        context,
        message: 'Không thể tải xuống file',
      );
    }
  }

  Future<void> _deleteContent(SavedContent content) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${content.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ContentProvider>().deleteContent(
        content.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa nội dung')),
          );
        }
      }
    }
  }
}