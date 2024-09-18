import 'dart:io';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  final String msg;

  @HiveField(1)
  final MessageType msgType;

  @HiveField(2)
  final String? imagePath;

  @HiveField(3)
  final DateTime timestamp;

  // Constructor
  Message({
    required this.msg,
    required this.msgType,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Getter for image file
  File? get imageFile => imagePath != null ? File(imagePath!) : null;
}

@HiveType(typeId: 3)
enum MessageType {
  @HiveField(0)
  user,
  @HiveField(1)
  bot,
  @HiveField(2)
  userImage,
}
