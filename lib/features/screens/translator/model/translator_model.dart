class TranslationMessage {
  final String text;
  final bool isUser;

  TranslationMessage({
    required this.text,
    required this.isUser,
  });
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }

  factory TranslationMessage.fromJson(Map<String, dynamic> json) {
    return TranslationMessage(
      text: json['text'],
      isUser: json['isUser'],
    );
  }
}
