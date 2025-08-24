class UpdateMessageDto {
  final String? content;
  final String? image;
  final bool? isRead;

  UpdateMessageDto({
    this.content,
    this.image,
    this.isRead,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (content != null) data['content'] = content;
    if (image != null) data['image'] = image;
    if (isRead != null) data['isRead'] = isRead;
    return data;
  }
}