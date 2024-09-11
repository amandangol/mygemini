// lib/data/models/message.dart

enum MessageType { user, bot }

class Message {
  final String msg;
  final MessageType msgType;

  Message({required this.msg, required this.msgType});

  Map<String, dynamic> toJson() => {
        'msg': msg,
        'msgType': msgType.toString(),
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      msg: json['msg'],
      msgType: json['msgType'] == 'MessageType.user'
          ? MessageType.user
          : MessageType.bot,
    );
  }
}
