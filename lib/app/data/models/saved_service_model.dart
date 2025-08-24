class SavedServiceModel {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime savedAt;

  SavedServiceModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.savedAt,
  });

  factory SavedServiceModel.fromJson(Map<String, dynamic> json) {
    return SavedServiceModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      savedAt: json['saved_at'] != null
          ? DateTime.parse(json['saved_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'service_id': serviceId,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  SavedServiceModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    DateTime? savedAt,
  }) {
    return SavedServiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}