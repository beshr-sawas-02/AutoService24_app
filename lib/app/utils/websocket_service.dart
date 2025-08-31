import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../data/models/message_model.dart';
import 'storage_service.dart';

class WebSocketService extends GetxService {
  static const String WS_URL = 'ws://192.168.201.167:3005';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 5;
  static const int RECONNECT_DELAY_SECONDS = 3;

  String? _currentUserId;
  List<String> _joinedChatIds = [];

  // إضافة مجموعة لتتبع الرسائل المستلمة لمنع التكرار
  final Set<String> _processedMessageIds = <String>{};

  var isConnected = false.obs;
  var connectionStatus = 'Disconnected'.obs;
  var isTyping = false.obs;
  var otherUserTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('WebSocketService: Initialized');
  }

  Future<void> connect() async {
    if (_isConnected || _isReconnecting) {
      print('WebSocketService: Already connected or reconnecting');
      return;
    }

    try {
      _currentUserId = await StorageService.getUserId();
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print('WebSocketService: No user ID found, cannot connect');
        return;
      }

      print('WebSocketService: Connecting to $WS_URL for user $_currentUserId');
      connectionStatus.value = 'Connecting...';

      _channel = WebSocketChannel.connect(Uri.parse(WS_URL));

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      _isConnected = true;
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      _reconnectAttempts = 0;

      print('WebSocketService: Connected successfully');

      await _authenticate();
      _startHeartbeat();

      if (_joinedChatIds.isNotEmpty) {
        await joinRooms(_joinedChatIds);
      }

    } catch (e) {
      print('WebSocketService: Connection failed: $e');
      _onConnectionFailed();
    }
  }

  void disconnect() {
    print('WebSocketService: Disconnecting...');

    _isConnected = false;
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();

    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    // تنظيف cache الرسائل المعالجة
    _processedMessageIds.clear();

    print('WebSocketService: Disconnected');
  }

  Future<void> _authenticate() async {
    if (!_isConnected || _currentUserId == null) return;

    final authMessage = {
      'type': 'auth',
      'data': {
        'userId': _currentUserId,
      },
    };

    _sendMessage(authMessage);
    print('WebSocketService: Authentication sent for user $_currentUserId');
  }

  Future<void> joinRooms(List<String> chatIds) async {
    if (!_isConnected || chatIds.isEmpty) {
      print('WebSocketService: Cannot join rooms - not connected or empty list');
      return;
    }

    _joinedChatIds = chatIds;

    final joinMessage = {
      'type': 'joinRooms',
      'chatIds': chatIds,
    };

    _sendMessage(joinMessage);
    print('WebSocketService: Joining rooms: $chatIds');
  }

  void sendTypingStatus(String chatId, bool isTyping) {
    if (!_isConnected) {
      print('WebSocketService: Cannot send typing - not connected');
      return;
    }

    final typingMessage = {
      'type': 'typing',
      'chatId': chatId,
      'isTyping': isTyping,
    };

    _sendMessage(typingMessage);
    print('WebSocketService: Sent typing status: $isTyping for chat $chatId');
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel?.sink != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        print('WebSocketService: Failed to send message: $e');
      }
    } else {
      print('WebSocketService: Cannot send message - channel not available or not connected');
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = json.decode(message);
      print('WebSocketService: Received message: ${data['type']}');

      switch (data['type']) {
        case 'auth-confirmation':
          print('WebSocketService: Authentication confirmed for user ${data['userId']}');
          break;

        case 'rooms-joined':
          print('WebSocketService: Successfully joined rooms: ${data['chatIds']}');
          break;

        case 'newMessage':
          _handleNewMessage(data['data']);
          break;

        case 'typing':
          _handleTypingStatus(data['data']);
          break;

        case 'pong':
          print('WebSocketService: Received pong');
          break;

        case 'error':
          print('WebSocketService: Server error: ${data['message']}');
          break;

        case 'server-shutdown':
          print('WebSocketService: Server is shutting down');
          _onDisconnected();
          break;

        default:
          print('WebSocketService: Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('WebSocketService: Error parsing message: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> messageData) {
    try {
      final messageId = messageData['_id'] ?? messageData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      // تحقق من عدم معالجة الرسالة من قبل
      if (_processedMessageIds.contains(messageId)) {
        print('WebSocketService: Duplicate message ignored: $messageId');
        return;
      }

      // إضافة معرف الرسالة للمجموعة
      _processedMessageIds.add(messageId);

      // تنظيف cache الرسائل القديمة (احتفظ بآخر 1000 رسالة)
      if (_processedMessageIds.length > 1000) {
        final toRemove = _processedMessageIds.take(_processedMessageIds.length - 1000);
        _processedMessageIds.removeAll(toRemove);
      }

      print('WebSocketService: Processing new message: ${messageData['content']}');

      final message = MessageModel(
        id: messageId,
        senderId: messageData['senderId']?.toString() ?? '',
        receiverId: messageData['receiverId']?.toString() ?? messageData['reciverId']?.toString() ?? '',
        chatId: messageData['chatId']?.toString() ?? '',
        content: messageData['content']?.toString(),
        image: messageData['image']?.toString(),
        createdAt: messageData['createdAt'] != null ? DateTime.parse(messageData['createdAt']) : DateTime.now(),
        updatedAt: messageData['updatedAt'] != null ? DateTime.parse(messageData['updatedAt']) : DateTime.now(),
      );

      // تحديث ChatController فقط إذا كان متاحًا
      try {
        final chatController = Get.find<ChatController>();

        // التحقق من عدم وجود الرسالة مسبقاً في ChatController أيضاً
        final exists = chatController.messages.any((m) => m.id == message.id);
        if (!exists) {
          chatController.messages.add(message);
          print('WebSocketService: Message added to ChatController');
        } else {
          print('WebSocketService: Message already exists in ChatController');
        }
      } catch (e) {
        print('WebSocketService: ChatController not available: $e');
      }

      // إظهار إشعار إذا كانت الرسالة من مستخدم آخر
      if (message.senderId != _currentUserId) {
        _showNotification(message);
      }

    } catch (e) {
      print('WebSocketService: Error handling new message: $e');
    }
  }

  void _handleTypingStatus(Map<String, dynamic> data) {
    try {
      final userId = data['userId']?.toString() ?? '';
      final chatId = data['chatId']?.toString() ?? '';
      final typing = data['isTyping'] ?? false;

      print('WebSocketService: User $userId is ${typing ? 'typing' : 'stopped typing'} in chat $chatId');

      // تحديث حالة الكتابة إذا كان من مستخدم آخر
      if (userId != _currentUserId) {
        otherUserTyping.value = typing;

        // إيقاف مؤشر الكتابة تلقائياً بعد 5 ثواني
        if (typing) {
          Timer(Duration(seconds: 5), () {
            if (otherUserTyping.value) {
              otherUserTyping.value = false;
            }
          });
        }
      }
    } catch (e) {
      print('WebSocketService: Error handling typing status: $e');
    }
  }

  void _showNotification(MessageModel message) {
    Get.snackbar(
      'رسالة جديدة',
      message.content ?? 'صورة',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _onError(error) {
    print('WebSocketService: Connection error: $error');
    _onConnectionFailed();
  }

  void _onDisconnected() {
    print('WebSocketService: Connection lost');
    _isConnected = false;
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';

    _heartbeatTimer?.cancel();
    _attemptReconnect();
  }

  void _onConnectionFailed() {
    _isConnected = false;
    isConnected.value = false;
    connectionStatus.value = 'Connection Failed';
    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (_isReconnecting || _reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    print('WebSocketService: Attempting reconnect $_reconnectAttempts/$MAX_RECONNECT_ATTEMPTS');
    connectionStatus.value = 'Reconnecting... ($_reconnectAttempts/$MAX_RECONNECT_ATTEMPTS)';

    _reconnectTimer = Timer(Duration(seconds: RECONNECT_DELAY_SECONDS), () {
      _isReconnecting = false;
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        print('WebSocketService: Sending heartbeat ping');
        _sendMessage({'type': 'ping'});
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> setUser(String? userId) async {
    if (_currentUserId != userId) {
      print('WebSocketService: Changing user from $_currentUserId to $userId');
      disconnect();
      _currentUserId = userId;
      _joinedChatIds.clear();

      if (userId != null && userId.isNotEmpty) {
        await Future.delayed(Duration(seconds: 1));
        connect();
      }
    }
  }

  void startTyping(String chatId) {
    if (!isTyping.value) {
      isTyping.value = true;
      sendTypingStatus(chatId, true);
    }
  }

  void stopTyping(String chatId) {
    if (isTyping.value) {
      isTyping.value = false;
      sendTypingStatus(chatId, false);
    }
  }

  @override
  void onClose() {
    print('WebSocketService: Service closing...');
    disconnect();
    super.onClose();
  }
}