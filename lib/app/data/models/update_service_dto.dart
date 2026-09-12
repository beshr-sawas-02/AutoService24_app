import 'service_model.dart';

class UpdateServiceDto {
  final String? title;
  final String? description;
  final double? price;
  final List<String>? images;
  final ServiceType? serviceType;

  UpdateServiceDto({
    this.title,
    this.description,
    this.price,
    this.images,
    this.serviceType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (images != null) data['images'] = images;
    if (serviceType != null) data['service_type'] = serviceType!.name;
    return data;
  }
}