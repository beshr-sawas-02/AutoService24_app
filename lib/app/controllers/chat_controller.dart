import 'package:get/get.dart';
import 'dart:io';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../utils/error_handler.dart';
import '../utils/websocket_service.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository;

  ChatController(this._chatRepository);

  var isLoading = false.obs;
  var chats = <ChatModel>[].obs;
  var messages = <MessageModel>[].obs;
  var isLoadingMessages = false.obs;
  var usersCache = <String, UserModel>{}.obs;
  var isLoadingUsers = false.obs;
  var unreadChats = <String>[].obs;

  WebSocketService? _webSocketService;
  var isTyping = false.obs;
  var otherUserTyping = false.obs;
  var lastMessages = <String, MessageModel>{}.obs; // chatId -> lastMessage

  bool _isSendingMessage = false;
  bool _isSendingImageMessage = false;
  String? _lastSentContent;
  String? _lastSentImagePath;
  DateTime? _lastSentTime;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
  }

  // Public method to sort chats by last message time
  void sortChatsByLastMessage() {
    chats.sort((a, b) {
      final messageA = lastMessages[a.id];
      final messageB = lastMessages[b.id];

      if (messageA == null && messageB == null) return 0;
      if (messageA == null) return 1;
      if (messageB == null) return -1;

      final timeA = messageA.createdAt ?? DateTime(2000);
      final timeB = messageB.createdAt ?? DateTime(2000);

      return timeB.compareTo(timeA); // Descending order (newest first)
    });
    chats.refresh(); // Trigger UI update
  }

  Future<void> _initializeWebSocket() async {
    try {
      _webSocketService = Get.find<WebSocketService>();
      await _webSocketService?.connect();

      if (_webSocketService != null) {
        otherUserTyping.bindStream(_webSocketService!.otherUserTyping.stream);
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;

      final chatList = await _chatRepository.getAllChats();
      chats.value = chatList;

      final chatIds = chatList.map((chat) => chat.id).toList();
      if (chatIds.isNotEmpty && _webSocketService != null) {
        await _webSocketService!.joinRooms(chatIds);
      }

      for (var chat in chatList) {
        final allMessages = await _chatRepository.getChatMessages(chat.id);
        if (allMessages.isNotEmpty) {
          lastMessages[chat.id] = allMessages.last;
        }
      }

      // Sort chats after loading last messages
      sortChatsByLastMessage();

      _loadUsersInBackground(chatList);
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

      if (_webSocketService != null) {
        await _webSocketService!.joinRooms([chatId]);
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoadingMessages.value = false;
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
      if (_isSendingMessage) {
        return false;
      }

      final now = DateTime.now();
      if (_lastSentContent == content &&
          _lastSentTime != null &&
          now.difference(_lastSentTime!).inMilliseconds < 2000) {
        return false;
      }

      _isSendingMessage = true;
      _lastSentContent = content;
      _lastSentTime = now;

      if (chatId.isEmpty || senderId.isEmpty || receiverId.isEmpty) {
        throw Exception('Missing required fields for sending message');
      }

      if (content == null || content.trim().isEmpty) {
        throw Exception('Message content cannot be empty');
      }

      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content.trim(),
      };

      if (image != null && image.isNotEmpty) {
        messageData['image'] = image;
      }

      final newMessage = await _chatRepository.sendMessage(messageData);

      // Enhanced duplicate detection
      final exists = messages.any((m) =>
          m.content == newMessage.content &&
          m.senderId == newMessage.senderId &&
          m.chatId == newMessage.chatId &&
          (newMessage.createdAt == null ||
              m.createdAt == null ||
              newMessage.createdAt!.difference(m.createdAt!).inSeconds.abs() <
                  10));

      if (!exists) {
        messages.add(newMessage);
        // Update last message immediately for chat list
        lastMessages[chatId] = newMessage;
        // Sort chats to move this chat to the top
        sortChatsByLastMessage();
      }

      if (isTyping.value && _webSocketService != null) {
        _webSocketService!.stopTyping(chatId);
      }

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _isSendingMessage = false;
      });
    }
  }

  void startTyping(String chatId) {
    if (_webSocketService != null && !isTyping.value) {
      isTyping.value = true;
      _webSocketService!.startTyping(chatId);
    }
  }

  void stopTyping(String chatId) {
    if (_webSocketService != null && isTyping.value) {
      isTyping.value = false;
      _webSocketService!.stopTyping(chatId);
    }
  }

  Future<void> updateWebSocketUser(String? userId) async {
    if (_webSocketService != null) {
      await _webSocketService!.setUser(userId);
    }
  }

  void disconnectWebSocket() {
    try {
      _webSocketService?.disconnect();
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      if (userId.isEmpty || userId == '0' || userId == 'null') {
        return null;
      }

      if (usersCache.containsKey(userId)) {
        return usersCache[userId];
      }

      final user = await _chatRepository.getUserById(userId);
      if (user != null) {
        usersCache[userId] = user;
      }
      return user;
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
      return null;
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.username ?? 'User $userId';
    } catch (e) {
      return 'User $userId';
    }
  }

  UserModel? getOtherUserInChat(ChatModel chat, String currentUserId) {
    final isCurrentUserUser1 = chat.user1Id == currentUserId;
    final otherUserId = isCurrentUserUser1 ? chat.user2Id : chat.user1Id;
    return usersCache[otherUserId];
  }

  String getOtherUserNameInChat(ChatModel chat, String currentUserId) {
    final otherUser = getOtherUserInChat(chat, currentUserId);
    if (otherUser != null) {
      return otherUser.username;
    }

    final isCurrentUserUser1 = chat.user1Id == currentUserId;
    final otherUserId = isCurrentUserUser1 ? chat.user2Id : chat.user1Id;
    return 'User $otherUserId';
  }

  void _loadUsersInBackground(List<ChatModel> chatList) async {
    if (isLoadingUsers.value) return;

    try {
      isLoadingUsers.value = true;

      Set<String> userIdsToLoad = {};

      for (var chat in chatList) {
        String user1Id = chat.user1Id;
        String user2Id = chat.user2Id;

        if (user1Id.isNotEmpty &&
            user1Id != '0' &&
            !usersCache.containsKey(user1Id)) {
          userIdsToLoad.add(user1Id);
        }
        if (user2Id.isNotEmpty &&
            user2Id != '0' &&
            !usersCache.containsKey(user2Id)) {
          userIdsToLoad.add(user2Id);
        }
      }

      for (String userId in userIdsToLoad) {
        try {
          await getUserById(userId);
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          ErrorHandler.handleAndShowError(e, silent: true);
        }
      }
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<ChatModel?> createChat(String user1Id, String user2Id) async {
    try {
      final existingChat =
          await _chatRepository.findChatBetweenUsers(user1Id, user2Id);
      if (existingChat != null) {
        return existingChat;
      }

      final newChat = await _chatRepository.createChat({
        'user1Id': user1Id,
        'user2Id': user2Id,
      });

      chats.insert(0, newChat);
      // Sort will happen automatically when first message is sent
      return newChat;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    }
  }

  Future<bool> sendMessageWithImage({
    required String chatId,
    required String senderId,
    required String receiverId,
    String? content,
    File? imageFile,
  }) async {
    try {
      if (_isSendingImageMessage) {
        return false;
      }

      final now = DateTime.now();
      final currentImagePath = imageFile?.path;

      if (currentImagePath != null &&
          _lastSentImagePath == currentImagePath &&
          _lastSentTime != null &&
          now.difference(_lastSentTime!).inMilliseconds < 5000) {
        return false;
      }

      _isSendingImageMessage = true;
      _lastSentImagePath = currentImagePath;
      _lastSentTime = now;

      final newMessage = await _chatRepository.sendMessageWithImage(
        {
          'chatId': chatId,
          'senderId': senderId,
          'receiverId': receiverId,
          if (content != null) 'content': content,
        },
        imageFile,
      );

      // Enhanced duplicate detection for image messages
      final exists = messages.any((m) {
        bool contentMatch = (m.content == newMessage.content) ||
            (m.content?.isEmpty == true && newMessage.content?.isEmpty == true);

        bool basicMatch =
            m.senderId == newMessage.senderId && m.chatId == newMessage.chatId;

        bool timeMatch = newMessage.createdAt == null ||
            m.createdAt == null ||
            newMessage.createdAt!.difference(m.createdAt!).inSeconds.abs() < 15;

        return contentMatch && basicMatch && timeMatch;
      });

      if (!exists) {
        messages.add(newMessage);
        // Update last message immediately for chat list
        lastMessages[chatId] = newMessage;
        // Sort chats to move this chat to the top
        sortChatsByLastMessage();
      }

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _isSendingImageMessage = false;
      });
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId);
      messages.removeWhere((message) => message.id == messageId);
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
      unreadChats.remove(chatId);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> updateMessage(
      String messageId, Map<String, dynamic> data) async {
    try {
      final updatedMessage =
          await _chatRepository.updateMessage(messageId, data);

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

  @override
  void onClose() {
    try {
      disconnectWebSocket();
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
    super.onClose();
  }
}
