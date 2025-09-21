import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

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
          'messages'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (authController.isGuest || !authController.isLoggedIn.value) {
          return _buildGuestChatContent();
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              await chatController.loadChats();
            },
            color: AppColors.primary,
            child: chatController.chats.isEmpty && chatController.isLoading.value
                ? _buildShimmerList()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatController.chats.isEmpty
                  ? 1
                  : chatController.chats.length,
              itemBuilder: (context, index) {
                if (chatController.chats.isEmpty) {
                  return _buildEmptyState();
                } else {
                  final chat = chatController.chats[index];
                  return _buildChatItem(chat);
                }
              },
            ),
          );
        }
      }),
    );
  }
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(radius: 25, backgroundColor: Colors.white),
              title: Container(
                height: 16,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              subtitle: Container(
                height: 14,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildGuestChatContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'connect_service_providers'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'sign_in_to_chat'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'chat_features'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildChatFeatureRow(Icons.message, 'direct_messaging'.tr),
                        _buildChatFeatureRow(Icons.schedule, 'schedule_appointments'.tr),
                        _buildChatFeatureRow(Icons.attach_money, 'instant_quotes'.tr),
                        _buildChatFeatureRow(Icons.photo_camera, 'share_photos'.tr),
                        _buildChatFeatureRow(Icons.location_on, 'share_location'.tr),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.login),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('sign_in'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('register'.tr),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.explore, color: AppColors.textSecondary),
                    label: Text(
                      'explore_services_instead'.tr,
                      style: const TextStyle(color: AppColors.textSecondary),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (chatController.chats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_conversations_yet'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'start_chatting'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.search),
            label: Text('browse_services'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildUserAvatar(otherUserId.toString()),
        title: _buildUserName(otherUserId.toString()),
        subtitle: _buildUserSubtitle(otherUserId.toString()),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chat.updatedAt ?? chat.createdAt),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
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
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Obx(() {
        final user = chatController.usersCache[userId];

        if (user?.fullProfileImage != null && user!.fullProfileImage!.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              user.fullProfileImage!,
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
      String displayName = user?.username ?? 'loading_user'.tr;

      if (user == null && !chatController.isLoadingUsers.value) {
        chatController.getUserById(userId);
      }

      return Text(
        displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      );
    });
  }

  Widget _buildUserSubtitle(String userId) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(() {
        final user = chatController.usersCache[userId];
        String subtitle = 'tap_to_view_conversation'.tr;

        if (user != null) {
          if (user.isOwner) {
            subtitle = '${'workshop_owner'.tr} • ${'tap_to_chat'.tr}';
          } else {
            subtitle = '${'user'.tr} • ${'tap_to_chat'.tr}';
          }
        }

        return Text(
          subtitle,
          style: const TextStyle(
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

    final otherUser = await chatController.getUserById(otherUserId.toString());
    final otherUserName = otherUser?.username ?? 'user'.tr;

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
      return 'now'.tr;
    }
  }
}