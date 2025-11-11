class ServiceModel {
  final String id;
  final String barberId;
  final String name;
  final double price;
  final String? description;
  final String? includes;

  const ServiceModel({
    required this.id,
    required this.barberId,
    required this.name,
    required this.price,
    this.description,
    this.includes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      barberId: json['barberId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      includes: json['includes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barberId': barberId,
      'name': name,
      'price': price,
      if (description != null) 'description': description,
      if (includes != null) 'includes': includes,
    };
  }
}
