class LearningAssistModel {
  final String content;
  final bool isUser;
  final bool isImportant;

  LearningAssistModel({
    required this.content,
    required this.isUser,
    this.isImportant = false,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'isImportant': isImportant,
      };

  factory LearningAssistModel.fromJson(Map<String, dynamic> json) =>
      LearningAssistModel(
        content: json['content'],
        isUser: json['isUser'],
        isImportant: json['isImportant'],
      );
}
