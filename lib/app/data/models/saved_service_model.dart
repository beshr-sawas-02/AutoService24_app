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
      userId: _extractUserId(json['user_id']),
      serviceId: _extractServiceId(json['service_id']),
      savedAt: _parseSavedAt(json['saved_at']),
    );
  }


  static String _extractUserId(dynamic data) {
    if (data == null) return '';


    if (data is String) return data;


    if (data is Map<String, dynamic>) {
      return data['_id']?.toString() ?? '';
    }

    return data.toString();
  }


  static String _extractServiceId(dynamic data) {
    if (data == null) return '';


    if (data is String) return data;


    if (data is Map<String, dynamic>) {
      return data['_id']?.toString() ?? '';
    }

    return data.toString();
  }


  static DateTime _parseSavedAt(dynamic savedAtData) {
    if (savedAtData == null) {
      return DateTime.now();
    }


    if (savedAtData is String) {
      try {
        return DateTime.parse(savedAtData);
      } catch (e) {
        return DateTime.now();
      }
    }


    if (savedAtData is Map<String, dynamic>) {

      final possibleKeys = ['\$date', 'date', 'value', 'timestamp'];

      for (String key in possibleKeys) {
        if (savedAtData.containsKey(key)) {
          try {
            final dateValue = savedAtData[key];
            if (dateValue is String) {
              return DateTime.parse(dateValue);
            } else if (dateValue is int) {
              return DateTime.fromMillisecondsSinceEpoch(dateValue);
            }
          } catch (e) {
          }
        }
      }
      return DateTime.now();
    }

    // إذا كان int (timestamp)
    if (savedAtData is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(savedAtData);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
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