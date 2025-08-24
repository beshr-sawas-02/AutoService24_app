class UserModel {
  final String id;
  final String email;
  final String username;
  final String userType;
  final String phone;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.userType,
    required this.phone,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("UserModel.fromJson() called with: $json");

    try {
      // Try both 'id' and '_id' fields (Backend sends 'id', we expect '_id')
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

      final userModel = UserModel(
        id: id,
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        userType: json['user_type']?.toString() ?? 'user',
        phone: json['phone']?.toString() ?? '', // Backend might not send phone, so default to empty
        profileImage: json['profile_image']?.toString(),
      );

      print("UserModel created successfully:");
      print("  - ID: ${userModel.id}");
      print("  - Username: ${userModel.username}");
      print("  - Email: ${userModel.email}");
      print("  - UserType: ${userModel.userType}");
      print("  - Phone: ${userModel.phone}");

      return userModel;
    } catch (e) {
      print("UserModel.fromJson() error: $e");
      print("Available keys in json: ${json.keys.toList()}");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'user_type': userType,
      'phone': phone,
      'profile_image': profileImage,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? userType,
    String? phone,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  bool get isOwner => userType == 'owner';
  bool get isUser => userType == 'user';

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, userType: $userType, phone: $phone)';
  }
}