import 'package:edu_agent/screens/chat/chat_screen.dart';
import 'package:edu_agent/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/create_content/create_content_screen.dart';
import 'screens/library/library_screen.dart';
import 'widgets/custom_app_bar.dart';
import 'utils/constants.dart';
import 'providers/content_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const NewHomeScreen(),
    const CreateContentScreen(),
    const LibraryScreen(),
    const ChatEduScreen(),
  ];

  final List<String> _pageTitles = [
    'EduMate',
    'Tạo nội dung',
    'Thư viện',
    'Chat AI',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Initialize content provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().initialize();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : AppColors.background,

      // AppBar cố định
      appBar: CustomAppBar(
        title: _pageTitles[_currentIndex],
        showBackButton: false,
      ),

      // Body
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Trang chủ',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.add_circle_outline,
                  label: 'Tạo mới',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.folder_open,
                  label: 'Thư viện',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button (Optional)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 1; // Go to Create
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white70 : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}