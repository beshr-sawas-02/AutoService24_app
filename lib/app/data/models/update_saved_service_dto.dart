class UpdateSavedServiceDto {
  final String? userId;
  final String? serviceId;
  final DateTime? savedAt;

  UpdateSavedServiceDto({
    this.userId,
    this.serviceId,
    this.savedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (userId != null) data['user_id'] = userId;
    if (serviceId != null) data['service_id'] = serviceId;
    if (savedAt != null) data['saved_at'] = savedAt!.toIso8601String();
    return data;
  }
}