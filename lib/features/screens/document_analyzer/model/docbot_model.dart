class AnalyzerMessage {
  final String content;
  final bool isUser;
  final bool isAnalysis;

  AnalyzerMessage({
    required this.content,
    required this.isUser,
    this.isAnalysis = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'isAnalysis': isAnalysis,
    };
  }

  factory AnalyzerMessage.fromJson(Map<String, dynamic> json) {
    return AnalyzerMessage(
      content: json['content'],
      isUser: json['isUser'],
      isAnalysis: json['isAnalysis'] ?? false,
    );
  }
}
