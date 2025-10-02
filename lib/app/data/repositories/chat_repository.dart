import 'package:dio/dio.dart';
import 'dart:convert';
import '../providers/api_provider.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'dart:io';

class ChatRepository {
  final ApiProvider _apiProvider;

  ChatRepository(this._apiProvider);


  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _apiProvider.getUserById(userId);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
      }
    } catch (e) {}
    return null;
  }

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


      List<ChatModel> chats = [];
      for (var chatJson in chatList) {
        try {
          final chat = ChatModel.fromJson(chatJson);
          chats.add(chat);
        } catch (e) {}
      }

      return chats;
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


  Future<MessageModel> sendMessage(Map<String, dynamic> messageData) async {
    try {

      final response = await _apiProvider.sendMessage(messageData);



      dynamic responseData = response.data;


      if (responseData == null || responseData.toString().trim().isEmpty) {

        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: messageData['senderId'].toString(),
          receiverId: messageData['receiverId'].toString(),
          chatId: messageData['chatId'].toString(),
          content: messageData['content']?.toString(),
          image: messageData['image']?.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      if (responseData is String) {
        try {
          responseData = json.decode(responseData);
        } catch (e) {

          return MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: messageData['senderId'].toString(),
            receiverId: messageData['receiverId'].toString(),
            chatId: messageData['chatId'].toString(),
            content: messageData['content']?.toString(),
            image: messageData['image']?.toString(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return MessageModel.fromJson(responseData['data']);
        } else {
          return MessageModel.fromJson(responseData);
        }
      } else {

        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: messageData['senderId'].toString(),
          receiverId: messageData['receiverId'].toString(),
          chatId: messageData['chatId'].toString(),
          content: messageData['content']?.toString(),
          image: messageData['image']?.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

    } catch (e) {

      if (e is DioException) {
      }

      throw Exception('Failed to send message: ${e.toString()}');
    }
  }


  Future<MessageModel> sendMessageWithImage(Map<String, dynamic> messageData, File? imageFile) async {
    try {

      final response = await _apiProvider.sendMessageWithImage(messageData, imageFile);

      if (response.statusCode == 200 || response.statusCode == 201) {

        dynamic responseData = response.data;

        if (responseData == null || responseData.toString().trim().isEmpty) {
          return MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: messageData['senderId'].toString(),
            receiverId: messageData['receiverId'].toString(),
            chatId: messageData['chatId'].toString(),
            content: messageData['content']?.toString(),
            image: 'uploaded_image',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        if (responseData is String) {
          try {
            responseData = json.decode(responseData);
          } catch (e) {
            return MessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: messageData['senderId'].toString(),
              receiverId: messageData['receiverId'].toString(),
              chatId: messageData['chatId'].toString(),
              content: messageData['content']?.toString(),
              image: 'uploaded_image',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return MessageModel.fromJson(responseData['data']);
          } else {
            return MessageModel.fromJson(responseData);
          }
        }

        return MessageModel.fromJson(response.data);
      } else {
        throw Exception('Message sending failed with status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      final response = await _apiProvider.getChatMessages(chatId);
      final List<dynamic> messageList = response.data;


      List<MessageModel> messages = [];
      for (var messageJson in messageList) {
        try {
          final message = MessageModel.fromJson(messageJson);
          messages.add(message);
        } catch (e) {
        }
      }

      return messages;
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
        (chat.user1Id == user1Id && chat.user2Id == user2Id) ||
            (chat.user1Id == user2Id && chat.user2Id == user1Id),
        orElse: () => throw Exception('Chat not found'),
      );
    } catch (e) {
      return null; // Chat doesn't exist
    }
  }
}