import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/app_colors.dart';
import '../../utils/websocket_service.dart';

class ChatView extends StatefulWidget {
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

  // متغيرات WebSocket جديدة
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

  bool _isSending = false;
  String? _lastMessageContent;
  DateTime? _lastSendTime;

  @override
  void initState() {
    super.initState();

    // التحقق من وجود arguments
    final arguments = Get.arguments;
    if (arguments == null || arguments is! Map<String, dynamic>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Error',
          'Chat information is missing',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      });
      return;
    }

    // استخراج البيانات من arguments
    chatId = arguments['chatId']?.toString();
    receiverId = arguments['receiverId']?.toString() ?? '';
    receiverName = arguments['receiverName']?.toString() ?? 'Unknown User';
    currentUserId = arguments['currentUserId']?.toString() ??
        authController.currentUser.value?.id ?? '';

    // البيانات الاختيارية للخدمة
    serviceId = arguments['serviceId']?.toString();
    serviceTitle = arguments['serviceTitle']?.toString();

    print('ChatView initialized with:');
    print('ChatID: $chatId');
    print('ReceiverID: $receiverId');
    print('ReceiverName: $receiverName');
    print('CurrentUserID: $currentUserId');
    print('ServiceID: $serviceId');
    print('ServiceTitle: $serviceTitle');

    // التحقق من صحة البيانات الأساسية
    if (receiverId.isEmpty || currentUserId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Error',
          'Invalid chat information. Missing required data.',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      });
      return;
    }

    // تحديد ما إذا كانت محادثة جديدة أم موجودة
    if (chatId == null || chatId!.isEmpty) {
      isNewChat = true;
      _handleNewChat();
    } else {
      isNewChat = false;
      // تحميل الرسائل للمحادثة الموجودة
      chatController.loadMessages(chatId!);
    }
  }

  Future<void> _handleNewChat() async {
    try {
      setState(() {
        isCreatingChat = true;
      });

      print('Creating new chat between $currentUserId and $receiverId');

      // البحث عن محادثة موجودة أولاً
      final existingChat = await chatController.createChat(currentUserId, receiverId);

      if (existingChat != null) {
        chatId = existingChat.id;
        isNewChat = false;
        print('Found existing chat: $chatId');

        // تحميل الرسائل
        await chatController.loadMessages(chatId!);
      } else {
        print('Failed to create/find chat');
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to create chat',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      print('Error handling new chat: $e');
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to create chat: $e',
        backgroundColor: AppColors.error.withOpacity(0.1),
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
    // إظهار loading إذا كانت المحادثة قيد الإنشاء
    if (isCreatingChat) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: Text('Starting Chat...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Creating chat with $receiverName...',
                style: TextStyle(
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
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receiverName,
                    style: TextStyle(
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
                  // إظهار حالة الاتصال
                    Obx(() {
                      final webSocketService = Get.find<WebSocketService>();
                      return Text(
                        webSocketService.isConnected.value ? 'Online' : 'Offline',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.whiteWithOpacity(0.7)
                        ),
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
            icon: Icon(Icons.phone),
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
            icon: Icon(Icons.more_vert),
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
                PopupMenuItem<String>(
                  value: 'view_service',
                  child: Row(
                    children: [
                      Icon(Icons.build, size: 20),
                      SizedBox(width: 8),
                      Text('View Service'),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'block_user',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
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
                return Center(
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
                padding: EdgeInsets.all(16),
                reverse: true,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[chatController.messages.length - 1 - index];
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
      padding: EdgeInsets.all(12),
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
          Icon(
            Icons.build_circle,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discussing: $serviceTitle',
              style: TextStyle(
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
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            serviceTitle != null
                ? 'Ask about "$serviceTitle"'
                : 'Send a message to begin chatting',
            style: TextStyle(
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.grey200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: isMe ? Radius.circular(18) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(18),
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
              if (message.hasContent) SizedBox(height: 8),
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: AppColors.textSecondary),
                            Text('Failed to load image', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? AppColors.whiteWithOpacity(0.7) : AppColors.textSecondary,
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // مؤشر "يكتب الآن" - إضافة جديدة
          Obx(() {
            if (chatController.otherUserTyping.value) {
              return Container(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$receiverName is typing',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(width: 6),
                          SizedBox(
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
            return SizedBox.shrink();
          }),

          // Connection status indicator - إضافة جديدة
          Obx(() {
            final webSocketService = Get.find<WebSocketService>();
            if (!webSocketService.isConnected.value) {
              return Container(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 12,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 4),
                          Text(
                            webSocketService.connectionStatus.value,
                            style: TextStyle(
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
            return SizedBox.shrink();
          }),

          // حقل إدخال الرسالة
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: AppColors.textSecondary),
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: _onTextChanged, // إضافة جديدة
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: AppColors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة جديدة لمعالجة تغيير النص
  void _onTextChanged(String text) {
    if (chatId == null) return;

    // إذا بدأ المستخدم بالكتابة
    if (text.isNotEmpty && !_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      chatController.startTyping(chatId!);
    }

    // إعادة ضبط المؤقت
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 2), () {
      if (_isCurrentlyTyping) {
        _isCurrentlyTyping = false;
        chatController.stopTyping(chatId!);
      }
    });

    // إذا مسح المستخدم النص تماماً
    if (text.isEmpty && _isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      chatController.stopTyping(chatId!);
      _typingTimer?.cancel();
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // حماية من الإرسال المكرر
    if (_isSending) {
      print('ChatView: Message sending in progress, ignoring tap');
      return;
    }

    // حماية إضافية من الإرسال السريع للمحتوى نفسه
    final now = DateTime.now();
    if (_lastMessageContent == content &&
        _lastSendTime != null &&
        now.difference(_lastSendTime!).inMilliseconds < 1000) {
      print('ChatView: Same message sent within 1 second, ignoring');
      return;
    }

    _isSending = true;
    _lastMessageContent = content;
    _lastSendTime = now;

    try {
      // مسح النص فوراً لمنع المستخدم من الضغط مرة أخرى
      _messageController.clear();

      // إذا كانت محادثة جديدة، إنشاء المحادثة أولاً
      if (isNewChat && (chatId == null || chatId!.isEmpty)) {
        await _createChatAndSendMessage(content);
        return;
      }

      // إذا كانت المحادثة موجودة، إرسال الرسالة مباشرة
      final success = await chatController.sendMessage(
        chatId: chatId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );

      if (success) {
        _scrollToBottom();
      } else {
        // في حالة فشل الإرسال، أعد النص إلى الحقل
        _messageController.text = content;
      }

    } catch (e) {
      print('ChatView: Error in _sendMessage: $e');
      // في حالة حدوث خطأ، أعد النص إلى الحقل
      _messageController.text = content;
    } finally {
      // تحرير القفل بعد تأخير قصير
      Future.delayed(Duration(milliseconds: 800), () {
        _isSending = false;
      });
    }
  }

  Future<void> _createChatAndSendMessage(String content) async {
    try {
      print('Creating new chat and sending first message...');

      // إنشاء المحادثة
      final newChat = await chatController.createChat(currentUserId, receiverId);

      if (newChat != null) {
        chatId = newChat.id;
        isNewChat = false;

        print('Chat created successfully: $chatId');

        // إرسال الرسالة
        final success = await chatController.sendMessage(
          chatId: chatId!,
          senderId: currentUserId,
          receiverId: receiverId,
          content: content,
        );

        if (success) {
          print('First message sent successfully');
          _scrollToBottom();
        } else {
          // في حالة فشل الإرسال، أعد النص إلى الحقل
          _messageController.text = content;
        }
      } else {
        // في حالة فشل إنشاء المحادثة، أعد النص إلى الحقل
        _messageController.text = content;
        Get.snackbar(
          'Error',
          'Failed to create chat',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      print('Error creating chat and sending message: $e');
      // في حالة حدوث خطأ، أعد النص إلى الحقل
      _messageController.text = content;
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showBlockUserDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Block User'),
        content: Text('Are you sure you want to block $receiverName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'User blocking feature coming soon');
            },
            child: Text('Block'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Report User'),
        content: Text('Report $receiverName for inappropriate behavior?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'User reporting feature coming soon');
            },
            child: Text('Report'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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

    // إيقاف مؤشر الكتابة عند الخروج من الشاشة
    if (_isCurrentlyTyping && chatId != null) {
      chatController.stopTyping(chatId!);
    }

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}