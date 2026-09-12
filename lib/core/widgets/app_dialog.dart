import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

class AppDialog {
  /// Confirmation dialog. Returns true if confirmed, false/null otherwise.
  static Future<bool?> confirm(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
        bool isDanger = false,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText, style: TextStyle(color: Colors.grey[600])),
          ),
          SizedBox(
            width: 120,
            child: AppButton(
              text: confirmText,
              variant: isDanger ? AppButtonVariant.danger : AppButtonVariant.primary,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple info/error dialog with a single dismiss button.
  static Future<void> info(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(buttonText, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}