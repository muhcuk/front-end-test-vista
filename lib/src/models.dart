class Service {
  const Service({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
  });

  final String id;
  final String companyId;
  final String name;
  final String description;
  final double price;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as String,
    companyId: json['companyId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: _parsePrice(json['price']),
  );

  static double _parsePrice(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const FormatException('Service price must be a number');
  }
}

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.services,
  });

  final String id;
  final String name;
  final String registrationNumber;
  final List<Service> services;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json['id'] as String,
    name: json['name'] as String,
    registrationNumber: json['registrationNumber'] as String,
    services: (json['services'] as List<dynamic>? ?? [])
        .map((item) => Service.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
