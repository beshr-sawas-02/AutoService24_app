class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String chatId;
  final String? content;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ///here
  static const String baseUrl = "http://192.168.201.167:8000";

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


  String? get fullImageUrl {
    if (image != null && image!.isNotEmpty) {
      if (image!.startsWith('http')) return image;
      return '$baseUrl$image';
    }
    return null;
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      content: json['content']?.toString(),
      image: json['image']?.toString(),
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
    String? senderId,
    String? receiverId,
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