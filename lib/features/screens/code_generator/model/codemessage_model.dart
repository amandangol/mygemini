class ChatMessage {
  final String content;
  final bool isUser;
  final bool isCode;

  ChatMessage(
      {required this.content, required this.isUser, this.isCode = false});
}
