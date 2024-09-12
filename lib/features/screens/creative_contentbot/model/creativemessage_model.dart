class CreativeMessage {
  final String content;
  final bool isUser;
  final bool isCreativeContent;

  CreativeMessage({
    required this.content,
    required this.isUser,
    this.isCreativeContent = false,
  });
}
