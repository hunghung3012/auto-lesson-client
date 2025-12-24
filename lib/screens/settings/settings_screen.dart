import 'package:edu_agent/providers/notification_provider.dart';
import 'package:edu_agent/providers/theme_provider.dart';
import 'package:edu_agent/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';

import '../../providers/content_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          _buildSection(
            context,
            title: 'Thông tin ứng dụng',
            icon: Icons.info_outline,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.school_rounded,
                title: AppConstants.appName,
                subtitle: 'Phiên bản ${AppConstants.appVersion}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appearance Section
          _buildSection(
            context,
            title: 'Giao diện',
            icon: Icons.palette_outlined,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSwitchTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Chế độ tối',
                    subtitle: 'Giao diện tối dễ nhìn hơn',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification Section
          _buildSection(
            context,
            title: 'Thông báo',
            icon: Icons.notifications_outlined,
            children: [
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, child) {
                  return _buildSwitchTile(
                    context,
                    icon: Icons.notifications_active_outlined,
                    title: 'Bật thông báo',
                    subtitle: 'Nhận thông báo về nội dung mới',
                    value: notifProvider.isEnabled,
                    onChanged: (value) {
                      notifProvider.toggleNotification();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Storage Section
          _buildSection(
            context,
            title: 'Bộ nhớ',
            icon: Icons.storage_outlined,
            children: [
              FutureBuilder<Map<String, int>>(
                future: context.read<ContentProvider>().getStatistics(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  final total = stats['total'] ?? 0;

                  return _buildInfoTile(
                    context,
                    icon: Icons.folder_outlined,
                    title: 'Nội dung đã lưu',
                    subtitle: '$total mục',
                  );
                },
              ),
              _buildActionTile(
                context,
                icon: Icons.delete_outline,
                title: 'Xóa tất cả nội dung',
                subtitle: 'Xóa toàn bộ dữ liệu đã lưu',
                color: AppColors.error,
                onTap: () => _confirmClearData(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Server Section
          _buildSection(
            context,
            title: 'Máy chủ',
            icon: Icons.cloud_outlined,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.link,
                title: 'API Server',
                subtitle: 'http://192.168.1.5:5000',
              ),
              _buildActionTile(
                context,
                icon: Icons.health_and_safety_outlined,
                title: 'Kiểm tra kết nối',
                subtitle: 'Kiểm tra kết nối tới server',
                onTap: () => _checkServerHealth(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About Section
          _buildSection(
            context,
            title: 'Về chúng tôi',
            icon: Icons.help_outline,
            children: [
              _buildActionTile(
                context,
                icon: Icons.description_outlined,
                title: 'Điều khoản sử dụng',
                onTap: () {
                  // TODO: Show terms
                },
              ),
              _buildActionTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách bảo mật',
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              _buildActionTile(
                context,
                icon: Icons.feedback_outlined,
                title: 'Gửi phản hồi',
                onTap: () {
                  // TODO: Send feedback
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        required bool value,
        required Function(bool) onChanged,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        Color? color,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
    );
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả nội dung đã lưu? '
              'Hành động này không thể hoàn tác.',
        ),
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
      LoadingDialog.show(context, message: 'Đang xóa...');

      await _storageService.clearAllContents();
      await context.read<ContentProvider>().loadRecentContents();

      LoadingDialog.hide(context);

      SuccessDialog.show(
        context,
        message: 'Đã xóa tất cả nội dung',
      );
    }
  }

  Future<void> _checkServerHealth(BuildContext context) async {
    LoadingDialog.show(context, message: 'Đang kiểm tra...');

    final isHealthy = await context.read<ContentProvider>().checkServerHealth();

    LoadingDialog.hide(context);

    if (isHealthy) {
      SuccessDialog.show(
        context,
        message: 'Kết nối thành công! Server đang hoạt động tốt.',
      );
    } else {
      ErrorDialog.show(
        context,
        message: 'Không thể kết nối tới server. Vui lòng kiểm tra:\n'
            '• Server có đang chạy không?\n'
            '• Địa chỉ IP có đúng không?\n'
            '• Kết nối mạng có ổn định không?',
      );
    }
  }
}