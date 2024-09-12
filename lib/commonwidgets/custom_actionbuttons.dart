import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:share_plus/share_plus.dart';

class CustomActionButtons extends StatelessWidget {
  final String text;
  final String shareSubject;

  const CustomActionButtons({
    Key? key,
    required this.text,
    this.shareSubject = 'Shared Text',
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, 'Text copied to clipboard');
  }

  void _shareContent() {
    Share.share(text, subject: shareSubject);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyMedium),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      tooltip: icon == Icons.copy ? 'Copy' : 'Share',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.copy,
          onPressed: () => _copyToClipboard(context),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          context: context,
          icon: Icons.share,
          onPressed: _shareContent,
        ),
      ],
    );
  }
}
