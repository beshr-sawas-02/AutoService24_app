class UserModel {
  final String id;
  final String email;
  final String? password;
  final String username;
  final String userType;
  final String? phone;
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

  /// Base URL للسيرفر، عدّل حسب بيئة التطوير أو الإنتاج
  static const String baseUrl = "http://192.168.201.167:8000"; // مثال: للمحاكي Android

  /// رابط كامل للصورة لو موجودة، أو null لو ما فيه
  String? get fullProfileImage {
    if (profileImage != null && profileImage!.isNotEmpty) {
      // لو الرابط كامل، رجّعه كما هو
      if (profileImage!.startsWith('http')) return profileImage;
      return '$baseUrl$profileImage';
    }
    return null;
  }

  /// Check إذا المستخدم مالك ورشة
  bool get isOwner => userType == 'owner';

  /// Check إذا المستخدم عادي
  bool get isUser => userType == 'user';

  /// Check إذا المستخدم محلي (local)
  bool get isLocalUser => provider == 'local';

  /// Check إذا المستخدم عن طريق حساب اجتماعي
  bool get isSocialUser => provider != 'local';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? phoneValue;
    if (json['phone'] != null && json['phone'].toString().isNotEmpty) {
      phoneValue = json['phone'].toString();
    }

    return UserModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      username: json['username']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? 'user',
      phone: phoneValue,
      profileImage: json['profile_image']?.toString(),
      provider: json['provider']?.toString() ?? 'local',
      providerId: json['providerId']?.toString(),
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
}
