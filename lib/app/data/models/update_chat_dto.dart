class UpdateChatDto {
  final String? name;
  final bool? isActive;

  UpdateChatDto({
    this.name,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}