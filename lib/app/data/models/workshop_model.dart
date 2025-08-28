class WorkshopModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String locationX;
  final String locationY;
  final String workingHours;
  final String? profileImage;

  WorkshopModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.locationX,
    required this.locationY,
    required this.workingHours,
    this.profileImage,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      locationX: json['location_x'] ?? '',
      locationY: json['location_y'] ?? '',
      workingHours: json['working_hours'] ?? '',
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'name': name,
      'description': description,
      'location_x': locationX,
      'location_y': locationY,
      'working_hours': workingHours,
    };

    if (profileImage != null) data['profile_image'] = profileImage;
    return data;
  }

  WorkshopModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? locationX,
    String? locationY,
    String? workingHours,
    String? profileImage,
  }) {
    return WorkshopModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      locationX: locationX ?? this.locationX,
      locationY: locationY ?? this.locationY,
      workingHours: workingHours ?? this.workingHours,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  double get latitude => double.tryParse(locationX) ?? 0.0;
  double get longitude => double.tryParse(locationY) ?? 0.0;
}