// models/chat_message_edu.dart
import 'dart:io';

class ChatMessageEdu {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? image;
  final bool isStreaming;

  ChatMessageEdu({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.image,
    this.isStreaming = false,
  });

  ChatMessageEdu copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    File? image,
    bool? isStreaming,
  }) {
    return ChatMessageEdu(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      image: image ?? this.image,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}