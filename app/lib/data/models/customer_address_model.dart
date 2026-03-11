class CustomerAddress {
  final int? id;
  final int customerId;
  final String addressLine;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? label;

  CustomerAddress({
    this.id,
    required this.customerId,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.label,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'],
      customerId: json['customer_id'] is String ? int.parse(json['customer_id']) : json['customer_id'],
      addressLine: json['address_line'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'address_line': addressLine,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
      'label': label,
    };
  }
}
