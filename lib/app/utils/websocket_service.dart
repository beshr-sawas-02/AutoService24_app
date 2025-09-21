import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../data/models/message_model.dart';
import 'constants.dart';
import 'storage_service.dart';

class WebSocketService extends GetxService {
  static const String WS_URL = AppConstants.wsUrl;

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

  final Set<String> _processedMessageIds = <String>{};

  var isConnected = false.obs;
  var connectionStatus = 'Disconnected'.obs;
  var isTyping = false.obs;
  var otherUserTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> connect() async {
    if (_isConnected || _isReconnecting) {
      return;
    }

    try {
      _currentUserId = await StorageService.getUserId();
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        return;
      }

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

      await _authenticate();
      _startHeartbeat();

      if (_joinedChatIds.isNotEmpty) {
        await joinRooms(_joinedChatIds);
      }
    } catch (e) {
      _onConnectionFailed();
    }
  }

  void disconnect() {
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

    _processedMessageIds.clear();
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
  }

  Future<void> joinRooms(List<String> chatIds) async {
    if (!_isConnected || chatIds.isEmpty) {
      return;
    }

    _joinedChatIds = chatIds;

    final joinMessage = {
      'type': 'joinRooms',
      'chatIds': chatIds,
    };

    _sendMessage(joinMessage);
  }

  void sendTypingStatus(String chatId, bool isTyping) {
    if (!_isConnected) {
      return;
    }

    final typingMessage = {
      'type': 'typing',
      'chatId': chatId,
      'isTyping': isTyping,
    };

    _sendMessage(typingMessage);
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel?.sink != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {}
    } else {}
  }

  void _onMessage(dynamic message) {
    try {
      final data = json.decode(message);

      switch (data['type']) {
        case 'auth-confirmation':
          break;

        case 'rooms-joined':
          break;

        case 'newMessage':
          _handleNewMessage(data['data']);
          break;

        case 'typing':
          _handleTypingStatus(data['data']);
          break;

        case 'pong':
          break;

        case 'error':
          break;

        case 'server-shutdown':
          _onDisconnected();
          break;

        default:
      }
    } catch (e) {}
  }

  void _handleNewMessage(Map<String, dynamic> messageData) {
    try {
      final messageId = messageData['_id'] ??
          messageData['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      if (_processedMessageIds.contains(messageId)) {
        return;
      }

      _processedMessageIds.add(messageId);

      if (_processedMessageIds.length > 1000) {
        final toRemove =
            _processedMessageIds.take(_processedMessageIds.length - 1000);
        _processedMessageIds.removeAll(toRemove);
      }

      final message = MessageModel(
        id: messageId,
        senderId: messageData['senderId']?.toString() ?? '',
        receiverId: messageData['receiverId']?.toString() ??
            messageData['reciverId']?.toString() ??
            '',
        chatId: messageData['chatId']?.toString() ?? '',
        content: messageData['content']?.toString(),
        image: messageData['image']?.toString(),
        createdAt: messageData['createdAt'] != null
            ? DateTime.parse(messageData['createdAt'])
            : DateTime.now(),
        updatedAt: messageData['updatedAt'] != null
            ? DateTime.parse(messageData['updatedAt'])
            : DateTime.now(),
      );

      try {
        final chatController = Get.find<ChatController>();

        final exists = chatController.messages.any((m) => m.id == message.id);
        if (!exists) {
          chatController.messages.add(message);
        } else {}
      } catch (e) {}

      if (message.senderId != _currentUserId) {
        _showNotification(message);
      }
    } catch (e) {}
  }

  void _handleTypingStatus(Map<String, dynamic> data) {
    try {
      final userId = data['userId']?.toString() ?? '';
      final chatId = data['chatId']?.toString() ?? '';
      final typing = data['isTyping'] ?? false;

      if (userId != _currentUserId) {
        otherUserTyping.value = typing;

        if (typing) {
          Timer(const Duration(seconds: 5), () {
            if (otherUserTyping.value) {
              otherUserTyping.value = false;
            }
          });
        }
      }
    } catch (e) {}
  }

  void _showNotification(MessageModel message) {
    Get.snackbar(
      'رسالة جديدة',
      message.content ?? 'صورة',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _onError(error) {
    _onConnectionFailed();
  }

  void _onDisconnected() {
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

    connectionStatus.value =
        'Reconnecting... ($_reconnectAttempts/$MAX_RECONNECT_ATTEMPTS)';

    _reconnectTimer =
        Timer(const Duration(seconds: RECONNECT_DELAY_SECONDS), () {
      _isReconnecting = false;
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _sendMessage({'type': 'ping'});
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> setUser(String? userId) async {
    if (_currentUserId != userId) {
      disconnect();
      _currentUserId = userId;
      _joinedChatIds.clear();

      if (userId != null && userId.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 1));
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
    disconnect();
    super.onClose();
  }
}
