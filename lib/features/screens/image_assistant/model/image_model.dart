class NewsletterMessage {
  final String content;
  final bool isUser;
  final bool isNewsletter;

  NewsletterMessage(
      {required this.content, required this.isUser, this.isNewsletter = false});

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'isNewsletter': isNewsletter,
      };

  factory NewsletterMessage.fromJson(Map<String, dynamic> json) =>
      NewsletterMessage(
        content: json['content'],
        isUser: json['isUser'],
        isNewsletter: json['isNewsletter'],
      );
}
