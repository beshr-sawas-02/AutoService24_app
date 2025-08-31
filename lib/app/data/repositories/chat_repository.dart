import 'package:dio/dio.dart';
import 'dart:convert'; // إضافة جديدة
import '../providers/api_provider.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'dart:io';

class ChatRepository {
  final ApiProvider _apiProvider;

  ChatRepository(this._apiProvider);

  // User operations - إضافة جديدة
  Future<UserModel?> getUserById(String userId) async {
    try {
      print('ChatRepository: Getting user by ID: $userId');
      final response = await _apiProvider.getUserById(userId);
      if (response.statusCode == 200) {
        print('ChatRepository: User $userId fetched successfully');
        return UserModel.fromJson(response.data);
      } else {
        print('ChatRepository: Failed to get user $userId, status: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatRepository: Error fetching user $userId: $e');
    }
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
      print('ChatRepository: Getting all chats');
      final response = await _apiProvider.getChats();
      final List<dynamic> chatList = response.data;

      print('ChatRepository: Received ${chatList.length} chats from server');

      List<ChatModel> chats = [];
      for (var chatJson in chatList) {
        try {
          final chat = ChatModel.fromJson(chatJson);
          chats.add(chat);
          print('ChatRepository: Successfully parsed chat ${chat.id}');
        } catch (e) {
          print('ChatRepository: Error parsing chat: $chatJson');
          print('ChatRepository: Parse error: $e');
        }
      }

      print('ChatRepository: Successfully parsed ${chats.length} chats');
      return chats;
    } catch (e) {
      print('ChatRepository: Error getting chats: $e');
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

  // Message operations - معدل بالكامل
  Future<MessageModel> sendMessage(Map<String, dynamic> messageData) async {
    try {
      print('ChatRepository: Sending message with data: $messageData');

      final response = await _apiProvider.sendMessage(messageData);

      print('ChatRepository: Send message response status: ${response.statusCode}');
      print('ChatRepository: Send message response data: ${response.data}');

      // التحقق من نوع البيانات المُرجعة
      dynamic responseData = response.data;

      // إذا كان الـ response فارغ أو null، أنشئ MessageModel من البيانات المُرسلة
      if (responseData == null || responseData.toString().trim().isEmpty) {
        print('ChatRepository: Empty response, creating message from sent data');

        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // ID مؤقت
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
          print('ChatRepository: Failed to parse JSON string: $e');
          // إذا فشل parsing، أنشئ MessageModel من البيانات المُرسلة
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
        // إذا كان النوع غير متوقع، أنشئ MessageModel من البيانات المُرسلة
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
      print('ChatRepository: Error sending message: $e');

      if (e is DioException) {
        print('ChatRepository: DioException details:');
        print('  - Status code: ${e.response?.statusCode}');
        print('  - Response data: ${e.response?.data}');
        print('  - Request data: ${e.requestOptions.data}');
        print('  - Request path: ${e.requestOptions.path}');
      }

      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // دالة جديدة لإرسال رسالة مع صورة
  Future<MessageModel> sendMessageWithImage(Map<String, dynamic> messageData, File? imageFile) async {
    try {
      print("ChatRepository: sendMessageWithImage called");

      final response = await _apiProvider.sendMessageWithImage(messageData, imageFile);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // نفس منطق sendMessage للتعامل مع response
        dynamic responseData = response.data;

        if (responseData == null || responseData.toString().trim().isEmpty) {
          return MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: messageData['senderId'].toString(),
            receiverId: messageData['receiverId'].toString(),
            chatId: messageData['chatId'].toString(),
            content: messageData['content']?.toString(),
            image: 'uploaded_image', // سنضع placeholder للصورة
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
      print("ChatRepository sendMessageWithImage Error: $e");
      rethrow;
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      print('ChatRepository: Getting messages for chat: $chatId');
      final response = await _apiProvider.getChatMessages(chatId);
      final List<dynamic> messageList = response.data;

      print('ChatRepository: Received ${messageList.length} messages');

      List<MessageModel> messages = [];
      for (var messageJson in messageList) {
        try {
          final message = MessageModel.fromJson(messageJson);
          messages.add(message);
        } catch (e) {
          print('ChatRepository: Error parsing message: $messageJson');
          print('ChatRepository: Parse error: $e');
        }
      }

      print('ChatRepository: Successfully parsed ${messages.length} messages');
      return messages;
    } catch (e) {
      print('ChatRepository: Error getting messages: $e');
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