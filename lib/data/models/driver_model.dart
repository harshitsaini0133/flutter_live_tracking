class DriverModel {
  final String id;
  final String name;
  final String vehicle;
  final String phone;

  DriverModel({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.phone,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'] as String,
        name: json['name'] as String,
        vehicle: json['vehicle'] as String,
        phone: json['phone'] as String,
      );
}
