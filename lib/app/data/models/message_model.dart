class MessageModel {
  final String id;
  final int senderId;
  final int receiverId;
  final String chatId;
  final String? content;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    this.content,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? 0,
      receiverId: json['receiverId'] ?? 0,
      chatId: json['chatId'] ?? '',
      content: json['content'],
      image: json['image'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatId': chatId,
      'content': content,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    int? senderId,
    int? receiverId,
    String? chatId,
    String? content,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasContent => content != null && content!.isNotEmpty;
  bool get hasImage => image != null && image!.isNotEmpty;
}