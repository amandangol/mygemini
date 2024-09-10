import 'dart:convert';

enum MessageType { user, bot }

class Message {
  String msg;
  final MessageType msgType;

  Message({required this.msg, required this.msgType});
  Map<String, dynamic> toMap() {
    return {
      'msg': msg,
      'msgType': msgType.index,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      msg: map['msg'],
      msgType: MessageType.values[map['msgType']],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}
