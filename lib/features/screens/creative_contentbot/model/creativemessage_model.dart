class CreativeMessage {
  final String content;
  final bool isUser;
  final bool isCreativeContent;

  CreativeMessage({
    required this.content,
    required this.isUser,
    this.isCreativeContent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'isCreativeContent': isCreativeContent,
    };
  }

  factory CreativeMessage.fromJson(Map<String, dynamic> json) {
    return CreativeMessage(
      content: json['content'],
      isUser: json['isUser'],
      isCreativeContent: json['isCreativeContent'] ?? false,
    );
  }
}
