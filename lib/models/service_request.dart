class ServiceRequest {
  final String id;
  final String category;
  final String district;
  final String description;
  final String status;
  final bool isHourly;
  final String date;
  final double? offeredPrice;

  ServiceRequest({
    required this.id,
    required this.category,
    required this.district,
    required this.description,
    required this.status,
    required this.isHourly,
    required this.date,
    this.offeredPrice,
  });
}
