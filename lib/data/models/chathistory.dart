import 'package:hive/hive.dart';
import 'package:mygemini/data/models/message.dart';

part 'chathistory.g.dart';

@HiveType(typeId: 1) // ChatHistory must have a unique typeId
class ChatHistory extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<Message> messages;

  @HiveField(2)
  DateTime timestamp;

  // Constructor
  ChatHistory(
      {required this.title, required this.messages, required this.timestamp});
}
