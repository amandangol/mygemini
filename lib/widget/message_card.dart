import 'package:ai_assistant/controllers/chat_controller.dart';
import 'package:ai_assistant/utils/helper/global.dart';
import 'package:ai_assistant/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(15);
    final chatController = Get.find<ChatController>();

    return message.msgType == MessageType.bot

        // bot
        ? Row(
            children: [
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: mq.width * .6,
                ),
                margin: EdgeInsets.only(
                    bottom: mq.height * .02, left: mq.width * .02),
                padding: EdgeInsets.symmetric(
                    vertical: mq.height * .01, horizontal: mq.width * .02),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: const BorderRadius.only(
                        topLeft: r, topRight: r, bottomRight: r)),
                child: Text(message.msg),
              )
            ],
          )

        // user
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: mq.width * .6,
                ),
                margin: EdgeInsets.only(
                    bottom: mq.height * .02, right: mq.width * .02),
                padding: EdgeInsets.symmetric(
                    vertical: mq.height * .01, horizontal: mq.width * .02),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: const BorderRadius.only(
                        topLeft: r, topRight: r, bottomLeft: r)),
                child: Text(message.msg),
              ),
              Column(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                    ),
                  ),
                  Obx(() {
                    return chatController.userName.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              chatController.userName.value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )
                        : const SizedBox.shrink();
                  })
                ],
              ),
              const SizedBox(width: 6),
            ],
          );
  }
}
