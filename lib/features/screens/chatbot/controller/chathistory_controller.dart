import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mygemini/data/models/chathistory.dart';

class ChatHistoryController extends GetxController {
  final RxList<ChatHistory> chatHistories = <ChatHistory>[].obs;
  late Box<ChatHistory> _chatHistoryBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _chatHistoryBox = await Hive.openBox<ChatHistory>('chatHistory');
      loadChatHistories();
    } catch (e) {
      print('Error initializing Hive: $e');
      Get.snackbar('Error', 'Failed to initialize chat history');
    }
  }

  void loadChatHistories() {
    try {
      if (_chatHistoryBox.isNotEmpty) {
        chatHistories.clear();
        chatHistories.addAll(_chatHistoryBox.values);
        _sortChatHistories();
      }
    } catch (e) {
      print('Error loading chat histories: $e');
      Get.snackbar('Error', 'Failed to load chat histories');
    }
  }

  Future<void> saveChatHistory(ChatHistory chatHistory) async {
    try {
      int existingIndex =
          chatHistories.indexWhere((ch) => ch.title == chatHistory.title);

      if (existingIndex != -1) {
        chatHistories[existingIndex] = chatHistory;
      } else {
        chatHistories.insert(0, chatHistory);
      }

      await _chatHistoryBox.put(chatHistory.title, chatHistory);
      _sortChatHistories();
    } catch (e) {
      print('Error saving chat history: $e');
      Get.snackbar('Error', 'Failed to save chat history');
    }
  }

  void _sortChatHistories() {
    chatHistories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteChatHistory(int index) async {
    try {
      if (index >= 0 && index < chatHistories.length) {
        String titleToDelete = chatHistories[index].title;
        chatHistories.removeAt(index);
        await _chatHistoryBox.delete(titleToDelete);
      } else {
        throw RangeError('Invalid index for chat history deletion');
      }
    } catch (e) {
      print('Error deleting chat history: $e');
      Get.snackbar('Error', 'Failed to delete chat history');
    }
  }

  @override
  void onClose() {
    _chatHistoryBox.close();
    super.onClose();
  }
}
