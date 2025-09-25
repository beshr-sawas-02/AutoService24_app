enum ServiceType {
  VEHICLE_INSPECTION('Vehicle inspection & emissions test'),
  CHANGE_OIL('Change oil'),
  CHANGE_TIRES('Change tires'),
  REMOVE_INSTALL_TIRES('Remove & install tires'),
  CLEANING('Cleaning'),
  DIAGNOSTIC_TEST('Test with diagnostic'),
  AU_TUV('AU & TÜV'),
  BALANCE_TIRES('Balance tires'),
  WHEEL_ALIGNMENT('Adjust wheel alignment'),
  POLISH('Polish'),
  CHANGE_BRAKE_FLUID('Change brake fluid');

  const ServiceType(this.displayName);

  final String displayName;

  static ServiceType? fromString(String value) {
    for (ServiceType type in ServiceType.values) {
      if (type.name == value || type.displayName == value) {
        return type;
      }
    }
    return null;
  }
}

class ServiceModel {
  final String id;
  final String workshopId;
  final String userId;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final ServiceType serviceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? workshopData;

  ServiceModel({
    required this.id,
    required this.workshopId,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.serviceType,
    this.createdAt,
    this.updatedAt,
    this.workshopData,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String workshopId;
    Map<String, dynamic>? workshopData;

    final workshopIdField = json['workshop_id'];
    if (workshopIdField is String) {
      workshopId = workshopIdField;
    } else if (workshopIdField is Map<String, dynamic>) {
      workshopId = workshopIdField['_id'] ?? '';
      workshopData = workshopIdField;
    } else {
      workshopId = '';
    }

    ServiceType? parsedServiceType =
        ServiceType.fromString(json['service_type'] ?? '');

    return ServiceModel(
      id: json['_id'] ?? '',
      workshopId: workshopId,
      userId: json['user_id'] ?? workshopData?['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
      images: _parseImages(json['images']),
      serviceType: parsedServiceType ?? ServiceType.CHANGE_OIL,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      workshopData: workshopData,
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];

    const String baseUrl = 'https://www.autoservicely.com';

    if (images is List) {
      return images
          .map((img) {
            String imagePath = img.toString().trim();

            if (imagePath.isEmpty) return '';

            if (imagePath.startsWith('http://') ||
                imagePath.startsWith('https://')) {
              return imagePath;
            }

            if (imagePath.startsWith('/uploads/')) {
              return '$baseUrl$imagePath';
            }

            if (imagePath.startsWith('uploads/')) {
              return '$baseUrl/$imagePath';
            }

            if (imagePath.startsWith('/')) {
              return '$baseUrl$imagePath';
            } else {
              return '$baseUrl/$imagePath';
            }
          })
          .where((path) => path.isNotEmpty)
          .toList();
    }

    return [];
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'workshop_id': workshopId,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'service_type': serviceType.name,
    };

    if (images.isNotEmpty) data['images'] = images;
    return data;
  }

  ServiceModel copyWith({
    String? id,
    String? workshopId,
    String? userId,
    String? title,
    String? description,
    double? price,
    List<String>? images,
    ServiceType? serviceType,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? workshopData,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      serviceType: serviceType ?? this.serviceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workshopData: workshopData ?? this.workshopData,
    );
  }

  String get formattedPrice => '\€${price.toStringAsFixed(2)}';

  String get serviceTypeName => serviceType.displayName;

  // Helper methods to get workshop info if available
  String get workshopName {
    return workshopData?['name'] ?? 'Unknown Workshop';
  }

  String get workshopDescription {
    return workshopData?['description'] ?? '';
  }

  String get workshopWorkingHours {
    return workshopData?['working_hours'] ?? '';
  }

  // Get workshop location coordinates
  double? get workshopLocationX {
    final locationX = workshopData?['location_x'];
    if (locationX is String) {
      return double.tryParse(locationX);
    }
    return locationX?.toDouble();
  }

  double? get workshopLocationY {
    final locationY = workshopData?['location_y'];
    if (locationY is String) {
      return double.tryParse(locationY);
    }
    return locationY?.toDouble();
  }
}
