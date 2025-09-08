import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/app_colors.dart';
import '../../utils/constants.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

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

  // Enhanced duplicate prevention variables
  bool _isSending = false;
  String? _lastMessageContent;
  DateTime? _lastSendTime;
  XFile? _lastSentImage;

  // Variables for image upload
  bool _isUploadingImage = false;
  XFile? _selectedImage;

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

    if (receiverId.isNotEmpty) {
      chatController.getUserById(receiverId);
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
            Obx(() {
              final receiverUser = chatController.usersCache[receiverId];

              if (receiverUser?.fullProfileImage != null && receiverUser!.fullProfileImage!.isNotEmpty) {
                return CircleAvatar(
                  backgroundColor: AppColors.whiteWithOpacity(0.2),
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      receiverUser.fullProfileImage!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return CircleAvatar(
                  backgroundColor: AppColors.whiteWithOpacity(0.2),
                  radius: 20,
                  child: Text(
                    receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
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
                child: GestureDetector(
                  onTap: () => _showFullImage(message.image!),
                  child: _buildImageWidget(message.image!),
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

  Widget _buildImageWidget(String imageData) {
    if (imageData.startsWith('data:image/')) {
      try {
        final base64Data = imageData.split(',')[1];
        final bytes = base64Decode(base64Data);

        return Image.memory(
          bytes,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
        );
      } catch (e) {
        return _buildImageErrorWidget();
      }
    }
    else if (imageData.startsWith('http') || imageData.startsWith('/uploads/')) {
      String imageUrl = imageData;
      if (imageData.startsWith('/uploads/')) {
        imageUrl = '${AppConstants.baseUrl}$imageData';      }

      return Image.network(
        imageUrl,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }
    else {
      return _buildImageErrorWidget();
    }
  }

  Widget _buildImageErrorWidget() {
    return Container(
      width: 200,
      height: 150,
      color: AppColors.grey300,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: AppColors.textSecondary),
            Text('Failed to load image', style: TextStyle(fontSize: 12)),
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
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedImage!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Ready to send',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

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

          if (_isUploadingImage)
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Uploading image...',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file,
                    color: AppColors.textSecondary),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _selectedImage != null
                        ? 'Add a caption...'
                        : 'Type a message...',
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    _pickImageFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    _pickImageFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'File',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Feature Coming Soon',
                      'File attachment will be available soon',
                      backgroundColor: AppColors.primaryWithOpacity(0.1),
                      colorText: AppColors.primary,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Camera Error',
        'Unable to access camera. Please enable camera permission in device settings.',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Gallery Error',
        'Unable to access gallery. Please enable storage permission in device settings.',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _showFullImage(String imageData) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: _buildFullImageWidget(imageData),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullImageWidget(String imageData) {
    if (imageData.startsWith('data:image/')) {
      try {
        final base64Data = imageData.split(',')[1];
        final bytes = base64Decode(base64Data);

        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 50),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white, size: 50),
              SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }
    } else if (imageData.startsWith('http') || imageData.startsWith('/uploads/')) {
      String imageUrl = imageData;
      if (imageData.startsWith('/uploads/')) {
        imageUrl = 'http://192.168.201.167:8000$imageData';
      }

      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 50),
                SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white, size: 50),
            SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
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

  // Enhanced _sendMessage method with better duplicate prevention
  void _sendMessage() async {
    final content = _messageController.text.trim();
    final hasImage = _selectedImage != null;

    // Basic validation
    if (content.isEmpty && !hasImage) return;

    // Enhanced duplicate prevention
    if (_isSending || _isUploadingImage) {
      return;
    }

    final now = DateTime.now();

    // Check for duplicate text message
    if (!hasImage &&
        _lastMessageContent == content &&
        _lastSendTime != null &&
        now.difference(_lastSendTime!).inMilliseconds < 3000) {
      return;
    }

    // Check for duplicate image message
    if (hasImage &&
        _lastSentImage != null &&
        _selectedImage?.path == _lastSentImage?.path &&
        _lastSendTime != null &&
        now.difference(_lastSendTime!).inMilliseconds < 5000) {
      return;
    }

    // Lock sending state immediately
    _isSending = true;
    _lastMessageContent = content;
    _lastSentImage = hasImage ? _selectedImage : null;
    _lastSendTime = now;

    // Clear input immediately to prevent re-sending
    final currentSelectedImage = _selectedImage;
    _messageController.clear();
    setState(() {
      _selectedImage = null;
    });

    try {
      if (isNewChat && (chatId == null || chatId!.isEmpty)) {
        await _createChatAndSendMessage(content, currentSelectedImage);
        return;
      }

      bool success = false;

      if (hasImage && currentSelectedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });

        success = await chatController.sendMessageWithImage(
          chatId: chatId!,
          senderId: currentUserId,
          receiverId: receiverId,
          content: content.isNotEmpty ? content : null,
          imageFile: File(currentSelectedImage.path),
        );

        setState(() {
          _isUploadingImage = false;
        });
      } else {
        success = await chatController.sendMessage(
          chatId: chatId!,
          senderId: currentUserId,
          receiverId: receiverId,
          content: content,
        );
      }

      if (success) {
        _scrollToBottom();
      } else {
        // Restore input only if sending failed
        _restoreInputOnFailure(content, currentSelectedImage);
      }
    } catch (e) {
      _restoreInputOnFailure(content, currentSelectedImage);
    } finally {
      // Release lock after a delay to prevent rapid duplicate sends
      Future.delayed(const Duration(milliseconds: 2000), () {
        _isSending = false;
      });
    }
  }

  // Helper method to restore input on failure
  void _restoreInputOnFailure(String content, XFile? imageFile) {
    _messageController.text = content;
    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
      });
    }

    Get.snackbar(
      'Error',
      'Failed to send message',
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      colorText: AppColors.error,
    );
  }

  Future<void> _createChatAndSendMessage(String content, XFile? imageFile) async {
    try {
      final newChat = await chatController.createChat(currentUserId, receiverId);

      if (newChat != null) {
        chatId = newChat.id;
        isNewChat = false;

        bool success = false;

        if (imageFile != null) {
          setState(() {
            _isUploadingImage = true;
          });

          success = await chatController.sendMessageWithImage(
            chatId: chatId!,
            senderId: currentUserId,
            receiverId: receiverId,
            content: content.isNotEmpty ? content : null,
            imageFile: File(imageFile.path),
          );

          setState(() {
            _isUploadingImage = false;
          });
        } else {
          success = await chatController.sendMessage(
            chatId: chatId!,
            senderId: currentUserId,
            receiverId: receiverId,
            content: content,
          );
        }

        if (success) {
          _scrollToBottom();
        } else {
          _restoreInputOnFailure(content, imageFile);
        }
      } else {
        _restoreInputOnFailure(content, imageFile);
        Get.snackbar(
          'Error',
          'Failed to create chat',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      _restoreInputOnFailure(content, imageFile);
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