import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

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
    chatController.loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.orange,
      ),
      body: Obx(() {
        if (chatController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (chatController.chats.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: chatController.chats.length,
          itemBuilder: (context, index) {
            final chat = chatController.chats[index];
            return _buildChatItem(chat);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start chatting with workshop owners',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(chat) {
    final currentUserId = authController.currentUser.value?.id ?? '';
    final isCurrentUserUser1 = chat.user1Id.toString() == currentUserId;
    final otherUserId = isCurrentUserUser1 ? chat.user2Id : chat.user1Id;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          'User $otherUserId', // In real app, fetch username
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tap to view conversation',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '12:30 PM', // Placeholder time
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed(
            AppRoutes.chat,
            arguments: {
              'chatId': chat.id,
              'otherUserId': otherUserId.toString(),
            },
          );
        },
      ),
    );
  }
}