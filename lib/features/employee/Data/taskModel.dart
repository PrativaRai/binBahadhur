class Schedule {
  final String id;
  final String phone;
  final String area;
  final String subArea;
  final String scheduleType;
  final String status;

  Schedule({
    required this.id,
    required this.phone,
    required this.area,
    required this.subArea,
    required this.scheduleType,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'],
      phone: json['phone'],
      area: json['area'],
      subArea: json['subArea'],
      scheduleType: json['scheduleType'],
      status: json['status'],
    );
  }
}
