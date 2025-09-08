import 'package:get/get.dart';
import 'dart:io';
import '../config/app_colors.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';
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

  WebSocketService? _webSocketService;
  var isTyping = false.obs;
  var otherUserTyping = false.obs;

  // Enhanced duplicate prevention
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

  Future<void> _initializeWebSocket() async {
    try {
      _webSocketService = Get.find<WebSocketService>();
      await _webSocketService?.connect();

      if (_webSocketService != null) {
        otherUserTyping.bindStream(_webSocketService!.otherUserTyping.stream);
      }
    } catch (e) {}
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
      // Enhanced duplicate prevention for text messages
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
      } else {}

      if (isTyping.value && _webSocketService != null) {
        _webSocketService!.stopTyping(chatId);
      }

      return true;
    } catch (e) {
      String errorMessage = 'Failed to send message';
      if (e.toString().contains('500')) {
        errorMessage = 'Server error - Please check the backend logs';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error - Check your connection';
      }

      Get.snackbar(
        'Send Message Failed',
        errorMessage,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 5),
      );

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
    _webSocketService?.disconnect();
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
        } catch (e) {}
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

      chats.add(newChat);
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
      // Enhanced duplicate prevention for image messages
      if (_isSendingImageMessage) {
        return false;
      }

      final now = DateTime.now();
      final currentImagePath = imageFile?.path;

      // Check for duplicate image based on file path and timing
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
        // Check content match
        bool contentMatch = (m.content == newMessage.content) ||
            (m.content?.isEmpty == true && newMessage.content?.isEmpty == true);

        // Check basic fields
        bool basicMatch =
            m.senderId == newMessage.senderId && m.chatId == newMessage.chatId;

        // Check timing
        bool timeMatch = newMessage.createdAt == null ||
            m.createdAt == null ||
            newMessage.createdAt!.difference(m.createdAt!).inSeconds.abs() < 15;

        return contentMatch && basicMatch && timeMatch;
      });

      if (!exists) {
        messages.add(newMessage);
        Helpers.showSuccessSnackbar('Image sent successfully');
      } else {}

      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
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

  @override
  void onClose() {
    disconnectWebSocket();
    super.onClose();
  }
}
