import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class CustomInputWidget extends StatelessWidget {
  final TextEditingController userInputController;
  final RxBool isLoading;
  final Function sendMessage;
  final String? hintText;

  const CustomInputWidget({
    Key? key,
    required this.userInputController,
    required this.isLoading,
    required this.sendMessage,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: userInputController,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                fillColor: AppTheme.primaryColorLight(context),
                filled: true,
                hintText: 'Ask EmailBot to generate an email',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => _buildSendButton(context)),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading.value ? null : () => sendMessage(),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.send, size: 24),
    );
  }
}
