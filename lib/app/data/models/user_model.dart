class UserModel {
  final String id;
  final String email;
  final String? password;     // اختيارية الآن
  final String username;
  final String userType;
  final String? phone;        // اختيارية
  final String? profileImage;
  final String provider;
  final String? providerId;

  UserModel({
    required this.id,
    required this.email,
    this.password,
    required this.username,
    required this.userType,
    this.phone,
    this.profileImage,
    this.provider = 'local',
    this.providerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'], // قد تكون null للـ social login
      username: json['username'] ?? '',
      userType: json['user_type'] ?? 'user',
      phone: json['phone'],
      profileImage: json['profile_image'],
      provider: json['provider'] ?? 'local',
      providerId: json['providerId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'username': username,
      'user_type': userType,
      'provider': provider,
    };

    if (password != null) data['password'] = password;
    if (phone != null) data['phone'] = phone;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (providerId != null) data['providerId'] = providerId;

    return data;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? username,
    String? userType,
    String? phone,
    String? profileImage,
    String? provider,
    String? providerId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
    );
  }

  bool get isOwner => userType == 'owner';
  bool get isUser => userType == 'user';
  bool get isLocalUser => provider == 'local';
  bool get isSocialUser => provider != 'local';
}