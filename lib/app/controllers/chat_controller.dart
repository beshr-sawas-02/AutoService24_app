import 'package:get/get.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository;

  ChatController(this._chatRepository);

  var isLoading = false.obs;
  var chats = <ChatModel>[].obs;
  var messages = <MessageModel>[].obs;
  var isLoadingMessages = false.obs;

  Future<void> loadChats() async {
    try {
      isLoading.value = true;

      final chatList = await _chatRepository.getAllChats();
      chats.value = chatList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      isLoadingMessages.value = true;

      final messageList = await _chatRepository.getChatMessages(chatId);
      messages.value = messageList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<ChatModel?> createChat(String user1Id, String user2Id) async {
    try {
      // First check if chat already exists
      final existingChat = await _chatRepository.findChatBetweenUsers(user1Id, user2Id);
      if (existingChat != null) {
        return existingChat;
      }

      final newChat = await _chatRepository.createChat({
        'user1Id': int.parse(user1Id),
        'user2Id': int.parse(user2Id),
      });

      chats.add(newChat);
      return newChat;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    }
  }

  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    String? content,
    String? image,
  }) async {
    try {
      final newMessage = await _chatRepository.sendMessage({
        'chatId': chatId,
        'senderId': int.parse(senderId),
        'receiverId': int.parse(receiverId),
        if (content != null) 'content': content,
        if (image != null) 'image': image,
      });

      messages.add(newMessage);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId);

      messages.removeWhere((message) => message.id == messageId);
      Helpers.showSuccessSnackbar('Message deleted');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> deleteChat(String chatId) async {
    try {
      await _chatRepository.deleteChat(chatId);

      chats.removeWhere((chat) => chat.id == chatId);
      Helpers.showSuccessSnackbar('Chat deleted');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> updateMessage(String messageId, Map<String, dynamic> data) async {
    try {
      final updatedMessage = await _chatRepository.updateMessage(messageId, data);

      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = updatedMessage;
      }

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }
}