import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SelectableMarkdown extends StatelessWidget {
  final String data;

  SelectableMarkdown({required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true, // Enable selectable text here
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: Colors.black87),
        strong: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        em: TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
        code: TextStyle(
            color: Colors.black87, backgroundColor: Colors.transparent),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
