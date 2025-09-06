import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/app_colors.dart';
import '../../utils/websocket_service.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? chatId;
  late String receiverId;
  late String receiverName;
  late String currentUserId;
  String? serviceId;
  String? serviceTitle;
  bool isNewChat = false;
  bool isCreatingChat = false;

  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

  bool _isSending = false;
  String? _lastMessageContent;
  DateTime? _lastSendTime;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;
    if (arguments == null || arguments is! Map<String, dynamic>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Error',
          'Chat information is missing',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      });
      return;
    }

    chatId = arguments['chatId']?.toString();
    receiverId = arguments['receiverId']?.toString() ?? '';
    receiverName = arguments['receiverName']?.toString() ?? 'Unknown User';
    currentUserId = arguments['currentUserId']?.toString() ??
        authController.currentUser.value?.id ??
        '';

    serviceId = arguments['serviceId']?.toString();
    serviceTitle = arguments['serviceTitle']?.toString();

    if (receiverId.isEmpty || currentUserId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Error',
          'Invalid chat information. Missing required data.',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      });
      return;
    }

    if (chatId == null || chatId!.isEmpty) {
      isNewChat = true;
      _handleNewChat();
    } else {
      isNewChat = false;

      chatController.loadMessages(chatId!);
    }
  }

  Future<void> _handleNewChat() async {
    try {
      setState(() {
        isCreatingChat = true;
      });

      final existingChat =
          await chatController.createChat(currentUserId, receiverId);

      if (existingChat != null) {
        chatId = existingChat.id;
        isNewChat = false;

        await chatController.loadMessages(chatId!);
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to create chat',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to create chat: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    } finally {
      setState(() {
        isCreatingChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCreatingChat) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text('Starting Chat...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Creating chat with $receiverName...',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.whiteWithOpacity(0.2),
              radius: 20,
              child: Text(
                receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receiverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (serviceTitle != null)
                    Text(
                      'About: $serviceTitle',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.whiteWithOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Obx(() {
                      final webSocketService = Get.find<WebSocketService>();
                      return Text(
                        webSocketService.isConnected.value
                            ? 'Online'
                            : 'Offline',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.whiteWithOpacity(0.7)),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              Get.snackbar(
                'Feature Coming Soon',
                'Voice call feature will be available soon',
                backgroundColor: AppColors.primaryWithOpacity(0.1),
                colorText: AppColors.primary,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              switch (result) {
                case 'view_service':
                  if (serviceId != null) {
                    Get.snackbar('Info', 'Service: $serviceTitle');
                  }
                  break;
                case 'block_user':
                  _showBlockUserDialog();
                  break;
                case 'report':
                  _showReportDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (serviceTitle != null)
                const PopupMenuItem<String>(
                  value: 'view_service',
                  child: Row(
                    children: [
                      Icon(Icons.build, size: 20),
                      SizedBox(width: 8),
                      Text('View Service'),
                    ],
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'block_user',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 20),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Service info banner (if available)
          if (serviceTitle != null) _buildServiceBanner(),

          Expanded(
            child: Obx(() {
              if (chatController.isLoadingMessages.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (chatController.messages.isEmpty) {
                return _buildEmptyMessages();
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController
                      .messages[chatController.messages.length - 1 - index];
                  final isMe = message.senderId.toString() == currentUserId;

                  return _buildMessageBubble(message, isMe);
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildServiceBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryWithOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryWithOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.build_circle,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discussing: $serviceTitle',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Start the conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceTitle != null
                ? 'Ask about "$serviceTitle"'
                : 'Send a message to begin chatting',
            style: const TextStyle(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.grey200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasContent)
              Text(
                message.content!,
                style: TextStyle(
                  color: isMe ? AppColors.white : AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            if (message.hasImage) ...[
              if (message.hasContent) const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.image!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: AppColors.grey300,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: AppColors.textSecondary),
                            Text('Failed to load image',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe
                    ? AppColors.whiteWithOpacity(0.7)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() {
            if (chatController.otherUserTyping.value) {
              return Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$receiverName is typing',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            final webSocketService = Get.find<WebSocketService>();
            if (!webSocketService.isConnected.value) {
              return Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 12,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            webSocketService.connectionStatus.value,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file,
                    color: AppColors.textSecondary),
                onPressed: () {
                  Get.snackbar(
                    'Feature Coming Soon',
                    'File attachment will be available soon',
                    backgroundColor: AppColors.primaryWithOpacity(0.1),
                    colorText: AppColors.primary,
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.grey100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: _onTextChanged,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTextChanged(String text) {
    if (chatId == null) return;

    if (text.isNotEmpty && !_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      chatController.startTyping(chatId!);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isCurrentlyTyping) {
        _isCurrentlyTyping = false;
        chatController.stopTyping(chatId!);
      }
    });

    if (text.isEmpty && _isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      chatController.stopTyping(chatId!);
      _typingTimer?.cancel();
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (_isSending) {
      return;
    }

    final now = DateTime.now();
    if (_lastMessageContent == content &&
        _lastSendTime != null &&
        now.difference(_lastSendTime!).inMilliseconds < 1000) {
      return;
    }

    _isSending = true;
    _lastMessageContent = content;
    _lastSendTime = now;

    try {
      _messageController.clear();

      if (isNewChat && (chatId == null || chatId!.isEmpty)) {
        await _createChatAndSendMessage(content);
        return;
      }

      final success = await chatController.sendMessage(
        chatId: chatId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );

      if (success) {
        _scrollToBottom();
      } else {
        _messageController.text = content;
      }
    } catch (e) {
      _messageController.text = content;
    } finally {
      Future.delayed(const Duration(milliseconds: 800), () {
        _isSending = false;
      });
    }
  }

  Future<void> _createChatAndSendMessage(String content) async {
    try {
      final newChat =
          await chatController.createChat(currentUserId, receiverId);

      if (newChat != null) {
        chatId = newChat.id;
        isNewChat = false;

        final success = await chatController.sendMessage(
          chatId: chatId!,
          senderId: currentUserId,
          receiverId: receiverId,
          content: content,
        );

        if (success) {
          _scrollToBottom();
        } else {
          _messageController.text = content;
        }
      } else {
        _messageController.text = content;
        Get.snackbar(
          'Error',
          'Failed to create chat',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      _messageController.text = content;
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showBlockUserDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Block User'),
        content: Text('Are you sure you want to block $receiverName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'User blocking feature coming soon');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Report User'),
        content: Text('Report $receiverName for inappropriate behavior?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'User reporting feature coming soon');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();

    if (_isCurrentlyTyping && chatId != null) {
      chatController.stopTyping(chatId!);
    }

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
