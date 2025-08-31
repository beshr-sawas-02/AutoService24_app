import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class ChatListView extends StatefulWidget {
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // تحميل المحادثات فقط للمستخدمين المسجلين
    if (authController.isLoggedIn.value && !authController.isGuest) {
      chatController.loadChats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (authController.isGuest || !authController.isLoggedIn.value) {
          return _buildGuestChatContent();
        } else {
          return _buildUserChatContent();
        }
      }),
    );
  }

  Widget _buildGuestChatContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryWithOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Connect with Service Providers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Sign in to chat directly with workshops and service providers.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat features:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildChatFeatureRow(Icons.message, 'Direct messaging with providers'),
                        _buildChatFeatureRow(Icons.schedule, 'Schedule appointments easily'),
                        _buildChatFeatureRow(Icons.attach_money, 'Get instant price quotes'),
                        _buildChatFeatureRow(Icons.photo_camera, 'Share photos of your vehicle'),
                        _buildChatFeatureRow(Icons.location_on, 'Share location details'),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.login),
                          child: Text('Sign In'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          child: Text('Register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.explore, color: AppColors.textSecondary),
                    label: Text(
                      'Explore Services Instead',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.info),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserChatContent() {
    if (chatController.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (chatController.chats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: chatController.chats.length,
      itemBuilder: (context, index) {
        final chat = chatController.chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Start chatting with workshop owners and service providers',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(Icons.search),
            label: Text('Browse Services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final currentUserId = authController.currentUser.value?.id ?? '';
    final isCurrentUserUser1 = chat.user1Id.toString() == currentUserId;
    final otherUserId = isCurrentUserUser1 ? chat.user2Id : chat.user1Id;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildUserAvatar(otherUserId.toString()),
        title: _buildUserName(otherUserId.toString()),
        subtitle: _buildUserSubtitle(otherUserId.toString()),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chat.updatedAt ?? chat.createdAt),
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        onTap: () => _navigateToChat(chat, currentUserId),
      ),
    );
  }

  Widget _buildUserAvatar(String userId) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Obx(() {
        final user = chatController.usersCache[userId];

        if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              user.profileImage!,
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar(user);
              },
            ),
          );
        }

        return _buildDefaultAvatar(user);
      }),
    );
  }

  Widget _buildDefaultAvatar(UserModel? user) {
    return Icon(
      user?.isOwner == true ? Icons.build : Icons.person,
      color: AppColors.white,
      size: 24,
    );
  }

  Widget _buildUserName(String userId) {
    return Obx(() {
      final user = chatController.usersCache[userId];
      String displayName = user?.username ?? 'Loading...';

      // إذا لم يتم تحميل المستخدم بعد، حاول تحميله
      if (user == null && !chatController.isLoadingUsers.value) {
        chatController.getUserById(userId); // يمكن أن يكون Future<void>
      }

      return Text(
        displayName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      );
    });
  }

  Widget _buildUserSubtitle(String userId) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Obx(() {
        final user = chatController.usersCache[userId];
        String subtitle = 'Tap to view conversation';

        if (user != null) {
          if (user.isOwner) {
            subtitle = 'Workshop Owner • Tap to chat';
          } else {
            subtitle = 'User • Tap to chat';
          }
        }

        return Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        );
      }),
    );
  }

  void _navigateToChat(ChatModel chat, String currentUserId) async {
    final isCurrentUserUser1 = chat.user1Id.toString() == currentUserId;
    final otherUserId = isCurrentUserUser1 ? chat.user2Id : chat.user1Id;

    // جلب المستخدم إذا لم يكن موجودًا في الكاش
    final otherUser = await chatController.getUserById(otherUserId.toString());
    final otherUserName = otherUser?.username ?? 'User';

    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'chatId': chat.id,
        'receiverId': otherUserId.toString(),
        'receiverName': otherUserName,
        'currentUserId': currentUserId,
      },
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  // دالة مساعدة لتنسيق الوقت
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}