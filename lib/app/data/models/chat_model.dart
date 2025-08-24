class ChatModel {
  final String id;
  final int user1Id;
  final int user2Id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] ?? '',
      user1Id: json['user1Id'] ?? 0,
      user2Id: json['user2Id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    int? user1Id,
    int? user2Id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}