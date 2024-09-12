class AnalyzerMessage {
  final String content;
  final bool isUser;
  final bool isAnalysis;

  AnalyzerMessage({
    required this.content,
    required this.isUser,
    this.isAnalysis = false,
  });
}
