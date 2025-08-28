import '../providers/api_provider.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'dart:io';

class ChatRepository {
  final ApiProvider _apiProvider;

  ChatRepository(this._apiProvider);

  // Chat operations
  Future<ChatModel> createChat(Map<String, dynamic> chatData) async {
    try {
      final response = await _apiProvider.createChat(chatData);
      return ChatModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create chat: ${e.toString()}');
    }
  }

  Future<List<ChatModel>> getAllChats() async {
    try {
      final response = await _apiProvider.getChats();
      final List<dynamic> chatList = response.data;
      return chatList.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chats: ${e.toString()}');
    }
  }

  Future<ChatModel> getChatById(String id) async {
    try {
      final response = await _apiProvider.getChat(id);
      return ChatModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get chat: ${e.toString()}');
    }
  }

  Future<void> deleteChat(String id) async {
    try {
      await _apiProvider.deleteChat(id);
    } catch (e) {
      throw Exception('Failed to delete chat: ${e.toString()}');
    }
  }

  // Message operations
  Future<MessageModel> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await _apiProvider.sendMessage(messageData);
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // دالة جديدة لإرسال رسالة مع صورة
  Future<MessageModel> sendMessageWithImage(Map<String, dynamic> messageData, File? imageFile) async {
    try {
      print("ChatRepository: sendMessageWithImage called");

      final response = await _apiProvider.sendMessageWithImage(messageData, imageFile);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data);
      } else {
        throw Exception('Message sending failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print("ChatRepository sendMessageWithImage Error: $e");
      rethrow;
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      final response = await _apiProvider.getChatMessages(chatId);
      final List<dynamic> messageList = response.data;
      return messageList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: ${e.toString()}');
    }
  }

  Future<MessageModel> getMessageById(String id) async {
    try {
      final response = await _apiProvider.getMessage(id);
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get message: ${e.toString()}');
    }
  }

  Future<MessageModel> updateMessage(String id, Map<String, dynamic> messageData) async {
    try {
      final response = await _apiProvider.updateMessage(id, messageData);
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _apiProvider.deleteMessage(id);
    } catch (e) {
      throw Exception('Failed to delete message: ${e.toString()}');
    }
  }

  Future<ChatModel?> findChatBetweenUsers(String user1Id, String user2Id) async {
    try {
      final chats = await getAllChats();
      return chats.firstWhere(
            (chat) =>
        (chat.user1Id.toString() == user1Id && chat.user2Id.toString() == user2Id) ||
            (chat.user1Id.toString() == user2Id && chat.user2Id.toString() == user1Id),
        orElse: () => throw Exception('Chat not found'),
      );
    } catch (e) {
      return null; // Chat doesn't exist
    }
  }
}