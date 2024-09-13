class CodeBotMessage {
  final String content;
  final bool isUser;
  final bool isCode;

  CodeBotMessage(
      {required this.content, required this.isUser, this.isCode = false});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'isEmail': isCode,
    };
  }

  factory CodeBotMessage.fromJson(Map<String, dynamic> json) {
    return CodeBotMessage(
      content: json['content'],
      isUser: json['isUser'],
      isCode: json['isCode'] ?? false,
    );
  }
}
