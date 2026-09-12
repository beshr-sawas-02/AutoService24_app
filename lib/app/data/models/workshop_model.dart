class WorkshopModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final LocationModel location;
  final String workingHours;
  final String? profileImage;
  double? distanceFromUser;

  WorkshopModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.location,
    required this.workingHours,
    this.profileImage,
    this.distanceFromUser,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      workingHours: json['working_hours'] ?? '',
      profileImage: json['profile_image'],
      distanceFromUser: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'name': name,
      'description': description,
      'location': location.toJson(),
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
    LocationModel? location,
    String? workingHours,
    String? profileImage,
    double? distanceFromUser,
  }) {
    return WorkshopModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      workingHours: workingHours ?? this.workingHours,
      profileImage: profileImage ?? this.profileImage,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
    );
  }

  // Helper getters for easy access to coordinates
  double get latitude => location.coordinates.isNotEmpty ? location.coordinates[1] : 0.0;
  double get longitude => location.coordinates.isNotEmpty ? location.coordinates[0] : 0.0;
}

// Separate class for handling GeoJSON location structure
class LocationModel {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  LocationModel({
    required this.type,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  // Helper constructor for creating location from lat/lng
  factory LocationModel.fromLatLng(double latitude, double longitude) {
    return LocationModel(
      type: 'Point',
      coordinates: [longitude, latitude], // Note: GeoJSON uses [lng, lat] order
    );
  }

  LocationModel copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return LocationModel(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}