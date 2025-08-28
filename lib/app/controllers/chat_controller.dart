import 'package:get/get.dart';
import 'dart:io';
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
      // التحقق من وجود محادثة موجودة أولاً
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

  // إرسال رسالة عادية (نص فقط)
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

  // إرسال رسالة مع صورة - دالة جديدة
  Future<bool> sendMessageWithImage({
    required String chatId,
    required String senderId,
    required String receiverId,
    String? content,
    File? imageFile,
  }) async {
    try {
      print("ChatController: sendMessageWithImage() called");

      final newMessage = await _chatRepository.sendMessageWithImage(
        {
          'chatId': chatId,
          'senderId': int.parse(senderId),
          'receiverId': int.parse(receiverId),
          if (content != null) 'content': content,
        },
        imageFile,
      );

      messages.add(newMessage);
      Helpers.showSuccessSnackbar('Message sent successfully');
      return true;
    } catch (e) {
      print("ChatController: sendMessageWithImage error: $e");
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
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

  String _extractErrorMessage(String error) {
    if (error.contains('Exception:')) {
      return error.split('Exception: ').last;
    } else if (error.contains('Network error')) {
      return 'Network error - Check your internet connection';
    } else if (error.contains('Server error')) {
      return 'Server error - Please try again later';
    } else {
      return 'An error occurred - Please try again';
    }
  }
}