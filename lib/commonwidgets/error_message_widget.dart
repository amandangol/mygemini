import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorMessageWidget extends StatelessWidget {
  final RxString errorMessage;

  const ErrorMessageWidget({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => errorMessage.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE74C3C)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage.value,
                    style: const TextStyle(color: Color(0xFFE74C3C)),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}
