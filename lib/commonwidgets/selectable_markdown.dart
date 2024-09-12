import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SelectableMarkdown extends StatelessWidget {
  final String data;
  final Color textColor;

  SelectableMarkdown({required this.data, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        code: TextStyle(
          color: textColor,
          backgroundColor: Colors.grey.withOpacity(0.2),
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
