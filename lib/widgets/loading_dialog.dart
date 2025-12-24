import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/constants.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final double? progress;

  const LoadingDialog({
    Key? key,
    this.message = 'Đang xử lý...',
    this.progress,
  }) : super(key: key);

  static void show(BuildContext context, {String? message, double? progress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        message: message ?? 'Đang xử lý...',
        progress: progress,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitFadingCircle(
              color: AppColors.primary,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            if (progress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    Key? key,
    this.title = 'Có lỗi xảy ra',
    required this.message,
    this.onRetry,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        String? title,
        required String message,
        VoidCallback? onRetry,
      }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? 'Có lỗi xảy ra',
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.heading3),
        ],
      ),
      content: Text(message, style: AppTextStyles.body1),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onRetry != null) {
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onRetry?.call();
                  },
                  child: const Text('Thử lại'),
                );
              }
            },
            child: const Text('Thử lại'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const SuccessDialog({
    Key? key,
    this.title = 'Thành công!',
    required this.message,
    this.onConfirm,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        String? title,
        required String message,
        VoidCallback? onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title ?? 'Thành công!',
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.heading3),
        ],
      ),
      content: Text(message, style: AppTextStyles.body1),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class ProgressDialog extends StatelessWidget {
  final String title;
  final String currentStep;
  final double progress;

  const ProgressDialog({
    Key? key,
    required this.title,
    required this.currentStep,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Current Step
            Text(
              currentStep,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Percentage
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}