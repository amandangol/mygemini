import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SelectableMarkdown extends StatelessWidget {
  final String data;
  final Color textColor;

  const SelectableMarkdown({
    Key? key,
    required this.data,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double baseFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14.0;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: baseFontSize, height: 1.3),
        h1: TextStyle(
            color: textColor,
            fontSize: baseFontSize * 1.5,
            fontWeight: FontWeight.bold,
            height: 1.3),
        h2: TextStyle(
            color: textColor,
            fontSize: baseFontSize * 1.3,
            fontWeight: FontWeight.bold,
            height: 1.3),
        h3: TextStyle(
            color: textColor,
            fontSize: baseFontSize * 1.1,
            fontWeight: FontWeight.bold,
            height: 1.3),
        h4: TextStyle(
            color: textColor,
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            height: 1.3),
        h5: TextStyle(
            color: textColor,
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            height: 1.3),
        h6: TextStyle(
            color: textColor,
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            height: 1.3),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        blockquote: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: baseFontSize,
            height: 1.3),
        code: TextStyle(
          color: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          fontSize: baseFontSize * 0.9,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        codeblockPadding: const EdgeInsets.all(8),
        blockSpacing: 12,
        listIndent: 16,
        listBullet: TextStyle(color: textColor, fontSize: baseFontSize),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: textColor.withOpacity(0.2),
            ),
          ),
        ),
        tableHead: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize * 0.9),
        tableBody: TextStyle(color: textColor, fontSize: baseFontSize * 0.9),
        tableBorder:
            TableBorder.all(color: textColor.withOpacity(0.2), width: 0.5),
        tableColumnWidth: const FlexColumnWidth(),
        tableCellsPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tableCellsDecoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
      ),
    );
  }
}
