// screens/chat_edu_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:edu_agent/models/chat_message_edu.dart';
import 'package:edu_agent/screens/chat/widgets/chat_bubble_edu.dart';
import 'package:edu_agent/screens/chat/widgets/chat_input_edu.dart';
import 'package:edu_agent/services/gemini_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ChatEduScreen extends StatefulWidget {
  const ChatEduScreen({Key? key}) : super(key: key);

  @override
  State<ChatEduScreen> createState() => _ChatEduScreenState();
}

class _ChatEduScreenState extends State<ChatEduScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final GeminiChatService _chatService = GeminiChatService();

  final List<ChatMessageEdu> _messages = [];
  File? _pendingImage;
  bool _isLoading = false;
  StreamSubscription? _currentStreamSubscription; // Thêm để quản lý stream

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    // Thêm listener để cập nhật UI khi text thay đổi
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _currentStreamSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessageEdu(
        text: "👋 Xin chào! Tôi là trợ lý AI giảng dạy của bạn.\n\n"
            "📚 Tôi có thể giúp bạn:\n"
            "• Tạo kế hoạch bài giảng\n"
            "• Soạn câu hỏi quiz\n"
            "• Thiết kế slide bài giảng\n"
            "• Tư vấn phương pháp giảng dạy\n"
            "• Phân tích hình ảnh giáo dục\n\n"
            "📸 Bạn cũng có thể gửi ảnh để tôi phân tích!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Thêm hàm dừng streaming
  void _stopStreaming() {
    _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Đánh dấu tin nhắn cuối cùng là đã hoàn thành
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          final lastIndex = _messages.length - 1;
          _messages[lastIndex] = _messages[lastIndex].copyWith(
            isStreaming: false,
          );
        }
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Chọn nguồn ảnh",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: "Máy ảnh",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: "Thư viện",
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _pendingImage = File(picked.path);
        });
      }
    } catch (e) {
      _showError('Không thể chọn ảnh: $e');
    }
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    final image = _pendingImage;

    // Allow sending if either text or image exists
    if ((text.isEmpty && image == null) || _isLoading) return;

    // Hủy stream hiện tại nếu có
    _currentStreamSubscription?.cancel();

    // Add user message
    setState(() {
      _messages.add(ChatMessageEdu(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        image: image,
      ));
      _pendingImage = null;
      _isLoading = true;
    });

    _controller.clear();
    _scrollDown();

    // Handle based on what user sent
    if (image != null) {
      // If there's an image, analyze it (with or without text prompt)
      await _handleImageMessage(image, text.isEmpty ? "Phân tích ảnh này" : text);
    } else {
      // Only text message
      await _handleTextMessage(text);
    }
  }

  Future<void> _handleImageMessage(File image, String prompt) async {
    final botIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessageEdu(
        text: "",
        isUser: false,
        timestamp: DateTime.now(),
        image: image,
        isStreaming: true,
      ));
    });

    final buffer = StringBuffer();

    try {
      final stream = _chatService.streamImageAnalysis(image, prompt);

      // Lưu subscription để có thể cancel
      _currentStreamSubscription = stream.listen(
            (chunk) {
          buffer.write(chunk);

          // Update UI theo từng chunk nhận được
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = _messages[botIndex].copyWith(
                text: buffer.toString(),
              );
            });
            _scrollDown();
          }
        },
        onDone: () {
          // Mark as complete
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = _messages[botIndex].copyWith(
                text: buffer.toString(),
                isStreaming: false,
              );
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = ChatMessageEdu(
                text: '❌ Lỗi phân tích ảnh: $e',
                isUser: false,
                timestamp: DateTime.now(),
              );
              _isLoading = false;
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted && _messages.length > botIndex) {
        setState(() {
          _messages[botIndex] = ChatMessageEdu(
            text: '❌ Lỗi phân tích ảnh: $e',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleTextMessage(String text) async {
    final botIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessageEdu(
        text: "",
        isUser: false,
        timestamp: DateTime.now(),
        isStreaming: true,
      ));
    });

    final buffer = StringBuffer();

    try {
      final stream = _chatService.streamTextResponse(text);

      // Lưu subscription để có thể cancel
      _currentStreamSubscription = stream.listen(
            (chunk) {
          buffer.write(chunk);

          // Update UI theo từng chunk nhận được
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = _messages[botIndex].copyWith(
                text: buffer.toString(),
              );
            });
            _scrollDown();
          }
        },
        onDone: () {
          // Mark as complete
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = _messages[botIndex].copyWith(
                text: buffer.toString(),
                isStreaming: false,
              );
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted && _messages.length > botIndex) {
            setState(() {
              _messages[botIndex] = ChatMessageEdu(
                text: '❌ Lỗi: $e',
                isUser: false,
                timestamp: DateTime.now(),
              );
              _isLoading = false;
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted && _messages.length > botIndex) {
        setState(() {
          _messages[botIndex] = ChatMessageEdu(
            text: '❌ Lỗi: $e',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat'),
        content: const Text('Bạn có chắc muốn xóa tất cả tin nhắn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _currentStreamSubscription?.cancel();
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
                _isLoading = false;
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6F47EB), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "Trợ lý AI",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubbleEdu(message: _messages[index]);
              },
            ),
          ),

          // Quick actions (show only if few messages)
          if (_messages.length <= 2) _buildQuickActions(),

          // Input area
          ChatInputEdu(
            controller: _controller,
            isLoading: _isLoading,
            pendingImage: _pendingImage,
            onSend: _handleSend,
            onStop: _stopStreaming, // Thêm callback dừng
            onCameraTap: _showImageSourceDialog,
            onRemoveImage: () => setState(() => _pendingImage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.article, 'label': 'Tạo kế hoạch bài giảng'},
      {'icon': Icons.quiz, 'label': 'Tạo câu hỏi quiz'},
      {'icon': Icons.slideshow, 'label': 'Thiết kế slide'},
      {'icon': Icons.lightbulb, 'label': 'Tư vấn phương pháp'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  _controller.text = action['label'] as String;
                  _handleSend();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F47EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6F47EB).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 18,
                        color: const Color(0xFF6F47EB),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action['label'] as String,
                        style: const TextStyle(
                          color: Color(0xFF6F47EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}