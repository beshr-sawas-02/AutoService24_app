enum ServiceType {
  VEHICLE_INSPECTION('Vehicle inspection & emissions test'),
  CHANGE_OIL('Change oil'),
  CHANGE_TIRES('Change tires'),
  REMOVE_INSTALL_TIRES('Remove & install tires'),
  CLEANING('Cleaning'),
  DIAGNOSTIC_TEST('Test with diagnostic'),
  PRE_TUV_CHECK('Pre-TÜV check'),
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
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final ServiceType serviceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.workshopId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.serviceType,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      workshopId: json['workshop_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      serviceType: ServiceType.fromString(json['service_type']) ?? ServiceType.CHANGE_OIL,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'workshop_id': workshopId,
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
    String? title,
    String? description,
    double? price,
    List<String>? images,
    ServiceType? serviceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      serviceType: serviceType ?? this.serviceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get serviceTypeName => serviceType.displayName;
}