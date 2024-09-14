import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2) // Message class must have a unique typeId
class Message {
  @HiveField(0)
  final String msg;

  @HiveField(1)
  final MessageType msgType;

  // Constructor
  Message({required this.msg, required this.msgType});
}

@HiveType(typeId: 3) // MessageType enum must have a unique typeId
enum MessageType {
  @HiveField(0)
  user,
  @HiveField(1)
  bot,
}
