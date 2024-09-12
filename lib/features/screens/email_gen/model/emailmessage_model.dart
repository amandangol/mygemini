class EmailMessage {
  final String content;
  final bool isUser;
  final bool isEmail;

  EmailMessage({
    required this.content,
    required this.isUser,
    this.isEmail = false,
  });
}
