class EmailMessage {
  final String content;
  final bool isUser;
  final bool isEmail;

  EmailMessage({
    required this.content,
    required this.isUser,
    this.isEmail = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'isEmail': isEmail,
    };
  }

  factory EmailMessage.fromJson(Map<String, dynamic> json) {
    return EmailMessage(
      content: json['content'],
      isUser: json['isUser'],
      isEmail: json['isEmail'] ?? false,
    );
  }
}
