// widgets/chat_input_edu.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ChatInputEdu extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final File? pendingImage;
  final VoidCallback onSend;
  final VoidCallback onStop; // Thêm callback dừng
  final VoidCallback onCameraTap;
  final VoidCallback onRemoveImage;

  const ChatInputEdu({
    Key? key,
    required this.controller,
    required this.isLoading,
    this.pendingImage,
    required this.onSend,
    required this.onStop,
    required this.onCameraTap,
    required this.onRemoveImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra có thể gửi không (có text hoặc image)
    final canSend = controller.text.trim().isNotEmpty || pendingImage != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            if (pendingImage != null) _buildImagePreview(),

            // Input field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Text field
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: TextField(
                          controller: controller,
                          enabled: !isLoading,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) {
                            if (canSend && !isLoading) {
                              onSend();
                            }
                          },
                        ),
                      ),
                    ),

                    // Camera button
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        icon: Icon(
                          Icons.image_outlined,
                          color: isLoading
                              ? Colors.grey[300]
                              : const Color(0xFF6F47EB),
                          size: 24,
                        ),
                        onPressed: isLoading ? null : onCameraTap,
                        tooltip: 'Thêm ảnh',
                      ),
                    ),

                    // Send/Stop button
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLoading
                                ? [Colors.red[400]!, Colors.red[600]!]
                                : !canSend
                                ? [Colors.grey[300]!, Colors.grey[400]!]
                                : [const Color(0xFF6F47EB), const Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isLoading || canSend)
                              BoxShadow(
                                color: isLoading
                                    ? Colors.red.withOpacity(0.3)
                                    : const Color(0xFF6F47EB).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isLoading ? Icons.stop_rounded : Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: isLoading
                              ? onStop  // Nếu đang loading thì dừng
                              : canSend
                              ? onSend  // Nếu có text/image thì gửi
                              : null,   // Nếu không có gì thì disable
                          padding: EdgeInsets.zero,
                          tooltip: isLoading ? 'Dừng' : 'Gửi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Stack(
            children: [
              // Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6F47EB).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    pendingImage!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Remove button
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: onRemoveImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),


        ],
      ),
    );
  }
}